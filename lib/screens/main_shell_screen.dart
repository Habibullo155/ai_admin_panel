import 'package:flutter/material.dart';

import '../state/auth_store.dart';
import '../state/chat_store.dart';
import '../state/theme_store.dart';
import '../state/voice_store.dart';
import '../widgets/glass_panel.dart';
import 'chat_screen.dart';
import 'profile_screen.dart';
import 'sleep_music_screen.dart';
import 'wellbeing_screen.dart';

/// Только для мобильных — на десктопе/планшете как было: один ChatScreen
/// с выпадающим меню (см. app.dart, Responsive.isMobile решает, что
/// показать). Три главных раздела как переключаемые вкладки без потери
/// состояния между переходами (IndexedStack держит их все смонтированными,
/// а не пересоздаёт заново при каждом переключении), остальное — доступно,
/// как и раньше, через меню внутри самого чата.
class MainShellScreen extends StatefulWidget {
  final ChatStore store;
  final AuthStore authStore;
  final ThemeStore themeStore;
  final VoiceStore voiceStore;
  const MainShellScreen({
    super.key,
    required this.store,
    required this.authStore,
    required this.themeStore,
    required this.voiceStore,
  });

  @override
  State<MainShellScreen> createState() => _MainShellScreenState();
}

class _MainShellScreenState extends State<MainShellScreen> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    final userId = widget.authStore.user?.id.toString() ?? '';

    final pages = [
      ChatScreen(
        store: widget.store,
        authStore: widget.authStore,
        themeStore: widget.themeStore,
        voiceStore: widget.voiceStore,
        hideShellDuplicates: true,
      ),
      WellbeingScreen(
        userId: userId,
        voiceStore: widget.voiceStore,
        authStore: widget.authStore,
        onStartAiConversation: (text) async {
          // без createNewChat() - не обрываем уже идущий разговор ради
          // нового, см. тот же фикс в chat_screen.dart::_chooseTest()
          await widget.store.sendMessage(text);
          if (mounted) setState(() => _index = 0);
        },
      ),
      ProfileScreen(authStore: widget.authStore),
      SleepMusicScreen(authStore: widget.authStore),
    ];

    return Scaffold(
      backgroundColor: const Color(0xFF0B0F1E),
      body: IndexedStack(index: _index, children: pages),
      bottomNavigationBar: _GlassBottomNav(
        index: _index,
        onTap: (i) => setState(() => _index = i),
      ),
    );
  }
}

class _GlassBottomNav extends StatelessWidget {
  final int index;
  final ValueChanged<int> onTap;
  const _GlassBottomNav({required this.index, required this.onTap});

  static const _items = [
    (icon: Icons.spa_rounded, label: 'Чат'),
    (icon: Icons.self_improvement_rounded, label: 'Самочувствие'),
    (icon: Icons.person_rounded, label: 'Профиль'),
    (icon: Icons.nightlight_rounded, label: 'Сон'),
  ];

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
        child: GlassPanel(
          opacity: 0.1,
          borderRadius: BorderRadius.circular(24),
          padding: EdgeInsets.zero,
          child: SizedBox(
            height: 62,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: List.generate(_items.length, (i) => _buildItem(i)),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildItem(int i) {
    final selected = i == index;
    final item = _items[i];
    return Expanded(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () => onTap(i),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
            padding: const EdgeInsets.symmetric(vertical: 6),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: selected
                  ? const LinearGradient(colors: [Color(0xFF6C5CE7), Color(0xFF00B4D8)])
                  : null,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  item.icon,
                  size: 22,
                  color: selected ? Colors.white : Colors.white.withValues(alpha: 0.5),
                ),
                const SizedBox(height: 2),
                Text(
                  item.label,
                  style: TextStyle(
                    fontSize: 10.5,
                    fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                    color: selected ? Colors.white : Colors.white.withValues(alpha: 0.5),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
