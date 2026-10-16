import 'package:local_auth/local_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Вход по биометрии (Face ID/отпечаток) — НЕ замена пароля, а
/// дополнительный, необязательный слой поверх уже сохранённой сессии
/// (токен как хранился в flutter_secure_storage, так и хранится).
/// Биометрия просто решает, показывать ли уже сохранённую сессию сразу,
/// или сначала попросить подтверждение — сам токен биометрия не создаёт
/// и не видит, это чисто локальная проверка через ОС (Keychain/Keystore),
/// приложение получает только true/false.
///
/// Честная граница этой защиты: она реально не даёт открыть приложение
/// без Face ID/отпечатка при обычном физическом доступе к
/// разблокированному телефону (LockScreen не рендерит основной UI, пока
/// authenticate() не вернёт true — токен из памяти этого экрана не
/// достать через обычный UI). Но на уже взломанном (root/jailbreak)
/// устройстве это не защита от кражи токена: сам ключ в
/// flutter_secure_storage НЕ привязан к биометрии на уровне ОС (это
/// потребовало бы нативного, платформенно-специфичного кода поверх
/// стандартного API - iOS kSecAccessControlBiometryCurrentSet или
/// Android KeyStore setUserAuthenticationRequired, которые ни этот
/// пакет, ни flutter_secure_storage не предоставляют "из коробки") -
/// он остаётся доступен любому коду того же процесса без повторного
/// запроса биометрии, а на рутованном устройстве память процесса
/// доступна и извне. Это ограничение выбранного стека (local_auth +
/// flutter_secure_storage без нативных плагинов под каждую платформу),
/// не недосмотр в реализации ниже.
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

  /// biometricOnly: false — если Face ID/отпечаток несколько раз не
  /// сработал, ОС сама предложит PIN/графический ключ устройства как
  /// запасной вариант (стандартное поведение большинства приложений, не
  /// наше решение поверх ОС).
  ///
  /// local_auth v3.0.0: AuthenticationOptions убран - теперь отдельные
  /// именованные параметры прямо у authenticate(), не обёрнуты в общий
  /// объект. stickyAuth переименован в persistAcrossBackgrounding
  /// (то же самое поведение, только новое имя). useErrorDialogs больше
  /// нет вообще, без замены - мы его и не использовали.
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
