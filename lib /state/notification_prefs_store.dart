import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import '../services/notification_prefs_service.dart';

// синглтон - нужен в чат-сторе (для самого звука/вибрации на новое
// сообщение) и в экране настроек (для переключателей) одновременно,
// тот же приём, что и у ThemeStore
class NotificationPrefsStore extends ChangeNotifier {
  NotificationPrefsStore._internal();
  static final NotificationPrefsStore instance = NotificationPrefsStore._internal();

  final NotificationPrefsService _service = NotificationPrefsService();
  bool soundEnabled = true;
  bool vibrationEnabled = true;

  Future<void> load() async {
    soundEnabled = await _service.loadSoundEnabled();
    vibrationEnabled = await _service.loadVibrationEnabled();
    notifyListeners();
  }

  Future<void> setSoundEnabled(bool value) async {
    soundEnabled = value;
    notifyListeners();
    await _service.saveSoundEnabled(value);
  }

  Future<void> setVibrationEnabled(bool value) async {
    vibrationEnabled = value;
    notifyListeners();
    await _service.saveVibrationEnabled(value);
  }

  // вызывается при получении нового ответа ИИ (см. chat_store.dart) -
  // системный звук/клик, не файл ассета: у проекта нет собственного
  // звука уведомления, а выдумывать его самому было бы неверно.
  // HapticFeedback.lightImpact - лёгкая вибрация, не слишком навязчивая
  // для события "пришло сообщение"
  void notifyNewMessage() {
    if (soundEnabled) SystemSound.play(SystemSoundType.click);
    if (vibrationEnabled) HapticFeedback.lightImpact();
  }
}
