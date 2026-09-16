import 'dart:async';

import 'package:flutter/material.dart';

import '../theme/app_text_color.dart';
import '../widgets/app_background.dart';
import '../widgets/glass_panel.dart';

enum _Stage { intro, writing, done }

/// Фрирайтинг (выгрузка сознания) — пишешь непрерывно, всё, что приходит
/// в голову, без цензуры и исправления ошибок, пока идёт таймер. Экран
/// мягко пульсирует, если пауза в наборе текста затянулась - не чтобы
/// подгонять, а чтобы напомнить продолжать поток, не задумываясь.
/// Текст не сохраняется технически ни при каком выборе на итоговом
/// экране - "сохранить как заметку" здесь пока просто оставляет текст
/// видимым, реального постоянного хранилища заметок в приложении нет.
class FreewritingScreen extends StatefulWidget {
  const FreewritingScreen({super.key});

  @override
  State<FreewritingScreen> createState() => _FreewritingScreenState();
}

class _FreewritingScreenState extends State<FreewritingScreen> with SingleTickerProviderStateMixin {
  final _controller = TextEditingController();
  final _focusNode = FocusNode();
  _Stage _stage = _Stage.intro;
  int _selectedMinutes = 3;
  int _secondsLeft = 0;
  Timer? _countdown;
  Timer? _pauseTimer;
  late final AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(vsync: this, duration: const Duration(milliseconds: 900));
    _controller.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    _countdown?.cancel();
    _pauseTimer?.cancel();
    _pulseController.dispose();
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onTextChanged() {
    // пауза больше 5 секунд без набора - лёгкая пульсация фона, не
    // навязчивое уведомление, просто мягкое "продолжай, не останавливайся"
    _pauseTimer?.cancel();
    _pulseController.stop();
    _pulseController.value = 0;
    _pauseTimer = Timer(const Duration(seconds: 5), () {
      if (mounted && _stage == _Stage.writing) {
        _pulseController.repeat(reverse: true);
      }
    });
  }

  void _start() {
    setState(() {
      _stage = _Stage.writing;
      _secondsLeft = _selectedMinutes * 60;
    });
    _focusNode.requestFocus();
    _onTextChanged();
    _countdown = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      setState(() => _secondsLeft--);
      if (_secondsLeft <= 0) {
        timer.cancel();
        _finish();
      }
    });
  }

  void _finish() {
    _countdown?.cancel();
    _pauseTimer?.cancel();
    _pulseController.stop();
    setState(() => _stage = _Stage.done);
  }

  void _discard() {
    setState(() {
      _controller.clear();
      _stage = _Stage.intro;
    });
  }

  String get _timeLabel {
    final m = (_secondsLeft ~/ 60).toString().padLeft(2, '0');
    final s = (_secondsLeft % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: AppBackground(
        child: SafeArea(
          child: switch (_stage) {
            _Stage.intro => _buildIntro(),
            _Stage.writing => _buildWriting(),
            _Stage.done => _buildDone(),
          },
        ),
      ),
    );
  }

  Widget _buildIntro() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              IconButton(
                icon: Icon(Icons.arrow_back_rounded, color: context.onSurface),
                onPressed: () => Navigator.of(context).pop(),
              ),
              Text('Фрирайтинг', style: TextStyle(color: context.onSurface, fontSize: 18, fontWeight: FontWeight.w600)),
            ],
          ),
        ),
        Expanded(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 480),
                child: GlassPanel(
                  opacity: 0.08,
                  borderRadius: BorderRadius.circular(20),
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Пиши непрерывно всё, что приходит в голову — без цензуры, '
                        'без исправления ошибок, не останавливаясь. Это не для '
                        'красивого текста, а чтобы разгрузить голову.',
                        style: TextStyle(color: context.onSurfaceFaded(0.65), fontSize: 13.5, height: 1.5),
                      ),
                      const SizedBox(height: 16),
                      Text('Сколько минут?', style: TextStyle(color: context.onSurfaceFaded(0.5), fontSize: 12.5)),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        children: [3, 5, 10].map((m) {
                          final selected = _selectedMinutes == m;
                          return ChoiceChip(
                            label: Text('$m мин'),
                            selected: selected,
                            onSelected: (_) => setState(() => _selectedMinutes = m),
                            labelStyle: TextStyle(color: selected ? Colors.white : context.onSurfaceFaded(0.7)),
                            selectedColor: const Color(0xFF6C5CE7),
                            backgroundColor: context.onSurfaceFaded(0.06),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 20),
                      Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(14),
                          onTap: _start,
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(vertical: 13),
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(14),
                              gradient: const LinearGradient(colors: [Color(0xFF6C5CE7), Color(0xFF00B4D8)]),
                            ),
                            child: const Text('Начать писать', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildWriting() {
    return AnimatedBuilder(
      animation: _pulseController,
      builder: (context, child) {
        final pulse = _pulseController.value * 0.06;
        return DecoratedBox(
          decoration: BoxDecoration(color: const Color(0xFFFFD166).withValues(alpha: pulse)),
          child: child,
        );
      },
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(_timeLabel, style: TextStyle(color: context.onSurfaceFaded(0.5), fontSize: 14, fontFeatures: const [FontFeature.tabularFigures()])),
                TextButton(onPressed: _finish, child: Text('Закончить', style: TextStyle(color: context.onSurfaceFaded(0.5)))),
              ],
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: TextField(
                controller: _controller,
                focusNode: _focusNode,
                maxLines: null,
                expands: true,
                textAlignVertical: TextAlignVertical.top,
                style: TextStyle(color: context.onSurface, fontSize: 16, height: 1.6),
                decoration: InputDecoration(
                  border: InputBorder.none,
                  hintText: 'Пиши, не останавливаясь…',
                  hintStyle: TextStyle(color: context.onSurfaceFaded(0.25)),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDone() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              IconButton(
                icon: Icon(Icons.arrow_back_rounded, color: context.onSurface),
                onPressed: () => Navigator.of(context).pop(),
              ),
              Text('Готово', style: TextStyle(color: context.onSurface, fontSize: 18, fontWeight: FontWeight.w600)),
            ],
          ),
        ),
        Expanded(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 480),
                child: GlassPanel(
                  opacity: 0.08,
                  borderRadius: BorderRadius.circular(20),
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        'Время вышло. Можешь оставить текст на экране и перечитать, '
                        'или сразу стереть — как удобнее.',
                        style: TextStyle(color: context.onSurfaceFaded(0.6), fontSize: 13, height: 1.5),
                      ),
                      const SizedBox(height: 16),
                      Container(
                        constraints: const BoxConstraints(maxHeight: 220),
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(14),
                          color: context.onSurfaceFaded(0.05),
                        ),
                        child: SingleChildScrollView(
                          child: Text(
                            _controller.text.isEmpty ? '(пусто)' : _controller.text,
                            style: TextStyle(color: context.onSurfaceFaded(0.75), fontSize: 13.5, height: 1.5),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              style: OutlinedButton.styleFrom(side: BorderSide(color: context.onSurfaceFaded(0.2))),
                              onPressed: _discard,
                              child: Text('Стереть', style: TextStyle(color: context.onSurfaceFaded(0.7))),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: FilledButton(
                              style: FilledButton.styleFrom(backgroundColor: const Color(0xFF6C5CE7)),
                              onPressed: () => Navigator.of(context).pop(),
                              child: const Text('Оставить и закрыть'),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
