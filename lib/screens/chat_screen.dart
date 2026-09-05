import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';

import '../models/chat_message.dart';
import '../models/sound_asset.dart';
import '../services/sounds_service.dart';
import '../state/auth_store.dart';
import '../state/chat_store.dart';
import '../state/theme_store.dart';
import '../theme/app_text_color.dart';
import '../state/voice_store.dart';
import '../utils/responsive.dart';
import '../widgets/app_background.dart';
import '../widgets/chat_input_bar.dart';
import '../widgets/conversation_sidebar.dart';
import '../widgets/glass_panel.dart';
import '../widgets/message_bubble.dart';
import '../widgets/report_dialog.dart';
import 'admin_shell_screen.dart';
import 'asrs_screen.dart';
import 'blog_list_screen.dart';
import 'custom_test_list_screen.dart';
import 'gad7_screen.dart';
import 'phq9_screen.dart';
import 'profile_screen.dart';
import 'purchase_screen.dart';
import 'settings_screen.dart';
import 'sleep_music_screen.dart';
import 'verify_email_screen.dart';
import '../services/chat_api_service.dart';
import '../services/help_service.dart';
import 'help_session_chat_screen.dart';
import 'my_help_screen.dart';
import 'my_reports_screen.dart';
import 'operator_dashboard_screen.dart';
import 'support_screen.dart';
import 'wellbeing_screen.dart';

class ChatScreen extends StatefulWidget {
  final ChatStore store;
  final AuthStore authStore;
  final ThemeStore themeStore;
  final VoiceStore voiceStore;
  // true в MainShellScreen (нижнее меню на мобильных) - там Профиль и
  // Самочувствие уже есть внизу, не дублируем в выпадающем меню
  final bool hideShellDuplicates;
  const ChatScreen({
    super.key,
    required this.store,
    required this.authStore,
    required this.themeStore,
    required this.voiceStore,
    this.hideShellDuplicates = false,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  // маркер "выбрал тест, не режим разговора" в общем выборе _chooseAiMode()
  static const _testSentinel = 'test';
  // отдельный маркер для явного "Остановить" в листе выбора белого шума -
  // без него закрытие того же листа простым свайпом (тоже возвращает null)
  // было бы неотличимо от явной остановки и случайно гасило бы уже
  // играющий звук
  static const _stopNoiseSentinel = 'stop_noise';
  final _scrollController = ScrollController();
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final _soundsService = SoundsService();
  final _noisePlayer = AudioPlayer();
  int? _playingNoiseId;
  bool _isLoadingNoise = false;

  @override
  void dispose() {
    // белый шум звучит только "на фоне диалога" - при выходе из чата
    // не должен продолжать играть в фоне бесконтрольно
    _noisePlayer.dispose();
    _soundsService.dispose();
    super.dispose();
  }

  Future<void> _toggleWhiteNoise() async {
    final token = widget.authStore.token;
    if (token == null) return;
    setState(() => _isLoadingNoise = true);
    try {
      final sounds = await _soundsService.list(
        baseUrl: widget.authStore.baseUrl,
        token: token,
        category: SoundCategory.whiteNoise,
      );
      if (!mounted) return;
      if (sounds.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Пока нет загруженных звуков — админ ещё не добавил их.')),
        );
        return;
      }

      // если уже играет и звук всего один - тап просто выключает, спрашивать
      // нечего. Если звуков несколько - даже при одном играющем сейчас
      // всегда открываем список заново (а не сразу стоп), чтобы можно было
      // переключиться на другой трек одним тапом, не выключая сначала
      SoundAsset? chosen;
      if (_playingNoiseId != null && sounds.length == 1) {
        await _noisePlayer.stop();
        setState(() => _playingNoiseId = null);
        return;
      } else if (sounds.length == 1) {
        chosen = sounds.first;
      } else {
        // Object?, не SoundAsset? - иначе "Остановить" (не SoundAsset) и
        // обычное закрытие свайпом (тоже null) неразличимы, а это разные
        // вещи: явная остановка должна остановить звук, случайный свайп -
        // просто закрыть лист, ничего не меняя
        final result = await showModalBottomSheet<Object>(
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
                  if (_playingNoiseId != null)
                    ListTile(
                      leading: const Icon(Icons.stop_circle_outlined, color: Colors.white),
                      title: const Text('Остановить', style: TextStyle(color: Colors.white)),
                      onTap: () => Navigator.of(context).pop(_stopNoiseSentinel),
                    ),
                  ...sounds.map((s) => ListTile(
                        leading: Icon(
                          s.id == _playingNoiseId ? Icons.graphic_eq_rounded : Icons.music_note_outlined,
                          color: s.id == _playingNoiseId ? const Color(0xFF00E6A0) : Colors.white,
                        ),
                        title: Text(s.title, style: const TextStyle(color: Colors.white)),
                        onTap: () => Navigator.of(context).pop(s),
                      )),
                ],
              ),
            ),
          ),
        );

        if (result == _stopNoiseSentinel) {
          await _noisePlayer.stop();
          if (mounted) setState(() => _playingNoiseId = null);
          return;
        }
        // result == null здесь означает закрытие свайпом без выбора -
        // ничего не меняем, просто выходим, не трогая уже играющий звук
        if (result == null) return;
        chosen = result as SoundAsset;
      }
      if (!mounted) return;
      if (chosen.id == _playingNoiseId) return; // выбрали тот же трек, что уже играет - ничего не делаем

      final bytes = await _soundsService.fetchAudioBytes(baseUrl: widget.authStore.baseUrl, token: token, soundId: chosen.id);
      if (!mounted) return;
      await _noisePlayer.setReleaseMode(ReleaseMode.loop);
      await _noisePlayer.play(BytesSource(bytes));
      setState(() => _playingNoiseId = chosen!.id);
    } on SoundsException catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message)));
    } finally {
      if (mounted) setState(() => _isLoadingNoise = false);
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) return;
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent + 120,
        duration: const Duration(milliseconds: 260),
        curve: Curves.easeOut,
      );
    });
  }

  Future<void> _handleSend(String text, {List<String>? images}) async {
    _scrollToBottom();
    await widget.store.sendMessage(text, images: images);
    _scrollToBottom();
    _maybeAutoReadLastResponse();
  }

  // только запасной путь для голоса на устройстве - облачный уже прочитан
  // по предложениям во время генерации (onAssistantTextChunk -> onIncomingText)
  void _maybeAutoReadLastResponse() {
    final voice = widget.voiceStore;
    if (!voice.settings.autoReadEnabled || !voice.isVoiceAvailable) return;
    if (voice.isCloudTtsAvailable) return;
    final convo = widget.store.active;
    if (convo == null || convo.messages.isEmpty) return;
    final last = convo.messages.last;
    if (last.role == MessageRole.assistant && !last.isError && last.content.trim().isNotEmpty) {
      voice.speak(last.content);
    }
  }

  // ближайшее сообщение юзера перед ответом - вопрос, на который отвечала
  // модель, для жалобы (видно вопрос и ответ вместе)
  String _precedingUserMessage(List<ChatMessage> messages, int assistantIndex) {
    for (var i = assistantIndex - 1; i >= 0; i--) {
      if (messages[i].role == MessageRole.user) return messages[i].content;
    }
    return '(вопрос не найден)';
  }

  // последние 15 сообщений для оператора при запросе живой помощи - не
  // автоматически, юзер подтверждает это в диалоге ниже
  String? _recentChatSnapshot() {
    final messages = widget.store.active?.messages;
    if (messages == null || messages.isEmpty) return null;
    final recent = messages.length > 15 ? messages.sublist(messages.length - 15) : messages;
    final lines = recent.map((m) {
      final who = m.role == MessageRole.user ? 'Пользователь' : 'ИИ';
      return '$who: ${m.content}';
    });
    return lines.join('\n');
  }

  // Раньше "поговорить об этом с ИИ" (развод/утрата/потеря работы/КПТ)
  // жило в отдельном экране внутри "Самочувствия" вперемешку с
  // дыханием/заземлением — при том, что сами эти упражнения и так
  // доступны там напрямую. Здесь — единая, логичная точка входа: выбрал
  // режим, сразу начался разговор, не нужно объяснять заново.
  Future<void> _chooseAiMode() async {
    final choice = await showModalBottomSheet<Object>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: GlassPanel(
            opacity: 0.18,
            borderRadius: BorderRadius.circular(20),
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // "Как ты сегодня?" - раньше жило в Самочувствии отдельной
                // плиткой; перенесено сюда же, куда переехали тесты - один
                // логичный центр для всего, что касается разговора с ИИ
                AnimatedBuilder(
                  animation: ThemeStore.instance,
                  builder: (context, _) {
                    final active = ThemeStore.instance.reducedContrast;
                    return Container(
                      margin: const EdgeInsets.only(bottom: 14),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(14),
                        color: context.onSurfaceFaded(0.05),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.brightness_low_outlined, color: context.onSurfaceFaded(0.6), size: 18),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'Мигрень или сильная усталость',
                              style: TextStyle(color: context.onSurfaceFaded(0.75), fontSize: 12.5),
                            ),
                          ),
                          Switch(
                            value: active,
                            onChanged: (v) => ThemeStore.instance.setReducedContrast(v),
                            activeThumbColor: const Color(0xFF6C5CE7),
                          ),
                        ],
                      ),
                    );
                  },
                ),
                Text(
                  'Что нужно сейчас?',
                  style: TextStyle(color: context.onSurface, fontSize: 16, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 12),
                ..._AiMode.values.map(
                  (mode) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: _modeTile(
                      icon: mode.icon,
                      title: mode.title,
                      subtitle: mode.subtitle,
                      onTap: () => Navigator.of(context).pop(mode),
                    ),
                  ),
                ),
                _modeTile(
                  icon: Icons.checklist_rtl_rounded,
                  title: 'Пройти тест',
                  subtitle: 'Опросник — результат сразу обсудим здесь',
                  onTap: () => Navigator.of(context).pop(_testSentinel),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    if (choice == null || !mounted) return;

    if (choice == _testSentinel) {
      await _chooseTest();
      return;
    }

    final mode = choice as _AiMode;
    widget.store.createNewChat();
    await widget.store.sendMessage(mode.opener);
    _scrollToBottom();
  }

  Widget _modeTile({required IconData icon, required String title, required String subtitle, required VoidCallback onTap}) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            color: context.onSurfaceFaded(0.06),
            border: Border.all(color: context.onSurfaceFaded(0.1)),
          ),
          child: Row(
            children: [
              Icon(icon, color: context.onSurfaceFaded(0.75), size: 20),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: TextStyle(color: context.onSurface, fontSize: 13.5, fontWeight: FontWeight.w500)),
                    Text(subtitle, style: TextStyle(color: context.onSurfaceFaded(0.45), fontSize: 11.5)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Раньше тесты жили только как отдельные статичные экраны без связи с
  // разговором - результат просто повисал сам по себе. Теперь тест можно
  // начать прямо отсюда, а после прохождения — сразу продолжить с ИИ, не
  // теряя контекст (кнопка "Обсудить с ИИ" на экране результата каждого
  // теста отправляет туда честную сводку). ВОЗ-5 сюда пока не входит -
  // он встроен внутрь экрана "Самочувствие" отдельно.
  //
  // Раньше здесь ещё был createNewChat() перед отправкой - если человек
  // уже вёл разговор с ИИ и прошёл тест ПРЯМО ОТТУДА, это обрывало
  // текущий чат и создавало новый, ровно противоположное тому, что
  // задумывалось фразой "не теряя контекст". Теперь сводка идёт в уже
  // активный чат, каким бы он ни был.
  Future<void> _chooseTest() async {
    final userId = widget.authStore.user?.id.toString();
    if (userId == null || !mounted) return;

    Future<void> discuss(String summary) async {
      await widget.store.sendMessage(summary);
      _scrollToBottom();
    }

    final test = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: GlassPanel(
            opacity: 0.18,
            borderRadius: BorderRadius.circular(20),
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Какой опросник?',
                  style: TextStyle(color: context.onSurface, fontSize: 16, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 12),
                _modeTile(
                  icon: Icons.mood_outlined,
                  title: 'PHQ-9',
                  subtitle: 'Депрессивные симптомы, 9 вопросов',
                  onTap: () => Navigator.of(context).pop('phq9'),
                ),
                const SizedBox(height: 8),
                _modeTile(
                  icon: Icons.waves_rounded,
                  title: 'GAD-7',
                  subtitle: 'Тревожные симптомы, 7 вопросов',
                  onTap: () => Navigator.of(context).pop('gad7'),
                ),
                const SizedBox(height: 8),
                _modeTile(
                  icon: Icons.bolt_outlined,
                  title: 'ASRS-v1.1',
                  subtitle: 'Скрининг СДВГ, 6 вопросов',
                  onTap: () => Navigator.of(context).pop('asrs'),
                ),
                const SizedBox(height: 8),
                _modeTile(
                  icon: Icons.fact_check_outlined,
                  title: 'Другие тесты',
                  subtitle: 'Опросники, созданные командой',
                  onTap: () => Navigator.of(context).pop('custom'),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    if (test == null || !mounted) return;

    switch (test) {
      case 'phq9':
        await Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => Phq9Screen(userId: userId, onDiscussWithAi: discuss)),
        );
        break;
      case 'gad7':
        await Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => Gad7Screen(userId: userId, onDiscussWithAi: discuss)),
        );
        break;
      case 'asrs':
        await Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => AsrsScreen(userId: userId, onDiscussWithAi: discuss)),
        );
        break;
      case 'custom':
        await Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => CustomTestListScreen(authStore: widget.authStore, onDiscussWithAi: discuss)),
        );
        break;
    }
  }

  Future<void> _requestLiveHelp() async {
    final snapshot = _recentChatSnapshot();

    // 'share' | 'no_share' | null(отмена) — раньше единственная кнопка
    // "Позвать" неявно тащила с собой перепиской, если она была; теперь
    // это отдельный, явный выбор самого пользователя, а не подразумеваемое
    // поведение.
    final choice = await showDialog<String>(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: GlassPanel(
          opacity: 0.18,
          borderRadius: BorderRadius.circular(20),
          padding: const EdgeInsets.all(20),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 380),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Позвать человека на помощь?',
                  style: TextStyle(color: context.onSurface, fontSize: 16, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                Text(
                  'Подключится врач или специалист из команды. Это не замена '
                  'экстренной службе — если ситуация требует срочной '
                  'медицинской помощи, звони 103.',
                  style: TextStyle(color: context.onSurfaceFaded(0.65), fontSize: 13, height: 1.5),
                ),
                if (snapshot != null) ...[
                  const SizedBox(height: 14),
                  Text(
                    'Подготовить врачу краткую сводку о разговоре с ИИ '
                    '(не переписку целиком), чтобы не объяснять всё заново?',
                    style: TextStyle(color: context.onSurfaceFaded(0.55), fontSize: 12.5, height: 1.4),
                  ),
                ],
                const SizedBox(height: 18),
                if (snapshot != null) ...[
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      style: FilledButton.styleFrom(backgroundColor: const Color(0xFF6C5CE7)),
                      onPressed: () => Navigator.of(context).pop('share'),
                      child: const Text('Да, подготовить сводку'),
                    ),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(side: BorderSide(color: context.onSurfaceFaded(0.2))),
                      onPressed: () => Navigator.of(context).pop('no_share'),
                      child: Text('Нет, не показывать', style: TextStyle(color: context.onSurfaceFaded(0.85))),
                    ),
                  ),
                ] else
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      style: FilledButton.styleFrom(backgroundColor: const Color(0xFF6C5CE7)),
                      onPressed: () => Navigator.of(context).pop('no_share'),
                      child: const Text('Позвать'),
                    ),
                  ),
                const SizedBox(height: 8),
                Center(
                  child: TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: Text('Отмена', style: TextStyle(color: context.onSurfaceFaded(0.5))),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    if (choice == null || !mounted) return;

    final token = widget.authStore.token;
    if (token == null) return;

    String? doctorContext;
    if (choice == 'share' && snapshot != null) {
      // короткая сводка от ИИ вместо сырой переписки - см. generateDoctorSummary
      // в chat_api_service.dart. Если не получилось (сеть, модель недоступна) -
      // не блокируем весь вызов помощи, просто идём дальше без контекста
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator(color: Color(0xFF6C5CE7))),
      );
      try {
        final recentMessages = widget.store.active?.messages ?? [];
        final trimmed = recentMessages.length > 15 ? recentMessages.sublist(recentMessages.length - 15) : recentMessages;
        doctorContext = await ChatApiService().generateDoctorSummary(
          baseUrl: widget.authStore.baseUrl,
          recentMessages: trimmed,
          authToken: token,
        );
      } catch (_) {
        doctorContext = null;
      } finally {
        if (mounted) Navigator.of(context).pop();
      }
      if (!mounted) return;
    }

    final service = HelpService();
    try {
      final session = await service.createSession(
        baseUrl: widget.authStore.baseUrl,
        token: token,
        chatContext: doctorContext,
      );
      if (!mounted) return;
      Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => HelpSessionChatScreen(authStore: widget.authStore, session: session)),
      );
    } on HelpException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message)));
    } finally {
      service.dispose();
    }
  }

  @override
  Widget build(BuildContext context) {
    final showSidebar = Responsive.showPersistentSidebar(context);
    final sidebarWidth = Responsive.sidebarWidth(context);

    return Scaffold(
      key: _scaffoldKey,
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.transparent,
      drawer: showSidebar
          ? null
          : Drawer(
              backgroundColor: Colors.transparent,
              child: AppBackground(
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Align(
                          alignment: Alignment.topRight,
                          child: IconButton(
                            icon: Icon(Icons.close_rounded, color: context.onSurfaceFaded(0.7)),
                            tooltip: 'Закрыть',
                            onPressed: () => Navigator.of(context).pop(),
                          ),
                        ),
                        Expanded(
                          child: ConversationSidebar(
                            store: widget.store,
                            authStore: widget.authStore,
                            onSelected: () => Navigator.of(context).pop(),
                            onCallHelp: _requestLiveHelp,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
      body: AppBackground(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (showSidebar) ...[
                  SizedBox(
                    width: sidebarWidth,
                    child: ConversationSidebar(store: widget.store, authStore: widget.authStore, onCallHelp: _requestLiveHelp),
                  ),
                  const SizedBox(width: 16),
                ],
                Expanded(child: _buildChatArea(context, showSidebar)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildChatArea(BuildContext context, bool showSidebar) {
    final maxWidth = Responsive.chatMaxWidth(context);

    return AnimatedBuilder(
      animation: widget.store,
      builder: (context, _) {
        final convo = widget.store.active;
        final messages = convo?.messages ?? const <ChatMessage>[];
        final canRegenerate = messages.isNotEmpty &&
            messages.last.role == MessageRole.assistant &&
            !messages.last.isStreaming &&
            !widget.store.isSending;

        return Column(
          children: [
            _buildTopBar(context, showSidebar, convo?.title ?? 'Новый чат'),
            if (widget.authStore.user?.isEmailVerified == false) _buildVerifyEmailBanner(),
            const SizedBox(height: 12),
            Expanded(
              child: Center(
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: maxWidth),
                  child: messages.isEmpty
                      ? _EmptyState(onPromptTap: _handleSend)
                      : ListView.builder(
                          controller: _scrollController,
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          itemCount: messages.length,
                          itemBuilder: (context, i) => MessageBubble(
                            message: messages[i],
                            onDelete: () => widget.store.deleteMessage(messages[i].id),
                            onEdit: messages[i].role == MessageRole.user
                                ? (newText) async {
                                    await widget.store.editAndResend(messages[i].id, newText);
                                    _scrollToBottom();
                                    _maybeAutoReadLastResponse();
                                  }
                                : null,
                            onReport: messages[i].role == MessageRole.assistant
                                ? () => showReportDialog(
                                      context,
                                      authStore: widget.authStore,
                                      userMessage: _precedingUserMessage(messages, i),
                                      aiResponse: messages[i].content,
                                    )
                                : null,
                            onSpeak: messages[i].role == MessageRole.assistant &&
                                    widget.voiceStore.isVoiceAvailable
                                ? () => widget.voiceStore.speak(messages[i].content)
                                : null,
                            // дизлайк = тот же поток, что жалоба - причина и на разбор
                            // админам. Лайк - просто локальная пометка
                            onRate: messages[i].role == MessageRole.assistant && !messages[i].isStreaming
                                ? (liked) {
                                    if (liked) {
                                      widget.store.rateMessage(messages[i].id, true);
                                    } else {
                                      widget.store.rateMessage(messages[i].id, false);
                                      showReportDialog(
                                        context,
                                        authStore: widget.authStore,
                                        userMessage: _precedingUserMessage(messages, i),
                                        aiResponse: messages[i].content,
                                      );
                                    }
                                  }
                                : null,
                            // только для последнего ответа, кнопка теперь в пузыре
                            onRegenerate: messages[i].role == MessageRole.assistant &&
                                    i == messages.length - 1 &&
                                    canRegenerate
                                ? () async {
                                    await widget.store.regenerateLastResponse();
                                    _scrollToBottom();
                                    _maybeAutoReadLastResponse();
                                  }
                                : null,
                            onTestPromptResponse: messages[i].offersTestPrompt
                                ? (yes) async {
                                    setState(() => messages[i].testPromptAnswered = true);
                                    if (yes) {
                                      await _chooseTest();
                                    } else {
                                      // естественное продолжение разговора, не сухой
                                      // технический отказ - ИИ должен просто продолжить,
                                      // а не решить, что диалог на этом закончен.
                                      // Скрытое сообщение (isHidden) - человек нажал
                                      // кнопку, не печатал текст, в чате не должно
                                      // появиться пузыря, будто он это напечатал сам
                                      await widget.store.sendHiddenContinuation(
                                        'Пользователь нажал "Нет, не сейчас" на предложение теста. '
                                        'Просто продолжи разговор дальше, естественно, не упоминая '
                                        'явно сам отказ и не извиняясь за предложение.',
                                      );
                                      _scrollToBottom();
                                    }
                                  }
                                : null,
                            onThemePickerDismissed: messages[i].offersThemePicker
                                ? () => setState(() => messages[i].themePickerAnswered = true)
                                : null,
                          ),
                        ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: maxWidth),
                child: ChatInputBar(
                  enabled: !widget.store.isSending,
                  onSend: _handleSend,
                  voiceStore: widget.voiceStore,
                  onQuickStart: _chooseAiMode,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'ИИ может ошибаться. Проверяй важную информацию самостоятельно.',
              textAlign: TextAlign.center,
              style: TextStyle(color: context.onSurfaceFaded(0.28), fontSize: 10.5),
            ),
          ],
        );
      },
    );
  }

  // мягкое напоминание, не блокирующее использование - см. комментарий
  // в backend/models_db.py про is_email_verified: сбой SMTP не должен
  // запирать человека из приложения, поэтому баннер только предлагает,
  // не требует
  Widget _buildVerifyEmailBanner() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => VerifyEmailScreen(store: widget.authStore)),
          ),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              color: const Color(0xFFFFD166).withValues(alpha: 0.12),
              border: Border.all(color: const Color(0xFFFFD166).withValues(alpha: 0.3)),
            ),
            child: Row(
              children: [
                const Icon(Icons.mark_email_unread_outlined, color: Color(0xFFFFD166), size: 18),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Подтверди почту',
                    style: TextStyle(color: context.onSurfaceFaded(0.85), fontSize: 12.5, fontWeight: FontWeight.w500),
                  ),
                ),
                Icon(Icons.chevron_right_rounded, color: context.onSurfaceFaded(0.4), size: 18),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTopBar(BuildContext context, bool showSidebar, String title) {
    return GlassPanel(
      opacity: 0.08,
      borderRadius: BorderRadius.circular(22),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          if (!showSidebar)
            IconButton(
              icon: Icon(Icons.menu_rounded, color: context.onSurface),
              onPressed: () => _scaffoldKey.currentState?.openDrawer(),
            ),
          Expanded(
            child: Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: context.onSurface,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          IconButton(
            icon: _isLoadingNoise
                ? SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: context.onSurface))
                : Icon(
                    _playingNoiseId != null ? Icons.graphic_eq_rounded : Icons.spa_outlined,
                    color: _playingNoiseId != null ? const Color(0xFF00E6A0) : context.onSurfaceFaded(0.7),
                  ),
            tooltip: _playingNoiseId != null ? 'Выключить фоновый звук' : 'Включить фоновый звук',
            onPressed: _isLoadingNoise ? null : _toggleWhiteNoise,
          ),
          _buildMenuButton(context),
        ],
      ),
    );
  }

  Widget _buildMenuButton(BuildContext context) {
    final isAdmin = widget.authStore.user?.isAdmin ?? false;
    final isOperator = widget.authStore.user?.isOperator ?? false;
    return PopupMenuButton<String>(
      tooltip: 'Меню',
      icon: Icon(Icons.account_circle_rounded, color: context.onSurface),
      color: const Color(0xFF1A2036),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      onSelected: (value) {
        switch (value) {
          case 'profile':
            Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => ProfileScreen(authStore: widget.authStore)),
            );
            break;
          case 'wellbeing':
            final userId = widget.authStore.user?.id.toString();
            if (userId == null) return;
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => WellbeingScreen(
                  userId: userId,
                  voiceStore: widget.voiceStore,
                  authStore: widget.authStore,
                  onStartAiConversation: (text) async {
                    // без createNewChat() - см. комментарий у _chooseTest()
                    // выше про ту же проблему: не обрываем уже идущий
                    // разговор ради нового
                    await widget.store.sendMessage(text);
                    if (mounted) Navigator.of(context).popUntil((route) => route.isFirst);
                  },
                ),
              ),
            );
            break;
          case 'purchase':
            Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => PurchaseScreen(authStore: widget.authStore)),
            );
            break;
          case 'settings':
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => SettingsScreen(
                  authStore: widget.authStore,
                  chatStore: widget.store,
                  themeStore: widget.themeStore,
                  voiceStore: widget.voiceStore,
                ),
              ),
            );
            break;
          case 'my_reports':
            Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => MyReportsScreen(authStore: widget.authStore)),
            );
            break;
          case 'my_help':
            Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => MyHelpScreen(authStore: widget.authStore)),
            );
            break;
          case 'operator':
            Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => OperatorDashboardScreen(authStore: widget.authStore)),
            );
            break;
          case 'support':
            Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => SupportScreen(authStore: widget.authStore)),
            );
            break;
          case 'blog':
            Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => BlogListScreen(authStore: widget.authStore)),
            );
            break;
          case 'sleep_music':
            Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => SleepMusicScreen(authStore: widget.authStore)),
            );
            break;
          case 'admin':
            Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => AdminShellScreen(authStore: widget.authStore)),
            );
            break;
        }
      },
      itemBuilder: (context) => [
        if (!widget.hideShellDuplicates) ...[
          _menuItem('profile', Icons.account_circle_outlined, 'Личный кабинет'),
          _menuItem('wellbeing', Icons.self_improvement_rounded, 'Самочувствие'),
          _menuItem('sleep_music', Icons.nightlight_outlined, 'Музыка для сна'),
        ],
        _menuItem('purchase', Icons.workspace_premium_rounded, 'Подписка'),
        _menuItem('settings', Icons.settings_outlined, 'Настройки'),
        _menuItem('my_reports', Icons.flag_outlined, 'Мои жалобы'),
        _menuItem('my_help', Icons.support_rounded, 'Живая помощь'),
        if (isOperator) _menuItem('operator', Icons.headset_mic_rounded, 'Кабинет оператора'),
        _menuItem('support', Icons.support_agent_rounded, 'Поддержка'),
        _menuItem('blog', Icons.article_outlined, 'Блог'),
        if (isAdmin) _menuItem('admin', Icons.admin_panel_settings_rounded, 'Админ-панель'),
      ],
    );
  }

  PopupMenuItem<String> _menuItem(String value, IconData icon, String label) {
    return PopupMenuItem(
      value: value,
      child: Row(
        children: [
          Icon(icon, size: 18, color: Colors.white70),
          const SizedBox(width: 12),
          Text(label, style: const TextStyle(color: Colors.white)),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final ValueChanged<String> onPromptTap;
  const _EmptyState({required this.onPromptTap});

  static const _suggestions = [
    'Объясни квантовую физику простыми словами',
    'Напиши план тренировок на неделю',
    'Помоги придумать название для проекта',
    'Как улучшить свой код на Dart?',
  ];

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const LinearGradient(
                  colors: [Color(0xFF6C5CE7), Color(0xFF00D9C0)],
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF6C5CE7).withValues(alpha: 0.5),
                    blurRadius: 30,
                  ),
                ],
              ),
              child: const Icon(Icons.spa_rounded,
                  color: Colors.white, size: 34),
            ),
            const SizedBox(height: 20),
            Text(
              'Чем помочь сегодня?',
              style: TextStyle(
                color: context.onSurfaceFaded(0.92),
                fontSize: 22,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 24),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              alignment: WrapAlignment.center,
              children: _suggestions
                  .map((s) => _SuggestionChip(text: s, onTap: () => onPromptTap(s)))
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }
}

class _SuggestionChip extends StatelessWidget {
  final String text;
  final VoidCallback onTap;
  const _SuggestionChip({required this.text, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GlassPanel(
      opacity: 0.08,
      borderRadius: BorderRadius.circular(16),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Text(
              text,
              style: TextStyle(color: context.onSurfaceFaded(0.85), fontSize: 13),
            ),
          ),
        ),
      ),
    );
  }
}

/// Режимы разговора с ИИ, доступные через _chooseAiMode() выше. Первые
/// два — общие, на любой случай; остальные четыре раньше жили в
/// отдельном экране "Ситуативная помощь" внутри Самочувствия — перенесены
/// сюда, потому что сами упражнения (дыхание/заземление/благодарность),
/// которые тот экран тоже предлагал, и так доступны в Самочувствии напрямую.
enum _AiMode {
  support(
    icon: Icons.favorite_border_rounded,
    title: 'Поддержать',
    subtitle: 'Просто побыть рядом в разговоре',
    opener: 'Мне сейчас нужна поддержка — просто побудь рядом в разговоре, подбодри меня.',
  ),
  listen(
    icon: Icons.hearing_outlined,
    title: 'Просто выслушать',
    subtitle: 'Не обязательно сразу советовать',
    opener: 'Мне просто нужно выговориться — послушай, не обязательно сразу давать советы.',
  ),
  breakup(
    icon: Icons.heart_broken_outlined,
    title: 'Развод или разрыв отношений',
    subtitle: 'Начать разговор об этом',
    opener: 'У меня сейчас развод или расставание, и мне тяжело с этим '
        'справляться. Можешь поддержать меня в разговоре об этом?',
  ),
  grief(
    icon: Icons.spa_outlined,
    title: 'Тяжёлая утрата',
    subtitle: 'Начать разговор об этом',
    opener: 'У меня недавно случилась тяжёлая утрата близкого человека, '
        'и мне хочется с кем-то об этом поговорить.',
  ),
  jobLoss(
    icon: Icons.work_off_outlined,
    title: 'Потеря работы или крупные перемены',
    subtitle: 'Начать разговор об этом',
    opener: 'У меня сейчас сложный период — потеряна работа или '
        'произошла резкая перемена в жизни, и это тяжело '
        'переживать. Можешь поддержать меня в разговоре об этом?',
  ),
  rationalizer(
    icon: Icons.balance_outlined,
    title: 'Рационализатор',
    subtitle: 'Разобрать тревожную мысль по методике КПТ',
    opener: 'У меня есть тревожная мысль, которая не даёт покоя. '
        'Помоги мне разобрать её по методике КПТ — задавай мне '
        'наводящие вопросы по одному за раз (например, какие есть '
        'доказательства этой мысли, что самое худшее может '
        'случиться и насколько это вероятно), чтобы посмотреть '
        'на ситуацию яснее.',
  );

  final IconData icon;
  final String title;
  final String subtitle;
  final String opener;
  const _AiMode({required this.icon, required this.title, required this.subtitle, required this.opener});
}
