import 'package:flutter/material.dart';

import '../theme/app_text_color.dart';
import '../widgets/app_background.dart';
import '../widgets/glass_panel.dart';

enum _Stage { writing, animating, done }

/// Техника "Сейф" (контейнирование) — для мысли или эмоции, с которой
/// сейчас нет времени разбираться (например, посреди рабочего дня).
/// В отличие от "Отпустить" (сжечь/разбить — окончательное прощание),
/// здесь мысль не уничтожается, а символически убирается на потом —
/// вернуться к ней можно, просто не прямо сейчас. Текст тем не менее
/// никуда не сохраняется технически - "сейф" тут метафора, не реальное
/// хранилище.
class SafeContainmentScreen extends StatefulWidget {
  const SafeContainmentScreen({super.key});

  @override
  State<SafeContainmentScreen> createState() => _SafeContainmentScreenState();
}

class _SafeContainmentScreenState extends State<SafeContainmentScreen> with SingleTickerProviderStateMixin {
  final _controller = TextEditingController();
  _Stage _stage = _Stage.writing;
  late final AnimationController _animController;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(vsync: this, duration: const Duration(milliseconds: 1800));
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

  void _lockAway() {
    if (_controller.text.trim().isEmpty) return;
    setState(() => _stage = _Stage.animating);
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
                    Text(
                      'Сейф',
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
                        _Stage.animating => SizedBox(
                            height: 320,
                            child: AnimatedBuilder(
                              animation: _animController,
                              builder: (context, _) => _SafeAnimation(progress: _animController.value, text: _controller.text),
                            ),
                          ),
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
            'Если мысль или чувство слишком сильные, но сейчас не время с ними '
            'разбираться — напиши и убери в сейф. Не пропадёт навсегда, просто '
            'подождёт, пока будет время вернуться.',
            style: TextStyle(color: context.onSurfaceFaded(0.6), fontSize: 12.5, height: 1.5),
          ),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _controller,
          minLines: 4,
          maxLines: 8,
          style: TextStyle(color: context.onSurface, fontSize: 14.5, height: 1.5),
          decoration: InputDecoration(
            filled: true,
            fillColor: context.onSurfaceFaded(0.07),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
            contentPadding: const EdgeInsets.all(16),
            hintText: 'Что нужно убрать на потом?',
            hintStyle: TextStyle(color: context.onSurfaceFaded(0.3)),
          ),
        ),
        const SizedBox(height: 16),
        Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(14),
            onTap: _lockAway,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 13),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                gradient: const LinearGradient(colors: [Color(0xFF5C7A99), Color(0xFF8FA8BF)]),
              ),
              child: const Text('Убрать в сейф', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDone() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.lock_rounded, color: context.onSurfaceFaded(0.5), size: 40),
        const SizedBox(height: 16),
        Text(
          'Надёжно спрятано. Оно больше не будет отвлекать прямо сейчас — '
          'вернёмся к этому, когда будешь готов(а).',
          textAlign: TextAlign.center,
          style: TextStyle(color: context.onSurfaceFaded(0.7), fontSize: 14.5, height: 1.5),
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

/// Текст плавно уменьшается и "втягивается" в контур сейфа, затем дверца
/// закрывается, появляется замок. Не физическая симуляция открывания
/// сейфа - стилизованная, но узнаваемая метафора.
class _SafeAnimation extends StatelessWidget {
  final double progress;
  final String text;
  const _SafeAnimation({required this.progress, required this.text});

  @override
  Widget build(BuildContext context) {
    const safeCenter = Offset(0, 40);
    // до трети - текст уменьшается и движется к сейфу
    final packPhase = (progress / 0.35).clamp(0.0, 1.0);
    // с трети до 70% - дверца поворачивается на петле и закрывается
    final doorPhase = ((progress - 0.35) / 0.35).clamp(0.0, 1.0);
    // после 70% - замок защёлкивается
    final lockPhase = ((progress - 0.7) / 0.3).clamp(0.0, 1.0);
    // угол двери: от ~80° открыто (почти "ребром" к зрителю) до 0° закрыто
    // (плоско, лицом к зрителю) - настоящий поворот в перспективе, не
    // плоское выезжание слева направо, как было раньше
    final doorAngle = -(1 - doorPhase) * 1.4;

    return Center(
      child: Stack(
        alignment: Alignment.center,
        children: [
          if (packPhase < 1.0)
            Transform.translate(
              offset: Offset.lerp(Offset.zero, safeCenter, packPhase)!,
              child: Opacity(
                opacity: (1 - packPhase).clamp(0.0, 1.0),
                child: Transform.scale(
                  scale: 1 - packPhase * 0.7,
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 240),
                    child: Text(
                      text,
                      textAlign: TextAlign.center,
                      maxLines: 4,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(color: context.onSurface, fontSize: 14),
                    ),
                  ),
                ),
              ),
            ),
          // корпус сейфа - диагональный градиент вместо плоской заливки,
          // имитирует металлический отблеск (светлее сверху-слева, темнее
          // снизу-справа), плюс небольшой наборный диск в углу для
          // достоверности
          Container(
            width: 160,
            height: 190,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF4A4A70), Color(0xFF2E2E4A), Color(0xFF25253C)],
                stops: [0.0, 0.6, 1.0],
              ),
              border: Border.all(color: const Color(0xFF5B4B8A), width: 3),
            ),
            child: Align(
              alignment: Alignment.bottomRight,
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Container(
                  width: 22,
                  height: 22,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(colors: [Color(0xFF6B6B94), Color(0xFF3A3A5C)]),
                  ),
                ),
              ),
            ),
          ),
          // дверца - настоящий 3D-поворот на петле (левый край), не
          // плоское выезжание. setEntry(3,2,...) добавляет перспективу,
          // без неё rotateY просто сжимал бы прямоугольник по горизонтали
          // без ощущения объёма
          if (doorPhase > 0)
            Transform(
              alignment: Alignment.centerLeft,
              transform: Matrix4.identity()
                ..setEntry(3, 2, 0.0025)
                ..rotateY(doorAngle),
              child: Container(
                width: 160,
                height: 190,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    // ближе к полному закрытию дверца "ловит свет" ярче -
                    // простая, но заметная имитация того, что плоскость
                    // разворачивается лицом к источнику света
                    colors: [
                      Color.lerp(const Color(0xFF3A3A56), const Color(0xFF52527A), doorPhase)!,
                      const Color(0xFF232338),
                    ],
                  ),
                  border: Border.all(color: const Color(0xFF4A3A72), width: 2),
                ),
              ),
            ),
          // замок - радиальный градиент вместо плоской заливки, тот же
          // приём "металлического" вида, что и у наборного диска на корпусе
          if (lockPhase > 0)
            Opacity(
              opacity: lockPhase,
              child: Transform.scale(
                scale: 0.6 + lockPhase * 0.4,
                child: Container(
                  width: 44,
                  height: 44,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      center: Alignment(-0.3, -0.3),
                      colors: [Color(0xFFFFE08A), Color(0xFFFFD166), Color(0xFFE0A83D)],
                      stops: [0.0, 0.6, 1.0],
                    ),
                  ),
                  child: const Icon(Icons.lock_rounded, color: Color(0xFF2A2A44), size: 24),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
