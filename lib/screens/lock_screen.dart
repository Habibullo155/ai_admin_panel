import 'package:flutter/material.dart';

import '../state/auth_store.dart';
import '../widgets/app_background.dart';
import '../widgets/glass_panel.dart';

/// Показывается при AuthStatus.locked — сессия реально есть (токен уже
/// прочитан из защищённого хранилища), просто пользователь включил вход
/// по биометрии и подтверждение ещё не пройдено в этом запуске.
class LockScreen extends StatefulWidget {
  final AuthStore authStore;
  const LockScreen({super.key, required this.authStore});

  @override
  State<LockScreen> createState() => _LockScreenState();
}

class _LockScreenState extends State<LockScreen> {
  bool _isChecking = false;
  bool _failed = false;

  @override
  void initState() {
    super.initState();
    // Предлагаем биометрию сразу, не дожидаясь тапа — так быстрее для
    // обычного случая (совпало с Face ID с первого раза), а кнопка ниже
    // остаётся на случай, если авто-попытка не сработала (например,
    // пользователь просто ещё не поднёс палец к сканеру).
    WidgetsBinding.instance.addPostFrameCallback((_) => _unlock());
  }

  Future<void> _unlock() async {
    setState(() {
      _isChecking = true;
      _failed = false;
    });
    final ok = await widget.authStore.unlockWithBiometrics();
    if (!mounted) return;
    setState(() {
      _isChecking = false;
      _failed = !ok;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: AppBackground(
        child: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 380),
                child: GlassPanel(
                  opacity: 0.12,
                  borderRadius: BorderRadius.circular(28),
                  padding: const EdgeInsets.all(28),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 64,
                        height: 64,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: const LinearGradient(colors: [Color(0xFF6C5CE7), Color(0xFF00D9C0)]),
                        ),
                        child: Icon(
                          _isChecking ? Icons.hourglass_top_rounded : Icons.fingerprint_rounded,
                          color: Colors.white,
                          size: 32,
                        ),
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        'Приложение заблокировано',
                        style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _failed
                            ? 'Не удалось подтвердить — попробуй ещё раз.'
                            : 'Подтверди личность, чтобы продолжить.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 13.5),
                      ),
                      const SizedBox(height: 24),
                      Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(14),
                          onTap: _isChecking ? null : _unlock,
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 13),
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(14),
                              gradient: const LinearGradient(colors: [Color(0xFF6C5CE7), Color(0xFF00B4D8)]),
                            ),
                            child: _isChecking
                                ? const SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                                  )
                                : const Text('Разблокировать', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextButton(
                        onPressed: _isChecking ? null : widget.authStore.continueWithoutBiometrics,
                        child: Text('Войти паролем', style: TextStyle(color: Colors.white.withOpacity(0.6))),
                      ),
                    ],
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
