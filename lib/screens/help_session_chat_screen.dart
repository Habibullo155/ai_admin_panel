import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

import '../models/help_session.dart';
import '../services/asrs_service.dart';
import '../services/gad7_service.dart';
import '../services/help_service.dart';
import '../services/phq9_service.dart';
import '../services/wellbeing_service.dart';
import '../state/auth_store.dart';
import '../theme/app_text_color.dart';
import '../widgets/app_background.dart';
import '../widgets/glass_panel.dart';

// экран переписки внутри сессии живой помощи, общий для юзера и
// оператора - кто есть кто определяется по currentUserId
//
// обновление по опросу (polling), не WebSocket - в проекте нет
// инфраструктуры для постоянного соединения (SSE только для стриминга
// ответов ИИ, другой протокол), добавлять WebSocket ради одной фичи -
// намного больше работы. Опрос раз в несколько секунд даёт приемлемую
// задержку, не мгновенную
class HelpSessionChatScreen extends StatefulWidget {
  final AuthStore authStore;
  final HelpSession session;
  const HelpSessionChatScreen({super.key, required this.authStore, required this.session});

  @override
  State<HelpSessionChatScreen> createState() => _HelpSessionChatScreenState();
}

class _HelpSessionChatScreenState extends State<HelpSessionChatScreen> {
  final _service = HelpService();
  final _controller = TextEditingController();
  final _scrollController = ScrollController();
  Timer? _pollTimer;
  List<HelpMessage> _messages = [];
  late HelpSession _session;
  bool _isLoading = true;
  bool _isSending = false;
  final _picker = ImagePicker();
  final List<String> _pickedImages = [];
  bool _isRatingSaving = false;
  String? _error;

  int? get _myId => widget.authStore.user?.id;

  bool get _isRequester => _myId != null && _myId == _session.userId;

  // участник переписки, не админ - тот может только смотреть для
  // надзора, не писать. Поле ввода и "Завершить" только для участников
  bool get _isParticipant => _myId != null && (_myId == _session.userId || _myId == _session.operatorId);

  @override
  void initState() {
    super.initState();
    _session = widget.session;
    _load();
    _pollTimer = Timer.periodic(const Duration(seconds: 4), (_) => _load(silent: true));
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    _service.dispose();
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _load({bool silent = false}) async {
    final token = widget.authStore.token;
    if (token == null) return;
    if (!silent) setState(() => _isLoading = true);
    try {
      final messages = await _service.getMessages(
        baseUrl: widget.authStore.baseUrl,
        token: token,
        sessionId: _session.id,
      );
      if (!mounted) return;
      final hadFewerMessages = messages.length > _messages.length;
      setState(() {
        _messages = messages;
        _isLoading = false;
      });
      if (hadFewerMessages) _scrollToBottom();
    } on HelpException catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.message;
        _isLoading = false;
      });
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) return;
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent + 80,
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
      );
    });
  }

  Future<void> _send() async {
    final token = widget.authStore.token;
    final text = _controller.text.trim();
    if (token == null || (text.isEmpty && _pickedImages.isEmpty) || _session.status == HelpSessionStatus.closed) {
      return;
    }

    setState(() => _isSending = true);
    try {
      final message = await _service.sendMessage(
        baseUrl: widget.authStore.baseUrl,
        token: token,
        sessionId: _session.id,
        content: text,
        images: _pickedImages.isEmpty ? null : List.of(_pickedImages),
      );
      if (!mounted) return;
      setState(() {
        _messages = [..._messages, message];
        _controller.clear();
        _pickedImages.clear();
      });
      _scrollToBottom();
    } on HelpException catch (e) {
      if (mounted) setState(() => _error = e.message);
    } finally {
      if (mounted) setState(() => _isSending = false);
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    // то же сжатие, что и в чате с ИИ (chat_input_bar.dart) - не раздувать
    // хранилище переписки несжатыми фото с камеры
    final file = await _picker.pickImage(source: source, maxWidth: 1280, maxHeight: 1280, imageQuality: 70);
    if (file == null) return;
    final bytes = await file.readAsBytes();
    if (!mounted) return;
    setState(() => _pickedImages.add(base64Encode(bytes)));
  }

  Future<void> _showImageSourceSheet() async {
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => SafeArea(
        child: Container(
          decoration: const BoxDecoration(
            color: Color(0xFF1A2036),
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.photo_camera_rounded, color: Colors.white),
                title: const Text('Сделать фото', style: TextStyle(color: Colors.white)),
                onTap: () => Navigator.of(context).pop(ImageSource.camera),
              ),
              ListTile(
                leading: const Icon(Icons.photo_library_rounded, color: Colors.white),
                title: const Text('Выбрать из галереи', style: TextStyle(color: Colors.white)),
                onTap: () => Navigator.of(context).pop(ImageSource.gallery),
              ),
            ],
          ),
        ),
      ),
    );
    if (source != null) await _pickImage(source);
  }

  Future<void> _close() async {
    final token = widget.authStore.token;
    if (token == null) return;
    try {
      final updated = await _service.closeSession(
        baseUrl: widget.authStore.baseUrl,
        token: token,
        sessionId: _session.id,
      );
      if (mounted) setState(() => _session = updated);
    } on HelpException catch (e) {
      if (mounted) setState(() => _error = e.message);
    }
  }

  Future<void> _submitRating(int stars, String? comment) async {
    final token = widget.authStore.token;
    if (token == null) return;
    setState(() => _isRatingSaving = true);
    try {
      final updated = await _service.rateSession(
        baseUrl: widget.authStore.baseUrl,
        token: token,
        sessionId: _session.id,
        rating: stars,
        comment: comment,
      );
      if (mounted) setState(() => _session = updated);
    } on HelpException catch (e) {
      if (mounted) setState(() => _error = e.message);
    } finally {
      if (mounted) setState(() => _isRatingSaving = false);
    }
  }

  // собирает последний результат каждого из трёх опросников (если он
  // вообще проходился) и даёт выбрать, какой отправить оператору —
  // отдельным сообщением в этой же (уже приватной) переписке, не через
  // новый канал. Ничего не отправляется без явного тапа пользователя.
  Future<void> _shareTestResults() async {
    final userId = widget.authStore.user?.id.toString() ?? '';
    final who5 = (await WellbeingService().loadCheckins(userId));
    final phq9 = (await Phq9Service().loadCheckins(userId));
    final gad7 = (await Gad7Service().loadCheckins(userId));
    final asrs = (await AsrsService().loadCheckins(userId));

    if (!mounted) return;

    if (who5.isEmpty && phq9.isEmpty && gad7.isEmpty && asrs.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Пока нет пройденных опросников — их можно пройти в разделе «Самочувствие».')),
      );
      return;
    }

    final weekAgo = DateTime.now().subtract(const Duration(days: 7));
    final who5Week = who5.where((c) => c.date.isAfter(weekAgo)).toList();
    final phq9Week = phq9.where((c) => c.date.isAfter(weekAgo)).toList();
    final gad7Week = gad7.where((c) => c.date.isAfter(weekAgo)).toList();
    final asrsWeek = asrs.where((c) => c.date.isAfter(weekAgo)).toList();
    final hasWeekData = who5Week.isNotEmpty || phq9Week.isNotEmpty || gad7Week.isNotEmpty || asrsWeek.isNotEmpty;

    final choice = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => SafeArea(
        child: Container(
          decoration: const BoxDecoration(
            color: Color(0xFF1A2036),
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Какой результат отправить?', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 15)),
              const SizedBox(height: 12),
              if (hasWeekData)
                _resultTile(
                  context,
                  title: 'Сводка за неделю',
                  date: DateTime.now(),
                  score: '${who5Week.length + phq9Week.length + gad7Week.length + asrsWeek.length} записей',
                  onTap: () => Navigator.of(context).pop('week'),
                ),
              if (who5.isNotEmpty)
                _resultTile(
                  context,
                  title: 'ВОЗ-5 — общее самочувствие',
                  date: who5.first.date,
                  score: '${who5.first.percentScore}%',
                  onTap: () => Navigator.of(context).pop('who5'),
                ),
              if (phq9.isNotEmpty)
                _resultTile(
                  context,
                  title: 'PHQ-9 — депрессивные симптомы',
                  date: phq9.first.date,
                  score: '${phq9.first.rawScore}/27',
                  onTap: () => Navigator.of(context).pop('phq9'),
                ),
              if (gad7.isNotEmpty)
                _resultTile(
                  context,
                  title: 'GAD-7 — тревожные симптомы',
                  date: gad7.first.date,
                  score: '${gad7.first.rawScore}/21',
                  onTap: () => Navigator.of(context).pop('gad7'),
                ),
              if (asrs.isNotEmpty)
                _resultTile(
                  context,
                  title: 'ASRS-v1.1 — скрининг СДВГ',
                  date: asrs.first.date,
                  score: '${asrs.first.shadedCount}/6',
                  onTap: () => Navigator.of(context).pop('asrs'),
                ),
            ],
          ),
        ),
      ),
    );

    if (choice == null || !mounted) return;

    String text;
    switch (choice) {
      case 'week':
        // сводка перечисляет КАЖДУЮ запись за 7 дней, не только последнюю
        // по каждому типу — врачу важна динамика, не только текущая точка
        final lines = <String>['Результаты опросников за последние 7 дней:'];
        for (final c in who5Week) {
          lines.add('• ВОЗ-5 (${DateFormat.MMMd().format(c.date)}): ${c.percentScore}%');
        }
        for (final c in phq9Week) {
          lines.add('• PHQ-9 (${DateFormat.MMMd().format(c.date)}): ${c.rawScore}/27, «${c.severityLabel}»'
              '${c.hasRiskSignal ? " — отмечены мысли о самоповреждении" : ""}');
        }
        for (final c in gad7Week) {
          lines.add('• GAD-7 (${DateFormat.MMMd().format(c.date)}): ${c.rawScore}/21, «${c.severityLabel}»');
        }
        for (final c in asrsWeek) {
          lines.add('• ASRS-v1.1 (${DateFormat.MMMd().format(c.date)}): ${c.shadedCount}/6');
        }
        text = lines.join('\n');
        break;
      case 'who5':
        final c = who5.first;
        text = 'Результат опросника ВОЗ-5 (${DateFormat.yMMMd().format(c.date)}): '
            '${c.percentScore}%${c.suggestsFurtherAssessment ? " — методика рекомендует обсудить со специалистом" : ""}.';
        break;
      case 'phq9':
        final c = phq9.first;
        text = 'Результат опросника PHQ-9 (${DateFormat.yMMMd().format(c.date)}): '
            '${c.rawScore}/27, методика описывает это как «${c.severityLabel}»'
            '${c.hasRiskSignal ? ". Отмечены мысли о самоповреждении в пункте 9" : ""}.';
        break;
      case 'gad7':
        final c = gad7.first;
        text = 'Результат опросника GAD-7 (${DateFormat.yMMMd().format(c.date)}): '
            '${c.rawScore}/21, методика описывает это как «${c.severityLabel}».';
        break;
      case 'asrs':
        final c = asrs.first;
        text = 'Результат опросника ASRS-v1.1 (${DateFormat.yMMMd().format(c.date)}): '
            '${c.shadedCount}/6 в зоне значимости'
            '${c.suggestsFurtherAssessment ? " — методика рекомендует обсудить со специалистом" : ""}.';
        break;
      default:
        return;
    }

    final token = widget.authStore.token;
    if (token == null) return;
    try {
      final message = await _service.sendMessage(
        baseUrl: widget.authStore.baseUrl,
        token: token,
        sessionId: _session.id,
        content: text,
      );
      if (mounted) {
        setState(() => _messages = [..._messages, message]);
        _scrollToBottom();
      }
    } on HelpException catch (e) {
      if (mounted) setState(() => _error = e.message);
    }
  }

  Widget _resultTile(
    BuildContext context, {
    required String title,
    required DateTime date,
    required String score,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: TextStyle(color: context.onSurface, fontSize: 13.5)),
                    Text(DateFormat.yMMMd().format(date), style: TextStyle(color: context.onSurfaceFaded(0.4), fontSize: 11.5)),
                  ],
                ),
              ),
              Text(score, style: const TextStyle(color: Color(0xFF00E6A0), fontWeight: FontWeight.w600)),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isClosed = _session.status == HelpSessionStatus.closed;
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: AppBackground(
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    IconButton(
                      icon: Icon(Icons.arrow_back_rounded, color: context.onSurface),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Живая помощь', style: TextStyle(color: context.onSurface, fontSize: 16, fontWeight: FontWeight.w600)),
                          Text(
                            isClosed
                                ? 'Обращение закрыто'
                                : _session.operatorEmail != null
                                    ? 'Подключён: ${_session.operatorEmail}'
                                    : 'Ждём, когда кто-то подключится…',
                            style: TextStyle(color: context.onSurfaceFaded(0.5), fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                    if (!isClosed && _isRequester && _session.operatorId != null)
                      IconButton(
                        tooltip: 'Отправить результаты теста',
                        icon: Icon(Icons.assignment_turned_in_outlined, color: context.onSurfaceFaded(0.7)),
                        onPressed: _shareTestResults,
                      ),
                    if (!isClosed && _isParticipant)
                      TextButton(
                        onPressed: _close,
                        child: Text('Завершить', style: TextStyle(color: context.onSurfaceFaded(0.6))),
                      ),
                  ],
                ),
              ),
              if (_error != null)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text(_error!, style: const TextStyle(color: Color(0xFFFFB4B4), fontSize: 12.5)),
                ),
              if (_session.chatContext != null && _session.chatContext!.isNotEmpty)
                Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 640),
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                      child: _ChatContextPanel(text: _session.chatContext!),
                    ),
                  ),
                ),
              if (isClosed && _isRequester && _session.operatorId != null)
                Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 640),
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                      child: _RatingPanel(
                        currentRating: _session.rating,
                        isSaving: _isRatingSaving,
                        onSubmit: _submitRating,
                      ),
                    ),
                  ),
                ),
              Expanded(
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator(color: Color(0xFF6C5CE7)))
                    : Center(
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 640),
                          child: _messages.isEmpty
                              ? Center(
                                  child: Text(
                                    _session.operatorEmail == null
                                        ? 'Заявка отправлена — сообщение появится, как только кто-то подключится.'
                                        : 'Напиши, что случилось.',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(color: context.onSurfaceFaded(0.4)),
                                  ),
                                )
                              : ListView.builder(
                                  controller: _scrollController,
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                  itemCount: _messages.length,
                                  itemBuilder: (context, i) => _buildMessage(_messages[i]),
                                ),
                        ),
                      ),
              ),
              if (!isClosed && _isParticipant)
                Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 640),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: GlassPanel(
                        opacity: 0.12,
                        borderRadius: BorderRadius.circular(24),
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (_pickedImages.isNotEmpty)
                              Padding(
                                padding: const EdgeInsets.only(top: 8, bottom: 2),
                                child: SizedBox(
                                  height: 52,
                                  child: ListView.separated(
                                    scrollDirection: Axis.horizontal,
                                    itemCount: _pickedImages.length,
                                    separatorBuilder: (_, __) => const SizedBox(width: 6),
                                    itemBuilder: (context, i) => Stack(
                                      clipBehavior: Clip.none,
                                      children: [
                                        ClipRRect(
                                          borderRadius: BorderRadius.circular(10),
                                          child: Image.memory(base64Decode(_pickedImages[i]), width: 52, height: 52, fit: BoxFit.cover),
                                        ),
                                        Positioned(
                                          top: -6,
                                          right: -6,
                                          child: GestureDetector(
                                            onTap: () => setState(() => _pickedImages.removeAt(i)),
                                            child: Container(
                                              width: 18,
                                              height: 18,
                                              decoration: const BoxDecoration(shape: BoxShape.circle, color: Color(0xFFFF6B6B)),
                                              child: const Icon(Icons.close_rounded, color: Colors.white, size: 12),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            Row(
                              children: [
                                IconButton(
                                  icon: Icon(Icons.add_photo_alternate_outlined, color: context.onSurfaceFaded(0.7)),
                                  onPressed: _isSending ? null : _showImageSourceSheet,
                                ),
                                Expanded(
                                  child: TextField(
                                    controller: _controller,
                                    minLines: 1,
                                    maxLines: 4,
                                    style: TextStyle(color: context.onSurface),
                                    decoration: InputDecoration(
                                      border: InputBorder.none,
                                      hintText: 'Написать сообщение…',
                                      hintStyle: TextStyle(color: context.onSurfaceFaded(0.4)),
                                    ),
                                    onSubmitted: (_) => _send(),
                                  ),
                                ),
                                IconButton(
                                  icon: _isSending
                                      ? SizedBox(
                                          width: 18,
                                          height: 18,
                                          child: CircularProgressIndicator(strokeWidth: 2, color: context.onSurface),
                                        )
                                      : Icon(Icons.send_rounded, color: context.onSurface),
                                  onPressed: _isSending ? null : _send,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMessage(HelpMessage message) {
    final isMine = message.senderId == _myId;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: isMine ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          Flexible(
            child: GlassPanel(
              opacity: isMine ? 0.16 : 0.09,
              tint: isMine ? const Color(0xFF6C5CE7) : null,
              blurred: false,
              borderRadius: BorderRadius.circular(16),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (message.images != null && message.images!.isNotEmpty) ...[
                    _MessageImages(images: message.images!),
                    if (message.content.isNotEmpty) const SizedBox(height: 6),
                  ],
                  if (message.content.isNotEmpty)
                    Text(message.content, style: TextStyle(color: isMine ? Colors.white : context.onSurface, fontSize: 14, height: 1.4)),
                  const SizedBox(height: 4),
                  Text(
                    DateFormat.Hm().format(message.createdAt),
                    style: TextStyle(color: isMine ? Colors.white.withValues(alpha: 0.65) : context.onSurfaceFaded(0.5), fontSize: 10.5),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Превью фото в переписке живой помощи — тап открывает во весь экран.
/// Тот же паттерн, что в message_bubble.dart для чата с ИИ.
class _MessageImages extends StatelessWidget {
  final List<String> images;
  const _MessageImages({required this.images});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 6,
      runSpacing: 6,
      children: images.map((base64Image) {
        final bytes = base64Decode(base64Image);
        return GestureDetector(
          onTap: () => showDialog(
            context: context,
            builder: (context) => Dialog(
              backgroundColor: Colors.transparent,
              insetPadding: const EdgeInsets.all(16),
              child: GestureDetector(
                onTap: () => Navigator.of(context).pop(),
                child: InteractiveViewer(child: Image.memory(bytes, fit: BoxFit.contain)),
              ),
            ),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Image.memory(bytes, width: 120, height: 120, fit: BoxFit.cover),
          ),
        );
      }).toList(),
    );
  }
}

// снимок сообщений с ИИ, которым юзер согласился поделиться (см.
// подтверждение в chat_screen.dart). Развёрнут по умолчанию
class _ChatContextPanel extends StatefulWidget {
  final String text;
  const _ChatContextPanel({required this.text});

  @override
  State<_ChatContextPanel> createState() => _ChatContextPanelState();
}

class _ChatContextPanelState extends State<_ChatContextPanel> {
  bool _expanded = true;

  @override
  Widget build(BuildContext context) {
    return GlassPanel(
      opacity: 0.07,
      blurred: false,
      borderRadius: BorderRadius.circular(14),
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => setState(() => _expanded = !_expanded),
              child: Row(
                children: [
                  Icon(Icons.history_rounded, size: 14, color: context.onSurfaceFaded(0.5)),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      'Что происходило в чате с ИИ до этого обращения',
                      style: TextStyle(color: context.onSurfaceFaded(0.6), fontSize: 12, fontWeight: FontWeight.w600),
                    ),
                  ),
                  Icon(
                    _expanded ? Icons.expand_less_rounded : Icons.expand_more_rounded,
                    size: 18,
                    color: context.onSurfaceFaded(0.4),
                  ),
                ],
              ),
            ),
          ),
          if (_expanded) ...[
            const SizedBox(height: 8),
            ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 220),
              child: SingleChildScrollView(
                child: Text(
                  widget.text,
                  style: TextStyle(color: context.onSurfaceFaded(0.55), fontSize: 12.5, height: 1.5),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// оценка оператора звёздами, видна только тому, кто запрашивал помощь,
// после закрытия. Можно переоценить - сервер просто перезаписывает
class _RatingPanel extends StatefulWidget {
  final int? currentRating;
  final bool isSaving;
  final void Function(int stars, String? comment) onSubmit;
  const _RatingPanel({required this.currentRating, required this.isSaving, required this.onSubmit});

  @override
  State<_RatingPanel> createState() => _RatingPanelState();
}

class _RatingPanelState extends State<_RatingPanel> {
  late int _selected = widget.currentRating ?? 0;
  final _commentController = TextEditingController();
  bool _showCommentField = false;

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final alreadyRated = widget.currentRating != null;
    return GlassPanel(
      opacity: 0.09,
      borderRadius: BorderRadius.circular(16),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            alreadyRated ? 'Твоя оценка' : 'Как прошло общение с оператором?',
            style: TextStyle(color: context.onSurface, fontWeight: FontWeight.w600, fontSize: 13.5),
          ),
          const SizedBox(height: 10),
          Row(
            children: List.generate(5, (i) {
              final starIndex = i + 1;
              final filled = starIndex <= _selected;
              return IconButton(
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                icon: Icon(
                  filled ? Icons.star_rounded : Icons.star_border_rounded,
                  color: filled ? const Color(0xFFFFD166) : context.onSurfaceFaded(0.3),
                  size: 30,
                ),
                onPressed: widget.isSaving
                    ? null
                    : () => setState(() {
                          _selected = starIndex;
                          _showCommentField = true;
                        }),
              );
            }),
          ),
          if (_showCommentField && !alreadyRated) ...[
            const SizedBox(height: 8),
            TextField(
              controller: _commentController,
              maxLines: 2,
              style: TextStyle(color: context.onSurface, fontSize: 13),
              decoration: InputDecoration(
                filled: true,
                fillColor: context.onSurfaceFaded(0.07),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                contentPadding: const EdgeInsets.all(10),
                hintText: 'Комментарий (необязательно)',
                hintStyle: TextStyle(color: context.onSurfaceFaded(0.3)),
              ),
            ),
            const SizedBox(height: 10),
            Align(
              alignment: Alignment.centerRight,
              child: FilledButton(
                style: FilledButton.styleFrom(backgroundColor: const Color(0xFF6C5CE7)),
                onPressed: widget.isSaving || _selected == 0
                    ? null
                    : () => widget.onSubmit(_selected, _commentController.text.trim().isEmpty ? null : _commentController.text.trim()),
                child: widget.isSaving
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : const Text('Отправить'),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
