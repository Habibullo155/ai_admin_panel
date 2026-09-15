import 'package:flutter/material.dart';

import '../widgets/app_background.dart';
import '../widgets/glass_panel.dart';

enum _Phase { inhale, holdFull, exhale, holdEmpty }

const _phaseLabels = {
  _Phase.inhale: 'Вдох',
  _Phase.holdFull: 'Задержка',
  _Phase.exhale: 'Выдох',
  _Phase.holdEmpty: 'Задержка',
};

/// "Квадратное" дыхание (box breathing) — 4 секунды на каждую фазу.
/// Простая, широко известная техника саморегуляции (используется в том
/// числе в спорте и медицине как вспомогательный приём) — не заменяет
/// профессиональную помощь, просто способ ненадолго успокоить дыхание.
class BreathingExerciseScreen extends StatefulWidget {
  const BreathingExerciseScreen({super.key});

  @override
  State<BreathingExerciseScreen> createState() => _BreathingExerciseScreenState();
}

class _BreathingExerciseScreenState extends State<BreathingExerciseScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  bool _isRunning = false;
  _Phase _phase = _Phase.inhale;
  static const _phaseDuration = Duration(seconds: 4);

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: _phaseDuration)
      ..addStatusListener(_onStatusChanged);
  }

  void _onStatusChanged(AnimationStatus status) {
    if (status == AnimationStatus.completed) {
      setState(() => _phase = _nextPhase(_phase));
      _controller
        ..reset()
        ..forward();
    }
  }

  _Phase _nextPhase(_Phase phase) {
    switch (phase) {
      case _Phase.inhale:
        return _Phase.holdFull;
      case _Phase.holdFull:
        return _Phase.exhale;
      case _Phase.exhale:
        return _Phase.holdEmpty;
      case _Phase.holdEmpty:
        return _Phase.inhale;
    }
  }

  void _toggle() {
    setState(() => _isRunning = !_isRunning);
    if (_isRunning) {
      _phase = _Phase.inhale;
      _controller
        ..reset()
        ..forward();
    } else {
      _controller.stop();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  double _circleScale() {
    final t = _controller.value;
    switch (_phase) {
      case _Phase.inhale:
        return 0.55 + 0.45 * t;
      case _Phase.holdFull:
        return 1.0;
      case _Phase.exhale:
        return 1.0 - 0.45 * t;
      case _Phase.holdEmpty:
        return 0.55;
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
                      icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                    const Text(
                      'Дыхательное упражнение',
                      style: TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      AnimatedBuilder(
                        animation: _controller,
                        builder: (context, _) {
                          final scale = _isRunning ? _circleScale() : 0.55;
                          return Container(
                            width: 220 * scale,
                            height: 220 * scale,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: const LinearGradient(
                                colors: [Color(0xFF6FB1DE), Color(0xFF4DD0C4)],
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFF4DD0C4).withOpacity(0.35),
                                  blurRadius: 40,
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 32),
                      Text(
                        _isRunning ? _phaseLabels[_phase]! : 'Готов(а) начать?',
                        style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 40),
                      Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(28),
                          onTap: _toggle,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(28),
                              gradient: const LinearGradient(colors: [Color(0xFF6C5CE7), Color(0xFF00B4D8)]),
                            ),
                            child: Text(
                              _isRunning ? 'Остановить' : 'Начать',
                              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 15),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(20),
                child: GlassPanel(
                  opacity: 0.07,
                  borderRadius: BorderRadius.circular(14),
                  padding: const EdgeInsets.all(14),
                  child: Text(
                    'Простая техника саморегуляции дыхания — не заменяет '
                    'профессиональную помощь. Если чувствуешь головокружение — '
                    'останови упражнение и дыши в привычном темпе.',
                    style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 11.5, height: 1.4),
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
