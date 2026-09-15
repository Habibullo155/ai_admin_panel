import 'dart:async';

import 'package:flutter/material.dart';

import '../theme/app_text_color.dart';
import '../widgets/app_background.dart';
import '../widgets/glass_panel.dart';

class _MuscleStep {
  final String muscleGroup;
  final String tenseInstruction;
  final String releaseInstruction;
  final int tenseSeconds;
  final int releaseSeconds;
  const _MuscleStep({
    required this.muscleGroup,
    required this.tenseInstruction,
    required this.releaseInstruction,
    this.tenseSeconds = 5,
    this.releaseSeconds = 10,
  });
}

const _steps = [
  _MuscleStep(muscleGroup: 'Кисти рук', tenseInstruction: 'Сильно сожми кулаки', releaseInstruction: 'Резко расслабь и почувствуй тепло'),
  _MuscleStep(muscleGroup: 'Плечи', tenseInstruction: 'Подними плечи к ушам как можно выше', releaseInstruction: 'Отпусти, дай плечам упасть'),
  _MuscleStep(muscleGroup: 'Лицо', tenseInstruction: 'Зажмурься и сожми челюсти', releaseInstruction: 'Расслабь лицо полностью'),
  _MuscleStep(muscleGroup: 'Пресс', tenseInstruction: 'Напряги живот, будто готовишься к удару', releaseInstruction: 'Отпусти напряжение'),
  _MuscleStep(muscleGroup: 'Ноги', tenseInstruction: 'Вытяни ноги и напряги стопы', releaseInstruction: 'Дай ногам расслабиться'),
];

enum _Phase { intro, tense, release, done }

/// Прогрессивная мышечная релаксация по Джейкобсону — пошаговое
/// напряжение и расслабление групп мышц с таймером на каждую фазу.
/// Снимает физический спазм при стрессе, который человек часто сам не
/// замечает, пока не обратит на него внимание намеренно.
class MuscleRelaxationScreen extends StatefulWidget {
  const MuscleRelaxationScreen({super.key});

  @override
  State<MuscleRelaxationScreen> createState() => _MuscleRelaxationScreenState();
}

class _MuscleRelaxationScreenState extends State<MuscleRelaxationScreen> {
  int _stepIndex = 0;
  _Phase _phase = _Phase.intro;
  int _secondsLeft = 0;
  Timer? _timer;

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startStep() {
    final step = _steps[_stepIndex];
    setState(() {
      _phase = _Phase.tense;
      _secondsLeft = step.tenseSeconds;
    });
    _runCountdown(onDone: () {
      setState(() {
        _phase = _Phase.release;
        _secondsLeft = step.releaseSeconds;
      });
      _runCountdown(onDone: _advanceStep);
    });
  }

  void _runCountdown({required VoidCallback onDone}) {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      setState(() => _secondsLeft--);
      if (_secondsLeft <= 0) {
        timer.cancel();
        onDone();
      }
    });
  }

  void _advanceStep() {
    if (_stepIndex < _steps.length - 1) {
      setState(() => _stepIndex++);
      _startStep();
    } else {
      setState(() => _phase = _Phase.done);
    }
  }

  void _restart() {
    _timer?.cancel();
    setState(() {
      _stepIndex = 0;
      _phase = _Phase.intro;
    });
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
                    Text(
                      'Мышечная релаксация',
                      style: TextStyle(color: context.onSurface, fontSize: 16, fontWeight: FontWeight.w600),
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
                      child: switch (_phase) {
                        _Phase.intro => _buildIntro(),
                        _Phase.done => _buildDone(),
                        _ => _buildStep(),
                      },
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

  Widget _buildIntro() {
    return GlassPanel(
      opacity: 0.08,
      borderRadius: BorderRadius.circular(20),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'По очереди напряжём и расслабим ${_steps.length} групп мышц. '
            'На каждую — несколько секунд напряжения, потом расслабление. '
            'Устройся поудобнее, чтобы двигать руками/ногами было ничем не стеснено.',
            style: TextStyle(color: context.onSurfaceFaded(0.65), fontSize: 13.5, height: 1.5),
          ),
          const SizedBox(height: 20),
          Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(14),
              onTap: _startStep,
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 13),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
                  gradient: const LinearGradient(colors: [Color(0xFF6C5CE7), Color(0xFF00B4D8)]),
                ),
                child: const Text('Начать', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStep() {
    final step = _steps[_stepIndex];
    final isTense = _phase == _Phase.tense;
    return Column(
      children: [
        Row(
          children: List.generate(
            _steps.length,
            (i) => Expanded(
              child: Container(
                margin: EdgeInsets.only(right: i < _steps.length - 1 ? 4 : 0),
                height: 4,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(2),
                  color: i <= _stepIndex ? const Color(0xFF6C5CE7) : context.onSurfaceFaded(0.12),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 6),
        Text('${_stepIndex + 1} из ${_steps.length}', style: TextStyle(color: context.onSurfaceFaded(0.4), fontSize: 11.5)),
        const SizedBox(height: 20),
        GlassPanel(
          opacity: 0.08,
          borderRadius: BorderRadius.circular(20),
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              Text(step.muscleGroup, style: TextStyle(color: context.onSurfaceFaded(0.5), fontSize: 12.5, letterSpacing: 1)),
              const SizedBox(height: 12),
              Text(
                isTense ? step.tenseInstruction : step.releaseInstruction,
                textAlign: TextAlign.center,
                style: TextStyle(color: context.onSurface, fontSize: 18, fontWeight: FontWeight.w600, height: 1.4),
              ),
              const SizedBox(height: 24),
              Container(
                width: 88,
                height: 88,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: isTense ? [const Color(0xFFFF6B6B), const Color(0xFFFF9E9E)] : [const Color(0xFF00E6A0), const Color(0xFF6FE7D4)],
                  ),
                ),
                child: Text('$_secondsLeft', style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.w700)),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDone() {
    return GlassPanel(
      opacity: 0.08,
      borderRadius: BorderRadius.circular(20),
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.check_circle_outline_rounded, color: context.onSurfaceFaded(0.5), size: 40),
          const SizedBox(height: 12),
          Text(
            'Готово — все группы мышц пройдены.',
            style: TextStyle(color: context.onSurfaceFaded(0.7), fontSize: 14.5),
          ),
          const SizedBox(height: 20),
          TextButton(onPressed: _restart, child: const Text('Пройти ещё раз')),
        ],
      ),
    );
  }
}
