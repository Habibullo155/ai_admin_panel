import 'package:flutter/material.dart';

import 'screens/admin_shell_screen.dart';
import 'screens/auth_screen.dart';
import 'screens/lock_screen.dart';
import 'state/auth_store.dart';
import 'state/theme_store.dart';

/// Точка входа админ-приложения - НЕ содержит чат/голос/упражнения вообще,
/// сразу после входа ведёт в AdminShellScreen. Использует тот же бэкенд
/// (config.dart::AppConfig.backendUrl), тот же логин/пароль, что и обычное
/// приложение - это не отдельная система авторизации, только отдельная
/// сборка с другим набором экранов.
class AdminApp extends StatefulWidget {
  const AdminApp({super.key});

  @override
  State<AdminApp> createState() => _AdminAppState();
}

class _AdminAppState extends State<AdminApp> {
  final AuthStore _authStore = AuthStore();
  final ThemeStore _themeStore = ThemeStore.instance;

  @override
  void initState() {
    super.initState();
    _authStore.addListener(_onAuthChanged);
    _authStore.restoreSession();
    _themeStore.addListener(_onThemeChanged);
    _themeStore.load();
  }

  void _onThemeChanged() => setState(() {});
  void _onAuthChanged() => setState(() {});

  @override
  void dispose() {
    _authStore.removeListener(_onAuthChanged);
    _authStore.dispose();
    _themeStore.removeListener(_onThemeChanged);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AI Glass Chat — админ',
      debugShowCheckedModeBanner: false,
      themeMode: switch (_themeStore.mode) {
        AppThemeMode.light => ThemeMode.light,
        AppThemeMode.dark => ThemeMode.dark,
        AppThemeMode.system => ThemeMode.system,
      },
      theme: ThemeData.light(useMaterial3: true).copyWith(
        scaffoldBackgroundColor: const Color(0xFFF3F0FF),
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF6C5CE7), brightness: Brightness.light),
      ),
      darkTheme: ThemeData.dark(useMaterial3: true).copyWith(
        scaffoldBackgroundColor: const Color(0xFF0B0F1E),
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF6C5CE7), brightness: Brightness.dark),
      ),
      home: _buildHome(),
    );
  }

  Widget _buildHome() {
    switch (_authStore.status) {
      case AuthStatus.unknown:
      case AuthStatus.checking:
        return const _LoadingScreen();
      case AuthStatus.unauthenticated:
        return AuthScreen(store: _authStore);
      case AuthStatus.locked:
        return LockScreen(authStore: _authStore);
      case AuthStatus.authenticated:
        final user = _authStore.user;
        // проверка роли здесь, не только на бэкенде - обычный пользователь,
        // случайно (или намеренно) открывший это отдельное приложение, не
        // должен видеть даже пустой экран админки, только явный отказ.
        // Сами данные всё равно защищены на бэкенде (get_current_admin),
        // это дополнительный, а не единственный слой
        if (user == null || !user.isAdmin) return _NotAdminScreen(onLogout: _authStore.logout);
        return AdminShellScreen(authStore: _authStore);
    }
  }
}

class _LoadingScreen extends StatelessWidget {
  const _LoadingScreen();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Color(0xFF0B0F1E),
      body: Center(child: CircularProgressIndicator(color: Color(0xFF6C5CE7))),
    );
  }
}

class _NotAdminScreen extends StatelessWidget {
  final VoidCallback onLogout;
  const _NotAdminScreen({required this.onLogout});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B0F1E),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.block_rounded, color: Colors.white38, size: 40),
              const SizedBox(height: 12),
              const Text(
                'Это приложение только для администраторов',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 6),
              const Text(
                'У твоего аккаунта нет прав администратора.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white54, fontSize: 12.5),
              ),
              const SizedBox(height: 20),
              TextButton(onPressed: onLogout, child: const Text('Выйти')),
            ],
          ),
        ),
      ),
    );
  }
}
