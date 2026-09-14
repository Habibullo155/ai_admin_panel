import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';

import '../models/system_status.dart';
import '../services/admin_system_service.dart';
import '../state/auth_store.dart';
import '../theme/app_text_color.dart';
import '../widgets/app_background.dart';
import '../widgets/glass_panel.dart';

class AdminSystemScreen extends StatefulWidget {
  final AuthStore authStore;
  final VoidCallback? onBack;
  const AdminSystemScreen({super.key, required this.authStore, this.onBack});

  @override
  State<AdminSystemScreen> createState() => _AdminSystemScreenState();
}

class _AdminSystemScreenState extends State<AdminSystemScreen> {
  final _service = AdminSystemService();
  SystemStatus? _status;
  List<BackupInfo> _backups = [];
  bool _isLoading = true;
  String? _error;
  bool _isCreatingBackup = false;
  // имя бэкапа, над которым СЕЙЧАС идёт скачивание/удаление/восстановление -
  // блокирует повторное нажатие именно на эту строку, не на весь экран
  String? _actioningFilename;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
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
      final status = await _service.getStatus(baseUrl: widget.authStore.baseUrl, token: token);
      final backups = await _service.listBackups(baseUrl: widget.authStore.baseUrl, token: token);
      if (!mounted) return;
      setState(() {
        _status = status;
        _backups = backups;
      });
    } on AdminSystemException catch (e) {
      if (!mounted) return;
      setState(() => _error = e.message);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showSnack(String text, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(text), backgroundColor: isError ? const Color(0xFFB33A3A) : null),
    );
  }

  Future<void> _createBackup() async {
    final token = widget.authStore.token;
    if (token == null) return;
    setState(() => _isCreatingBackup = true);
    try {
      await _service.createBackup(baseUrl: widget.authStore.baseUrl, token: token);
      if (!mounted) return;
      _showSnack('Бэкап создан.');
      await _load();
    } on AdminSystemException catch (e) {
      if (!mounted) return;
      _showSnack(e.message, isError: true);
    } finally {
      if (mounted) setState(() => _isCreatingBackup = false);
    }
  }

  Future<void> _downloadBackup(BackupInfo backup) async {
    final token = widget.authStore.token;
    if (token == null) return;
    setState(() => _actioningFilename = backup.filename);
    try {
      final bytes = await _service.downloadBackup(baseUrl: widget.authStore.baseUrl, token: token, filename: backup.filename);
      if (!mounted) return;
      await Share.shareXFiles([XFile.fromData(bytes, name: backup.filename, mimeType: 'application/octet-stream')]);
    } on AdminSystemException catch (e) {
      if (!mounted) return;
      _showSnack(e.message, isError: true);
    } finally {
      if (mounted) setState(() => _actioningFilename = null);
    }
  }

  Future<void> _deleteBackup(BackupInfo backup) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A2036),
        title: const Text('Удалить бэкап?', style: TextStyle(color: Colors.white)),
        content: Text('${backup.filename} (${backup.formattedSize}) будет удалён без возможности восстановить сам файл.', style: const TextStyle(color: Colors.white70)),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('Отмена')),
          TextButton(onPressed: () => Navigator.of(context).pop(true), child: const Text('Удалить', style: TextStyle(color: Color(0xFFFF6B6B)))),
        ],
      ),
    );
    if (confirmed != true) return;

    final token = widget.authStore.token;
    if (token == null) return;
    setState(() => _actioningFilename = backup.filename);
    try {
      await _service.deleteBackup(baseUrl: widget.authStore.baseUrl, token: token, filename: backup.filename);
      if (!mounted) return;
      _showSnack('Бэкап удалён.');
      await _load();
    } on AdminSystemException catch (e) {
      if (!mounted) return;
      _showSnack(e.message, isError: true);
    } finally {
      if (mounted) setState(() => _actioningFilename = null);
    }
  }

  Future<void> _restoreBackup(BackupInfo backup) async {
    final result = await showDialog<_RestoreConfirmResult>(
      context: context,
      builder: (context) => _RestoreConfirmDialog(backup: backup),
    );
    if (result == null) return;

    final token = widget.authStore.token;
    if (token == null) return;
    setState(() => _actioningFilename = backup.filename);
    try {
      await _service.restoreBackup(
        baseUrl: widget.authStore.baseUrl,
        token: token,
        filename: backup.filename,
        confirmFilename: result.typedFilename,
        adminPassword: result.password,
      );
      if (!mounted) return;
      _showSnack('База восстановлена из ${backup.filename}.');
      await _load();
    } on AdminSystemException catch (e) {
      if (!mounted) return;
      _showSnack(e.message, isError: true);
    } finally {
      if (mounted) setState(() => _actioningFilename = null);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: AppBackground(
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    if (widget.onBack != null)
                      IconButton(
                        icon: Icon(Icons.arrow_back_rounded, color: context.onSurface),
                        onPressed: widget.onBack,
                      ),
                    Text(
                      'Сервер и бэкапы',
                      style: TextStyle(color: context.onSurface, fontSize: 18, fontWeight: FontWeight.w600),
                    ),
                    const Spacer(),
                    IconButton(
                      icon: Icon(Icons.refresh_rounded, color: context.onSurfaceFaded(0.6)),
                      onPressed: _isLoading ? null : _load,
                    ),
                  ],
                ),
              ),
              Expanded(
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator(color: Color(0xFF6C5CE7)))
                    : _error != null
                        ? Center(child: Text(_error!, style: const TextStyle(color: Color(0xFFFFB4B4))))
                        : RefreshIndicator(
                            onRefresh: _load,
                            child: ListView(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              children: [
                                if (_status != null) _StatusGrid(status: _status!),
                                const SizedBox(height: 16),
                                _buildBackupsSection(),
                                const SizedBox(height: 24),
                              ],
                            ),
                          ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBackupsSection() {
    return GlassPanel(
      opacity: 0.08,
      borderRadius: BorderRadius.circular(16),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('Бэкапы базы данных', style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w600)),
              const Spacer(),
              FilledButton.icon(
                style: FilledButton.styleFrom(backgroundColor: const Color(0xFF6C5CE7)),
                onPressed: _isCreatingBackup ? null : _createBackup,
                icon: _isCreatingBackup
                    ? const SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : const Icon(Icons.add_rounded, size: 18),
                label: Text(_isCreatingBackup ? 'Создаю…' : 'Создать бэкап'),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'pg_dump в сжатом формате (-Fc). Может занять до нескольких минут в зависимости от размера базы.',
            style: TextStyle(color: Colors.white.withValues(alpha: 0.4), fontSize: 12),
          ),
          const SizedBox(height: 12),
          if (_backups.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Text('Бэкапов пока нет.', style: TextStyle(color: Colors.white.withValues(alpha: 0.4))),
            )
          else
            ..._backups.map(_buildBackupTile),
        ],
      ),
    );
  }

  Widget _buildBackupTile(BackupInfo backup) {
    final isActioning = _actioningFilename == backup.filename;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: Colors.white.withValues(alpha: 0.04),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(backup.filename, style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w500)),
                  const SizedBox(height: 2),
                  Text(
                    '${backup.formattedSize} · ${DateFormat('dd.MM.yyyy HH:mm').format(backup.createdAt.toLocal())}',
                    style: TextStyle(color: Colors.white.withValues(alpha: 0.4), fontSize: 11.5),
                  ),
                ],
              ),
            ),
            if (isActioning)
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 12),
                child: SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white70)),
              )
            else ...[
              IconButton(
                icon: const Icon(Icons.download_rounded, color: Colors.white70, size: 20),
                tooltip: 'Скачать',
                onPressed: () => _downloadBackup(backup),
              ),
              IconButton(
                icon: const Icon(Icons.settings_backup_restore_rounded, color: Color(0xFFFFD166), size: 20),
                tooltip: 'Восстановить из этого бэкапа',
                onPressed: () => _restoreBackup(backup),
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline_rounded, color: Color(0xFFFF6B6B), size: 20),
                tooltip: 'Удалить',
                onPressed: () => _deleteBackup(backup),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _StatusGrid extends StatelessWidget {
  final SystemStatus status;
  const _StatusGrid({required this.status});

  String _formatUptime(int seconds) {
    final d = seconds ~/ 86400;
    final h = (seconds % 86400) ~/ 3600;
    final m = (seconds % 3600) ~/ 60;
    if (d > 0) return '$d д $h ч';
    if (h > 0) return '$h ч $m мин';
    return '$m мин';
  }

  @override
  Widget build(BuildContext context) {
    final dbOk = status.dbStatus == 'ok';
    final cards = [
      (
        'CPU', '${status.cpuPercent.toStringAsFixed(0)}%', Icons.memory_rounded,
        status.cpuPercent > 85 ? const Color(0xFFFF6B6B) : const Color(0xFF6C5CE7),
      ),
      (
        'Память', '${status.memoryPercent.toStringAsFixed(0)}% (${status.memoryUsedMb} / ${status.memoryTotalMb} МБ)', Icons.developer_board_rounded,
        status.memoryPercent > 85 ? const Color(0xFFFF6B6B) : const Color(0xFF00B4D8),
      ),
      (
        'Диск', '${status.diskPercent.toStringAsFixed(0)}% (${status.diskUsedGb.toStringAsFixed(1)} / ${status.diskTotalGb.toStringAsFixed(1)} ГБ)', Icons.storage_rounded,
        status.diskPercent > 85 ? const Color(0xFFFF6B6B) : const Color(0xFFFFD166),
      ),
      (
        'База данных', dbOk ? 'В порядке (${status.dbType})' : 'Недоступна', Icons.dns_rounded,
        dbOk ? const Color(0xFF00E6A0) : const Color(0xFFFF6B6B),
      ),
      (
        'Аптайм бэкенда', _formatUptime(status.backendUptimeSeconds), Icons.timer_outlined,
        const Color(0xFF9D8CFF),
      ),
      (
        'Последний бэкап',
        status.lastBackupAt != null ? DateFormat('dd.MM.yyyy HH:mm').format(status.lastBackupAt!.toLocal()) : 'Ещё не создавался',
        Icons.backup_outlined,
        status.lastBackupAt == null ? const Color(0xFFFF6B6B) : const Color(0xFF6FCF97),
      ),
    ];

    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: MediaQuery.of(context).size.width > 700 ? 3 : 2,
      childAspectRatio: 2.4,
      crossAxisSpacing: 10,
      mainAxisSpacing: 10,
      children: cards.map((c) {
        final (label, value, icon, color) = c;
        return GlassPanel(
          opacity: 0.08,
          borderRadius: BorderRadius.circular(14),
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Icon(icon, color: color, size: 22),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(label, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.white.withValues(alpha: 0.5))),
                    const SizedBox(height: 2),
                    Text(value, style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600), maxLines: 1, overflow: TextOverflow.ellipsis),
                  ],
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}

class _RestoreConfirmResult {
  final String typedFilename;
  final String password;
  _RestoreConfirmResult({required this.typedFilename, required this.password});
}

class _RestoreConfirmDialog extends StatefulWidget {
  final BackupInfo backup;
  const _RestoreConfirmDialog({required this.backup});

  @override
  State<_RestoreConfirmDialog> createState() => _RestoreConfirmDialogState();
}

class _RestoreConfirmDialogState extends State<_RestoreConfirmDialog> {
  final _filenameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _filenameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  bool get _filenameMatches => _filenameController.text.trim() == widget.backup.filename;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: const Color(0xFF1A2036),
      title: const Row(
        children: [
          Icon(Icons.warning_amber_rounded, color: Color(0xFFFFD166)),
          SizedBox(width: 8),
          Text('Восстановить базу?', style: TextStyle(color: Colors.white, fontSize: 16)),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Это НЕОБРАТИМО удалит и заменит ВСЁ текущее содержимое базы данных содержимым выбранного бэкапа. '
              'Все изменения, сделанные после создания этого бэкапа, будут потеряны без возможности восстановить.',
              style: TextStyle(color: Colors.white70, fontSize: 13, height: 1.4),
            ),
            const SizedBox(height: 16),
            Text('Чтобы продолжить, напечатай имя файла:', style: TextStyle(color: Colors.white.withValues(alpha: 0.6), fontSize: 12.5)),
            const SizedBox(height: 4),
            SelectableText(widget.backup.filename, style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            TextField(
              controller: _filenameController,
              style: const TextStyle(color: Colors.white),
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.white.withValues(alpha: 0.08),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                hintText: 'Имя файла бэкапа',
                hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.3)),
              ),
            ),
            const SizedBox(height: 12),
            Text('И свой пароль администратора:', style: TextStyle(color: Colors.white.withValues(alpha: 0.6), fontSize: 12.5)),
            const SizedBox(height: 4),
            TextField(
              controller: _passwordController,
              obscureText: _obscurePassword,
              style: const TextStyle(color: Colors.white),
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.white.withValues(alpha: 0.08),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                hintText: 'Пароль',
                hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.3)),
                suffixIcon: IconButton(
                  icon: Icon(_obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined, color: Colors.white38, size: 20),
                  onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                ),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Отмена')),
        FilledButton(
          style: FilledButton.styleFrom(backgroundColor: const Color(0xFFFF6B6B)),
          onPressed: (_filenameMatches && _passwordController.text.isNotEmpty)
              ? () => Navigator.of(context).pop(
                    _RestoreConfirmResult(typedFilename: _filenameController.text.trim(), password: _passwordController.text),
                  )
              : null,
          child: const Text('Восстановить'),
        ),
      ],
    );
  }
}
