import 'dart:async';

import 'package:flutter/material.dart';

import '../models/ollama_server.dart';
import '../services/ollama_pool_service.dart';
import '../state/auth_store.dart';
import '../theme/app_text_color.dart';
import '../widgets/glass_panel.dart';

/// Пул серверов Ollama для распределения нагрузки генерации ответов.
/// Документы (их эмбеддинги) синхронизировать никуда не нужно - они
/// живут в общей базе данных, доступны с любого сервера. Единственное,
/// что нужно новому серверу - сами модели, установка которых идёт в
/// фоне на бэкенде сразу после добавления - здесь просто опрашиваем
/// прогресс, пока он не завершится.
class AdminOllamaPoolPanel extends StatefulWidget {
  final AuthStore authStore;
  const AdminOllamaPoolPanel({super.key, required this.authStore});

  @override
  State<AdminOllamaPoolPanel> createState() => _AdminOllamaPoolPanelState();
}

class _AdminOllamaPoolPanelState extends State<AdminOllamaPoolPanel> {
  final _service = OllamaPoolService();
  List<OllamaServer> _servers = [];
  bool _isLoading = true;
  String? _error;
  // отдельный таймер опроса на каждый сервер, который сейчас готовится -
  // останавливается сам, как только сервер перестал быть "в процессе"
  final Map<int, Timer> _pollTimers = {};

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    for (final timer in _pollTimers.values) {
      timer.cancel();
    }
    _service.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    final token = widget.authStore.token;
    if (token == null) return;
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final servers = await _service.list(baseUrl: widget.authStore.baseUrl, token: token);
      if (!mounted) return;
      setState(() => _servers = servers);
      for (final server in servers) {
        if (server.isBusyPreparing) _startPolling(server.id);
      }
    } on OllamaPoolException catch (e) {
      if (mounted) setState(() => _error = e.message);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _startPolling(int serverId) {
    if (_pollTimers.containsKey(serverId)) return; // уже опрашивается
    _pollTimers[serverId] = Timer.periodic(const Duration(seconds: 2), (timer) async {
      final token = widget.authStore.token;
      if (token == null) {
        timer.cancel();
        _pollTimers.remove(serverId);
        return;
      }
      try {
        final updated = await _service.getOne(baseUrl: widget.authStore.baseUrl, token: token, id: serverId);
        if (!mounted) {
          timer.cancel();
          return;
        }
        setState(() {
          final index = _servers.indexWhere((s) => s.id == serverId);
          if (index != -1) _servers[index] = updated;
        });
        if (!updated.isBusyPreparing) {
          timer.cancel();
          _pollTimers.remove(serverId);
        }
      } catch (_) {
        // сеть моргнула - пробуем ещё раз на следующем тике, не глушим
        // опрос из-за одной неудачной попытки
      }
    });
  }

  Future<void> _addServer() async {
    final nameController = TextEditingController();
    final urlController = TextEditingController();
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A2036),
        title: const Text('Добавить сервер Ollama', style: TextStyle(color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(labelText: 'Название', hintText: 'Например: Второй сервер'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: urlController,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(labelText: 'Адрес', hintText: 'http://192.168.1.10:11434'),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('Отмена')),
          TextButton(onPressed: () => Navigator.of(context).pop(true), child: const Text('Добавить')),
        ],
      ),
    );
    if (result != true) return;

    final name = nameController.text.trim();
    final url = urlController.text.trim();
    if (name.isEmpty || url.isEmpty) return;

    final token = widget.authStore.token;
    if (token == null) return;
    try {
      final server = await _service.add(baseUrl: widget.authStore.baseUrl, token: token, name: name, url: url);
      if (!mounted) return;
      setState(() => _servers = [..._servers, server]);
      _startPolling(server.id);
    } on OllamaPoolException catch (e) {
      if (mounted) setState(() => _error = e.message);
    }
  }

  Future<void> _toggleEnabled(OllamaServer server) async {
    final token = widget.authStore.token;
    if (token == null) return;
    try {
      final updated = await _service.setEnabled(
        baseUrl: widget.authStore.baseUrl,
        token: token,
        id: server.id,
        enabled: !server.enabled,
      );
      if (!mounted) return;
      setState(() {
        final index = _servers.indexWhere((s) => s.id == server.id);
        if (index != -1) _servers[index] = updated;
      });
    } on OllamaPoolException catch (e) {
      if (mounted) setState(() => _error = e.message);
    }
  }

  Future<void> _recheck(OllamaServer server) async {
    final token = widget.authStore.token;
    if (token == null) return;
    try {
      final updated = await _service.recheck(baseUrl: widget.authStore.baseUrl, token: token, id: server.id);
      if (!mounted) return;
      setState(() {
        final index = _servers.indexWhere((s) => s.id == server.id);
        if (index != -1) _servers[index] = updated;
      });
      _startPolling(server.id);
    } on OllamaPoolException catch (e) {
      if (mounted) setState(() => _error = e.message);
    }
  }

  Future<void> _remove(OllamaServer server) async {
    final confirmed = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            backgroundColor: const Color(0xFF1A2036),
            title: const Text('Удалить сервер?', style: TextStyle(color: Colors.white)),
            content: Text(
              '«${server.name}» больше не будет получать запросы.',
              style: TextStyle(color: Colors.white.withValues(alpha: 0.75)),
            ),
            actions: [
              TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('Отмена')),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text('Удалить', style: TextStyle(color: Color(0xFFFF6B6B))),
              ),
            ],
          ),
        ) ??
        false;
    if (!confirmed) return;

    final token = widget.authStore.token;
    if (token == null) return;
    try {
      await _service.remove(baseUrl: widget.authStore.baseUrl, token: token, id: server.id);
      _pollTimers[server.id]?.cancel();
      _pollTimers.remove(server.id);
      if (!mounted) return;
      setState(() => _servers = _servers.where((s) => s.id != server.id).toList());
    } on OllamaPoolException catch (e) {
      if (mounted) setState(() => _error = e.message);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading && _servers.isEmpty) {
      return const Center(child: CircularProgressIndicator(color: Color(0xFF6C5CE7)));
    }

    return RefreshIndicator(
      onRefresh: _load,
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Row(
            children: [
              Text('Серверы Ollama', style: TextStyle(color: context.onSurface, fontSize: 20, fontWeight: FontWeight.w700)),
              const Spacer(),
              IconButton(icon: Icon(Icons.refresh_rounded, color: context.onSurfaceFaded(0.5)), onPressed: _load),
              FilledButton.icon(
                style: FilledButton.styleFrom(backgroundColor: const Color(0xFF6C5CE7)),
                onPressed: _addServer,
                icon: const Icon(Icons.add_rounded, size: 18),
                label: const Text('Добавить сервер'),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'Единственный сервер из .env всегда используется, если пул пуст - '
            'документы синхронизировать не нужно, они уже в общей базе. '
            'Новому серверу нужны только сами модели - устанавливаются автоматически.',
            style: TextStyle(color: context.onSurfaceFaded(0.4), fontSize: 12, height: 1.4),
          ),
          if (_error != null) ...[
            const SizedBox(height: 8),
            Text(_error!, style: const TextStyle(color: Color(0xFFFFB4B4), fontSize: 13)),
          ],
          const SizedBox(height: 16),
          if (_servers.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 40),
              child: Center(
                child: Text('Дополнительных серверов пока нет.', style: TextStyle(color: context.onSurfaceFaded(0.4))),
              ),
            )
          else
            ..._servers.map(_buildServerCard),
        ],
      ),
    );
  }

  Widget _buildServerCard(OllamaServer server) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: GlassPanel(
        opacity: 0.06,
        borderRadius: BorderRadius.circular(16),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                _buildStatusDot(server),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(server.name, style: TextStyle(color: context.onSurface, fontSize: 14.5, fontWeight: FontWeight.w600)),
                      Text(server.baseUrl, style: TextStyle(color: context.onSurfaceFaded(0.4), fontSize: 12)),
                    ],
                  ),
                ),
                Switch(
                  value: server.enabled,
                  activeThumbColor: const Color(0xFF6C5CE7),
                  onChanged: (_) => _toggleEnabled(server),
                ),
              ],
            ),
            const SizedBox(height: 10),
            if (server.isBusyPreparing) ...[
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: server.pullProgress > 0 ? server.pullProgress / 100 : null,
                  minHeight: 6,
                  backgroundColor: context.onSurfaceFaded(0.08),
                  color: const Color(0xFF6C5CE7),
                ),
              ),
              const SizedBox(height: 6),
            ],
            Text(
              server.statusDetail ?? _statusLabel(server.status),
              style: TextStyle(color: context.onSurfaceFaded(0.55), fontSize: 12.5),
            ),
            if (server.isReady) ...[
              const SizedBox(height: 4),
              Text(
                'Активных запросов сейчас: ${server.activeRequests}',
                style: TextStyle(color: context.onSurfaceFaded(0.4), fontSize: 11.5),
              ),
            ],
            const SizedBox(height: 10),
            Row(
              children: [
                TextButton.icon(
                  onPressed: () => _recheck(server),
                  icon: Icon(Icons.refresh_rounded, size: 16, color: context.onSurfaceFaded(0.6)),
                  label: Text('Перепроверить', style: TextStyle(color: context.onSurfaceFaded(0.6), fontSize: 12.5)),
                ),
                const Spacer(),
                TextButton.icon(
                  onPressed: () => _remove(server),
                  icon: const Icon(Icons.delete_outline_rounded, size: 16, color: Color(0xFFFF6B6B)),
                  label: const Text('Удалить', style: TextStyle(color: Color(0xFFFF6B6B), fontSize: 12.5)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusDot(OllamaServer server) {
    final color = server.isReady
        ? const Color(0xFF00E6A0)
        : server.hasProblem
            ? const Color(0xFFFF6B6B)
            : const Color(0xFFFFD166);
    return Container(width: 10, height: 10, decoration: BoxDecoration(shape: BoxShape.circle, color: color));
  }

  String _statusLabel(String status) {
    switch (status) {
      case 'pending':
        return 'Ожидает проверки...';
      case 'pulling_models':
        return 'Устанавливаю модели...';
      case 'ready':
        return 'Готов к работе.';
      case 'unreachable':
        return 'Сервер недоступен.';
      case 'error':
        return 'Ошибка установки моделей.';
      default:
        return status;
    }
  }
}
