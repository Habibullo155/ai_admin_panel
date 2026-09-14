import 'dart:math' as math;

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';

import '../models/sound_asset.dart';
import '../services/sounds_service.dart';
import '../state/auth_store.dart';
import '../theme/app_text_color.dart';
import '../widgets/app_background.dart';
import '../widgets/glass_panel.dart';

enum _ReleaseMode { burn, shatter }
enum _Stage { writing, animating, done }

/// "Отпустить" — написать тяжёлую мысль/воспоминание и символически
/// уничтожить её (сжечь или разбить). Текст НИКУДА не сохраняется и
/// никуда не отправляется — ни на сервер, ни в локальное хранилище: сам
/// смысл упражнения в том, чтобы отпустить, а не архивировать.
class MemoryReleaseScreen extends StatefulWidget {
  final AuthStore? authStore;
  const MemoryReleaseScreen({super.key, this.authStore});

  @override
  State<MemoryReleaseScreen> createState() => _MemoryReleaseScreenState();
}

class _MemoryReleaseScreenState extends State<MemoryReleaseScreen> with SingleTickerProviderStateMixin {
  final _controller = TextEditingController();
  final _soundsService = SoundsService();
  final _effectPlayer = AudioPlayer();
  _ReleaseMode _mode = _ReleaseMode.burn;
  _Stage _stage = _Stage.writing;
  late final AnimationController _animController;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(vsync: this, duration: const Duration(seconds: 3));
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
    _soundsService.dispose();
    _effectPlayer.dispose();
    super.dispose();
  }

  // необязательное озвучивание эффекта - если админ не загрузил звук
  // категории "release" (или что-то пошло не так с сетью), анимация всё
  // равно проигрывается молча, это не должно ломать основной сценарий
  Future<void> _playReleaseSoundIfAvailable() async {
    final authStore = widget.authStore;
    final token = authStore?.token;
    if (token == null) return;
    try {
      final sounds = await _soundsService.list(baseUrl: authStore!.baseUrl, token: token, category: SoundCategory.release);
      if (sounds.isEmpty) return;
      final bytes = await _soundsService.fetchAudioBytes(baseUrl: authStore.baseUrl, token: token, soundId: sounds.first.id);
      await _effectPlayer.play(BytesSource(bytes));
    } catch (_) {
      // тихо игнорируем - звук необязателен для самого упражнения
    }
  }

  void _startRelease() {
    if (_controller.text.trim().isEmpty) return;
    setState(() => _stage = _Stage.animating);
    _animController.forward(from: 0);
    _playReleaseSoundIfAvailable();
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
                    Text(
                      'Отпустить',
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
                      child: switch (_stage) {
                        _Stage.writing => _buildWriting(),
                        _Stage.animating => _buildAnimating(),
                        _Stage.done => _buildDone(),
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

  Widget _buildWriting() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        GlassPanel(
          opacity: 0.07,
          borderRadius: BorderRadius.circular(16),
          padding: const EdgeInsets.all(14),
          child: Text(
            'Напиши то, что тяжело держать в себе — тяжёлую мысль, обиду, '
            'воспоминание. Никто это не увидит и не сохранит — после того, '
            'как отпустишь, текст исчезнет насовсем, без возможности вернуть.',
            style: TextStyle(color: context.onSurfaceFaded(0.6), fontSize: 12.5, height: 1.5),
          ),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _controller,
          minLines: 5,
          maxLines: 10,
          style: TextStyle(color: context.onSurface, fontSize: 14.5, height: 1.5),
          decoration: InputDecoration(
            filled: true,
            fillColor: context.onSurfaceFaded(0.07),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
            contentPadding: const EdgeInsets.all(16),
            hintText: 'Пиши здесь…',
            hintStyle: TextStyle(color: context.onSurfaceFaded(0.3)),
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(child: _modeChip(_ReleaseMode.burn, Icons.local_fire_department_rounded, 'Сжечь')),
            const SizedBox(width: 10),
            Expanded(child: _modeChip(_ReleaseMode.shatter, Icons.blur_on_rounded, 'Разбить')),
          ],
        ),
        const SizedBox(height: 20),
        Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(14),
            onTap: _startRelease,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 14),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                gradient: LinearGradient(
                  colors: _mode == _ReleaseMode.burn
                      ? [const Color(0xFFFF7E5F), const Color(0xFFFEB47B)]
                      : [const Color(0xFF6C5CE7), const Color(0xFF00B4D8)],
                ),
              ),
              child: Text(
                _mode == _ReleaseMode.burn ? 'Сжечь' : 'Разбить',
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _modeChip(_ReleaseMode mode, IconData icon, String label) {
    final selected = _mode == mode;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => setState(() => _mode = mode),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 12),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: selected ? context.onSurfaceFaded(0.12) : context.onSurfaceFaded(0.04),
            border: Border.all(color: selected ? context.onSurfaceFaded(0.4) : context.onSurfaceFaded(0.1)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 18, color: context.onSurfaceFaded(selected ? 0.9 : 0.5)),
              const SizedBox(width: 8),
              Text(label, style: TextStyle(color: context.onSurfaceFaded(selected ? 0.9 : 0.5), fontSize: 13.5)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAnimating() {
    return SizedBox(
      height: 420,
      child: AnimatedBuilder(
        animation: _animController,
        builder: (context, _) {
          return _mode == _ReleaseMode.burn
              ? _BurnEffect(progress: _animController.value, text: _controller.text)
              : _ShatterEffect(progress: _animController.value, text: _controller.text);
        },
      ),
    );
  }

  Widget _buildDone() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          _mode == _ReleaseMode.burn ? Icons.local_fire_department_outlined : Icons.check_circle_outline_rounded,
          color: context.onSurfaceFaded(0.5),
          size: 40,
        ),
        const SizedBox(height: 16),
        Text(
          _mode == _ReleaseMode.burn ? 'Сгорело — от текста ничего не осталось.' : 'Разбилось вдребезги — текста больше нет.',
          textAlign: TextAlign.center,
          style: TextStyle(color: context.onSurfaceFaded(0.7), fontSize: 14.5),
        ),
        const SizedBox(height: 24),
        Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(14),
            onTap: _reset,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 13, horizontal: 24),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: context.onSurfaceFaded(0.2)),
              ),
              child: Text('Написать ещё', style: TextStyle(color: context.onSurfaceFaded(0.85), fontWeight: FontWeight.w600)),
            ),
          ),
        ),
      ],
    );
  }
}

/// Огонь — не фотореалистичная симуляция (для этого нужен настоящий
/// шейдер/частицы на GPU), а стилизованный, но живой эффект на базе
/// CustomPainter: текст плавно темнеет и тает снизу вверх, поверх летят
/// частицы-угольки. Честная планка для того, что реально можно сделать
/// средствами Flutter без сторонних библиотек частиц.
class _BurnEffect extends StatelessWidget {
  final double progress;
  final String text;
  const _BurnEffect({required this.progress, required this.text});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: const Size(double.infinity, 420),
      painter: _BurnPainter(progress: progress, text: text),
    );
  }
}

/// Раньше текст просто таял поверх пустого фона — не очень читалось как
/// "сжигание письма". Теперь есть настоящий лист бумаги: рваная
/// обугленная граница реально ползёт снизу вверх, вдоль неё — тлеющая
/// оранжевая кромка, искры вылетают именно из этой границы, а не с
/// произвольной высоты. Всё ещё не физическая симуляция огня (для этого
/// нужен настоящий шейдер), но заметно более буквальная метафора.
class _BurnPainter extends CustomPainter {
  final double progress;
  final String text;
  final math.Random _rnd;
  _BurnPainter({required this.progress, required this.text}) : _rnd = math.Random(text.hashCode);

  static const _teeth = 20;

  @override
  void paint(Canvas canvas, Size size) {
    final paperRect = Rect.fromLTRB(20, 20, size.width - 20, size.height - 50);
    // ползёт снизу вверх: при progress=0 вся бумага цела, при progress=1 - вся сгорела
    final burnLineY = paperRect.bottom - paperRect.height * progress;

    // рваная (обугленная) верхняя граница ещё уцелевшей части бумаги -
    // не прямая линия, а зубчатая, как настоящий обгоревший край
    final edgePoints = <Offset>[];
    for (var i = 0; i <= _teeth; i++) {
      final x = paperRect.left + paperRect.width * i / _teeth;
      // две синусоиды разной частоты, не одна - идеально периодичный край
      // выглядел слишком математически правильным для настоящей рваной
      // обугленной бумаги
      final jag = math.sin(i * 2.3 + text.hashCode * 0.0001) * 5 + math.sin(i * 5.1 + text.hashCode * 0.0003) * 2;
      edgePoints.add(Offset(x, (burnLineY + jag).clamp(paperRect.top, paperRect.bottom)));
    }

    final paperPath = Path()
      ..moveTo(paperRect.left, paperRect.top)
      ..lineTo(paperRect.right, paperRect.top)
      ..lineTo(paperRect.right, edgePoints.last.dy);
    for (final p in edgePoints.reversed) {
      paperPath.lineTo(p.dx, p.dy);
    }
    paperPath.close();

    // сама уцелевшая бумага - тёплый кремовый цвет
    canvas.drawPath(paperPath, Paint()..color = const Color(0xFFF3E5C8));

    // обугленная полоса прямо перед кромкой горения - без неё переход от
    // целой кремовой бумаги к пустоте был слишком резким. Тень ложится
    // ВНУТРИ уцелевшей области (clip тем же paperPath), поэтому не
    // выходит за реальный контур бумаги
    if (progress > 0.01 && progress < 0.99) {
      canvas.save();
      canvas.clipPath(paperPath);
      final charPath = Path()..moveTo(edgePoints.first.dx, edgePoints.first.dy);
      for (final p in edgePoints.skip(1)) {
        charPath.lineTo(p.dx, p.dy);
      }
      canvas.drawPath(
        charPath,
        Paint()
          ..color = const Color(0xFF3A2313).withValues(alpha: 0.5)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 10,
      );
      canvas.restore();
    }

    // тлеющая кромка вдоль границы горения - светящаяся оранжевая полоса
    if (progress > 0.01 && progress < 0.99) {
      final glowPath = Path()..moveTo(edgePoints.first.dx, edgePoints.first.dy);
      for (final p in edgePoints.skip(1)) {
        glowPath.lineTo(p.dx, p.dy);
      }
      canvas.drawPath(
        glowPath,
        Paint()
          ..color = const Color(0xFFFF7A3D)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3,
      );

      // дым - серые волнистые полупрозрачные полосы, поднимающиеся выше и
      // медленнее огня. Раньше горение показывало только огонь и угольки -
      // без дыма выглядело неполно, настоящий огонь почти всегда дымит.
      //
      // RadialGradient вместо MaskFilter.blur - та же причина, что и у
      // бликов на воде в "Листьях на ручье" (экран удалён целиком из-за
      // тормозов, но вывод остаётся верным): размытие здесь
      // рисовалось 6 раз за кадр (по одному на облачко дыма), и это
      // вносило вклад в тормоза после недавних изменений анимаций.
      // Радиальный градиент даёт похожий мягкий вид без свёртки.
      final smokeRnd = math.Random(text.hashCode + 700);
      for (var i = 0; i < 6; i++) {
        final base = edgePoints[(smokeRnd.nextDouble() * (edgePoints.length - 1)).floor()];
        final smokePhase = (progress * 0.6 + i * 0.17) % 1.0;
        final riseHeight = 90 * smokePhase;
        final wobble = math.sin(smokePhase * 8 + i * 2) * 14 * smokePhase;
        final fade = (1 - smokePhase).clamp(0.0, 1.0) * 0.18;
        final radius = 6 + smokePhase * 10;
        final center = Offset(base.dx + wobble, base.dy - riseHeight - 10);
        canvas.drawCircle(
          center,
          radius,
          Paint()
            ..shader = RadialGradient(
              colors: [const Color(0xFF9B9B9B).withValues(alpha: fade), const Color(0xFF9B9B9B).withValues(alpha: 0.0)],
            ).createShader(Rect.fromCircle(center: center, radius: radius)),
        );
      }

      // настоящие языки пламени вдоль кромки - раньше горение показывали
      // только тлеющая полоса и угольки, без самого огня. Частота
      // мерцания (~85 в аргументе sin) подобрана под 3-секундную
      // анимацию так, чтобы получалось 4-5 мерцаний в секунду - темп
      // настоящего огня; у каждого языка свой сдвиг фазы (+ i*1.7), иначе
      // все мерцают синхронно и выглядит неестественно, как один объект
      for (var i = 0; i < edgePoints.length - 1; i += 2) {
        final base = edgePoints[i];
        final flicker = math.sin(progress * 85 + i * 1.7);
        final flicker2 = math.sin(progress * 130 + i * 2.3);
        final height = 22 + flicker * 8 + math.sin(progress * 40 + i) * 4;
        final lean = flicker2 * 6;

        // внешний язык - шире, тусклее, красно-оранжевый
        final outer = Path()
          ..moveTo(base.dx - 9, base.dy + 2)
          ..quadraticBezierTo(base.dx - 10 + lean * 0.5, base.dy - height * 0.5, base.dx + lean, base.dy - height)
          ..quadraticBezierTo(base.dx + 10 + lean * 0.5, base.dy - height * 0.5, base.dx + 9, base.dy + 2)
          ..close();
        canvas.drawPath(outer, Paint()..color = const Color(0xFFFF5A36).withValues(alpha: 0.65));

        // внутренний язык - уже, ярче, жёлто-белый - классический приём
        // двухслойного пламени для более убедительного вида
        final innerHeight = height * 0.6;
        final inner = Path()
          ..moveTo(base.dx - 4, base.dy + 2)
          ..quadraticBezierTo(base.dx - 4 + lean * 0.5, base.dy - innerHeight * 0.5, base.dx + lean * 0.7, base.dy - innerHeight)
          ..quadraticBezierTo(base.dx + 4 + lean * 0.5, base.dy - innerHeight * 0.5, base.dx + 4, base.dy + 2)
          ..close();
        canvas.drawPath(inner, Paint()..color = const Color(0xFFFFD166).withValues(alpha: 0.8));
      }
    }

    // текст - виден только там, где бумага ещё цела; тёмно-сепийные
    // чернила, не адаптивный цвет темы - подложка теперь сама бумага,
    // не фон приложения, ей не нужно подстраиваться под тему
    canvas.save();
    canvas.clipPath(paperPath);
    final textPainter = TextPainter(
      text: TextSpan(text: text, style: const TextStyle(color: Color(0xFF3B2A1A), fontSize: 14.5, height: 1.5)),
      textAlign: TextAlign.center,
      maxLines: 14,
      ellipsis: '…',
    )..layout(maxWidth: paperRect.width - 24);
    textPainter.paint(canvas, Offset(paperRect.left + 12, paperRect.top + 12));
    canvas.restore();

    // угольки/искры - вылетают именно из линии горения, не с
    // произвольной фиксированной высоты, как было раньше
    final particlePaint = Paint()..style = PaintingStyle.fill;
    for (var i = 0; i < 45; i++) {
      final seed = _rnd.nextDouble();
      final startDelay = seed * 0.5;
      final localProgress = ((progress - startDelay) / (1 - startDelay)).clamp(0.0, 1.0);
      if (localProgress <= 0 || localProgress >= 1) continue;

      final originX = paperRect.left + paperRect.width * ((i * 37) % 100) / 100;
      final riseHeight = 60 + 100 * seed;
      final y = burnLineY - riseHeight * localProgress;
      final wobble = math.sin(localProgress * 8 + i) * 10;

      final fade = (1 - localProgress).clamp(0.0, 1.0);
      final color = Color.lerp(const Color(0xFFFFB37A), const Color(0xFFFF5A36), seed)!;
      particlePaint.color = color.withValues(alpha: fade * 0.85);
      canvas.drawCircle(Offset(originX + wobble, y), 1.3 + seed * 2.2, particlePaint);
    }
  }

  @override
  bool shouldRepaint(covariant _BurnPainter oldDelegate) => oldDelegate.progress != progress;
}

/// "Тарелка" с текстом внутри, разлетающаяся на осколки. Тоже не
/// физический движок — заранее заданные направления/повороты для
/// каждого осколка, честный компромисс между "красиво" и "реализуемо
/// без сторонних пакетов физики".
class _ShatterEffect extends StatelessWidget {
  final double progress;
  final String text;
  const _ShatterEffect({required this.progress, required this.text});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: const Size(double.infinity, 420),
      painter: _ShatterPainter(progress: progress, text: text, baseColor: context.onSurface),
    );
  }
}

class _ShatterPainter extends CustomPainter {
  final double progress;
  final String text;
  final Color baseColor;
  final math.Random _rnd;
  _ShatterPainter({required this.progress, required this.text, required this.baseColor}) : _rnd = math.Random(text.hashCode);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2 - 20);
    const plateRadius = 130.0;

    // до 30% - тарелка цела; трещины начинают проступать в последней
    // трети этой фазы, ещё до самого разлёта - даёт ощущение нарастания,
    // а не мгновенного "было целое - стало на куски"
    final crackPhase = ((progress - 0.18) / 0.12).clamp(0.0, 1.0);
    final shatterProgress = ((progress - 0.3) / 0.7).clamp(0.0, 1.0);

    if (progress < 0.3) {
      // настоящая тарелка - обод и внутренняя часть двумя концентрическими
      // кругами, а не один плоский круг с тонкой обводкой, как раньше
      canvas.drawCircle(center, plateRadius, Paint()..color = baseColor.withValues(alpha: 0.16));
      canvas.drawCircle(center, plateRadius * 0.78, Paint()..color = baseColor.withValues(alpha: 0.08));
      canvas.drawCircle(
        center,
        plateRadius,
        Paint()
          ..color = baseColor.withValues(alpha: 0.3)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2,
      );
      canvas.drawCircle(
        center,
        plateRadius * 0.78,
        Paint()
          ..color = baseColor.withValues(alpha: 0.18)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.2,
      );

      final textPainter = TextPainter(
        text: TextSpan(
          text: text,
          style: TextStyle(color: baseColor.withValues(alpha: 0.85), fontSize: 12.5, height: 1.4),
        ),
        textAlign: TextAlign.center,
        maxLines: 6,
        ellipsis: '…',
      )..layout(maxWidth: plateRadius * 1.4);
      textPainter.paint(canvas, Offset(center.dx - textPainter.width / 2, center.dy - textPainter.height / 2));

      // трещины - зерно смещено от _rnd (text.hashCode), чтобы не совпадать
      // один в один с последовательностью, которую использует разлёт
      // осколков ниже
      if (crackPhase > 0) {
        final crackRnd = math.Random(text.hashCode + 500);
        const crackCount = 6;
        for (var i = 0; i < crackCount; i++) {
          var angle = crackRnd.nextDouble() * 2 * math.pi;
          var x = center.dx;
          var y = center.dy;
          final path = Path()..moveTo(x, y);
          const segments = 4;
          for (var s = 0; s < segments; s++) {
            final segLen = (plateRadius / segments) * crackPhase;
            angle += (crackRnd.nextDouble() - 0.5) * 0.7;
            x += math.cos(angle) * segLen;
            y += math.sin(angle) * segLen;
            path.lineTo(x, y);
          }
          canvas.drawPath(
            path,
            Paint()
              ..color = baseColor.withValues(alpha: 0.55 * crackPhase)
              ..style = PaintingStyle.stroke
              ..strokeWidth = 1.4,
          );
        }
      }
    }

    if (progress >= 0.3) {
      // пылевой всплеск ровно в момент разлёта - без него переход от
      // "целое" к "куски летят" выглядел слишком резко
      if (shatterProgress < 0.15) {
        final dustFade = 1 - shatterProgress / 0.15;
        final dustRnd = math.Random(text.hashCode + 900);
        for (var i = 0; i < 20; i++) {
          final a = dustRnd.nextDouble() * 2 * math.pi;
          final r = dustRnd.nextDouble() * 40 * (shatterProgress / 0.15);
          canvas.drawCircle(
            center + Offset(math.cos(a) * r, math.sin(a) * r),
            1.5,
            Paint()..color = baseColor.withValues(alpha: 0.35 * dustFade),
          );
        }
      }

      const shardCount = 16;
      for (var i = 0; i < shardCount; i++) {
        final angle = (i / shardCount) * 2 * math.pi + _rnd.nextDouble() * 0.3;
        final speed = 140 + _rnd.nextDouble() * 120;
        final dx = math.cos(angle) * speed * shatterProgress;
        final dy = math.sin(angle) * speed * shatterProgress - 80 * shatterProgress * (1 - shatterProgress);
        final rotation = angle * 3 * shatterProgress;
        final fade = (1 - shatterProgress).clamp(0.0, 1.0);

        canvas.save();
        canvas.translate(center.dx + dx, center.dy + dy);
        canvas.rotate(rotation);

        // неправильный четырёхугольник вместо ровного треугольника -
        // больше похоже на реальный обломок керамики, не на геометрическую
        // фигуру
        final baseSize = 12.0 + _rnd.nextDouble() * 12;
        final shardPath = Path()
          ..moveTo(-baseSize * 0.4 + _rnd.nextDouble() * 4, -baseSize + _rnd.nextDouble() * 4)
          ..lineTo(baseSize * 0.6 + _rnd.nextDouble() * 4, -baseSize * 0.3 + _rnd.nextDouble() * 4)
          ..lineTo(baseSize * 0.3 + _rnd.nextDouble() * 4, baseSize * 0.6 + _rnd.nextDouble() * 4)
          ..lineTo(-baseSize * 0.5 + _rnd.nextDouble() * 4, baseSize * 0.2 + _rnd.nextDouble() * 4)
          ..close();
        canvas.drawPath(shardPath, Paint()..color = baseColor.withValues(alpha: fade * 0.55));
        // тонкая светлая грань по контуру - ощущение объёма у обломка
        canvas.drawPath(
          shardPath,
          Paint()
            ..color = baseColor.withValues(alpha: fade * 0.3)
            ..style = PaintingStyle.stroke
            ..strokeWidth = 1,
        );
        canvas.restore();
      }
    }
  }

  @override
  bool shouldRepaint(covariant _ShatterPainter oldDelegate) => oldDelegate.progress != progress;
}
