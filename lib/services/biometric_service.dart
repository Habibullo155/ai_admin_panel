import 'package:local_auth/local_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Вход по биометрии (Face ID/отпечаток) — НЕ замена пароля, а дополнительный,
/// необязательный слой поверх уже сохранённой сессии (токен как хранился в
/// flutter_secure_storage, так и хранится).
class BiometricService {
  static const _key = 'biometric_login_enabled_v1';
  final LocalAuthentication _auth = LocalAuthentication();

  /// Есть ли на устройстве вообще работающая биометрия (оборудование +
  /// хоть один отпечаток/лицо настроены в самой ОС) — если нет, не имеет
  /// смысла предлагать переключатель в настройках.
  Future<bool> isDeviceSupported() async {
    try {
      final canCheck = await _auth.canCheckBiometrics;
      final deviceSupported = await _auth.isDeviceSupported();
      return canCheck && deviceSupported;
    } catch (_) {
      return false;
    }
  }

  /// biometricOnly: false
  Future<bool> authenticate({String reason = 'Подтверди личность, чтобы войти'}) async {
    try {
      return await _auth.authenticate(
        localizedReason: reason,
        biometricOnly: false,
        persistAcrossBackgrounding: true,
      );
    } catch (_) {
      return false;
    }
  }

  Future<bool> isEnabled() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getBool(_key) ?? false;
    } catch (_) {
      return false;
    }
  }

  Future<void> setEnabled(bool enabled) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_key, enabled);
    } catch (_) {
      // Не удалось сохранить — переключатель в UI просто не отразит
      // изменение, ничего критичного не сломается.
    }
  }
}
