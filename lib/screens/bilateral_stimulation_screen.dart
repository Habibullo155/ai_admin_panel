import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme/app_text_color.dart';
import '../widgets/app_background.dart';
import '../widgets/glass_panel.dart';

/// Билатеральная стимуляция (элементы EMDR/ДПДГ) - шар плавно движется
/// слева направо и обратно, взгляд следует за ним без поворота головы.
/// Не заменяет настоящую сессию ДПДГ со специалистом - это упрощённый,
/// самостоятельный вариант техники слежения глазами.
class BilateralStimulationScreen extends StatefulWidget {
  const BilateralStimulationScreen({super.key});

  @override
  State<BilateralStimulationScreen> createState() => _BilateralStimulationScreenState();
}

class _BilateralStimulationScreenState extends State<BilateralStimulationScreen> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  bool _isRunning = false;
  int _selectedMinutes = 1;
  // near_left/near_right пересекаются на стыке циклов (0.98..1.0 одного
  // цикла продолжается в 0..0.02 следующего) - простой булев флаг "рядом
  // ли с любым краем сейчас" даёт ровно одно срабатывание на каждый
  // разворот, без отдельного отслеживания "какой именно край"
  bool _wasAtEdge = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(seconds: 4))
      ..addListener(_checkEdge);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _checkEdge() {
    final t = _controller.value;
    final nearLeftEdge = t < 0.02 || t > 0.98;
    final nearRightEdge = t > 0.48 && t < 0.52;
    final nearAnyEdge = nearLeftEdge || nearRightEdge;
    if (nearAnyEdge && !_wasAtEdge) {
      HapticFeedback.lightImpact();
    }
    _wasAtEdge = nearAnyEdge;
  }

  void _start() {
    setState(() => _isRunning = true);
    _controller.repeat();
    Future.delayed(Duration(minutes: _selectedMinutes), () {
      if (mounted && _isRunning) _stop();
    });
  }

  void _stop() {
    _controller.stop();
    setState(() => _isRunning = false);
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
                      'Билатеральная стимуляция',
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
                      child: Column(
                        children: [
                          if (!_isRunning) ...[
                            GlassPanel(
                              opacity: 0.07,
                              borderRadius: BorderRadius.circular(16),
                              padding: const EdgeInsets.all(14),
                              child: Text(
                                'Следи за шаром только глазами, не поворачивая голову. '
                                'Это помогает снизить остроту тревоги. Не заменяет работу '
                                'со специалистом, если тревога сильная или частая.',
                                style: TextStyle(color: context.onSurfaceFaded(0.6), fontSize: 12.5, height: 1.5),
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text('Сколько минут?', style: TextStyle(color: context.onSurfaceFaded(0.5), fontSize: 12.5)),
                            const SizedBox(height: 8),
                            Wrap(
                              spacing: 8,
                              children: [1, 2, 3].map((m) {
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
                          ] else
                            SizedBox(
                              height: 260,
                              child: AnimatedBuilder(
                                animation: _controller,
                                builder: (context, _) {
                                  // треугольная волна 0->1->0 из линейного value 0->1
                                  final t = _controller.value;
                                  final progress = t < 0.5 ? t * 2 : 2 - t * 2;
                                  return LayoutBuilder(
                                    builder: (context, constraints) {
                                      final width = constraints.maxWidth - 60;
                                      return Stack(
                                        children: [
                                          Positioned(
                                            top: 110,
                                            left: 30 + width * progress,
                                            child: Container(
                                              width: 34,
                                              height: 34,
                                              decoration: BoxDecoration(
                                                shape: BoxShape.circle,
                                                gradient: const LinearGradient(colors: [Color(0xFF6C5CE7), Color(0xFF00D9C0)]),
                                                boxShadow: [
                                                  BoxShadow(color: const Color(0xFF6C5CE7).withValues(alpha: 0.5), blurRadius: 16, spreadRadius: 2),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ],
                                      );
                                    },
                                  );
                                },
                              ),
                            ),
                          Material(
                            color: Colors.transparent,
                            child: InkWell(
                              borderRadius: BorderRadius.circular(14),
                              onTap: _isRunning ? _stop : _start,
                              child: Container(
                                padding: const EdgeInsets.symmetric(vertical: 13),
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(14),
                                  gradient: LinearGradient(
                                    colors: _isRunning
                                        ? [context.onSurfaceFaded(0.2), context.onSurfaceFaded(0.1)]
                                        : [const Color(0xFF6C5CE7), const Color(0xFF00B4D8)],
                                  ),
                                ),
                                child: Text(
                                  _isRunning ? 'Остановить' : 'Начать',
                                  style: TextStyle(color: _isRunning ? context.onSurface : Colors.white, fontWeight: FontWeight.w600),
                                ),
                              ),
                            ),
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
}
