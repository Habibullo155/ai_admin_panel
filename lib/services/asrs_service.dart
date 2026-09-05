import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/asrs_checkin.dart';

// хранится только на устройстве, тот же принцип, что у ВОЗ-5/PHQ-9/GAD-7
class AsrsService {
  String _keyFor(String userId) => 'asrs_checkins_v1_$userId';

  Future<List<AsrsCheckin>> loadCheckins(String userId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_keyFor(userId));
      if (raw == null || raw.isEmpty) return [];
      final list = jsonDecode(raw) as List<dynamic>;
      return list.map((e) => AsrsCheckin.fromJson(e as Map<String, dynamic>)).toList();
    } catch (_) {
      return [];
    }
  }

  Future<bool> saveCheckins(String userId, List<AsrsCheckin> checkins) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = jsonEncode(checkins.map((c) => c.toJson()).toList());
      await prefs.setString(_keyFor(userId), raw);
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
