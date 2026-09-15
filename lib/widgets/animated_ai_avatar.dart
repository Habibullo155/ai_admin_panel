import 'package:flutter/material.dart';

/// Вместо "точек ожидания" — сама аватарка ИИ мягко "дышит" (пульсирует
/// свечением) во время генерации ответа. Не анимация загрузки, а
/// спокойное, тонкое движение — в тон уже выбранному символу спокойствия
/// (spa) для ассистента.
class AnimatedAiAvatar extends StatefulWidget {
  final bool isActive;
  final double size;
  const AnimatedAiAvatar({super.key, required this.isActive, this.size = 34});

  @override
  State<AnimatedAiAvatar> createState() => _AnimatedAiAvatarState();
}

class _AnimatedAiAvatarState extends State<AnimatedAiAvatar> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(seconds: 2))
      ..repeat(reverse: true);
  }

  @override
  void didUpdateWidget(covariant AnimatedAiAvatar oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Экономим кадры, когда генерация уже закончилась — незачем крутить
    // анимацию бесконечно на статичном сообщении.
    if (!widget.isActive && _controller.isAnimating) {
      _controller.stop();
    } else if (widget.isActive && !_controller.isAnimating) {
      _controller.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.isActive) return _staticAvatar();

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        final t = Curves.easeInOut.transform(_controller.value); // 0..1 плавно туда-обратно
        final glowScale = 1.0 + 0.22 * t;
        final glowOpacity = 0.18 + 0.24 * t;
        final iconScale = 1.0 + 0.06 * t;

        return SizedBox(
          width: widget.size * 1.6,
          height: widget.size * 1.6,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Мягкое свечение вокруг — расширяется и тускнеет по кругу.
              Transform.scale(
                scale: glowScale,
                child: Container(
                  width: widget.size * 1.5,
                  height: widget.size * 1.5,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        const Color(0xFF4DD0C4).withOpacity(glowOpacity),
                        const Color(0xFF4DD0C4).withOpacity(0.0),
                      ],
                    ),
                  ),
                ),
              ),
              Transform.scale(
                scale: iconScale,
                child: _staticAvatar(),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _staticAvatar() {
    return Container(
      width: widget.size,
      height: widget.size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const LinearGradient(colors: [Color(0xFF6FB1DE), Color(0xFF4DD0C4)]),
        border: Border.all(color: Colors.white.withOpacity(0.25)),
      ),
      child: Icon(Icons.spa_rounded, size: widget.size * 0.53, color: Colors.white),
    );
  }
}
