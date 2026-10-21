import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:encrypt/encrypt.dart' as enc;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Шифрует данные перед сохранением в SharedPreferences
class EncryptedStorage {
  static const _secureStorage = FlutterSecureStorage();
  static const _keyStorageKey = 'encrypted_storage_aes_key_v1';
  static enc.Key? _cachedKey;

  static Future<enc.Key> _getOrCreateKey() async {
    if (_cachedKey != null) return _cachedKey!;
    final existing = await _secureStorage.read(key: _keyStorageKey);
    if (existing != null) {
      _cachedKey = enc.Key.fromBase64(existing);
      return _cachedKey!;
    }
    // генерируем новый 256-битный ключ - Random.secure() - криптографически
    // стойкий генератор случайных чисел, не обычный Random()
    final random = Random.secure();
    final keyBytes = Uint8List.fromList(List<int>.generate(32, (_) => random.nextInt(256)));
    final key = enc.Key(keyBytes);
    await _secureStorage.write(key: _keyStorageKey, value: key.base64);
    _cachedKey = key;
    return key;
  }

  /// Шифрует plaintext, возвращает base64(iv (12 байт для GCM) +
  /// ciphertext+tag)
  static Future<String> encryptString(String plaintext) async {
    final key = await _getOrCreateKey();
    final iv = enc.IV.fromSecureRandom(12); // 12 байт - стандартный размер nonce для GCM
    final encrypter = enc.Encrypter(enc.AES(key, mode: enc.AESMode.gcm));
    final encrypted = encrypter.encrypt(plaintext, iv: iv);
    final combined = iv.bytes + encrypted.bytes;
    return base64Encode(combined);
  }

  /// Обратная операция - бросает FormatException/ArgumentError на
  /// повреждённых/неожиданных данных, вызывающий код должен сам решить, что
  /// делать.
  static Future<String> decryptString(String encoded) async {
    final key = await _getOrCreateKey();
    final combined = base64Decode(encoded);
    final ivBytes = combined.sublist(0, 12);
    final cipherBytes = combined.sublist(12);
    final encrypter = enc.Encrypter(enc.AES(key, mode: enc.AESMode.gcm));
    return encrypter.decrypt(enc.Encrypted(cipherBytes), iv: enc.IV(ivBytes));
  }

  // --- удобные обёртки поверх SharedPreferences, взамен прямых prefs.getString/setString ---

  static Future<String?> getString(String key) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(key);
    if (raw == null || raw.isEmpty) return null;
    try {
      return await decryptString(raw);
    } catch (_) {
      // повреждённые/незашифрованные (например, старые, ещё не
      // мигрированные) данные - вызывающий код трактует null как "нет
      // сохранённых данных", безопасное поведение по умолчанию
      return null;
    }
  }

  static Future<void> setString(String key, String value) async {
    final prefs = await SharedPreferences.getInstance();
    final encrypted = await encryptString(value);
    await prefs.setString(key, encrypted);
  }

  static Future<void> remove(String key) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(key);
  }
}
