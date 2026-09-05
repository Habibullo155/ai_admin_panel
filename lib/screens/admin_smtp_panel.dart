import 'package:flutter/material.dart';

import '../models/smtp_settings.dart';
import '../services/smtp_admin_service.dart';
import '../state/auth_store.dart';
import '../theme/app_text_color.dart';
import '../widgets/glass_panel.dart';

/// Настройка отправки почты (коды подтверждения, восстановление пароля).
/// БД имеет приоритет над .env - если задано здесь, используется это,
/// иначе бэкенд падает обратно на переменные окружения. Пароль никогда
/// не приходит обратно с сервера - только признак, задан он или нет.
class AdminSmtpPanel extends StatefulWidget {
  final AuthStore authStore;
  const AdminSmtpPanel({super.key, required this.authStore});

  @override
  State<AdminSmtpPanel> createState() => _AdminSmtpPanelState();
}

class _AdminSmtpPanelState extends State<AdminSmtpPanel> {
  final _service = SmtpAdminService();
  final _hostController = TextEditingController();
  final _portController = TextEditingController();
  final _userController = TextEditingController();
  final _passwordController = TextEditingController();
  final _fromController = TextEditingController();
  final _fromNameController = TextEditingController();
  final _testEmailController = TextEditingController();

  SmtpSettings? _settings;
  bool _isLoading = true;
  bool _isSaving = false;
  bool _isSendingTest = false;
  String? _error;
  String? _testResultMessage;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _service.dispose();
    _hostController.dispose();
    _portController.dispose();
    _userController.dispose();
    _passwordController.dispose();
    _fromController.dispose();
    _fromNameController.dispose();
    _testEmailController.dispose();
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
        _hostController.text = settings.smtpHost;
        _portController.text = settings.smtpPort;
        _userController.text = settings.smtpUser;
        _fromController.text = settings.smtpFrom;
        _fromNameController.text = settings.smtpFromName;
      });
    } on SmtpAdminException catch (e) {
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
      _testResultMessage = null;
    });
    try {
      final updated = await _service.update(
        baseUrl: widget.authStore.baseUrl,
        token: token,
        smtpHost: _hostController.text.trim(),
        smtpPort: _portController.text.trim(),
        smtpUser: _userController.text.trim(),
        // пустое поле = "не менять" - не затираем уже сохранённый пароль,
        // если админ просто поправил другое поле и не трогал пароль
        smtpPassword: _passwordController.text.isNotEmpty ? _passwordController.text : null,
        smtpFrom: _fromController.text.trim(),
        smtpFromName: _fromNameController.text.trim(),
      );
      if (!mounted) return;
      setState(() {
        _settings = updated;
        _passwordController.clear();
      });
    } on SmtpAdminException catch (e) {
      if (mounted) setState(() => _error = e.message);
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Future<void> _sendTest() async {
    final token = widget.authStore.token;
    if (token == null) return;
    final to = _testEmailController.text.trim();
    if (to.isEmpty) return;

    setState(() {
      _isSendingTest = true;
      _testResultMessage = null;
      _error = null;
    });
    try {
      final sent = await _service.sendTest(baseUrl: widget.authStore.baseUrl, token: token, to: to);
      if (!mounted) return;
      setState(() {
        _testResultMessage = sent
            ? 'Письмо отправлено на $to — проверь почту.'
            : 'Письмо не отправлено — SMTP не настроен ни здесь, ни в .env.';
      });
    } on SmtpAdminException catch (e) {
      if (mounted) setState(() => _error = e.message);
    } finally {
      if (mounted) setState(() => _isSendingTest = false);
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
            Text('Настройки почты', style: TextStyle(color: context.onSurface, fontSize: 20, fontWeight: FontWeight.w700)),
            const Spacer(),
            IconButton(icon: Icon(Icons.refresh_rounded, color: context.onSurfaceFaded(0.5)), onPressed: _load),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          'Коды подтверждения почты и восстановления пароля отправляются через этот сервер. '
          'Если не настроено здесь — используется .env на сервере, если и там пусто — письма только логируются, не уходят реально.',
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
              _buildField(_hostController, 'SMTP-сервер', hint: 'smtp.gmail.com'),
              const SizedBox(height: 10),
              _buildField(_portController, 'Порт', keyboardType: TextInputType.number, hint: '587'),
              const SizedBox(height: 10),
              _buildField(_userController, 'Логин', hint: 'you@gmail.com'),
              const SizedBox(height: 10),
              _buildField(
                _passwordController,
                'Пароль',
                obscureText: true,
                hint: _settings?.smtpPasswordIsSet == true ? 'уже задан, оставь пустым чтобы не менять' : null,
              ),
              const SizedBox(height: 10),
              _buildField(_fromController, 'Адрес отправителя', hint: 'noreply@example.com'),
              const SizedBox(height: 10),
              _buildField(_fromNameController, 'Имя отправителя', hint: 'AI Glass Chat'),
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
        const SizedBox(height: 16),
        GlassPanel(
          opacity: 0.06,
          borderRadius: BorderRadius.circular(16),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Тестовое письмо', style: TextStyle(color: context.onSurface, fontSize: 14.5, fontWeight: FontWeight.w600)),
              const SizedBox(height: 4),
              Text(
                'Проверь настройки, не проходя всю регистрацию заново.',
                style: TextStyle(color: context.onSurfaceFaded(0.5), fontSize: 12),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: _buildField(_testEmailController, 'Адрес для теста', hint: 'test@example.com'),
                  ),
                  const SizedBox(width: 10),
                  FilledButton(
                    style: FilledButton.styleFrom(backgroundColor: const Color(0xFF00B4D8)),
                    onPressed: _isSendingTest ? null : _sendTest,
                    child: _isSendingTest
                        ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                        : const Text('Отправить'),
                  ),
                ],
              ),
              if (_testResultMessage != null) ...[
                const SizedBox(height: 8),
                Text(_testResultMessage!, style: TextStyle(color: context.onSurfaceFaded(0.6), fontSize: 12.5)),
              ],
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
