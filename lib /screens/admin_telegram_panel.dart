import 'package:flutter/material.dart';

import '../models/telegram_settings.dart';
import '../services/telegram_admin_service.dart';
import '../state/auth_store.dart';
import '../theme/app_text_color.dart';
import '../widgets/glass_panel.dart';

/// Канал, бот и размер бонуса за подписку - см. backend/telegram_integration.py
/// и daily_limits.py про то, как именно используется каждое поле.
class AdminTelegramPanel extends StatefulWidget {
  final AuthStore authStore;
  const AdminTelegramPanel({super.key, required this.authStore});

  @override
  State<AdminTelegramPanel> createState() => _AdminTelegramPanelState();
}

class _AdminTelegramPanelState extends State<AdminTelegramPanel> {
  final _service = TelegramAdminService();
  final _channelLinkController = TextEditingController();
  final _channelChatIdController = TextEditingController();
  final _botUsernameController = TextEditingController();
  final _botTokenController = TextEditingController();
  final _bonusRequestsController = TextEditingController();

  TelegramSettings? _settings;
  bool _isLoading = true;
  bool _isSaving = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _service.dispose();
    _channelLinkController.dispose();
    _channelChatIdController.dispose();
    _botUsernameController.dispose();
    _botTokenController.dispose();
    _bonusRequestsController.dispose();
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
      final settings = await _service.fetch(baseUrl: widget.authStore.baseUrl, token: token);
      if (!mounted) return;
      setState(() {
        _settings = settings;
        _channelLinkController.text = settings.channelLink;
        _channelChatIdController.text = settings.channelChatId;
        _botUsernameController.text = settings.botUsername;
        _bonusRequestsController.text = settings.bonusRequests.toString();
      });
    } on TelegramAdminException catch (e) {
      if (mounted) setState(() => _error = e.message);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _save() async {
    final token = widget.authStore.token;
    if (token == null) return;
    setState(() {
      _isSaving = true;
      _error = null;
    });
    try {
      final updated = await _service.update(
        baseUrl: widget.authStore.baseUrl,
        token: token,
        channelLink: _channelLinkController.text.trim(),
        channelChatId: _channelChatIdController.text.trim(),
        botUsername: _botUsernameController.text.trim(),
        // пустое поле = "не менять" - см. тот же принцип у SMTP-пароля
        botToken: _botTokenController.text.isNotEmpty ? _botTokenController.text : null,
        bonusRequests: int.tryParse(_bonusRequestsController.text.trim()),
      );
      if (!mounted) return;
      setState(() {
        _settings = updated;
        _botTokenController.clear();
      });
    } on TelegramAdminException catch (e) {
      if (mounted) setState(() => _error = e.message);
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading && _settings == null) {
      return const Center(child: CircularProgressIndicator(color: Color(0xFF6C5CE7)));
    }

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Row(
          children: [
            Text('Telegram', style: TextStyle(color: context.onSurface, fontSize: 20, fontWeight: FontWeight.w700)),
            const Spacer(),
            IconButton(icon: Icon(Icons.refresh_rounded, color: context.onSurfaceFaded(0.5)), onPressed: _load),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          'Бонус для free-тарифа за подписку на канал — начисляется каждый день заново, пока человек подписан. '
          'Chat ID и токен бота нужны, чтобы сервер мог реально проверять подписку через Bot API, не только показывать ссылку.',
          style: TextStyle(color: context.onSurfaceFaded(0.4), fontSize: 12, height: 1.4),
        ),
        if (_error != null) ...[
          const SizedBox(height: 8),
          Text(_error!, style: const TextStyle(color: Color(0xFFFFB4B4), fontSize: 13)),
        ],
        const SizedBox(height: 16),
        GlassPanel(
          opacity: 0.06,
          borderRadius: BorderRadius.circular(16),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildField(_channelLinkController, 'Ссылка на канал', hint: 'https://t.me/mychannel'),
              const SizedBox(height: 10),
              _buildField(_channelChatIdController, 'Chat ID канала', hint: '@mychannel или -100...'),
              const SizedBox(height: 10),
              _buildField(_botUsernameController, 'Имя бота (без @)', hint: 'my_awesome_bot'),
              const SizedBox(height: 10),
              _buildField(
                _botTokenController,
                'Токен бота',
                obscureText: true,
                hint: _settings?.botTokenIsSet == true ? 'уже задан, оставь пустым чтобы не менять' : null,
              ),
              const SizedBox(height: 10),
              _buildField(_bonusRequestsController, 'Бонус запросов в день', keyboardType: TextInputType.number),
              const SizedBox(height: 14),
              Align(
                alignment: Alignment.centerRight,
                child: FilledButton(
                  style: FilledButton.styleFrom(backgroundColor: const Color(0xFF6C5CE7)),
                  onPressed: _isSaving ? null : _save,
                  child: _isSaving
                      ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : const Text('Сохранить'),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildField(
    TextEditingController controller,
    String label, {
    bool obscureText = false,
    TextInputType? keyboardType,
    String? hint,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      style: TextStyle(color: context.onSurface),
      decoration: InputDecoration(
        filled: true,
        fillColor: context.onSurfaceFaded(0.08),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        labelText: label,
        labelStyle: TextStyle(color: context.onSurfaceFaded(0.5)),
        hintText: hint,
        hintStyle: TextStyle(color: context.onSurfaceFaded(0.3), fontSize: 12.5),
      ),
    );
  }
}
