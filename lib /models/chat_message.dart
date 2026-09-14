import 'chat_source.dart';

enum MessageRole { user, assistant, system }

/// null — не оценено, true — лайк, false — дизлайк.
class ChatMessage {
  final String id;
  final MessageRole role;
  String content;
  final DateTime createdAt;
  bool isStreaming;
  bool isError;
  bool? liked;
  // Источники из загруженных документов (RAG) — заполняется только для
  // админа, сервер сам решает, присылать ли это поле вообще (см.
  // chat_api_service.dart). Не сохраняется между сессиями — это просто
  // отображение "откуда взят этот конкретный ответ прямо сейчас".
  List<ChatSource>? sources;
  // Прикреплённые фото — base64 (без префикса data:), уже сжатые при
  // выборе (ChatInputBar: maxWidth/imageQuality), чтобы не раздувать
  // локальное хранилище истории чатов. В отличие от sources — реальный
  // контент пользователя, сохраняется вместе с остальным сообщением.
  List<String>? images;
  // true, если это сообщение содержало маркер [[OFFER_TEST]] от ИИ (сам
  // маркер к этому моменту уже вырезан из content). Не сохраняется между
  // сессиями - раз пользователь ответил да/нет, кнопки под старым
  // сообщением при следующем открытии чата уже не нужны.
  bool offersTestPrompt;
  // после ответа (да или нет) прячем кнопки под этим конкретным
  // сообщением, не удаляя сам факт предложения из истории
  bool testPromptAnswered;
  // маркер [[OFFER_THEME_PICKER]] от ИИ - вместо того чтобы силой менять
  // тему или заставлять модель помнить, какие варианты уже предлагались
  // (ненадёжно), под сообщением показывается весь набор образцов темы,
  // человек сам решает
  bool offersThemePicker;
  bool themePickerAnswered;
  // сообщение остаётся в истории (нужно ИИ для связности на будущих
  // ходах разговора - например, "пользователь отказался от теста сейчас"),
  // но не отображается пузырём в интерфейсе. Используется, когда кнопка
  // ("Нет, не сейчас" и т.п.) продолжает разговор без видимого
  // сообщения, будто напечатанного пользователем вручную
  bool isHidden;

  ChatMessage({
    required this.id,
    required this.role,
    required this.content,
    DateTime? createdAt,
    this.isStreaming = false,
    this.isError = false,
    this.liked,
    this.sources,
    this.images,
    this.offersTestPrompt = false,
    this.testPromptAnswered = false,
    this.offersThemePicker = false,
    this.themePickerAnswered = false,
    this.isHidden = false,
  }) : createdAt = createdAt ?? DateTime.now();

  String get roleKey => switch (role) {
        MessageRole.user => 'user',
        MessageRole.assistant => 'assistant',
        MessageRole.system => 'system',
      };

  Map<String, dynamic> toJson() => {
        'id': id,
        'role': roleKey,
        'content': content,
        'createdAt': createdAt.toIso8601String(),
        'liked': liked,
        'images': images,
        // в отличие от offersTestPrompt/themePickerAnswered и т.п. (те
        // сознательно не переживают перезапуск) - isHidden обязан
        // сохраняться, иначе после перезапуска скрытое "продолжи
        // разговор" сообщение вдруг стало бы видимым обычным пузырём
        'isHidden': isHidden,
      };

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    final roleStr = json['role'] as String? ?? 'user';
    final role = MessageRole.values.firstWhere(
      (r) => r.name == roleStr,
      orElse: () => MessageRole.user,
    );
    return ChatMessage(
      id: json['id'] as String,
      role: role,
      content: json['content'] as String? ?? '',
      createdAt: DateTime.tryParse(json['createdAt'] as String? ?? '') ??
          DateTime.now(),
      liked: json['liked'] as bool?,
      images: (json['images'] as List<dynamic>?)?.map((e) => e as String).toList(),
      isHidden: json['isHidden'] as bool? ?? false,
    );
  }
}
