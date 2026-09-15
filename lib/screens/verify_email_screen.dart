import 'package:flutter/material.dart';

import '../state/auth_store.dart';
import '../theme/app_text_color.dart';
import '../widgets/app_background.dart';
import '../widgets/glass_panel.dart';

/// Ввод кода подтверждения почты - код приходит письмом при регистрации
/// (или повторно через "Отправить ещё раз" здесь же). В отличие от
/// восстановления пароля здесь человек уже залогинен - незачем спрашивать
/// email заново, только сам код.
class VerifyEmailScreen extends StatefulWidget {
  final AuthStore store;
  const VerifyEmailScreen({super.key, required this.store});

  @override
  State<VerifyEmailScreen> createState() => _VerifyEmailScreenState();
}

class _VerifyEmailScreenState extends State<VerifyEmailScreen> {
  final _codeController = TextEditingController();
  String? _successMessage;

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  Future<void> _verify() async {
    final code = _codeController.text.trim();
    if (code.isEmpty) return;
    setState(() => _successMessage = null);
    final ok = await widget.store.verifyEmail(code);
    if (ok && mounted) Navigator.of(context).pop();
  }

  Future<void> _resend() async {
    setState(() => _successMessage = null);
    final ok = await widget.store.resendVerification();
    if (ok && mounted) setState(() => _successMessage = 'Код отправлен повторно — проверь почту.');
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
                      'Подтверждение почты',
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
                        builder: (context, _) {
                          final store = widget.store;
                          final email = store.user?.email;
                          return GlassPanel(
                            opacity: 0.12,
                            borderRadius: BorderRadius.circular(28),
                            padding: const EdgeInsets.all(28),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Icon(Icons.mark_email_unread_outlined, color: context.onSurfaceFaded(0.5), size: 40),
                                const SizedBox(height: 16),
                                Text(
                                  email == null
                                      ? 'Введи код, который пришёл на почту при регистрации.'
                                      : 'Введи код, который пришёл на $email.',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(color: context.onSurfaceFaded(0.65), fontSize: 13.5, height: 1.5),
                                ),
                                const SizedBox(height: 20),
                                Container(
                                  decoration: BoxDecoration(
                                    color: context.onSurfaceFaded(0.06),
                                    borderRadius: BorderRadius.circular(14),
                                    border: Border.all(color: context.onSurfaceFaded(0.12)),
                                  ),
                                  child: TextField(
                                    controller: _codeController,
                                    onSubmitted: (_) => store.isBusy ? null : _verify(),
                                    style: TextStyle(color: context.onSurface),
                                    decoration: InputDecoration(
                                      border: InputBorder.none,
                                      prefixIcon: Icon(Icons.key_outlined, color: context.onSurfaceFaded(0.5), size: 20),
                                      hintText: 'Код из письма',
                                      hintStyle: TextStyle(color: context.onSurfaceFaded(0.35)),
                                      contentPadding: const EdgeInsets.symmetric(vertical: 16),
                                    ),
                                  ),
                                ),
                                if (_successMessage != null) ...[
                                  const SizedBox(height: 14),
                                  Text(_successMessage!, style: const TextStyle(color: Color(0xFF00E6A0), fontSize: 13)),
                                ],
                                if (store.lastError != null) ...[
                                  const SizedBox(height: 14),
                                  Text(store.lastError!, style: const TextStyle(color: Color(0xFFFFB4B4), fontSize: 13)),
                                ],
                                const SizedBox(height: 20),
                                Material(
                                  color: Colors.transparent,
                                  child: InkWell(
                                    borderRadius: BorderRadius.circular(16),
                                    onTap: store.isBusy ? null : _verify,
                                    child: Container(
                                      height: 50,
                                      alignment: Alignment.center,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(16),
                                        gradient: LinearGradient(
                                          colors: store.isBusy
                                              ? [context.onSurfaceFaded(0.2), context.onSurfaceFaded(0.1)]
                                              : [const Color(0xFF6C5CE7), const Color(0xFF00B4D8)],
                                        ),
                                      ),
                                      child: store.isBusy
                                          ? const SizedBox(
                                              width: 20,
                                              height: 20,
                                              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                                            )
                                          : const Text(
                                              'Подтвердить',
                                              style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 15),
                                            ),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 10),
                                TextButton(
                                  onPressed: store.isBusy ? null : _resend,
                                  child: Text('Отправить код ещё раз', style: TextStyle(color: context.onSurfaceFaded(0.5))),
                                ),
                              ],
                            ),
                          );
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
}
