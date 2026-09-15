import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';

import '../config.dart';
import '../models/chat_conversation.dart';
import '../models/chat_message.dart';
import '../services/chat_api_service.dart';
import '../services/storage_service.dart';
import 'notification_prefs_store.dart';
import '../theme/background_variant.dart';
import 'theme_store.dart';

const _uuid = Uuid();

enum BackendStatus { unknown, checking, online, offline }

class ChatStore extends ChangeNotifier {
  // конструктор, не каскад ..field = ... после создания - так required
  // видно в сигнатуре, не забудешь подключить где-то ещё
  ChatStore({this.getAuthToken, this.onSessionExpired, this.onAssistantTextChunk});

  final StorageService _storage = StorageService();
  final ChatApiService _api = ChatApiService();
  // ИИ может сменить оформление приложения через специальный маркер в
  // конце ответа (backend/safety.py: THEME_CONTROL_PROMPT) - не настоящий
  // tool use, а просто текстовый сигнал, который парсится и стирается
  // здесь, до того как текст попадёт на экран или в озвучку
  static final _themeMarkerPattern = RegExp(r'\s*\[\[THEME:(\w+)\]\]\s*', caseSensitive: false);
  // отдельный маркер от THEME выше - тот управляет только ЦВЕТОВОЙ
  // палитрой фона (violet/ocean/... - 9 вариантов), не умеет переключать
  // светлый/тёмный режим вообще. Раньше человек мог попросить "сделай
  // белым"/"светлую тему" - ИИ физически не мог этого сделать, такой
  // возможности не существовало в разметке промпта
  static final _themeModeMarkerPattern = RegExp(r'\s*\[\[THEME_MODE:(\w+)\]\]\s*', caseSensitive: false);
  static final _offerTestMarkerPattern = RegExp(r'\s*\[\[OFFER_TEST\]\]\s*', caseSensitive: false);
  static final _offerThemePickerMarkerPattern = RegExp(r'\s*\[\[OFFER_THEME_PICKER\]\]\s*', caseSensitive: false);

  // задаётся один раз при сборке через --dart-define=BACKEND_URL=...
  // (config.dart), кнопку сменить адрес в приложении убрали намеренно
  final String baseUrl = AppConfig.backendUrl;

  final List<ChatConversation> conversations = [];
  String? activeConversationId;
  BackendStatus backendStatus = BackendStatus.unknown;

  // id чатов, где сейчас идёт генерация. Раньше было одно глобальное
  // isSending - пока ИИ отвечал в одном чате, поле ввода блокировалось
  // везде. Теперь каждый чат независим
  final Set<String> _sendingConversationIds = {};

  // отправляется ли сообщение в ТЕКУЩЕМ чате, для блокировки инпута
  bool get isSending =>
      activeConversationId != null && _sendingConversationIds.contains(activeConversationId);

  // то же самое, но для любого чата по id - нужно сайдбару
  bool isSendingIn(String conversationId) => _sendingConversationIds.contains(conversationId);

  // токен не храним сами, источник правды - AuthStore. Функция, а не
  // строка, потому что токен может обновиться между запросами
  final String? Function()? getAuthToken;

  final Future<void> Function()? onSessionExpired; // 401 -> разлогинить

  // дёргается на каждый апдейт текста ответа, ещё до завершения генерации -
  // нужно для потокового чтения вслух (voice_store.dart: onIncomingText)
  final void Function({required String messageId, required String fullContent, required bool isDone})?
      onAssistantTextChunk;

  ChatConversation? get active => conversations
      .where((c) => c.id == activeConversationId)
      .cast<ChatConversation?>()
      .firstOrNull;

  String _userId = 'anonymous';

  Future<void> init(String userId) async {
    _userId = userId;
    try {
      final saved = await _storage.loadConversations(_userId);
      conversations.addAll(saved);
    } catch (_) {
      // подстраховка на случай непредвиденной ошибки, чтобы не зависнуть
    }
    if (conversations.isEmpty) {
      _createConversation();
    } else {
      activeConversationId = conversations.first.id;
    }
    notifyListeners();
    unawaited(refreshBackendStatus());
  }

  Future<void> refreshBackendStatus() async {
    backendStatus = BackendStatus.checking;
    notifyListeners();
    final ok = await _api.checkHealth(baseUrl);
    backendStatus = ok ? BackendStatus.online : BackendStatus.offline;
    notifyListeners();
  }

  void _createConversation() {
    final convo = ChatConversation(id: _uuid.v4(), title: 'Новый чат');
    conversations.insert(0, convo);
    activeConversationId = convo.id;
  }

  void createNewChat() {
    // если уже есть пустой чат - просто переключаемся на него
    final existingEmpty =
        conversations.where((c) => c.isEmpty).cast<ChatConversation?>().firstOrNull;
    if (existingEmpty != null) {
      activeConversationId = existingEmpty.id;
      notifyListeners();
      return;
    }
    _createConversation();
    notifyListeners();
  }

  void selectConversation(String id) {
    activeConversationId = id;
    notifyListeners();
  }

  void deleteConversation(String id) {
    conversations.removeWhere((c) => c.id == id);
    if (conversations.isEmpty) {
      _createConversation();
    } else if (activeConversationId == id) {
      activeConversationId = conversations.first.id;
    }
    _persist();
    notifyListeners();
  }

  // юзер сам переименовывает - иначе название всегда из первого сообщения
  void renameConversation(String id, String newTitle) {
    final title = newTitle.trim();
    if (title.isEmpty) return;
    final convo = conversations.where((c) => c.id == id).cast<ChatConversation?>().firstOrNull;
    if (convo == null) return;
    convo.title = title;
    unawaited(_persist());
    notifyListeners();
  }

  void deleteMessage(String messageId) {
    final convo = active;
    if (convo == null) return;
    convo.messages.removeWhere((m) => m.id == messageId);
    unawaited(_persist());
    notifyListeners();
  }

  // повторный тап по уже выставленной оценке снимает её, не переключает
  // на противоположную
  void rateMessage(String messageId, bool liked) {
    final convo = active;
    if (convo == null) return;
    final message = convo.messages.where((m) => m.id == messageId).firstOrNull;
    if (message == null) return;
    message.liked = message.liked == liked ? null : liked;
    unawaited(_persist());
    notifyListeners();
  }

  // как в ChatGPT: всё после отредактированного сообщения удаляется,
  // генерируется новый ответ на исправленный текст
  Future<void> editAndResend(String messageId, String newText) async {
    final convo = active;
    if (convo == null || newText.trim().isEmpty || _sendingConversationIds.contains(convo.id)) return;

    final index = convo.messages.indexWhere((m) => m.id == messageId);
    if (index == -1 || convo.messages[index].role != MessageRole.user) return;

    // обрезаем начиная с редактируемого, sendMessage() добавит новое как обычно
    convo.messages.removeRange(index, convo.messages.length);
    await sendMessage(newText);
  }

  Future<void> sendMessage(String text, {List<String>? images}) async {
    final convo = active;
    final hasImages = images != null && images.isNotEmpty;
    // раньше пустой текст всегда блокировал отправку - теперь фото без
    // подписи тоже валидное сообщение, текст можно оставить пустым
    if (convo == null || (text.trim().isEmpty && !hasImages) || _sendingConversationIds.contains(convo.id)) {
      return;
    }

    final userMsg = ChatMessage(
      id: _uuid.v4(),
      role: MessageRole.user,
      content: text.trim(),
      images: hasImages ? images : null,
    );
    convo.messages.add(userMsg);

    if (convo.title == 'Новый чат') {
      final title = text.trim().isNotEmpty ? text.trim() : 'Фото';
      convo.title = title.length > 40 ? '${title.substring(0, 40)}…' : title;
    }

    await _streamAssistantReply(convo);
  }

  // используется кнопками-развилками в чате (например, "Нет, не сейчас"
  // под предложением теста) - продолжает разговор так, будто человек
  // ответил, но без видимого пузыря с текстом, который на самом деле
  // напечатала не человеческая рука. Сообщение остаётся в истории
  // (isHidden: true) для связности контекста ИИ на будущих ходах, просто
  // не рисуется в интерфейсе (см. MessageBubble.build())
  Future<void> sendHiddenContinuation(String hiddenPrompt) async {
    final convo = active;
    if (convo == null || _sendingConversationIds.contains(convo.id)) return;

    final hiddenMsg = ChatMessage(
      id: _uuid.v4(),
      role: MessageRole.user,
      content: hiddenPrompt,
      isHidden: true,
    );
    convo.messages.add(hiddenMsg);

    await _streamAssistantReply(convo);
  }

  // убирает предыдущий ответ и запрашивает новый на ту же историю,
  // без повторной отправки вопроса
  Future<void> regenerateLastResponse() async {
    final convo = active;
    if (convo == null || _sendingConversationIds.contains(convo.id) || convo.messages.isEmpty) return;

    if (convo.messages.last.role == MessageRole.assistant) {
      convo.messages.removeLast();
    }
    if (convo.messages.isEmpty || convo.messages.last.role != MessageRole.user) {
      // нечего перегенерировать - последний вопрос юзера не найден
      notifyListeners();
      return;
    }

    await _streamAssistantReply(convo);
  }

  // выключить обратно можно из админки (theme_control_enabled) - тогда
  // ИИ вообще не получит инструкцию про маркер и этот код просто никогда
  // не найдёт совпадение
  void _applyThemeMarkerIfPresent(ChatMessage msg) {
    final match = _themeMarkerPattern.firstMatch(msg.content);
    if (match == null) return;

    final variantName = match.group(1)!.toLowerCase();
    BackgroundVariant? variant;
    for (final v in BackgroundVariant.values) {
      if (v.name == variantName) {
        variant = v;
        break;
      }
    }

    // маркер убираем из текста в любом случае - даже если модель ошиблась
    // с названием варианта, пользователь не должен видеть техническую
    // разметку вместо обычного ответа
    msg.content = msg.content.replaceFirst(match.group(0)!, ' ').trim();
    if (variant != null) {
      ThemeStore.instance.setVariant(variant);
    }
  }

  // светлый/тёмный режим - отдельно от цветовой палитры выше (см.
  // комментарий у _themeModeMarkerPattern про то, почему это два разных
  // маркера, не один)
  void _applyThemeModeMarkerIfPresent(ChatMessage msg) {
    final match = _themeModeMarkerPattern.firstMatch(msg.content);
    if (match == null) return;

    final modeName = match.group(1)!.toLowerCase();
    AppThemeMode? mode;
    for (final m in AppThemeMode.values) {
      if (m.name == modeName) {
        mode = m;
        break;
      }
    }

    msg.content = msg.content.replaceFirst(match.group(0)!, ' ').trim();
    if (mode != null) {
      ThemeStore.instance.setMode(mode);
    }
  }

  // в отличие от темы - здесь ничего не применяется автоматически, просто
  // выставляется флаг на самом сообщении, чтобы message_bubble.dart
  // показал кнопки "Да"/"Нет" под ним - решение остаётся за человеком
  void _applyOfferTestMarkerIfPresent(ChatMessage msg) {
    final match = _offerTestMarkerPattern.firstMatch(msg.content);
    if (match == null) return;
    msg.content = msg.content.replaceFirst(match.group(0)!, ' ').trim();
    msg.offersTestPrompt = true;
  }

  // как и с тестом - ничего не применяется автоматически, только флаг на
  // сообщении; сами образцы тем рендерит message_bubble.dart
  void _applyOfferThemePickerMarkerIfPresent(ChatMessage msg) {
    final match = _offerThemePickerMarkerPattern.firstMatch(msg.content);
    if (match == null) return;
    msg.content = msg.content.replaceFirst(match.group(0)!, ' ').trim();
    msg.offersThemePicker = true;
  }

  Future<void> _streamAssistantReply(ChatConversation convo) async {
    final assistantMsg = ChatMessage(
      id: _uuid.v4(),
      role: MessageRole.assistant,
      content: '',
      isStreaming: true,
    );
    convo.messages.add(assistantMsg);
    convo.updatedAt = DateTime.now();
    _sendingConversationIds.add(convo.id);
    notifyListeners();

    try {
      final history = convo.messages
          .where((m) => m.id != assistantMsg.id)
          .toList(growable: false);

      // notifyListeners() на каждый токен перестраивал бы дерево виджетов
      // чаще, чем заметно глазу - ограничиваем частоту, финальное
      // состояние долетит через finally ниже
      var lastNotify = DateTime.fromMillisecondsSinceEpoch(0);
      const notifyInterval = Duration(milliseconds: 50);

      await for (final event in _api.sendMessage(
        baseUrl: baseUrl,
        history: history,
        authToken: getAuthToken?.call(),
      )) {
        if (event.error != null) {
          assistantMsg.content += event.error!;
          assistantMsg.isError = true;
          assistantMsg.isStreaming = false;
          if (event.isAuthError) {
            unawaited(onSessionExpired?.call());
          } else {
            backendStatus = BackendStatus.offline;
          }
          break;
        }
        assistantMsg.content += event.token;
        if (event.done) {
          assistantMsg.isStreaming = false;
          if (event.sources != null) assistantMsg.sources = event.sources;
          // до onAssistantTextChunk ниже - иначе озвучка (TTS) прочитала бы
          // вслух сырой технический маркер, а не только человеческий текст
          _applyThemeMarkerIfPresent(assistantMsg);
          _applyThemeModeMarkerIfPresent(assistantMsg);
          _applyOfferTestMarkerIfPresent(assistantMsg);
          _applyOfferThemePickerMarkerIfPresent(assistantMsg);
          // только на успешном завершении - неудачный ответ (см. ветку
          // event.error выше, там return/break раньше этого места) не
          // должен звучать как "пришло сообщение"
          NotificationPrefsStore.instance.notifyNewMessage();
        }
        onAssistantTextChunk?.call(
          messageId: assistantMsg.id,
          fullContent: assistantMsg.content,
          isDone: event.done,
        );
        final now = DateTime.now();
        if (now.difference(lastNotify) >= notifyInterval) {
          lastNotify = now;
          notifyListeners();
        }
      }
    } finally {
      assistantMsg.isStreaming = false;
      _sendingConversationIds.remove(convo.id);
      convo.updatedAt = DateTime.now();
      _reorderActiveToTop();
      await _persist();
      notifyListeners();
    }
  }

  void _reorderActiveToTop() {
    final id = activeConversationId;
    if (id == null) return;
    final idx = conversations.indexWhere((c) => c.id == id);
    if (idx <= 0) return;
    final convo = conversations.removeAt(idx);
    conversations.insert(0, convo);
  }

  Future<void> _persist() => _storage.saveConversations(_userId, conversations);

  @override
  void dispose() {
    _api.dispose();
    super.dispose();
  }
}

extension _FirstOrNull<T> on Iterable<T> {
  T? get firstOrNull => isEmpty ? null : first;
}
