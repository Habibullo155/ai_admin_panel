import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../state/auth_store.dart';
import '../state/performance_mode_store.dart';
import '../theme/app_text_color.dart';
import '../widgets/app_background.dart';
import '../widgets/glass_panel.dart';

enum _Stage { writing, releasing, done }

/// "Отпустить мысль" — написать её и смотреть, как лист с этой мыслью
/// уплывает по ручью. Текст НИКУДА не сохраняется и никуда не
/// отправляется — тот же принцип, что и у "Сжечь"/"Разбить"
/// (memory_release_screen.dart).
///
/// Перестроен с нуля после удаления прежней версии - та использовала
/// бесконечно тикающий AnimationController для фона воды и несколько
/// листьев одновременно, что реально давало ощутимые тормоза (см.
/// историю разговора: Interaction to Next Paint доходил до 6+ секунд
/// даже на простых экранах). Здесь — один лист за раз, ОГРАНИЧЕННАЯ по
/// времени анимация (~5 секунд, тот же проверенный паттерн, что у
/// сжигания/разбивания в memory_release_screen.dart), вода привязана к
/// ТОЙ ЖЕ анимации, а не крутится отдельным бесконечным циклом. Никакого
/// MaskFilter.blur нигде.
class LeavesOnStreamScreen extends StatefulWidget {
  final AuthStore? authStore;
  const LeavesOnStreamScreen({super.key, this.authStore});

  @override
  State<LeavesOnStreamScreen> createState() => _LeavesOnStreamScreenState();
}

class _LeavesOnStreamScreenState extends State<LeavesOnStreamScreen> with SingleTickerProviderStateMixin {
  final _controller = TextEditingController();
  _Stage _stage = _Stage.writing;
  late final AnimationController _animController;
  String _releasedText = '';

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(vsync: this, duration: const Duration(seconds: 5));
    _animController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        setState(() => _stage = _Stage.done);
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _animController.dispose();
    super.dispose();
  }

  void _startRelease() {
    if (_controller.text.trim().isEmpty) return;
    _releasedText = _controller.text.trim();
    setState(() => _stage = _Stage.releasing);
    _animController.forward(from: 0);
  }

  void _reset() {
    setState(() {
      _controller.clear();
      _stage = _Stage.writing;
    });
    _animController.reset();
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
                        'Листья на ручье',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: context.onSurface, fontSize: 17, fontWeight: FontWeight.w600),
                      ),
                    ),
                    const SizedBox(width: 48),
                  ],
                ),
              ),
              Expanded(
                child: switch (_stage) {
                  _Stage.writing => _buildWriting(),
                  _Stage.releasing => _buildReleasing(),
                  _Stage.done => _buildDone(),
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWriting() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Напиши мысль, от которой хочешь отпустить себя. '
            'Она уплывёт по ручью и растворится — никуда не сохраняется.',
            style: TextStyle(color: context.onSurfaceFaded(0.6), fontSize: 14, height: 1.4),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: GlassPanel(
              opacity: 0.10,
              borderRadius: BorderRadius.circular(20),
              padding: const EdgeInsets.all(16),
              child: TextField(
                controller: _controller,
                maxLines: null,
                expands: true,
                textAlignVertical: TextAlignVertical.top,
                style: TextStyle(color: context.onSurface, fontSize: 15, height: 1.4),
                decoration: InputDecoration(
                  border: InputBorder.none,
                  hintText: 'Например: я боюсь, что не справлюсь...',
                  hintStyle: TextStyle(color: context.onSurfaceFaded(0.3)),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(14),
              onTap: _startRelease,
              child: Container(
                height: 50,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
                  gradient: const LinearGradient(colors: [Color(0xFF00B4D8), Color(0xFF00E6A0)]),
                ),
                child: const Text('Отпустить', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReleasing() {
    // экономный режим - без анимации вообще, лист просто "уже уплыл"
    // сразу, чтобы не заставлять человека ждать эффект, которого он не
    // увидит в полной мере (или который его устройство не потянет)
    if (PerformanceModeStore.instance.enabled) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) setState(() => _stage = _Stage.done);
      });
      return const SizedBox.shrink();
    }

    return AnimatedBuilder(
      animation: _animController,
      builder: (context, _) {
        return CustomPaint(
          size: Size.infinite,
          painter: _StreamPainter(progress: _animController.value, text: _releasedText),
        );
      },
    );
  }

  Widget _buildDone() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.spa_outlined, size: 48, color: context.onSurfaceFaded(0.5)),
            const SizedBox(height: 16),
            Text(
              'Мысль уплыла.',
              style: TextStyle(color: context.onSurface, fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 24),
            Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(14),
                onTap: _reset,
                child: Container(
                  height: 46,
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: context.borderSubtle),
                  ),
                  child: Text('Написать ещё', style: TextStyle(color: context.onSurface, fontWeight: FontWeight.w600)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Вода и лист - ОДИН CustomPainter, оба привязаны к ОДНОЙ и той же
/// ограниченной анимации (progress 0..1 за 5 секунд), не к отдельным
/// бесконечным тикерам. Никакого MaskFilter.blur - только заливки и
/// градиенты.
class _StreamPainter extends CustomPainter {
  final double progress;
  final String text;
  _StreamPainter({required this.progress, required this.text});

  @override
  void paint(Canvas canvas, Size size) {
    // фон воды - простой вертикальный градиент, статичный (не бегущие
    // волнистые линии, как было раньше) - вся "жизнь" сцены теперь в
    // движении самого листа, не в постоянно пересчитываемом фоне
    final gradient = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          const Color(0xFF0B3B4A).withValues(alpha: 0.05),
          const Color(0xFF0B3B4A).withValues(alpha: 0.22),
        ],
      ).createShader(Offset.zero & size);
    canvas.drawRect(Offset.zero & size, gradient);

    // сам лист - плывёт слева направо с лёгким покачиванием по вертикали,
    // затухает у краёв (появляется и исчезает плавно, не обрезается резко)
    final x = -80 + (size.width + 160) * progress;
    final y = size.height * 0.5 + math.sin(progress * 6 * math.pi) * 18;
    final opacity = (progress < 0.08 ? progress / 0.08 : (progress > 0.92 ? (1 - progress) / 0.08 : 1.0)).clamp(0.0, 1.0);
    final angle = math.sin(progress * 6 * math.pi) * 0.15;

    canvas.save();
    canvas.translate(x, y);
    canvas.rotate(angle);
    canvas.saveLayer(const Rect.fromLTWH(-90, -90, 180, 180), Paint()..color = Colors.white.withValues(alpha: opacity));

    _paintLeafShape(canvas, text.hashCode);
    _paintLeafText(canvas, text);

    canvas.restore(); // saveLayer
    canvas.restore(); // translate+rotate
  }

  void _paintLeafShape(Canvas canvas, int seed) {
    final rnd = math.Random(seed);
    const w = 130.0, h = 160.0;
    final rightBulge = w * 0.5 + rnd.nextDouble() * 12;
    final leftBulge = w * 0.5 - rnd.nextDouble() * 8;

    final path = Path()
      ..moveTo(0, -h / 2)
      ..quadraticBezierTo(rightBulge, -h * 0.15, 0, h / 2)
      ..quadraticBezierTo(-leftBulge, -h * 0.15, 0, -h / 2)
      ..close();

    canvas.drawPath(
      path,
      Paint()
        ..shader = const RadialGradient(
          colors: [Color(0xFF4CAF7D), Color(0xFF1F6B48)],
        ).createShader(const Rect.fromLTWH(-w / 2, -h / 2, w, h)),
    );

    // центральная жилка - слегка изогнутая, не идеально прямая линия
    final vein = Path()
      ..moveTo(0, -h * 0.42)
      ..quadraticBezierTo(rnd.nextDouble() * 6 - 3, 0, 0, h * 0.42);
    canvas.drawPath(vein, Paint()..color = Colors.white.withValues(alpha: 0.25)..style = PaintingStyle.stroke..strokeWidth = 1.4);
  }

  void _paintLeafText(Canvas canvas, String text) {
    final painter = TextPainter(
      text: TextSpan(
        text: text,
        style: const TextStyle(color: Colors.white, fontSize: 11, height: 1.25, fontWeight: FontWeight.w600),
      ),
      textAlign: TextAlign.center,
      maxLines: 4,
      ellipsis: '…',
      textDirection: TextDirection.ltr,
    );
    // отступы держат текст в самой широкой средней части формы листа -
    // тот же приём, что и в прошлой версии, всё ещё верен
    const maxWidth = 90.0;
    painter.layout(maxWidth: maxWidth);
    painter.paint(canvas, Offset(-painter.width / 2, -painter.height / 2));
  }

  @override
  bool shouldRepaint(covariant _StreamPainter oldDelegate) => oldDelegate.progress != progress;
}
