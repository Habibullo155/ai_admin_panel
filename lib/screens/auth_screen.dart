import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../state/auth_store.dart';
import '../theme/app_text_color.dart';
import '../widgets/app_background.dart';
import '../widgets/glass_panel.dart';
import 'forgot_password_screen.dart';

class AuthScreen extends StatefulWidget {
  final AuthStore store;
  const AuthScreen({super.key, required this.store});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isRegisterMode = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    if (email.isEmpty || password.isEmpty) return;
    if (_isRegisterMode && password.length < 8) return;
    // защита от опечатки при регистрации - два поля должны совпадать,
    // при входе подтверждение не показывается вообще, там сверять нечего
    if (_isRegisterMode && password != _confirmPasswordController.text) return;

    final ok = _isRegisterMode
        ? await widget.store.register(email, password)
        : await widget.store.login(email, password);

    if (ok && mounted) {
      // Завершает автозаполнение и явно сигналит ОС/браузеру, что можно
      // предложить "Сохранить пароль?" — без этого вызова на некоторых
      // платформах (особенно вебе и части Android-путей) подсказка о
      // сохранении может не появиться, даже если поля размечены
      // autofillHints правильно.
      TextInput.finishAutofillContext();
      _passwordController.clear();
      _confirmPasswordController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: AppBackground(
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 420),
                child: AnimatedBuilder(
                  animation: widget.store,
                  builder: (context, _) => _buildForm(context),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildForm(BuildContext context) {
    final store = widget.store;

    return GlassPanel(
      opacity: 0.12,
      borderRadius: BorderRadius.circular(28),
      padding: const EdgeInsets.all(28),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            width: 64,
            height: 64,
            alignment: Alignment.center,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [Color(0xFF6C5CE7), Color(0xFF00D9C0)],
              ),
            ),
            child: const Icon(Icons.spa_rounded, color: Colors.white, size: 30),
          ),
          const SizedBox(height: 20),
          Text(
            _isRegisterMode ? 'Создать аккаунт' : 'Вход в AI Chat',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: context.onSurface,
              fontSize: 22,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 24),
          AutofillGroup(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildField(
                  controller: _emailController,
                  hint: 'Email',
                  icon: Icons.alternate_email_rounded,
                  keyboardType: TextInputType.emailAddress,
                  autofillHints: const [AutofillHints.email],
                ),
                const SizedBox(height: 12),
                _buildField(
                  controller: _passwordController,
                  hint: 'Пароль',
                  icon: Icons.lock_outline_rounded,
                  obscureText: _obscurePassword,
                  // newPassword при регистрации — сигнал ОС/браузеру, что
                  // это НОВЫЙ пароль (может предложить сгенерировать
                  // надёжный и сохранить его), а не подставить старый.
                  autofillHints: [_isRegisterMode ? AutofillHints.newPassword : AutofillHints.password],
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword ? Icons.visibility_off_rounded : Icons.visibility_rounded,
                      color: context.onSurfaceFaded(0.5),
                      size: 20,
                    ),
                    onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                  ),
                  onChanged: _isRegisterMode ? (_) => setState(() {}) : null,
                  onSubmitted: _isRegisterMode ? null : (_) => store.isBusy ? null : _submit(),
                ),
                if (_isRegisterMode) ...[
                  const SizedBox(height: 12),
                  _buildField(
                    controller: _confirmPasswordController,
                    hint: 'Повтори пароль',
                    icon: Icons.lock_outline_rounded,
                    obscureText: _obscureConfirmPassword,
                    autofillHints: const [AutofillHints.newPassword],
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscureConfirmPassword ? Icons.visibility_off_rounded : Icons.visibility_rounded,
                        color: context.onSurfaceFaded(0.5),
                        size: 20,
                      ),
                      onPressed: () => setState(() => _obscureConfirmPassword = !_obscureConfirmPassword),
                    ),
                    onChanged: (_) => setState(() {}),
                    onSubmitted: (_) => store.isBusy ? null : _submit(),
                  ),
                ],
              ],
            ),
          ),
          if (_isRegisterMode) ...[
            const SizedBox(height: 8),
            _buildPasswordHint(),
            if (_confirmPasswordController.text.isNotEmpty) ...[
              const SizedBox(height: 4),
              _buildPasswordMatchHint(),
            ],
          ],
          if (!_isRegisterMode) ...[
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => ForgotPasswordScreen(store: widget.store)),
                ),
                child: Text('Забыли пароль?', style: TextStyle(color: context.onSurfaceFaded(0.6), fontSize: 12.5)),
              ),
            ),
          ],
          if (store.lastError != null) ...[
            const SizedBox(height: 14),
            Text(
              store.lastError!,
              style: const TextStyle(color: Color(0xFFFFB4B4), fontSize: 13),
            ),
          ],
          const SizedBox(height: 20),
          _SubmitButton(
            isBusy: store.isBusy,
            label: _isRegisterMode ? 'Зарегистрироваться' : 'Войти',
            onTap: _submit,
          ),
          const SizedBox(height: 16),
          Center(
            child: TextButton(
              onPressed: () => setState(() => _isRegisterMode = !_isRegisterMode),
              child: Text(
                _isRegisterMode
                    ? 'Уже есть аккаунт? Войти'
                    : 'Нет аккаунта? Зарегистрироваться',
                style: TextStyle(color: context.onSurfaceFaded(0.7)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    TextInputType? keyboardType,
    bool obscureText = false,
    Widget? suffixIcon,
    ValueChanged<String>? onChanged,
    ValueChanged<String>? onSubmitted,
    List<String>? autofillHints,
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
        autofillHints: autofillHints,
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

  /// Живая подсказка про минимальную длину пароля (8 символов — то же
  /// правило, что и на сервере, schemas.py:UserRegister). Без этого
  /// единственная обратная связь была — ошибка сервера уже ПОСЛЕ отправки
  /// формы, что неудобно и непонятно на этапе ввода.
  Widget _buildPasswordHint() {
    final length = _passwordController.text.length;
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

  Widget _buildPasswordMatchHint() {
    final matches = _passwordController.text == _confirmPasswordController.text;
    return Row(
      children: [
        Icon(
          matches ? Icons.check_circle_rounded : Icons.error_outline_rounded,
          size: 14,
          color: matches ? const Color(0xFF00E6A0) : const Color(0xFFFFB4B4),
        ),
        const SizedBox(width: 6),
        Text(
          matches ? 'Пароли совпадают' : 'Пароли не совпадают',
          style: TextStyle(
            color: matches ? const Color(0xFF00E6A0) : const Color(0xFFFFB4B4),
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}

class _SubmitButton extends StatelessWidget {
  final bool isBusy;
  final String label;
  final VoidCallback onTap;
  const _SubmitButton({required this.isBusy, required this.label, required this.onTap});

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
                  ? [Colors.white24, Colors.white10]
                  : [const Color(0xFF6C5CE7), const Color(0xFF00B4D8)],
            ),
          ),
          child: isBusy
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                )
              : Text(
                  label,
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 15),
                ),
        ),
      ),
    );
  }
}
