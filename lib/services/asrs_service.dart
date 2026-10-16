import 'dart:convert';

import 'package:flutter/foundation.dart' show compute;

import 'encrypted_storage.dart';

import '../models/asrs_checkin.dart';

// хранится только на устройстве, тот же принцип, что у ВОЗ-5/PHQ-9/GAD-7
class AsrsService {
  String _keyFor(String userId) => 'asrs_checkins_v1_$userId';

  Future<List<AsrsCheckin>> loadCheckins(String userId) async {
    try {
      final raw = await EncryptedStorage.getString(_keyFor(userId));
      if (raw == null || raw.isEmpty) return [];
      // compute() - jsonDecode синхронно на главном потоке при годах
      // накопленных чек-инов/результатов заметно подвешивает интерфейс -
      // изолят убирает это из UI-потока
      final list = await compute(jsonDecode, raw) as List<dynamic>;
      return list.map((e) => AsrsCheckin.fromJson(e as Map<String, dynamic>)).toList();
    } catch (_) {
      return [];
    }
  }

  Future<bool> saveCheckins(String userId, List<AsrsCheckin> checkins) async {
    try {
      final raw = jsonEncode(checkins.map((c) => c.toJson()).toList());
      await EncryptedStorage.setString(_keyFor(userId), raw);
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<AsrsCheckin?> addCheckin(String userId, AsrsCheckin checkin) async {
    final existing = await loadCheckins(userId);
    final updated = [checkin, ...existing];
    final ok = await saveCheckins(userId, updated);
    return ok ? checkin : null;
  }
}
