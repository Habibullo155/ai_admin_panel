import 'package:flutter/material.dart';

import '../state/auth_store.dart';
import '../theme/app_text_color.dart';
import '../widgets/app_background.dart';
import '../widgets/glass_panel.dart';

/// Второй шаг входа, когда у аккаунта включена 2FA - AuthStore уже перешёл в
/// AuthStatus.twoFactorRequired (email+пароль приняты, pendingTwoFactorToken
/// ждёт кода).
class TwoFactorVerifyScreen extends StatefulWidget {
  final AuthStore store;
  const TwoFactorVerifyScreen({super.key, required this.store});

  @override
  State<TwoFactorVerifyScreen> createState() => _TwoFactorVerifyScreenState();
}

class _TwoFactorVerifyScreenState extends State<TwoFactorVerifyScreen> {
  final _codeController = TextEditingController();
  bool _useBackupCode = false;
  String? _error;

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final code = _codeController.text.trim();
    if (code.isEmpty) return;
    setState(() => _error = null);
    final error = await widget.store.submitTwoFactorCode(code);
    if (!mounted) return;
    if (error != null) {
      setState(() => _error = error);
      _codeController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    final store = widget.store;
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
                  animation: store,
                  builder: (context, _) => GlassPanel(
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
                            gradient: LinearGradient(colors: [Color(0xFF6C5CE7), Color(0xFF00D9C0)]),
                          ),
                          child: const Icon(Icons.shield_moon_rounded, color: Colors.white, size: 30),
                        ),
                        const SizedBox(height: 20),
                        Text(
                          'Введи код подтверждения',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: context.onSurface, fontSize: 20, fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _useBackupCode
                              ? 'Введи один из резервных кодов, которые ты сохранил при включении 2FA'
                              : 'Открой приложение-аутентификатор и введи текущий 6-значный код',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: context.onSurfaceFaded(0.6), fontSize: 13.5),
                        ),
                        const SizedBox(height: 24),
                        Container(
                          decoration: BoxDecoration(
                            color: context.onSurfaceFaded(0.06),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: context.onSurfaceFaded(0.12)),
                          ),
                          child: TextField(
                            controller: _codeController,
                            keyboardType: _useBackupCode ? TextInputType.text : TextInputType.number,
                            textAlign: TextAlign.center,
                            autofocus: true,
                            style: TextStyle(color: context.onSurface, fontSize: 22, letterSpacing: 4),
                            decoration: InputDecoration(
                              border: InputBorder.none,
                              hintText: _useBackupCode ? 'Резервный код' : 'Код из приложения',
                              hintStyle: TextStyle(color: context.onSurfaceFaded(0.3), fontSize: 16, letterSpacing: 1),
                              contentPadding: const EdgeInsets.symmetric(vertical: 16),
                            ),
                            onSubmitted: (_) => store.isBusy ? null : _submit(),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed: () {
                              setState(() {
                                _useBackupCode = !_useBackupCode;
                                _codeController.clear();
                                _error = null;
                              });
                            },
                            child: Text(
                              _useBackupCode ? 'Использовать код из приложения' : 'Использовать резервный код',
                              style: TextStyle(color: context.onSurfaceFaded(0.6), fontSize: 12.5),
                            ),
                          ),
                        ),
                        if (_error != null) ...[
                          const SizedBox(height: 6),
                          Text(_error!, style: const TextStyle(color: Color(0xFFFFB4B4), fontSize: 13)),
                        ],
                        const SizedBox(height: 14),
                        _TwoFactorSubmitButton(isBusy: store.isBusy, label: 'Подтвердить', onTap: _submit),
                        const SizedBox(height: 12),
                        Center(
                          child: TextButton(
                            onPressed: store.isBusy ? null : store.cancelTwoFactorLogin,
                            child: Text('Отменить вход', style: TextStyle(color: context.onSurfaceFaded(0.5))),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _TwoFactorSubmitButton extends StatelessWidget {
  final bool isBusy;
  final String label;
  final VoidCallback onTap;
  const _TwoFactorSubmitButton({required this.isBusy, required this.label, required this.onTap});

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
              colors: isBusy ? [Colors.white24, Colors.white10] : [const Color(0xFF6C5CE7), const Color(0xFF00B4D8)],
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
