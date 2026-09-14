import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/chat_conversation.dart';

/// Локальное хранение истории чатов на устройстве (без бэкенда).
/// История привязана к конкретному пользователю (userId), чтобы на одном
/// устройстве разные аккаунты не видели историю друг друга.
class StorageService {
  String _keyFor(String userId) => 'conversations_v1_$userId';

  Future<List<ChatConversation>> loadConversations(String userId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_keyFor(userId));
      if (raw == null || raw.isEmpty) return [];
      final list = jsonDecode(raw) as List<dynamic>;
      return list
          .map((e) => ChatConversation.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (_) {
      // Повреждённые данные или недоступное хранилище — не роняем приложение,
      // просто стартуем с чистой историей.
      return [];
    }
  }

  /// Возвращает false вместо исключения, если сохранить не удалось —
  /// это best-effort операция, она не должна ронять вызывающий код.
  Future<bool> saveConversations(String userId, List<ChatConversation> conversations) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = jsonEncode(conversations.map((c) => c.toJson()).toList());
      await prefs.setString(_keyFor(userId), raw);
      return true;
    } catch (_) {
      return false;
    }
  }
}
