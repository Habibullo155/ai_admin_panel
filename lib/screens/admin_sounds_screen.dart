import 'package:audioplayers/audioplayers.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

import '../models/sound_asset.dart';
import '../services/sounds_service.dart';
import '../state/auth_store.dart';
import '../theme/app_text_color.dart';
import '../widgets/app_background.dart';
import '../widgets/glass_panel.dart';

/// Загрузка звуков для трёх мест в приложении: эффект при "сжечь/разбить"
/// тяжёлую мысль (release), белый шум во время диалога (white_noise),
/// музыка для сна (sleep_music). Реальные аудиофайлы должен загрузить
/// админ сам — здесь только управление ими, готовых звуков в комплекте
/// нет (не то, что можно правдоподобно сгенерировать самому).
class AdminSoundsScreen extends StatefulWidget {
  final AuthStore authStore;
  final VoidCallback? onBack;
  const AdminSoundsScreen({super.key, required this.authStore, this.onBack});

  @override
  State<AdminSoundsScreen> createState() => _AdminSoundsScreenState();
}

class _AdminSoundsScreenState extends State<AdminSoundsScreen> {
  final _service = SoundsService();
  final _player = AudioPlayer();
  final _titleController = TextEditingController();
  SoundCategory _uploadCategory = SoundCategory.whiteNoise;
  List<SoundAsset> _sounds = [];
  bool _isLoading = true;
  bool _isUploading = false;
  int? _playingId;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _service.dispose();
    _player.dispose();
    _titleController.dispose();
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
      final sounds = await _service.adminList(baseUrl: widget.authStore.baseUrl, token: token);
      if (mounted) setState(() => _sounds = sounds);
    } on SoundsException catch (e) {
      if (mounted) setState(() => _error = e.message);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _pickAndUpload() async {
    final title = _titleController.text.trim();
    if (title.isEmpty) {
      setState(() => _error = 'Сначала укажи название звука.');
      return;
    }
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['mp3', 'wav'],
      withData: true,
    );
    if (result == null || result.files.isEmpty) return;
    final file = result.files.single;
    final bytes = file.bytes;
    if (bytes == null) {
      setState(() => _error = 'Не удалось прочитать файл.');
      return;
    }

    final token = widget.authStore.token;
    if (token == null) return;
    setState(() {
      _isUploading = true;
      _error = null;
    });
    try {
      await _service.upload(
        baseUrl: widget.authStore.baseUrl,
        token: token,
        title: title,
        category: _uploadCategory,
        bytes: bytes,
        filename: file.name,
      );
      _titleController.clear();
      await _load();
    } on SoundsException catch (e) {
      if (mounted) setState(() => _error = e.message);
    } finally {
      if (mounted) setState(() => _isUploading = false);
    }
  }

  Future<void> _togglePreview(SoundAsset sound) async {
    final token = widget.authStore.token;
    if (token == null) return;

    if (_playingId == sound.id) {
      await _player.stop();
      setState(() => _playingId = null);
      return;
    }

    try {
      final bytes = await _service.fetchAudioBytes(baseUrl: widget.authStore.baseUrl, token: token, soundId: sound.id);
      if (!mounted) return;
      setState(() => _playingId = sound.id);
      await _player.play(BytesSource(bytes));
      _player.onPlayerComplete.first.then((_) {
        if (mounted && _playingId == sound.id) setState(() => _playingId = null);
      });
    } on SoundsException catch (e) {
      if (mounted) setState(() => _error = e.message);
    }
  }

  Future<void> _delete(SoundAsset sound) async {
    final token = widget.authStore.token;
    if (token == null) return;
    try {
      if (_playingId == sound.id) {
        await _player.stop();
        setState(() => _playingId = null);
      }
      await _service.delete(baseUrl: widget.authStore.baseUrl, token: token, soundId: sound.id);
      await _load();
    } on SoundsException catch (e) {
      if (mounted) setState(() => _error = e.message);
    }
  }

  String _categoryLabel(SoundCategory c) {
    switch (c) {
      case SoundCategory.release:
        return 'Сжечь/разбить';
      case SoundCategory.whiteNoise:
        return 'Белый шум';
      case SoundCategory.sleepMusic:
        return 'Музыка для сна';
      case SoundCategory.streamWater:
        return 'Ручей (фон)';
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
                    // сайдбар в AdminShellScreen уже даёт навигацию - кнопка "назад" была
                    // бы бессмысленной, когда экран встроен содержимым (onBack задан).
                    // Показываем её только при обычном отдельном маршруте (onBack == null).
                    if (widget.onBack == null)
                      IconButton(
                        icon: Icon(Icons.arrow_back_rounded, color: context.onSurface),
                        onPressed: () => Navigator.of(context).pop(),
                      )
                    else
                      const SizedBox(width: 8),
                    Text(
                      'Звуки',
                      style: TextStyle(color: context.onSurface, fontSize: 18, fontWeight: FontWeight.w600),
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
                          if (_error != null) ...[
                            Text(_error!, style: const TextStyle(color: Color(0xFFFFB4B4), fontSize: 13)),
                            const SizedBox(height: 12),
                          ],
                          _buildUploadForm(),
                          const SizedBox(height: 24),
                          if (_isLoading)
                            const Padding(
                              padding: EdgeInsets.symmetric(vertical: 40),
                              child: Center(child: CircularProgressIndicator(color: Color(0xFF6C5CE7))),
                            )
                          else
                            ...SoundCategory.values.map(_buildCategorySection),
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

  Widget _buildUploadForm() {
    return GlassPanel(
      opacity: 0.08,
      borderRadius: BorderRadius.circular(16),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('ЗАГРУЗИТЬ ЗВУК', style: TextStyle(color: context.onSurfaceFaded(0.4), fontSize: 11, letterSpacing: 1.2, fontWeight: FontWeight.w600)),
          const SizedBox(height: 4),
          Text('Поддерживаются mp3 и wav, до 20 МБ.', style: TextStyle(color: context.onSurfaceFaded(0.4), fontSize: 11.5)),
          const SizedBox(height: 10),
          TextField(
            controller: _titleController,
            style: TextStyle(color: context.onSurface, fontSize: 13.5),
            decoration: InputDecoration(
              filled: true,
              fillColor: context.onSurfaceFaded(0.07),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
              hintText: 'Название (например: Дождь)',
              hintStyle: TextStyle(color: context.onSurfaceFaded(0.3)),
            ),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            children: SoundCategory.values.map((c) {
              final selected = _uploadCategory == c;
              return ChoiceChip(
                label: Text(_categoryLabel(c)),
                selected: selected,
                onSelected: (_) => setState(() => _uploadCategory = c),
                labelStyle: TextStyle(color: selected ? Colors.white : context.onSurfaceFaded(0.7), fontSize: 12.5),
                selectedColor: const Color(0xFF6C5CE7),
                backgroundColor: context.onSurfaceFaded(0.06),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                  side: BorderSide(color: context.onSurfaceFaded(0.12)),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              style: FilledButton.styleFrom(backgroundColor: const Color(0xFF6C5CE7), padding: const EdgeInsets.symmetric(vertical: 13)),
              onPressed: _isUploading ? null : _pickAndUpload,
              icon: _isUploading
                  ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : const Icon(Icons.upload_file_rounded, size: 18),
              label: const Text('Выбрать файл и загрузить'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategorySection(SoundCategory category) {
    final items = _sounds.where((s) => s.category == category).toList();
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(_categoryLabel(category), style: TextStyle(color: context.onSurfaceFaded(0.5), fontSize: 12, fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          if (items.isEmpty)
            Text('Пока ничего не загружено.', style: TextStyle(color: context.onSurfaceFaded(0.35), fontSize: 12.5))
          else
            ...items.map((s) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: GlassPanel(
                    opacity: 0.06,
                    blurred: false,
                    borderRadius: BorderRadius.circular(12),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    child: Row(
                      children: [
                        IconButton(
                          icon: Icon(
                            _playingId == s.id ? Icons.stop_circle_outlined : Icons.play_circle_outline_rounded,
                            color: context.onSurfaceFaded(0.7),
                          ),
                          onPressed: () => _togglePreview(s),
                        ),
                        Expanded(
                          child: Text(s.title, style: TextStyle(color: context.onSurface, fontSize: 13.5)),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete_outline_rounded, size: 18, color: Color(0xFFFFB4B4)),
                          onPressed: () => _delete(s),
                        ),
                      ],
                    ),
                  ),
                )),
        ],
      ),
    );
  }
}
