import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';

import '../models/sound_asset.dart';
import '../services/sounds_service.dart';
import '../state/auth_store.dart';
import '../theme/app_text_color.dart';
import '../widgets/app_background.dart';
import '../widgets/glass_panel.dart';

/// Список звуков категории sleep_music (загружает админ, см.
/// admin_sounds_screen.dart) — тап проигрывает/ставит на паузу, играет
/// только один трек за раз, зациклен, чтобы не обрывался внезапно.
class SleepMusicScreen extends StatefulWidget {
  final AuthStore authStore;
  const SleepMusicScreen({super.key, required this.authStore});

  @override
  State<SleepMusicScreen> createState() => _SleepMusicScreenState();
}

class _SleepMusicScreenState extends State<SleepMusicScreen> {
  final _service = SoundsService();
  final _player = AudioPlayer();
  List<SoundAsset> _sounds = [];
  int? _playingId;
  bool _isLoading = true;
  bool _isBuffering = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _player.setReleaseMode(ReleaseMode.loop);
    _load();
  }

  @override
  void dispose() {
    _service.dispose();
    _player.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    final token = widget.authStore.token;
    if (token == null) return;
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final sounds = await _service.list(baseUrl: widget.authStore.baseUrl, token: token, category: SoundCategory.sleepMusic);
      if (mounted) setState(() => _sounds = sounds);
    } on SoundsException catch (e) {
      if (mounted) setState(() => _error = e.message);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _toggle(SoundAsset sound) async {
    final token = widget.authStore.token;
    if (token == null) return;

    if (_playingId == sound.id) {
      await _player.stop();
      setState(() => _playingId = null);
      return;
    }

    setState(() => _isBuffering = true);
    try {
      final bytes = await _service.fetchAudioBytes(baseUrl: widget.authStore.baseUrl, token: token, soundId: sound.id);
      if (!mounted) return;
      await _player.play(BytesSource(bytes));
      setState(() => _playingId = sound.id);
    } on SoundsException catch (e) {
      if (mounted) setState(() => _error = e.message);
    } finally {
      if (mounted) setState(() => _isBuffering = false);
    }
  }

  // треков будет много - плеер по одному "нажми и жди следующий" неудобен.
  // индекс ищем в уже загруженном списке (_sounds) каждый раз заново, не
  // храним отдельно - список не меняется, пока экран открыт, так что
  // расхождения не будет, а отдельное поле только добавило бы риск забыть
  // синхронизировать при перезагрузке (_load())
  Future<void> _playAdjacent(int delta) async {
    if (_sounds.isEmpty) return;
    final currentIndex = _playingId == null ? -1 : _sounds.indexWhere((s) => s.id == _playingId);
    // если ничего не играло - "следующий" начинает с первого трека, а не
    // прыгает от несуществующей позиции. % в Dart для int всегда даёт
    // неотрицательный результат при положительном делителе (в отличие от
    // C/Java/JS) - оборачивание назад (delta=-1) работает без отдельной
    // проверки на отрицательное значение
    final nextIndex = currentIndex == -1 ? 0 : (currentIndex + delta) % _sounds.length;
    await _toggle(_sounds[nextIndex]);
  }

  @override
  Widget build(BuildContext context) {
    SoundAsset? playingSound;
    if (_playingId != null) {
      final idx = _sounds.indexWhere((s) => s.id == _playingId);
      if (idx != -1) playingSound = _sounds[idx];
    }
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
                    Text(
                      'Музыка для сна',
                      style: TextStyle(color: context.onSurface, fontSize: 18, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Center(
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Color(0xFF6C5CE7))
                      : SingleChildScrollView(
                          padding: const EdgeInsets.all(16),
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 480),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                if (_error != null) ...[
                                  Text(_error!, style: const TextStyle(color: Color(0xFFFFB4B4), fontSize: 13)),
                                  const SizedBox(height: 12),
                                ],
                                if (_sounds.isEmpty)
                                  Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 30),
                                    child: Center(
                                      child: Text(
                                        'Пока нет загруженной музыки — админ ещё не добавил её.',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(color: context.onSurfaceFaded(0.4)),
                                      ),
                                    ),
                                  )
                                else
                                  ..._sounds.map((s) => Padding(
                                        padding: const EdgeInsets.only(bottom: 10),
                                        child: Material(
                                          color: Colors.transparent,
                                          child: InkWell(
                                            borderRadius: BorderRadius.circular(16),
                                            onTap: _isBuffering ? null : () => _toggle(s),
                                            child: GlassPanel(
                                              opacity: 0.08,
                                              borderRadius: BorderRadius.circular(16),
                                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                              child: Row(
                                                children: [
                                                  Icon(
                                                    _playingId == s.id ? Icons.pause_circle_filled_rounded : Icons.play_circle_outline_rounded,
                                                    color: _playingId == s.id ? const Color(0xFF00E6A0) : context.onSurfaceFaded(0.6),
                                                    size: 28,
                                                  ),
                                                  const SizedBox(width: 12),
                                                  Expanded(
                                                    child: Text(s.title, style: TextStyle(color: context.onSurface, fontSize: 14.5)),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                      )),
                                // отступ снизу, чтобы последний трек списка не
                                // прятался под плеером с кнопками ниже
                                if (playingSound != null) const SizedBox(height: 76),
                              ],
                            ),
                          ),
                        ),
                ),
              ),
              if (playingSound != null)
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  child: GlassPanel(
                    opacity: 0.14,
                    borderRadius: BorderRadius.circular(20),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            playingSound.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(color: context.onSurface, fontSize: 13.5, fontWeight: FontWeight.w500),
                          ),
                        ),
                        IconButton(
                          icon: Icon(Icons.skip_previous_rounded, color: context.onSurfaceFaded(0.8)),
                          onPressed: _isBuffering ? null : () => _playAdjacent(-1),
                        ),
                        IconButton(
                          icon: const Icon(Icons.pause_circle_filled_rounded, color: Color(0xFF00E6A0)),
                          onPressed: _isBuffering ? null : () => _toggle(playingSound!),
                        ),
                        IconButton(
                          icon: Icon(Icons.skip_next_rounded, color: context.onSurfaceFaded(0.8)),
                          onPressed: _isBuffering ? null : () => _playAdjacent(1),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
