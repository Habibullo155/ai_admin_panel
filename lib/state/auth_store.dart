import 'dart:async';

import 'package:flutter/foundation.dart';

import '../config.dart';
import '../models/app_user.dart';
import '../services/biometric_service.dart';
import '../services/auth_service.dart' as auth_svc;

// locked - токен уже прочитан (сессия есть), но биометрия ещё не подтверждена в
// этом запуске.
enum AuthStatus { unknown, checking, authenticated, unauthenticated, locked, twoFactorRequired }

class AuthStore extends ChangeNotifier {
  final auth_svc.AuthService _authService = auth_svc.AuthService();
  final BiometricService _biometricService = BiometricService();

  AuthStatus status = AuthStatus.unknown;
  AppUser? user;
  String? token;
  String? lastError;
  bool isBusy = false;
  String? _pendingToken; // токен, ожидающий подтверждения биометрией
  String? _pendingTwoFactorToken; // ожидает подтверждения TOTP/резервным кодом (см. AuthStatus.twoFactorRequired)

  // только из --dart-define=BACKEND_URL=..., не редактируется в приложении -
  // рядовой юзер не должен мочь перенаправить приложение на чужой сервер
  final String baseUrl = AppConfig.backendUrl;

  Future<bool> isBiometricDeviceSupported() => _biometricService.isDeviceSupported();
  Future<bool> isBiometricEnabled() => _biometricService.isEnabled();

  // сначала проверяет, что подтверждение реально проходит, потом
  // сохраняет флаг - не запираем настройкой, которая не работает на
  // устройстве. null при успехе, иначе текст ошибки
  Future<String?> enableBiometric() async {
    final supported = await _biometricService.isDeviceSupported();
    if (!supported) {
      return 'На этом устройстве не настроена биометрия (Face ID/отпечаток) — сначала включи её в настройках самого устройства.';
    }
    final confirmed = await _biometricService.authenticate(
      reason: 'Подтверди, чтобы включить вход по биометрии',
    );
    if (!confirmed) return 'Не удалось подтвердить — попробуй ещё раз.';
    await _biometricService.setEnabled(true);
    return null;
  }

  Future<void> disableBiometric() => _biometricService.setEnabled(false);

  // проверяет сохранённый токен на сервере (мог истечь/быть отозван).
  // С включённой биометрией сначала уходим в locked
  Future<void> restoreSession() async {
    status = AuthStatus.checking;
    notifyListeners();

    final storedToken = await _authService.readStoredToken();
    if (storedToken == null) {
      status = AuthStatus.unauthenticated;
      notifyListeners();
      return;
    }

    if (await _biometricService.isEnabled()) {
      _pendingToken = storedToken;
      status = AuthStatus.locked;
      notifyListeners();
      return;
    }

    await _finishRestoringSession(storedToken);
  }

  Future<void> _finishRestoringSession(String storedToken) async {
    final freshUser = await _authService.fetchMe(baseUrl: baseUrl, token: storedToken);
    if (freshUser == null) {
      // истёк, недействителен или сервер недоступен - в обоих случаях
      // просим войти заново, безопаснее, чем делать вид, что всё ок
      await _authService.clearToken();
      status = AuthStatus.unauthenticated;
    } else {
      token = storedToken;
      user = freshUser;
      status = AuthStatus.authenticated;
    }
    notifyListeners();
  }

  // false, если биометрия не подтверждена - юзер остаётся на locked,
  // может попробовать снова
  Future<bool> unlockWithBiometrics() async {
    final pending = _pendingToken;
    if (pending == null) return false;
    final ok = await _biometricService.authenticate();
    if (!ok) return false;
    await _finishRestoringSession(pending);
    _pendingToken = null;
    return true;
  }

  // сессия не сбрасывается, токен остаётся - просто уходим на обычный
  // экран входа поверх него
  void continueWithoutBiometrics() {
    _pendingToken = null;
    status = AuthStatus.unauthenticated;
    notifyListeners();
  }

  Future<bool> register(String email, String password) =>
      _attempt(() => _authService.register(baseUrl: baseUrl, email: email, password: password));

  // Возвращает true и переводит в authenticated только если 2FA не
  // потребовалась
  Future<bool> login(String email, String password) async {
    isBusy = true;
    lastError = null;
    notifyListeners();
    try {
      final outcome = await _authService.login(baseUrl: baseUrl, email: email, password: password);
      if (outcome.requiresTwoFactor) {
        _pendingTwoFactorToken = outcome.pendingToken;
        status = AuthStatus.twoFactorRequired;
        return false;
      }
      final result = outcome.result!;
      token = result.token;
      user = result.user;
      status = AuthStatus.authenticated;
      return true;
    } on auth_svc.AuthException catch (e) {
      lastError = e.message;
      return false;
    } catch (e) {
      lastError = 'Непредвиденная ошибка: $e';
      return false;
    } finally {
      isBusy = false;
      notifyListeners();
    }
  }

  // Второй шаг входа при twoFactorRequired - код из аутентификатора
  // (6 цифр) или резервный код. null при успехе, иначе текст ошибки.
  Future<String?> submitTwoFactorCode(String code) async {
    final pending = _pendingTwoFactorToken;
    if (pending == null) return 'Сессия не найдена. Войди заново.';

    isBusy = true;
    lastError = null;
    notifyListeners();
    try {
      final result = await _authService.verifyLoginTwoFactor(baseUrl: baseUrl, pendingToken: pending, code: code);
      token = result.token;
      user = result.user;
      status = AuthStatus.authenticated;
      _pendingTwoFactorToken = null;
      return null;
    } on auth_svc.AuthException catch (e) {
      return e.message;
    } catch (e) {
      return 'Непредвиденная ошибка: $e';
    } finally {
      isBusy = false;
      notifyListeners();
    }
  }

  // Отмена ввода 2FA-кода - возвращает на обычный экран входа
  void cancelTwoFactorLogin() {
    _pendingTwoFactorToken = null;
    status = AuthStatus.unauthenticated;
    notifyListeners();
  }

  // --- Управление 2FA для уже вошедшего пользователя (настройки) ---

  Future<auth_svc.TwoFactorSetup?> startTwoFactorSetup() async {
    final currentToken = token;
    if (currentToken == null) return null;
    try {
      return await _authService.setupTwoFactor(baseUrl: baseUrl, token: currentToken);
    } on auth_svc.AuthException catch (e) {
      lastError = e.message;
      notifyListeners();
      return null;
    } catch (e) {
      lastError = 'Непредвиденная ошибка: $e';
      notifyListeners();
      return null;
    }
  }

  // Список из 10 резервных кодов при успехе (показать РОВНО ОДИН РАЗ),
  // null при ошибке (текст - в lastError)
  Future<List<String>?> confirmTwoFactorSetup(String code) async {
    final currentToken = token;
    if (currentToken == null) return null;
    isBusy = true;
    lastError = null;
    notifyListeners();
    try {
      final codes = await _authService.confirmTwoFactor(baseUrl: baseUrl, token: currentToken, code: code);
      if (user != null) user = user!.copyWithTotpEnabled(true);
      return codes;
    } on auth_svc.AuthException catch (e) {
      lastError = e.message;
      return null;
    } catch (e) {
      lastError = 'Непредвиденная ошибка: $e';
      return null;
    } finally {
      isBusy = false;
      notifyListeners();
    }
  }

  // null при успехе, иначе текст ошибки
  Future<String?> disableTwoFactor({required String password, required String code}) async {
    final currentToken = token;
    if (currentToken == null) return 'Сессия не найдена. Войди заново.';
    isBusy = true;
    notifyListeners();
    try {
      await _authService.disableTwoFactor(baseUrl: baseUrl, token: currentToken, password: password, code: code);
      if (user != null) user = user!.copyWithTotpEnabled(false);
      return null;
    } on auth_svc.AuthException catch (e) {
      return e.message;
    } catch (e) {
      return 'Непредвиденная ошибка: $e';
    } finally {
      isBusy = false;
      notifyListeners();
    }
  }

  // не через _attempt() - тот выставляет token/user/status при успехе,
  // здесь ничего из этого не происходит (только письмо уходит либо
  // пароль меняется), нужен пароль сам должен ещё раз войти обычным login
  Future<bool> forgotPassword(String email) async {
    isBusy = true;
    lastError = null;
    notifyListeners();
    try {
      await _authService.forgotPassword(baseUrl: baseUrl, email: email);
      return true;
    } on auth_svc.AuthException catch (e) {
      lastError = e.message;
      return false;
    } catch (e) {
      lastError = 'Непредвиденная ошибка: $e';
      return false;
    } finally {
      isBusy = false;
      notifyListeners();
    }
  }

  Future<bool> resetPassword({required String token, required String newPassword}) async {
    isBusy = true;
    lastError = null;
    notifyListeners();
    try {
      await _authService.resetPassword(baseUrl: baseUrl, token: token, newPassword: newPassword);
      return true;
    } on auth_svc.AuthException catch (e) {
      lastError = e.message;
      return false;
    } catch (e) {
      lastError = 'Непредвиденная ошибка: $e';
      return false;
    } finally {
      isBusy = false;
      notifyListeners();
    }
  }

  Future<bool> verifyEmail(String code) async {
    isBusy = true;
    lastError = null;
    notifyListeners();
    try {
      // сервер возвращает свежего пользователя с is_email_verified=true -
      // обновляем поле user сразу здесь, иначе баннер "подтвердите почту"
      // не пропал бы до следующего /me или перезапуска приложения
      user = await _authService.verifyEmail(baseUrl: baseUrl, token: code);
      return true;
    } on auth_svc.AuthException catch (e) {
      lastError = e.message;
      return false;
    } catch (e) {
      lastError = 'Непредвиденная ошибка: $e';
      return false;
    } finally {
      isBusy = false;
      notifyListeners();
    }
  }

  Future<bool> resendVerification() async {
    final currentToken = token;
    if (currentToken == null) return false;
    isBusy = true;
    lastError = null;
    notifyListeners();
    try {
      await _authService.resendVerification(baseUrl: baseUrl, token: currentToken);
      return true;
    } on auth_svc.AuthException catch (e) {
      lastError = e.message;
      return false;
    } catch (e) {
      lastError = 'Непредвиденная ошибка: $e';
      return false;
    } finally {
      isBusy = false;
      notifyListeners();
    }
  }

  Future<bool> _attempt(Future<auth_svc.AuthResult> Function() action) async {
    isBusy = true;
    lastError = null;
    notifyListeners();
    try {
      final result = await action();
      token = result.token;
      user = result.user;
      status = AuthStatus.authenticated;
      return true;
    } on auth_svc.AuthException catch (e) {
      lastError = e.message;
      return false;
    } catch (e) {
      lastError = 'Непредвиденная ошибка: $e';
      return false;
    } finally {
      isBusy = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    await _authService.clearToken();
    token = null;
    user = null;
    status = AuthStatus.unauthenticated;
    notifyListeners();
  }

  // необратимо, требует пароль. null при успехе, иначе текст ошибки для UI
  Future<String?> deleteAccount(String password) async {
    final currentToken = token;
    if (currentToken == null) return 'Сессия не найдена. Войди заново.';

    isBusy = true;
    notifyListeners();
    try {
      await _authService.deleteAccount(baseUrl: baseUrl, token: currentToken, password: password);
      token = null;
      user = null;
      status = AuthStatus.unauthenticated;
      return null;
    } on auth_svc.AuthException catch (e) {
      return e.message;
    } catch (e) {
      return 'Непредвиденная ошибка: $e';
    } finally {
      isBusy = false;
      notifyListeners();
    }
  }

  // подменяет user свежими данными сразу после сохранения, отдельно
  // перезагружать профиль не нужно
  Future<String?> updateProfile({
    String? fullName,
    bool clearFullName = false,
    DateTime? birthDate,
    bool clearBirthDate = false,
    String? hobbies,
    bool clearHobbies = false,
    String? emergencyContact,
    bool clearEmergencyContact = false,
    String? avatarBase64,
    bool clearAvatar = false,
  }) async {
    final currentToken = token;
    if (currentToken == null) return 'Сессия не найдена. Войди заново.';

    final fields = <String, dynamic>{};
    if (fullName != null) fields['full_name'] = fullName;
    if (clearFullName) fields['full_name'] = null;
    // только дата (YYYY-MM-DD) - backend ждёт date, не datetime с временем
    if (birthDate != null) {
      fields['birth_date'] =
          '${birthDate.year.toString().padLeft(4, '0')}-${birthDate.month.toString().padLeft(2, '0')}-${birthDate.day.toString().padLeft(2, '0')}';
    }
    if (clearBirthDate) fields['birth_date'] = null;
    if (hobbies != null) fields['hobbies'] = hobbies;
    if (clearHobbies) fields['hobbies'] = null;
    if (emergencyContact != null) fields['emergency_contact'] = emergencyContact;
    if (clearEmergencyContact) fields['emergency_contact'] = null;
    if (avatarBase64 != null) fields['avatar_base64'] = avatarBase64;
    if (clearAvatar) fields['clear_avatar'] = true;

    if (fields.isEmpty) return null;

    isBusy = true;
    notifyListeners();
    try {
      final updated = await _authService.updateProfile(baseUrl: baseUrl, token: currentToken, fields: fields);
      user = updated;
      return null;
    } on auth_svc.AuthException catch (e) {
      return e.message;
    } catch (e) {
      return 'Непредвиденная ошибка: $e';
    } finally {
      isBusy = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _authService.dispose();
    super.dispose();
  }

  Future<String?> changePassword({required String currentPassword, required String newPassword}) async {
    final currentToken = token;
    if (currentToken == null) return 'Сессия не найдена. Войди заново.';

    isBusy = true;
    notifyListeners();
    try {
      await _authService.changePassword(
        baseUrl: baseUrl,
        token: currentToken,
        currentPassword: currentPassword,
        newPassword: newPassword,
      );
      return null;
    } on auth_svc.AuthException catch (e) {
      return e.message;
    } catch (e) {
      return 'Непредвиденная ошибка: $e';
    } finally {
      isBusy = false;
      notifyListeners();
    }
  }

  Future<String?> requestEmailChange({required String newEmail, required String currentPassword}) async {
    final currentToken = token;
    if (currentToken == null) return 'Сессия не найдена. Войди заново.';

    isBusy = true;
    notifyListeners();
    try {
      await _authService.requestEmailChange(
        baseUrl: baseUrl,
        token: currentToken,
        newEmail: newEmail,
        currentPassword: currentPassword,
      );
      return null;
    } on auth_svc.AuthException catch (e) {
      return e.message;
    } catch (e) {
      return 'Непредвиденная ошибка: $e';
    } finally {
      isBusy = false;
      notifyListeners();
    }
  }

  Future<String?> confirmEmailChange({required String changeToken}) async {
    final currentToken = token;
    if (currentToken == null) return 'Сессия не найдена. Войди заново.';

    isBusy = true;
    notifyListeners();
    try {
      final updated = await _authService.confirmEmailChange(baseUrl: baseUrl, token: currentToken, changeToken: changeToken);
      user = updated;
      return null;
    } on auth_svc.AuthException catch (e) {
      return e.message;
    } catch (e) {
      return 'Непредвиденная ошибка: $e';
    } finally {
      isBusy = false;
      notifyListeners();
    }
  }
}
