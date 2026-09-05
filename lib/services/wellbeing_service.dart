import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/wellbeing_checkin.dart';

/// Результаты чек-инов самочувствия хранятся ТОЛЬКО на устройстве —
/// сознательное решение, не техническое ограничение. Это чувствительные
/// данные о психологическом состоянии; на сервер они никогда не
/// отправляются и никому, кроме самого пользователя, не видны (в том
/// числе администратору приложения).
class WellbeingService {
  String _keyFor(String userId) => 'wellbeing_checkins_v1_$userId';

  Future<List<WellbeingCheckin>> loadCheckins(String userId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_keyFor(userId));
      if (raw == null || raw.isEmpty) return [];
      final list = jsonDecode(raw) as List<dynamic>;
      return list
          .map((e) => WellbeingCheckin.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (_) {
      // Повреждённые локальные данные не должны ронять приложение —
      // просто начинаем с чистой истории чек-инов.
      return [];
    }
  }

  Future<bool> saveCheckins(String userId, List<WellbeingCheckin> checkins) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = jsonEncode(checkins.map((c) => c.toJson()).toList());
      await prefs.setString(_keyFor(userId), raw);
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<WellbeingCheckin?> addCheckin(String userId, WellbeingCheckin checkin) async {
    final existing = await loadCheckins(userId);
    final updated = [checkin, ...existing];
    final ok = await saveCheckins(userId, updated);
    return ok ? checkin : null;
  }
}
