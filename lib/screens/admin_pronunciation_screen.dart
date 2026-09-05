import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';

import '../services/app_settings_service.dart';
import '../services/cloud_tts_service.dart';
import '../services/pronunciation_service.dart';
import '../state/auth_store.dart';
import '../theme/app_text_color.dart';
import '../widgets/app_background.dart';
import '../widgets/glass_panel.dart';

class AdminPronunciationScreen extends StatefulWidget {
  final AuthStore authStore;
  const AdminPronunciationScreen({super.key, required this.authStore});

  @override
  State<AdminPronunciationScreen> createState() => _AdminPronunciationScreenState();
}

class _AdminPronunciationScreenState extends State<AdminPronunciationScreen> {
  final _service = PronunciationService();
  final _settingsService = AppSettingsService();
  final _cloudTts = CloudTtsService();
  final _previewPlayer = AudioPlayer();
  final _wordController = TextEditingController();
  final _pronunciationController = TextEditingController();

  List<Map<String, String>> _entries = [];
  bool _isLoading = true;
  bool _isSaving = false;
  bool _isPreviewPlaying = false;
  bool _cloudTtsAvailable = false;
  String _defaultVoice = 'baya';
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _service.dispose();
    _settingsService.dispose();
    _previewPlayer.dispose();
    _wordController.dispose();
    _pronunciationController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    final token = widget.authStore.token;
    if (token == null) return;
    setState(() => _isLoading = true);
    try {
      final entries = await _service.listAdmin(baseUrl: widget.authStore.baseUrl, token: token);
      final settings = await _settingsService.getPublicSettings(widget.authStore.baseUrl);
      if (mounted) {
        setState(() {
          _entries = entries;
          _cloudTtsAvailable = settings.cloudTtsEnabled;
          _defaultVoice = settings.defaultVoice;
        });
      }
    } on PronunciationException catch (e) {
      if (mounted) setState(() => _error = e.message);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // сохраняет слово и сразу проигрывает ЕГО ПРОИЗНОШЕНИЕ так, как оно
  // прозвучит в реальном разговоре — синтез идёт через тот же
  // /api/tts/synthesize, что и обычная озвучка ответов, честно показывает
  // результат, а не просто "текст сохранён"
  Future<void> _addAndPreview() async {
    final token = widget.authStore.token;
    final word = _wordController.text.trim();
    final pronunciation = _pronunciationController.text.trim();
    if (token == null || word.isEmpty || pronunciation.isEmpty) return;

    setState(() {
      _isSaving = true;
      _error = null;
    });
    try {
      await _service.upsert(baseUrl: widget.authStore.baseUrl, token: token, word: word, pronunciation: pronunciation);
      _wordController.clear();
      _pronunciationController.clear();
      await _load();

      if (_cloudTtsAvailable) {
        setState(() => _isPreviewPlaying = true);
        final bytes = await _cloudTts.synthesize(
          baseUrl: widget.authStore.baseUrl,
          token: token,
          text: pronunciation,
          voiceName: _defaultVoice,
        );
        await _previewPlayer.play(BytesSource(bytes));
      }
    } on PronunciationException catch (e) {
      if (mounted) setState(() => _error = e.message);
    } catch (_) {
      // прослушивание — необязательная часть, слово уже сохранено к
      // этому моменту; молча не проигрываем, не превращаем это в ошибку
      // всей операции
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
          _isPreviewPlaying = false;
        });
      }
    }
  }

  Future<void> _previewExisting(String pronunciation) async {
    final token = widget.authStore.token;
    if (token == null || !_cloudTtsAvailable) return;
    setState(() => _isPreviewPlaying = true);
    try {
      final bytes = await _cloudTts.synthesize(
        baseUrl: widget.authStore.baseUrl,
        token: token,
        text: pronunciation,
        voiceName: _defaultVoice,
      );
      await _previewPlayer.play(BytesSource(bytes));
    } catch (_) {
      // то же самое — не критично, если прослушивание не сработало
    } finally {
      if (mounted) setState(() => _isPreviewPlaying = false);
    }
  }

  Future<void> _delete(String word) async {
    final token = widget.authStore.token;
    if (token == null) return;
    try {
      await _service.delete(baseUrl: widget.authStore.baseUrl, token: token, word: word);
      await _load();
    } on PronunciationException catch (e) {
      if (mounted) setState(() => _error = e.message);
    }
  }

  @override
  Widget build(BuildContext context) {
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
                      child: Text(
                        'Словарь произношения',
                        style: TextStyle(color: context.onSurface, fontSize: 17, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Center(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 560),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Простыми словами, с примером — раньше был абзац
                          // прозы без наглядного примера, что именно
                          // произойдёт с конкретным словом.
                          GlassPanel(
                            opacity: 0.07,
                            borderRadius: BorderRadius.circular(14),
                            padding: const EdgeInsets.all(14),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Если озвучка неправильно читает какое-то слово — научи её здесь.',
                                  style: TextStyle(color: context.onSurfaceFaded(0.7), fontSize: 13, height: 1.4),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  'Пример: слово «ИИ» озвучка может прочитать по буквам '
                                  '«и-и» — впиши «ИИ» слева и «искусственный интеллект» '
                                  'справа, и в разговоре она будет произносить это словами.',
                                  style: TextStyle(color: context.onSurfaceFaded(0.45), fontSize: 12, height: 1.4),
                                ),
                                if (!_cloudTtsAvailable) ...[
                                  const SizedBox(height: 8),
                                  Text(
                                    'Прослушать результат сразу нельзя — сервер облачной озвучки не настроен.',
                                    style: TextStyle(color: context.onSurfaceFaded(0.4), fontSize: 11.5),
                                  ),
                                ],
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),
                          _buildEditor(),
                          if (_error != null) ...[
                            const SizedBox(height: 10),
                            Text(_error!, style: const TextStyle(color: Color(0xFFFFB4B4), fontSize: 13)),
                          ],
                          const SizedBox(height: 20),
                          if (_isLoading)
                            const Padding(
                              padding: EdgeInsets.symmetric(vertical: 40),
                              child: Center(child: CircularProgressIndicator(color: Color(0xFF6C5CE7))),
                            )
                          else if (_entries.isEmpty)
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 30),
                              child: Center(
                                child: Text('Словарь пуст', style: TextStyle(color: context.onSurfaceFaded(0.4))),
                              ),
                            )
                          else
                            ..._entries.map(_buildEntryTile),
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

  Widget _buildEditor() {
    return GlassPanel(
      opacity: 0.08,
      borderRadius: BorderRadius.circular(16),
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('КАК НАПИСАНО В ТЕКСТЕ', style: TextStyle(color: context.onSurfaceFaded(0.4), fontSize: 10.5, letterSpacing: 1, fontWeight: FontWeight.w600)),
          const SizedBox(height: 6),
          TextField(
            controller: _wordController,
            style: TextStyle(color: context.onSurface, fontSize: 13.5),
            decoration: InputDecoration(
              filled: true,
              fillColor: context.onSurfaceFaded(0.08),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
              hintText: 'Например: ИИ',
              hintStyle: TextStyle(color: context.onSurfaceFaded(0.3)),
            ),
          ),
          const SizedBox(height: 12),
          Text('КАК ДОЛЖНО ПРОЗВУЧАТЬ', style: TextStyle(color: context.onSurfaceFaded(0.4), fontSize: 10.5, letterSpacing: 1, fontWeight: FontWeight.w600)),
          const SizedBox(height: 6),
          TextField(
            controller: _pronunciationController,
            style: TextStyle(color: context.onSurface, fontSize: 13.5),
            decoration: InputDecoration(
              filled: true,
              fillColor: context.onSurfaceFaded(0.08),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
              hintText: 'Например: искусственный интеллект',
              hintStyle: TextStyle(color: context.onSurfaceFaded(0.3)),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              style: FilledButton.styleFrom(backgroundColor: const Color(0xFF6C5CE7), padding: const EdgeInsets.symmetric(vertical: 13)),
              onPressed: _isSaving ? null : _addAndPreview,
              icon: _isSaving
                  ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : Icon(_cloudTtsAvailable ? Icons.volume_up_rounded : Icons.add_rounded, size: 18),
              label: Text(_cloudTtsAvailable ? 'Сохранить и прослушать' : 'Сохранить'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEntryTile(Map<String, String> entry) {
    final pronunciation = entry['pronunciation'] ?? '';
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: GlassPanel(
        opacity: 0.07,
        blurred: false, // список из многих слов — см. message_bubble.dart
        borderRadius: BorderRadius.circular(12),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        child: Row(
          children: [
            Expanded(
              child: Text(
                '${entry['word']} → $pronunciation',
                style: TextStyle(color: context.onSurface, fontSize: 13.5),
              ),
            ),
            if (_cloudTtsAvailable)
              IconButton(
                icon: Icon(Icons.volume_up_rounded, size: 18, color: context.onSurfaceFaded(0.6)),
                tooltip: 'Прослушать',
                onPressed: _isPreviewPlaying ? null : () => _previewExisting(pronunciation),
              ),
            IconButton(
              icon: const Icon(Icons.delete_outline_rounded, size: 18, color: Color(0xFFFFB4B4)),
              onPressed: () => _delete(entry['word'] ?? ''),
            ),
          ],
        ),
      ),
    );
  }
}
