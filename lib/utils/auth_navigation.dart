import 'package:flutter/material.dart';

import '../state/auth_store.dart';
import '../widgets/glass_panel.dart';

/// Раньше просто вызывался authStore.logout() без подтверждения — и если
/// пользователь был на вложенном экране (Настройки, Профиль), выход не
/// возвращал его на экран входа: смена состояния авторизации меняет, что
/// рендерит MaterialApp.home, но САМ Navigator при этом не сбрасывает свой
/// стек — вложенный экран как был поверх всего, так и оставался виден.
/// Поэтому здесь ДВА шага: сначала схлопнуть стек навигации до корня,
/// потом уже менять состояние авторизации — так пользователь реально
/// оказывается на экране входа, а не на настройках поверх него.
Future<void> confirmAndLogout(BuildContext context, AuthStore authStore) async {
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (context) => Dialog(
      backgroundColor: Colors.transparent,
      child: GlassPanel(
        opacity: 0.18,
        borderRadius: BorderRadius.circular(20),
        padding: const EdgeInsets.all(20),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 340),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Выйти из аккаунта?',
                style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              Text(
                'История переписки на этом устройстве останется — она нигде, кроме этого устройства, не хранится.',
                style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 13, height: 1.4),
              ),
              const SizedBox(height: 18),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    child: Text('Отмена', style: TextStyle(color: Colors.white.withOpacity(0.6))),
                  ),
                  const SizedBox(width: 8),
                  FilledButton(
                    style: FilledButton.styleFrom(backgroundColor: const Color(0xFF6C5CE7)),
                    onPressed: () => Navigator.of(context).pop(true),
                    child: const Text('Выйти'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    ),
  );

  if (confirmed != true) return;
  if (!context.mounted) return;

  Navigator.of(context).popUntil((route) => route.isFirst);
  await authStore.logout();
}
