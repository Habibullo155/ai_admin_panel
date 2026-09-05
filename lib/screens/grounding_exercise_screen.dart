import 'dart:async';

import 'package:flutter/material.dart';

import '../state/voice_store.dart';
import '../theme/app_text_color.dart';
import '../widgets/app_background.dart';
import '../widgets/glass_panel.dart';

class _GroundingStep {
  final int count;
  final String sense;
  final String prompt;
  const _GroundingStep(this.count, this.sense, this.prompt);
}

const _steps = [
  _GroundingStep(5, 'Зрение', 'Назови 5 вещей, которые видишь вокруг себя'),
  _GroundingStep(4, 'Осязание', 'Назови 4 вещи, которые можешь потрогать'),
  _GroundingStep(3, 'Слух', 'Назови 3 звука, которые слышишь прямо сейчас'),
  _GroundingStep(2, 'Обоняние', 'Назови 2 запаха, которые чувствуешь'),
  _GroundingStep(1, 'Вкус', 'Назови 1 вкус, который чувствуешь или помнишь'),
];

/// Техника заземления "5-4-3-2-1" — известный приём переключения внимания
/// на органы чувств при тревоге. Не диагностика и не замена профессиональной
/// помощи, просто способ на минуту вернуть внимание в настоящий момент.
///
/// Если доступен голос — шаг переключается сам, как только человек что-то
/// произнёс (распознавание речи, без анализа тона/эмоций — см. обсуждение
/// в истории чата, почему анализ "плачущего голоса" не делаем: это
/// ненадёжно технически и рискованно именно там, где цена ошибки высокая).
/// Кнопка "Дальше" остаётся всегда — на случай, если микрофон недоступен
/// или человек предпочитает жать сам.
class GroundingExerciseScreen extends StatefulWidget {
  final VoiceStore? voiceStore;
  const GroundingExerciseScreen({super.key, this.voiceStore});

  @override
  State<GroundingExerciseScreen> createState() => _GroundingExerciseScreenState();
}

class _GroundingExerciseScreenState extends State<GroundingExerciseScreen> {
  int _stepIndex = 0;
  Timer? _silenceTimer;
  bool _heardSomething = false;

  bool get _voiceAvailable {
    final v = widget.voiceStore;
    return v != null && v.isVoiceAvailable && v.isSttAvailable;
  }

  @override
  void initState() {
    super.initState();
    _startListeningForStep();
  }

  void _startListeningForStep() {
    if (!_voiceAvailable) return;
    _heardSomething = false;
    widget.voiceStore!.startListening(
      onResult: (text) {
        if (text.trim().isEmpty) return;
        _heardSomething = true;
        // Debounce: каждое новое слово откладывает переход — считаем, что
        // человек договорил, если после последнего распознанного слова
        // прошло 1.8 секунды тишины, а не пытаемся угадать это по смыслу
        // или тону сказанного.
        _silenceTimer?.cancel();
        _silenceTimer = Timer(const Duration(milliseconds: 1800), () {
          if (mounted && _heardSomething) _next();
        });
      },
    );
  }

  void _stopListening() {
    _silenceTimer?.cancel();
    widget.voiceStore?.stopListening();
  }

  void _next() {
    _stopListening();
    if (_stepIndex < _steps.length - 1) {
      setState(() => _stepIndex++);
      _startListeningForStep();
    } else {
      setState(() => _stepIndex = -1); // финальный экран "готово"
    }
  }

  void _restart() {
    setState(() => _stepIndex = 0);
    _startListeningForStep();
  }

  @override
  void dispose() {
    _stopListening();
    super.dispose();
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
                      onPressed: () {
                        _stopListening();
                        Navigator.of(context).pop();
                      },
                    ),
                    Text(
                      'Техника заземления',
                      style: TextStyle(color: context.onSurface, fontSize: 17, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 440),
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: _stepIndex == -1 ? _buildDone() : _buildStep(_steps[_stepIndex]),
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

  Widget _buildStep(_GroundingStep step) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(_steps.length, (i) {
            final active = i == _stepIndex;
            final done = i < _stepIndex;
            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 3),
              width: active ? 22 : 8,
              height: 8,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(4),
                color: done || active ? const Color(0xFF6C5CE7) : context.onSurfaceFaded(0.15),
              ),
            );
          }),
        ),
        const SizedBox(height: 32),
        Text(
          '${step.count}',
          style: TextStyle(color: context.onSurface, fontSize: 56, fontWeight: FontWeight.w700),
        ),
        Text(
          step.sense.toUpperCase(),
          style: TextStyle(color: context.onSurfaceFaded(0.45), fontSize: 12, letterSpacing: 1.5),
        ),
        const SizedBox(height: 20),
        GlassPanel(
          opacity: 0.08,
          borderRadius: BorderRadius.circular(18),
          padding: const EdgeInsets.all(20),
          child: Text(
            step.prompt,
            textAlign: TextAlign.center,
            style: TextStyle(color: context.onSurface, fontSize: 16, height: 1.4),
          ),
        ),
        const SizedBox(height: 16),
        if (_voiceAvailable)
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(
                width: 12,
                height: 12,
                child: CircularProgressIndicator(strokeWidth: 1.5, color: Color(0xFF00D9C0)),
              ),
              const SizedBox(width: 8),
              Text(
                'Слушаю — переключусь сам, когда договоришь',
                style: TextStyle(color: context.onSurfaceFaded(0.4), fontSize: 12),
              ),
            ],
          ),
        const SizedBox(height: 20),
        Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(28),
            onTap: _next,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(28),
                gradient: const LinearGradient(colors: [Color(0xFF6C5CE7), Color(0xFF00B4D8)]),
              ),
              child: Text(
                _stepIndex < _steps.length - 1 ? 'Дальше' : 'Готово',
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 15),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDone() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.check_circle_rounded, color: Color(0xFF00E6A0), size: 56),
        const SizedBox(height: 16),
        Text(
          'Готово',
          style: TextStyle(color: context.onSurface, fontSize: 20, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        Text(
          'Можно повторить в любой момент.',
          style: TextStyle(color: context.onSurfaceFaded(0.5), fontSize: 13),
        ),
        const SizedBox(height: 20),
        // Универсальная приписка — НЕ по итогам какого-то анализа
        // (мы ничего не анализируем), просто напоминание, что есть куда
        // обратиться, если техника не помогает.
        GlassPanel(
          opacity: 0.07,
          borderRadius: BorderRadius.circular(14),
          padding: const EdgeInsets.all(14),
          child: Text(
            'Если тревога не отступает — это нормально, что одной техники '
            'может быть недостаточно. Можно поговорить с близким человеком '
            'или специалистом.',
            textAlign: TextAlign.center,
            style: TextStyle(color: context.onSurfaceFaded(0.45), fontSize: 12, height: 1.4),
          ),
        ),
        const SizedBox(height: 24),
        TextButton(
          onPressed: _restart,
          child: const Text('Начать заново'),
        ),
      ],
    );
  }
}
