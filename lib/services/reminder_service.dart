import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/data/latest_all.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

/// Ежедневное напоминание в момент, когда пользователь обычно дома —
/// НЕ живая генерация текста ИИ в момент срабатывания: у нас нет
/// серверной push-инфраструктуры (FCM/APNs с бэкендом), а фоновое
/// выполнение на iOS/Android слишком ограничено, чтобы надёжно успеть
/// обратиться к Ollama прямо в момент показа уведомления. Вместо этого —
/// заранее заданный, но разнообразный набор фраз, меняющийся по дням, а
/// не один и тот же текст каждый раз.
class ReminderService {
  static const _enabledKey = 'daily_reminder_enabled_v1';
  static const _hourKey = 'daily_reminder_hour_v1';
  static const _minuteKey = 'daily_reminder_minute_v1';
  static const _notificationId = 7001;

  final FlutterLocalNotificationsPlugin _plugin = FlutterLocalNotificationsPlugin();
  bool _initialized = false;

  static const _prompts = [
    'Как прошёл день? Если хочется поговорить — я здесь.',
    'Небольшая пауза — как ты сейчас, в целом?',
    'Если накопилось что-то, о чём хочется рассказать — самое время.',
    'Как настроение сегодня? Загляни, если нужно выговориться.',
    'Просто напоминаю, что можно зайти и поделиться, как прошёл день.',
  ];

  Future<void> _ensureInitialized() async {
    if (_initialized) return;
    tz_data.initializeTimeZones();
    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosInit = DarwinInitializationSettings();
    await _plugin.initialize(
      settings: const InitializationSettings(android: androidInit, iOS: iosInit),
    );
    _initialized = true;
  }

  Future<bool> isEnabled() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getBool(_enabledKey) ?? false;
    } catch (_) {
      return false;
    }
  }

  /// Час/минута в 24-часовом формате — по умолчанию 19:00, разумное
  /// "обычно уже дома" время, если пользователь ещё не настраивал своё.
  Future<(int, int)> getTime() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final hour = prefs.getInt(_hourKey) ?? 19;
      final minute = prefs.getInt(_minuteKey) ?? 0;
      return (hour, minute);
    } catch (_) {
      return (19, 0);
    }
  }

  /// Запрашивает разрешение на уведомления (обязательно на Android 13+ и
  /// iOS) и, если получено, планирует ежедневное напоминание на указанное
  /// время. Возвращает false, если разрешение не дали — тогда включать
  /// переключатель в настройках не имеет смысла.
  Future<bool> enable({required int hour, required int minute}) async {
    await _ensureInitialized();

    final androidPlugin = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    final iosPlugin = _plugin.resolvePlatformSpecificImplementation<
        IOSFlutterLocalNotificationsPlugin>();

    bool granted = true;
    if (androidPlugin != null) {
      granted = await androidPlugin.requestNotificationsPermission() ?? false;
    }
    if (iosPlugin != null) {
      granted = await iosPlugin.requestPermissions(alert: true, badge: true, sound: true) ?? false;
    }
    if (!granted) return false;

    await _scheduleDaily(hour: hour, minute: minute);

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_enabledKey, true);
      await prefs.setInt(_hourKey, hour);
      await prefs.setInt(_minuteKey, minute);
    } catch (_) {
      // настройка сохранится некорректно, но само уведомление уже
      // запланировано — не критично для этого разового случая
    }
    return true;
  }

  Future<void> disable() async {
    await _ensureInitialized();
    await _plugin.cancel(id: _notificationId);
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_enabledKey, false);
    } catch (_) {}
  }

  Future<void> _scheduleDaily({required int hour, required int minute}) async {
    final now = tz.TZDateTime.now(tz.local);
    var scheduled = tz.TZDateTime(tz.local, now.year, now.month, now.day, hour, minute);
    if (scheduled.isBefore(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }

    // разная фраза для разных дней года - не один и тот же текст каждый
    // раз, но и не выдуманная "генерация налету"
    final prompt = _prompts[now.day % _prompts.length];

    await _plugin.zonedSchedule(
      id: _notificationId,
      title: 'AI Glass Chat',
      body: prompt,
      scheduledDate: scheduled,
      notificationDetails: const NotificationDetails(
        android: AndroidNotificationDetails(
          'daily_reminder',
          'Ежедневные напоминания',
          channelDescription: 'Напоминание проверить, как дела, в выбранное время',
          importance: Importance.defaultImportance,
          priority: Priority.defaultPriority,
        ),
        iOS: DarwinNotificationDetails(),
      ),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      // uiLocalNotificationDateInterpretation убран из API начиная с
      // 19.0.0 (см. pubspec.yaml — пакет теперь на ^22.3.0) — параметр
      // был нужен только для iOS < 10, которые эта версия пакета уже не
      // поддерживает, так что просто не передаём его вообще.
      matchDateTimeComponents: DateTimeComponents.time, // повтор каждый день в это время
    );
  }
}
