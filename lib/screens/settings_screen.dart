import 'package:flutter/material.dart';

import '../services/reminder_service.dart';
import '../state/auth_store.dart';
import '../state/chat_store.dart';
import '../state/notification_prefs_store.dart';
import '../state/performance_mode_store.dart';
import '../state/theme_store.dart';
import '../state/voice_store.dart';
import '../theme/app_text_color.dart';
import '../utils/auth_navigation.dart';
import '../widgets/app_background.dart';
import '../widgets/glass_panel.dart';
import '../widgets/theme_variant_swatch.dart';
import 'voice_settings_screen.dart';

/// Адрес сервера здесь только отображается — редактировать его в
/// приложении больше нельзя, он задаётся один раз при сборке через
/// --dart-define=BACKEND_URL=... (см. lib/config.dart). Это осознанное
/// решение: рядовой пользователь не должен иметь возможность
/// перенаправить приложение на произвольный сервер.
class SettingsScreen extends StatefulWidget {
  final AuthStore authStore;
  final ChatStore chatStore;
  final ThemeStore themeStore;
  final VoiceStore voiceStore;
  const SettingsScreen({
    super.key,
    required this.authStore,
    required this.chatStore,
    required this.themeStore,
    required this.voiceStore,
  });

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _biometricSupported = false;
  bool _biometricEnabled = false;
  bool _isBiometricBusy = false;
  String? _biometricError;

  final _reminderService = ReminderService();
  bool _reminderEnabled = false;
  int _reminderHour = 19;
  int _reminderMinute = 0;
  bool _isReminderBusy = false;
  String? _reminderError;

  @override
  void initState() {
    super.initState();
    _loadBiometricState();
    _loadReminderState();
  }

  Future<void> _loadReminderState() async {
    final enabled = await _reminderService.isEnabled();
    final (hour, minute) = await _reminderService.getTime();
    if (mounted) {
      setState(() {
        _reminderEnabled = enabled;
        _reminderHour = hour;
        _reminderMinute = minute;
      });
    }
  }

  Future<void> _toggleReminder(bool value) async {
    setState(() {
      _isReminderBusy = true;
      _reminderError = null;
    });
    if (value) {
      final granted = await _reminderService.enable(hour: _reminderHour, minute: _reminderMinute);
      if (mounted) {
        setState(() {
          _isReminderBusy = false;
          if (granted) {
            _reminderEnabled = true;
          } else {
            _reminderError = 'Нет разрешения на уведомления — включи их в настройках устройства для этого приложения.';
          }
        });
      }
    } else {
      await _reminderService.disable();
      if (mounted) {
        setState(() {
          _isReminderBusy = false;
          _reminderEnabled = false;
        });
      }
    }
  }

  Future<void> _pickReminderTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: _reminderHour, minute: _reminderMinute),
    );
    if (picked == null) return;
    setState(() {
      _reminderHour = picked.hour;
      _reminderMinute = picked.minute;
    });
    // если уже включено — перепланируем на новое время сразу, не ждём
    // отдельного действия пользователя
    if (_reminderEnabled) {
      await _reminderService.enable(hour: _reminderHour, minute: _reminderMinute);
    }
  }

  Future<void> _loadBiometricState() async {
    final supported = await widget.authStore.isBiometricDeviceSupported();
    final enabled = await widget.authStore.isBiometricEnabled();
    if (mounted) {
      setState(() {
        _biometricSupported = supported;
        _biometricEnabled = enabled;
      });
    }
  }

  Future<void> _toggleBiometric(bool value) async {
    setState(() {
      _isBiometricBusy = true;
      _biometricError = null;
    });
    if (value) {
      final error = await widget.authStore.enableBiometric();
      if (mounted) {
        setState(() {
          _isBiometricBusy = false;
          if (error != null) {
            _biometricError = error;
          } else {
            _biometricEnabled = true;
          }
        });
      }
    } else {
      await widget.authStore.disableBiometric();
      if (mounted) {
        setState(() {
          _isBiometricBusy = false;
          _biometricEnabled = false;
        });
      }
    }
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
                      'Настройки',
                      style: TextStyle(color: context.onSurface, fontSize: 18, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Center(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 480),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _sectionLabel('ОФОРМЛЕНИЕ'),
                          AnimatedBuilder(
                            animation: widget.themeStore,
                            builder: (context, _) {
                              return GlassPanel(
                                opacity: 0.08,
                                borderRadius: BorderRadius.circular(18),
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Тема', style: TextStyle(color: context.onSurface)),
                                    const SizedBox(height: 12),
                                    SegmentedButton<AppThemeMode>(
                                      segments: const [
                                        ButtonSegment(
                                          value: AppThemeMode.dark,
                                          icon: Icon(Icons.dark_mode_rounded, size: 17),
                                          label: Text('Тёмная'),
                                        ),
                                        ButtonSegment(
                                          value: AppThemeMode.light,
                                          icon: Icon(Icons.light_mode_rounded, size: 17),
                                          label: Text('Светлая'),
                                        ),
                                        ButtonSegment(
                                          value: AppThemeMode.system,
                                          icon: Icon(Icons.brightness_auto_rounded, size: 17),
                                          label: Text('Системная'),
                                        ),
                                      ],
                                      selected: {widget.themeStore.mode},
                                      onSelectionChanged: (selection) => widget.themeStore.setMode(selection.first),
                                      style: SegmentedButton.styleFrom(
                                        selectedBackgroundColor: const Color(0xFF6C5CE7),
                                        selectedForegroundColor: Colors.white,
                                      ),
                                    ),
                                    Divider(color: context.borderSubtle, height: 24),
                                    Text('Цвет фона', style: TextStyle(color: context.onSurface)),
                                    const SizedBox(height: 12),
                                    Wrap(
                                      spacing: 12,
                                      runSpacing: 12,
                                      children: BackgroundVariant.values
                                          .map((v) => ThemeVariantSwatch(
                                                variant: v,
                                                selected: widget.themeStore.variant == v,
                                                onTap: () => widget.themeStore.setVariant(v),
                                              ))
                                          .toList(),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                          const SizedBox(height: 24),
                          _sectionLabel('ПРОИЗВОДИТЕЛЬНОСТЬ'),
                          AnimatedBuilder(
                            animation: PerformanceModeStore.instance,
                            builder: (context, _) {
                              return GlassPanel(
                                opacity: 0.08,
                                borderRadius: BorderRadius.circular(18),
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Icon(Icons.battery_saver_outlined, color: context.onSurfaceFaded(0.7), size: 18),
                                        const SizedBox(width: 10),
                                        Expanded(
                                          child: Text('Экономный режим', style: TextStyle(color: context.onSurface)),
                                        ),
                                        Switch(
                                          value: PerformanceModeStore.instance.enabled,
                                          activeThumbColor: const Color(0xFF6C5CE7),
                                          onChanged: (v) => PerformanceModeStore.instance.setEnabled(v),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      'Отключает анимированный фон и размытие "стекла" по всему приложению. '
                                      'Стоит включить, если телефон слабый, тормозит или перегревается — '
                                      'на большинстве устройств в этом нет необходимости.',
                                      style: TextStyle(color: context.onSurfaceFaded(0.5), fontSize: 12, height: 1.4),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                          const SizedBox(height: 24),
                          _sectionLabel('УВЕДОМЛЕНИЯ'),
                          AnimatedBuilder(
                            animation: NotificationPrefsStore.instance,
                            builder: (context, _) {
                              final prefs = NotificationPrefsStore.instance;
                              return GlassPanel(
                                opacity: 0.08,
                                borderRadius: BorderRadius.circular(18),
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Icon(Icons.volume_up_rounded, color: context.onSurfaceFaded(0.7), size: 18),
                                        const SizedBox(width: 10),
                                        Expanded(
                                          child: Text('Звук на новое сообщение', style: TextStyle(color: context.onSurface)),
                                        ),
                                        Switch(
                                          value: prefs.soundEnabled,
                                          activeThumbColor: const Color(0xFF6C5CE7),
                                          onChanged: (v) => prefs.setSoundEnabled(v),
                                        ),
                                      ],
                                    ),
                                    Divider(color: context.borderSubtle, height: 24),
                                    Row(
                                      children: [
                                        Icon(Icons.vibration_rounded, color: context.onSurfaceFaded(0.7), size: 18),
                                        const SizedBox(width: 10),
                                        Expanded(
                                          child: Text('Вибрация на новое сообщение', style: TextStyle(color: context.onSurface)),
                                        ),
                                        Switch(
                                          value: prefs.vibrationEnabled,
                                          activeThumbColor: const Color(0xFF6C5CE7),
                                          onChanged: (v) => prefs.setVibrationEnabled(v),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                          const SizedBox(height: 24),
                          _sectionLabel('ГОЛОС'),
                          AnimatedBuilder(
                            animation: widget.voiceStore,
                            builder: (context, _) {
                              final voice = widget.voiceStore;
                              return GlassPanel(
                                opacity: 0.08,
                                borderRadius: BorderRadius.circular(18),
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                                child: Column(
                                  children: [
                                    Row(
                                      children: [
                                        Icon(
                                          voice.settings.voiceUiEnabled ? Icons.record_voice_over_rounded : Icons.voice_over_off_rounded,
                                          color: context.onSurfaceFaded(0.7),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Text('Голосовые кнопки в чате', style: TextStyle(color: context.onSurface, fontSize: 13.5)),
                                        ),
                                        Switch(
                                          value: voice.settings.voiceUiEnabled,
                                          activeThumbColor: const Color(0xFF6C5CE7),
                                          onChanged: (v) => voice.updateSettings(voice.settings.copyWith(voiceUiEnabled: v)),
                                        ),
                                      ],
                                    ),
                                    Divider(color: context.borderSubtle, height: 20),
                                    Material(
                                      color: Colors.transparent,
                                      child: InkWell(
                                        borderRadius: BorderRadius.circular(12),
                                        onTap: () => Navigator.of(context).push(
                                          MaterialPageRoute(builder: (_) => VoiceSettingsScreen(voiceStore: widget.voiceStore)),
                                        ),
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(vertical: 8),
                                          child: Row(
                                            children: [
                                              Expanded(
                                                child: Text(
                                                  'Выбор голоса и распознавание речи',
                                                  style: TextStyle(color: context.onSurfaceFaded(0.75), fontSize: 13),
                                                ),
                                              ),
                                              Icon(Icons.chevron_right_rounded, color: context.onSurfaceFaded(0.4)),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                          const SizedBox(height: 24),
                          _sectionLabel('БЕЗОПАСНОСТЬ'),
                          if (_biometricSupported)
                            GlassPanel(
                              opacity: 0.08,
                              borderRadius: BorderRadius.circular(18),
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Row(
                                    children: [
                                      Icon(
                                        _biometricEnabled ? Icons.fingerprint_rounded : Icons.fingerprint_outlined,
                                        color: context.onSurfaceFaded(0.7),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Text('Вход по биометрии', style: TextStyle(color: context.onSurface, fontSize: 13.5)),
                                      ),
                                      if (_isBiometricBusy)
                                        const SizedBox(
                                          width: 20,
                                          height: 20,
                                          child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF6C5CE7)),
                                        )
                                      else
                                        Switch(
                                          value: _biometricEnabled,
                                          activeThumbColor: const Color(0xFF6C5CE7),
                                          onChanged: _toggleBiometric,
                                        ),
                                    ],
                                  ),
                                  if (_biometricError != null)
                                    Padding(
                                      padding: const EdgeInsets.only(bottom: 10),
                                      child: Align(
                                        alignment: Alignment.centerLeft,
                                        child: Text(
                                          _biometricError!,
                                          style: const TextStyle(color: Color(0xFFFFB4B4), fontSize: 12),
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            )
                          else
                            GlassPanel(
                              opacity: 0.06,
                              borderRadius: BorderRadius.circular(18),
                              padding: const EdgeInsets.all(16),
                              child: Text(
                                'На этом устройстве не настроена биометрия (Face ID/отпечаток) — включи её в настройках самого устройства, если хочешь использовать здесь.',
                                style: TextStyle(color: context.onSurfaceFaded(0.4), fontSize: 12.5),
                              ),
                            ),
                          const SizedBox(height: 24),
                          _sectionLabel('НАПОМИНАНИЯ'),
                          Text(
                            'Раз в день, в выбранное время (например, когда ты обычно уже дома) — просто предложит заглянуть, если захочется поговорить.',
                            style: TextStyle(color: context.onSurfaceFaded(0.4), fontSize: 12),
                          ),
                          const SizedBox(height: 10),
                          GlassPanel(
                            opacity: 0.08,
                            borderRadius: BorderRadius.circular(18),
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Row(
                                  children: [
                                    Icon(
                                      _reminderEnabled ? Icons.notifications_active_rounded : Icons.notifications_off_outlined,
                                      color: context.onSurfaceFaded(0.7),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Text('Ежедневное напоминание', style: TextStyle(color: context.onSurface, fontSize: 13.5)),
                                    ),
                                    if (_isReminderBusy)
                                      const SizedBox(
                                        width: 20,
                                        height: 20,
                                        child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF6C5CE7)),
                                      )
                                    else
                                      Switch(
                                        value: _reminderEnabled,
                                        activeThumbColor: const Color(0xFF6C5CE7),
                                        onChanged: _toggleReminder,
                                      ),
                                  ],
                                ),
                                if (_reminderEnabled) ...[
                                  Divider(color: context.borderSubtle, height: 20),
                                  Material(
                                    color: Colors.transparent,
                                    child: InkWell(
                                      borderRadius: BorderRadius.circular(12),
                                      onTap: _pickReminderTime,
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(vertical: 8),
                                        child: Row(
                                          children: [
                                            Expanded(
                                              child: Text('Время', style: TextStyle(color: context.onSurfaceFaded(0.75), fontSize: 13)),
                                            ),
                                            Text(
                                              TimeOfDay(hour: _reminderHour, minute: _reminderMinute).format(context),
                                              style: const TextStyle(color: Color(0xFF00E6A0), fontWeight: FontWeight.w600),
                                            ),
                                            const SizedBox(width: 6),
                                            Icon(Icons.chevron_right_rounded, color: context.onSurfaceFaded(0.4)),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                                if (_reminderError != null)
                                  Padding(
                                    padding: const EdgeInsets.only(bottom: 10),
                                    child: Align(
                                      alignment: Alignment.centerLeft,
                                      child: Text(
                                        _reminderError!,
                                        style: const TextStyle(color: Color(0xFFFFB4B4), fontSize: 12),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 24),
                          _sectionLabel('АККАУНТ'),
                          GlassPanel(
                            opacity: 0.08,
                            borderRadius: BorderRadius.circular(18),
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                borderRadius: BorderRadius.circular(18),
                                onTap: () => confirmAndLogout(context, widget.authStore),
                                child: Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Row(
                                    children: [
                                      Icon(Icons.logout_rounded, color: context.onSurfaceFaded(0.7)),
                                      const SizedBox(width: 12),
                                      Text('Выйти из аккаунта', style: TextStyle(color: context.onSurface)),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),
                          _sectionLabel('О ПРИЛОЖЕНИИ'),
                          GlassPanel(
                            opacity: 0.08,
                            borderRadius: BorderRadius.circular(18),
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('AI Glass Chat', style: TextStyle(color: context.onSurface, fontWeight: FontWeight.w600)),
                                const SizedBox(height: 4),
                                Text('Версия 1.0.0', style: TextStyle(color: context.onSurfaceFaded(0.4), fontSize: 12.5)),
                                const SizedBox(height: 8),
                                Text(
                                  'Модель по умолчанию: gemma4:e2b через локальный Ollama.',
                                  style: TextStyle(color: context.onSurfaceFaded(0.5), fontSize: 12.5),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 24),
                          _sectionLabel('ОПАСНАЯ ЗОНА'),
                          GlassPanel(
                            opacity: 0.08,
                            borderRadius: BorderRadius.circular(18),
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                borderRadius: BorderRadius.circular(18),
                                onTap: () => _showDeleteAccountDialog(context, widget.authStore),
                                child: const Padding(
                                  padding: EdgeInsets.all(16),
                                  child: Row(
                                    children: [
                                      Icon(Icons.delete_forever_rounded, color: Color(0xFFFF6B6B)),
                                      SizedBox(width: 12),
                                      Text(
                                        'Удалить аккаунт',
                                        style: TextStyle(color: Color(0xFFFFB4B4), fontWeight: FontWeight.w500),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
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

  Widget _sectionLabel(String text) => Padding(
        padding: const EdgeInsets.only(bottom: 8, left: 4),
        child: Text(
          text,
          style: TextStyle(
            color: context.onSurfaceFaded(0.4),
            fontSize: 11,
            letterSpacing: 1.2,
            fontWeight: FontWeight.w600,
          ),
        ),
      );

  Future<void> _showDeleteAccountDialog(BuildContext context, AuthStore authStore) async {
    await showDialog(
      context: context,
      builder: (context) => _DeleteAccountDialog(authStore: widget.authStore),
    );
  }
}

/// Отдельный StatefulWidget для диалога — нужно локальное состояние (поле
/// пароля, текст ошибки), а сам SettingsScreen остаётся StatelessWidget.
class _DeleteAccountDialog extends StatefulWidget {
  final AuthStore authStore;
  const _DeleteAccountDialog({required this.authStore});

  @override
  State<_DeleteAccountDialog> createState() => _DeleteAccountDialogState();
}

class _DeleteAccountDialogState extends State<_DeleteAccountDialog> {
  final _passwordController = TextEditingController();
  bool _isBusy = false;
  String? _error;

  @override
  void dispose() {
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _confirmDelete() async {
    final password = _passwordController.text;
    if (password.isEmpty) return;

    setState(() {
      _isBusy = true;
      _error = null;
    });

    final error = await widget.authStore.deleteAccount(password);

    if (!mounted) return;

    if (error != null) {
      setState(() {
        _isBusy = false;
        _error = error;
      });
      return;
    }

    // Аккаунт удалён — закрываем диалог И возвращаемся на корень стека
    // навигации (тот же приём, что и в lib/utils/auth_navigation.dart для
    // обычного выхода): иначе экран настроек, с которого запускалось
    // удаление, так и остался бы виден поверх уже изменившегося состояния
    // "не авторизован" — просто закрыть диалог для этого недостаточно.
    Navigator.of(context).pop();
    Navigator.of(context).popUntil((route) => route.isFirst);
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: GlassPanel(
        opacity: 0.18,
        borderRadius: BorderRadius.circular(20),
        padding: const EdgeInsets.all(20),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 380),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Удалить аккаунт?',
                style: TextStyle(color: context.onSurface, fontSize: 17, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              Text(
                'Это необратимо: аккаунт, история обращений в поддержку и '
                'статистика использования будут удалены полностью. История '
                'переписки на этом устройстве останется — она никогда не '
                'хранилась на сервере, и её можно удалить отдельно.',
                style: TextStyle(color: context.onSurfaceFaded(0.6), fontSize: 13, height: 1.45),
              ),
              const SizedBox(height: 16),
              Text(
                'Подтверди паролем',
                style: TextStyle(color: context.onSurfaceFaded(0.5), fontSize: 12),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _passwordController,
                obscureText: true,
                autofocus: true,
                onSubmitted: (_) => _isBusy ? null : _confirmDelete(),
                style: TextStyle(color: context.onSurface),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: context.onSurfaceFaded(0.08),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  hintText: 'Пароль',
                  hintStyle: TextStyle(color: context.onSurfaceFaded(0.3)),
                ),
              ),
              if (_error != null) ...[
                const SizedBox(height: 10),
                Text(_error!, style: const TextStyle(color: Color(0xFFFFB4B4), fontSize: 13)),
              ],
              const SizedBox(height: 18),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: _isBusy ? null : () => Navigator.of(context).pop(),
                    child: Text('Отмена', style: TextStyle(color: context.onSurfaceFaded(0.6))),
                  ),
                  const SizedBox(width: 8),
                  FilledButton(
                    style: FilledButton.styleFrom(backgroundColor: const Color(0xFFFF6B6B)),
                    onPressed: _isBusy ? null : _confirmDelete,
                    child: _isBusy
                        ? SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2, color: context.onSurface),
                          )
                        : const Text('Удалить навсегда'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
