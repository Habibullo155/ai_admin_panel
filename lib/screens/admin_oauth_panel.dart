import 'package:flutter/material.dart';

import '../models/oauth_provider.dart';
import '../services/oauth_admin_service.dart';
import '../state/auth_store.dart';
import '../theme/app_text_color.dart';
import '../widgets/glass_panel.dart';

/// Настройка входа через внешних провайдеров (Google, VK, Госуслуги, MAX).
/// После регистрации приложения у самого провайдера сюда вписываются
/// полученные client_id/client_secret. Честно про Google/VK/Госуслуги/MAX:
/// не все умеют реально пройти вход целиком прямо сейчас - см.
/// is_flow_implemented ниже, карточка неготового провайдера показывает
/// предупреждение, а не притворяется рабочей.
class AdminOAuthPanel extends StatefulWidget {
  final AuthStore authStore;
  const AdminOAuthPanel({super.key, required this.authStore});

  @override
  State<AdminOAuthPanel> createState() => _AdminOAuthPanelState();
}

class _AdminOAuthPanelState extends State<AdminOAuthPanel> {
  final _service = OAuthAdminService();
  List<OAuthProvider> _providers = [];
  bool _isLoading = true;
  String? _error;

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
      final providers = await _service.list(baseUrl: widget.authStore.baseUrl, token: token);
      if (!mounted) return;
      setState(() => _providers = providers);
    } on OAuthAdminException catch (e) {
      if (mounted) setState(() => _error = e.message);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _toggleEnabled(OAuthProvider provider) async {
    final token = widget.authStore.token;
    if (token == null) return;
    try {
      final updated = await _service.update(
        baseUrl: widget.authStore.baseUrl,
        token: token,
        provider: provider.provider,
        enabled: !provider.enabled,
      );
      if (!mounted) return;
      setState(() {
        final index = _providers.indexWhere((p) => p.provider == provider.provider);
        if (index != -1) _providers[index] = updated;
      });
    } on OAuthAdminException catch (e) {
      if (mounted) setState(() => _error = e.message);
    }
  }

  Future<void> _editCredentials(OAuthProvider provider) async {
    final clientIdController = TextEditingController(text: provider.clientId ?? '');
    final clientSecretController = TextEditingController();
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A2036),
        title: Text('${provider.displayName} - учётные данные', style: const TextStyle(color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: clientIdController,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(labelText: 'Client ID'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: clientSecretController,
              obscureText: true,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: 'Client Secret',
                hintText: provider.clientSecretIsSet ? 'уже задан, оставь пустым чтобы не менять' : null,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('Отмена')),
          TextButton(onPressed: () => Navigator.of(context).pop(true), child: const Text('Сохранить')),
        ],
      ),
    );
    if (result != true) return;

    final token = widget.authStore.token;
    if (token == null) return;
    final clientId = clientIdController.text.trim();
    final clientSecret = clientSecretController.text;
    try {
      final updated = await _service.update(
        baseUrl: widget.authStore.baseUrl,
        token: token,
        provider: provider.provider,
        clientId: clientId.isNotEmpty ? clientId : null,
        // пустое поле = "не менять" - тот же принцип, что и у SMTP-пароля:
        // не затираем уже сохранённый секрет случайной пустой строкой
        clientSecret: clientSecret.isNotEmpty ? clientSecret : null,
      );
      if (!mounted) return;
      setState(() {
        final index = _providers.indexWhere((p) => p.provider == provider.provider);
        if (index != -1) _providers[index] = updated;
      });
    } on OAuthAdminException catch (e) {
      if (mounted) setState(() => _error = e.message);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading && _providers.isEmpty) {
      return const Center(child: CircularProgressIndicator(color: Color(0xFF6C5CE7)));
    }

    return RefreshIndicator(
      onRefresh: _load,
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Row(
            children: [
              Text('Вход через соцсети', style: TextStyle(color: context.onSurface, fontSize: 20, fontWeight: FontWeight.w700)),
              const Spacer(),
              IconButton(icon: Icon(Icons.refresh_rounded, color: context.onSurfaceFaded(0.5)), onPressed: _load),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'Впиши client_id и client_secret, полученные после регистрации приложения у самого провайдера, '
            'затем включи переключателем.',
            style: TextStyle(color: context.onSurfaceFaded(0.4), fontSize: 12, height: 1.4),
          ),
          if (_error != null) ...[
            const SizedBox(height: 8),
            Text(_error!, style: const TextStyle(color: Color(0xFFFFB4B4), fontSize: 13)),
          ],
          const SizedBox(height: 16),
          ..._providers.map(_buildProviderCard),
        ],
      ),
    );
  }

  Widget _buildProviderCard(OAuthProvider provider) {
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
                Expanded(
                  child: Text(provider.displayName, style: TextStyle(color: context.onSurface, fontSize: 15, fontWeight: FontWeight.w600)),
                ),
                Switch(
                  value: provider.enabled,
                  activeThumbColor: const Color(0xFF6C5CE7),
                  // выключенный провайдер (не реализован целиком) нельзя
                  // включить - честнее не дать переключить, чем притворяться
                  onChanged: provider.isFlowImplemented ? (_) => _toggleEnabled(provider) : null,
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              provider.clientId != null && provider.clientId!.isNotEmpty
                  ? 'Client ID: ${provider.clientId}'
                  : 'Client ID не задан',
              style: TextStyle(color: context.onSurfaceFaded(0.5), fontSize: 12.5),
            ),
            Text(
              provider.clientSecretIsSet ? 'Client Secret: задан' : 'Client Secret не задан',
              style: TextStyle(color: context.onSurfaceFaded(0.5), fontSize: 12.5),
            ),
            if (!provider.isFlowImplemented) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFD166).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.info_outline_rounded, size: 14, color: Color(0xFFFFD166)),
                    const SizedBox(width: 6),
                    Text(
                      'Вход через этого провайдера ещё не реализован целиком',
                      style: TextStyle(color: context.onSurfaceFaded(0.6), fontSize: 11.5),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 10),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                onPressed: () => _editCredentials(provider),
                icon: Icon(Icons.edit_outlined, size: 16, color: context.onSurfaceFaded(0.6)),
                label: Text('Изменить', style: TextStyle(color: context.onSurfaceFaded(0.6), fontSize: 12.5)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
