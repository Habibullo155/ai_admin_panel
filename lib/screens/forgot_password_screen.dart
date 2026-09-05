import 'package:flutter/material.dart';

import '../state/auth_store.dart';
import '../theme/app_text_color.dart';
import '../widgets/app_background.dart';
import '../widgets/glass_panel.dart';

enum _Stage { enterEmail, checkEmailSent, enterCodeAndPassword, done }

/// Восстановление пароля в один заход: сначала email, потом (после того
/// как код "отправлен" - реально уходит только если на сервере настроен
/// SMTP, см. backend/email_service.py) код + новый пароль на этом же
/// экране, без перехода куда-то ещё по ссылке из письма - проще для
/// мобильного приложения, чем полагаться на deep link.
class ForgotPasswordScreen extends StatefulWidget {
  final AuthStore store;
  const ForgotPasswordScreen({super.key, required this.store});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _emailController = TextEditingController();
  final _codeController = TextEditingController();
  final _newPasswordController = TextEditingController();
  _Stage _stage = _Stage.enterEmail;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _codeController.dispose();
    _newPasswordController.dispose();
    super.dispose();
  }

  Future<void> _sendCode() async {
    final email = _emailController.text.trim();
    if (email.isEmpty) return;
    final ok = await widget.store.forgotPassword(email);
    if (ok && mounted) setState(() => _stage = _Stage.checkEmailSent);
  }

  Future<void> _resetPassword() async {
    final code = _codeController.text.trim();
    final password = _newPasswordController.text;
    if (code.isEmpty || password.length < 8) return;
    final ok = await widget.store.resetPassword(token: code, newPassword: password);
    if (ok && mounted) setState(() => _stage = _Stage.done);
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
                    IconButton(
                      icon: Icon(Icons.arrow_back_rounded, color: context.onSurface),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                    Text(
                      'Восстановление пароля',
                      style: TextStyle(color: context.onSurface, fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Center(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(24),
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 420),
                      child: AnimatedBuilder(
                        animation: widget.store,
                        builder: (context, _) => switch (_stage) {
                          _Stage.enterEmail => _buildEnterEmail(),
                          _Stage.checkEmailSent => _buildCheckEmailSent(),
                          _Stage.enterCodeAndPassword => _buildEnterCodeAndPassword(),
                          _Stage.done => _buildDone(),
                        },
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEnterEmail() {
    final store = widget.store;
    return GlassPanel(
      opacity: 0.12,
      borderRadius: BorderRadius.circular(28),
      padding: const EdgeInsets.all(28),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Укажи email, на который зарегистрирован аккаунт — пришлём код для сброса пароля.',
            style: TextStyle(color: context.onSurfaceFaded(0.65), fontSize: 13.5, height: 1.5),
          ),
          const SizedBox(height: 20),
          _buildTextField(
            controller: _emailController,
            hint: 'Email',
            icon: Icons.alternate_email_rounded,
            keyboardType: TextInputType.emailAddress,
            onSubmitted: (_) => store.isBusy ? null : _sendCode(),
          ),
          if (store.lastError != null) ...[
            const SizedBox(height: 14),
            Text(store.lastError!, style: const TextStyle(color: Color(0xFFFFB4B4), fontSize: 13)),
          ],
          const SizedBox(height: 20),
          _GradientButton(isBusy: store.isBusy, label: 'Отправить код', onTap: _sendCode),
        ],
      ),
    );
  }

  Widget _buildCheckEmailSent() {
    return GlassPanel(
      opacity: 0.12,
      borderRadius: BorderRadius.circular(28),
      padding: const EdgeInsets.all(28),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Icon(Icons.mark_email_read_outlined, color: context.onSurfaceFaded(0.5), size: 40),
          const SizedBox(height: 16),
          Text(
            'Если такой email зарегистрирован — на него отправлен код для восстановления пароля. '
            'Проверь почту (и папку "Спам") и введи код ниже вместе с новым паролем.',
            textAlign: TextAlign.center,
            style: TextStyle(color: context.onSurfaceFaded(0.65), fontSize: 13.5, height: 1.5),
          ),
          const SizedBox(height: 20),
          _GradientButton(
            isBusy: false,
            label: 'У меня есть код',
            onTap: () => setState(() => _stage = _Stage.enterCodeAndPassword),
          ),
          const SizedBox(height: 10),
          TextButton(
            onPressed: () => setState(() => _stage = _Stage.enterEmail),
            child: Text('Отправить ещё раз', style: TextStyle(color: context.onSurfaceFaded(0.5))),
          ),
        ],
      ),
    );
  }

  Widget _buildEnterCodeAndPassword() {
    final store = widget.store;
    return GlassPanel(
      opacity: 0.12,
      borderRadius: BorderRadius.circular(28),
      padding: const EdgeInsets.all(28),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Код из письма',
            style: TextStyle(color: context.onSurface, fontSize: 18, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 16),
          _buildTextField(controller: _codeController, hint: 'Код', icon: Icons.key_outlined),
          const SizedBox(height: 12),
          _buildTextField(
            controller: _newPasswordController,
            hint: 'Новый пароль',
            icon: Icons.lock_outline_rounded,
            obscureText: _obscurePassword,
            suffixIcon: IconButton(
              icon: Icon(
                _obscurePassword ? Icons.visibility_off_rounded : Icons.visibility_rounded,
                color: context.onSurfaceFaded(0.5),
                size: 20,
              ),
              onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
            ),
            onChanged: (_) => setState(() {}),
            onSubmitted: (_) => store.isBusy ? null : _resetPassword(),
          ),
          const SizedBox(height: 8),
          _buildPasswordHint(),
          if (store.lastError != null) ...[
            const SizedBox(height: 14),
            Text(store.lastError!, style: const TextStyle(color: Color(0xFFFFB4B4), fontSize: 13)),
          ],
          const SizedBox(height: 20),
          _GradientButton(isBusy: store.isBusy, label: 'Сменить пароль', onTap: _resetPassword),
        ],
      ),
    );
  }

  Widget _buildDone() {
    return GlassPanel(
      opacity: 0.12,
      borderRadius: BorderRadius.circular(28),
      padding: const EdgeInsets.all(28),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Icon(Icons.check_circle_outline_rounded, color: Color(0xFF00E6A0), size: 40),
          const SizedBox(height: 16),
          Text(
            'Пароль изменён. Теперь можно войти с новым паролем.',
            textAlign: TextAlign.center,
            style: TextStyle(color: context.onSurfaceFaded(0.7), fontSize: 14.5),
          ),
          const SizedBox(height: 20),
          _GradientButton(
            isBusy: false,
            label: 'Войти',
            onTap: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    TextInputType? keyboardType,
    bool obscureText = false,
    Widget? suffixIcon,
    ValueChanged<String>? onChanged,
    ValueChanged<String>? onSubmitted,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: context.onSurfaceFaded(0.06),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: context.onSurfaceFaded(0.12)),
      ),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        obscureText: obscureText,
        onChanged: onChanged,
        onSubmitted: onSubmitted,
        style: TextStyle(color: context.onSurface),
        decoration: InputDecoration(
          border: InputBorder.none,
          prefixIcon: Icon(icon, color: context.onSurfaceFaded(0.5), size: 20),
          suffixIcon: suffixIcon,
          hintText: hint,
          hintStyle: TextStyle(color: context.onSurfaceFaded(0.35)),
          contentPadding: const EdgeInsets.symmetric(vertical: 16),
        ),
      ),
    );
  }

  // то же правило длины (8 символов), что и на сервере (schemas.py:
  // ResetPasswordRequest) - тот же приём живой подсказки, что уже есть в
  // auth_screen.dart для регистрации
  Widget _buildPasswordHint() {
    final length = _newPasswordController.text.length;
    const minLength = 8;
    final isValid = length >= minLength;
    return Row(
      children: [
        Icon(
          isValid ? Icons.check_circle_rounded : Icons.circle_outlined,
          size: 14,
          color: isValid ? const Color(0xFF00E6A0) : context.onSurfaceFaded(0.35),
        ),
        const SizedBox(width: 6),
        Text(
          isValid ? 'Длина пароля подходит' : 'Минимум $minLength символов (введено: $length)',
          style: TextStyle(
            color: isValid ? const Color(0xFF00E6A0) : context.onSurfaceFaded(0.45),
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}

class _GradientButton extends StatelessWidget {
  final bool isBusy;
  final String label;
  final VoidCallback onTap;
  const _GradientButton({required this.isBusy, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: isBusy ? null : onTap,
        child: Container(
          height: 50,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              colors: isBusy
                  ? [context.onSurfaceFaded(0.2), context.onSurfaceFaded(0.1)]
                  : [const Color(0xFF6C5CE7), const Color(0xFF00B4D8)],
            ),
          ),
          child: isBusy
              ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
              : Text(label, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 15)),
        ),
      ),
    );
  }
}
