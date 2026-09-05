import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/gratitude_entry.dart';

/// Записи дневника благодарности хранятся ТОЛЬКО на устройстве — тот же
/// принцип, что и у чек-инов самочувствия (wellbeing_service.dart):
/// сервер об этих данных вообще не знает.
class GratitudeService {
  String _keyFor(String userId) => 'gratitude_entries_v1_$userId';

  Future<List<GratitudeEntry>> loadEntries(String userId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_keyFor(userId));
      if (raw == null || raw.isEmpty) return [];
      final list = jsonDecode(raw) as List<dynamic>;
      return list.map((e) => GratitudeEntry.fromJson(e as Map<String, dynamic>)).toList();
    } catch (_) {
      return [];
    }
  }

  Future<bool> _saveEntries(String userId, List<GratitudeEntry> entries) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = jsonEncode(entries.map((e) => e.toJson()).toList());
      await prefs.setString(_keyFor(userId), raw);
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<GratitudeEntry?> addEntry(String userId, GratitudeEntry entry) async {
    final existing = await loadEntries(userId);
    final updated = [entry, ...existing];
    final ok = await _saveEntries(userId, updated);
    return ok ? entry : null;
  }
}
