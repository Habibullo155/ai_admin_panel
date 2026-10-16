import 'dart:convert';

import 'package:flutter/foundation.dart' show compute;

import 'encrypted_storage.dart';

import '../models/gad7_checkin.dart';

/// Результаты GAD-7 хранятся ТОЛЬКО на устройстве — тот же принцип, что
/// и у чек-инов ВОЗ-5 (wellbeing_service.dart).
class Gad7Service {
  String _keyFor(String userId) => 'gad7_checkins_v1_$userId';

  Future<List<Gad7Checkin>> loadCheckins(String userId) async {
    try {
      final raw = await EncryptedStorage.getString(_keyFor(userId));
      if (raw == null || raw.isEmpty) return [];
      // compute() - jsonDecode синхронно на главном потоке при годах
      // накопленных чек-инов/результатов заметно подвешивает интерфейс -
      // изолят убирает это из UI-потока
      final list = await compute(jsonDecode, raw) as List<dynamic>;
      return list.map((e) => Gad7Checkin.fromJson(e as Map<String, dynamic>)).toList();
    } catch (_) {
      return [];
    }
  }

  Future<bool> saveCheckins(String userId, List<Gad7Checkin> checkins) async {
    try {
      final raw = jsonEncode(checkins.map((c) => c.toJson()).toList());
      await EncryptedStorage.setString(_keyFor(userId), raw);
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<Gad7Checkin?> addCheckin(String userId, Gad7Checkin checkin) async {
    final existing = await loadCheckins(userId);
    final updated = [checkin, ...existing];
    final ok = await saveCheckins(userId, updated);
    return ok ? checkin : null;
  }
}
