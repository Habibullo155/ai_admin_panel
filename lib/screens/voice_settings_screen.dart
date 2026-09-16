import 'package:flutter/material.dart';

import '../models/cloud_voice.dart';
import '../state/voice_store.dart';
import '../theme/app_text_color.dart';
import '../widgets/app_background.dart';
import '../widgets/glass_panel.dart';

enum _VoiceGender { female, male, other }

/// Эвристика по имени голоса — НЕ надёжна на 100% (движки синтеза речи
/// по-разному называют голоса на разных платформах), поэтому рядом с
/// каждым вариантом есть кнопка "прослушать": если категория ошиблась,
/// пользователь всё равно может на слух найти нужный голос.
_VoiceGender _guessGender(String name) {
  final lower = name.toLowerCase();
  const femaleMarkers = [
    'female', 'woman', '#female', 'milena', 'anna', 'alyona', 'алёна', 'анна',
    'elena', 'елена', 'olga', 'ольга', 'irina', 'ирина', 'katya', 'катя',
  ];
  const maleMarkers = [
    'male', 'man', '#male', 'yuri', 'юрий', 'pavel', 'павел', 'maxim',
    'максим', 'dmitri', 'дмитрий', 'ivan', 'иван', 'boris', 'борис',
  ];
  for (final m in femaleMarkers) {
    if (lower.contains(m)) return _VoiceGender.female;
  }
  for (final m in maleMarkers) {
    if (lower.contains(m)) return _VoiceGender.male;
  }
  return _VoiceGender.other;
}

class VoiceSettingsScreen extends StatefulWidget {
  final VoiceStore voiceStore;
  const VoiceSettingsScreen({super.key, required this.voiceStore});

  @override
  State<VoiceSettingsScreen> createState() => _VoiceSettingsScreenState();
}

class _VoiceSettingsScreenState extends State<VoiceSettingsScreen> {
  @override
  Widget build(BuildContext context) {
    final voice = widget.voiceStore;

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
                      'Голос',
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
                      constraints: const BoxConstraints(maxWidth: 480),
                      child: AnimatedBuilder(
                        animation: voice,
                        builder: (context, _) => _buildContent(context, voice),
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

  Widget _buildContent(BuildContext context, VoiceStore voice) {
    if (!voice.isVoiceFeatureEnabled) {
      return GlassPanel(
        opacity: 0.08,
        borderRadius: BorderRadius.circular(18),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(Icons.mic_off_rounded, color: context.onSurfaceFaded(0.4), size: 28),
            const SizedBox(height: 12),
            Text(
              'Голосовые функции временно выключены администратором.',
              style: TextStyle(color: context.onSurfaceFaded(0.6), fontSize: 13.5, height: 1.4),
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        GlassPanel(
          opacity: 0.08,
          borderRadius: BorderRadius.circular(18),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: Row(
            children: [
              Icon(
                voice.settings.voiceUiEnabled ? Icons.record_voice_over_rounded : Icons.voice_over_off_rounded,
                color: context.onSurfaceFaded(0.7),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text('Использовать голос', style: TextStyle(color: context.onSurface)),
              ),
              Switch(
                value: voice.settings.voiceUiEnabled,
                activeThumbColor: const Color(0xFF6C5CE7),
                onChanged: (value) => voice.updateSettings(voice.settings.copyWith(voiceUiEnabled: value)),
              ),
            ],
          ),
        ),
        if (!voice.settings.voiceUiEnabled) ...[
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Text(
              'Микрофон и озвучка ответов скрыты. Включи переключатель выше, чтобы вернуть их.',
              style: TextStyle(color: context.onSurfaceFaded(0.4), fontSize: 12.5, height: 1.4),
            ),
          ),
        ] else ...[
          const SizedBox(height: 20),
          _buildVoiceOptions(voice),
        ],
      ],
    );
  }

  Widget _buildVoiceOptions(VoiceStore voice) {
    final femaleVoices = voice.availableVoices.where((v) => _guessGender(v['name'] ?? '') == _VoiceGender.female).toList();
    final maleVoices = voice.availableVoices.where((v) => _guessGender(v['name'] ?? '') == _VoiceGender.male).toList();
    final otherVoices = voice.availableVoices.where((v) => _guessGender(v['name'] ?? '') == _VoiceGender.other).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _sectionLabel('РАСПОЗНАВАНИЕ РЕЧИ'),
        GlassPanel(
          opacity: 0.08,
          borderRadius: BorderRadius.circular(18),
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Icon(
                voice.isSttAvailable ? Icons.check_circle_rounded : Icons.error_outline_rounded,
                color: voice.isSttAvailable ? const Color(0xFF00E6A0) : Colors.white38,
                size: 20,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  voice.isSttAvailable
                      ? 'Микрофон доступен — кнопка появится рядом с полем ввода'
                      : 'Микрофон недоступен на этом устройстве (нет разрешения или движка распознавания)',
                  style: TextStyle(color: context.onSurfaceFaded(0.6), fontSize: 12.5),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        _sectionLabel('ОЗВУЧКА ОТВЕТОВ'),
        GlassPanel(
          opacity: 0.08,
          borderRadius: BorderRadius.circular(18),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: Row(
            children: [
              Expanded(
                child: Text('Озвучивать ответы автоматически', style: TextStyle(color: context.onSurface)),
              ),
              Switch(
                value: voice.settings.autoReadEnabled,
                activeThumbColor: const Color(0xFF6C5CE7),
                onChanged: (value) =>
                    voice.updateSettings(voice.settings.copyWith(autoReadEnabled: value)),
              ),
            ],
          ),
        ),
        if (voice.isCloudTtsAvailable) ...[
          const SizedBox(height: 20),
          _sectionLabel('ГОЛОС'),
          Text(
            'Прослушай каждый и выбери тот, что звучит для тебя спокойнее — '
            'на слух это надёжнее, чем описание.',
            style: TextStyle(color: context.onSurfaceFaded(0.4), fontSize: 11.5),
          ),
          const SizedBox(height: 10),
          ...elevenLabsCloudVoices.map((v) => _buildCloudVoiceTile(voice, v)),
        ] else if (voice.availableVoices.isEmpty) ...[
          const SizedBox(height: 16),
          Text(
            'Голоса ещё не загрузились или недоступны на этом устройстве.',
            style: TextStyle(color: context.onSurfaceFaded(0.4), fontSize: 12.5),
          ),
        ] else ...[
          if (femaleVoices.isNotEmpty) ...[
            const SizedBox(height: 20),
            _sectionLabel('ЖЕНСКИЙ ГОЛОС'),
            ...femaleVoices.map((v) => _buildVoiceTile(voice, v)),
          ],
          if (maleVoices.isNotEmpty) ...[
            const SizedBox(height: 20),
            _sectionLabel('МУЖСКОЙ ГОЛОС'),
            ...maleVoices.map((v) => _buildVoiceTile(voice, v)),
          ],
          if (otherVoices.isNotEmpty) ...[
            const SizedBox(height: 20),
            _sectionLabel('ДРУГИЕ ВАРИАНТЫ'),
            Text(
              'Не удалось определить голос по имени — просто послушай и выбери.',
              style: TextStyle(color: context.onSurfaceFaded(0.35), fontSize: 11.5),
            ),
            const SizedBox(height: 8),
            ...otherVoices.map((v) => _buildVoiceTile(voice, v)),
          ],
        ],
      ],
    );
  }

  Widget _buildCloudVoiceTile(VoiceStore voice, CloudVoice v) {
    final selected = v.name == voice.settings.cloudVoiceName;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: GlassPanel(
        opacity: selected ? 0.14 : 0.07,
        blurred: false, // список из нескольких голосов — см. message_bubble.dart
        borderRadius: BorderRadius.circular(14),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(14),
            onTap: () => voice.updateSettings(voice.settings.copyWith(cloudVoiceName: v.name)),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              child: Row(
                children: [
                  Icon(
                    v.isFemale ? Icons.face_3_rounded : Icons.face_6_rounded,
                    color: context.onSurfaceFaded(0.6),
                    size: 18,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(v.label, style: TextStyle(color: context.onSurface, fontSize: 13.5)),
                  ),
                  IconButton(
                    icon: Icon(Icons.play_circle_outline_rounded, color: context.onSurfaceFaded(0.6), size: 20),
                    tooltip: 'Прослушать',
                    onPressed: () => voice.previewCloudVoice(v.name),
                  ),
                  if (selected) const Icon(Icons.check_circle_rounded, color: Color(0xFF00E6A0), size: 18),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildVoiceTile(VoiceStore voice, Map<String, String> v) {
    final selected = v['name'] == voice.settings.voiceName && v['locale'] == voice.settings.voiceLocale;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: GlassPanel(
        opacity: selected ? 0.14 : 0.07,
        blurred: false, // список из многих голосов — см. message_bubble.dart
        borderRadius: BorderRadius.circular(14),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(14),
            onTap: () => voice.updateSettings(
              voice.settings.copyWith(voiceName: v['name'], voiceLocale: v['locale']),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          v['name'] ?? '',
                          style: TextStyle(color: context.onSurfaceFaded(0.9), fontSize: 13),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(v['locale'] ?? '', style: TextStyle(color: context.onSurfaceFaded(0.4), fontSize: 11)),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.play_circle_outline_rounded, color: context.onSurfaceFaded(0.6), size: 20),
                    tooltip: 'Прослушать',
                    onPressed: () => voice.previewVoice(v['name'] ?? '', v['locale'] ?? ''),
                  ),
                  if (selected) const Icon(Icons.check_circle_rounded, color: Color(0xFF00E6A0), size: 18),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _sectionLabel(String text) => Padding(
        padding: const EdgeInsets.only(bottom: 8, left: 4),
        child: Text(
          text,
          style: TextStyle(
            color: context.onSurfaceFaded(0.4),
            fontSize: 11,
            letterSpacing: 1.2,
            fontWeight: FontWeight.w600,
          ),
        ),
      );
}
