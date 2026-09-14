import 'package:flutter/material.dart';

import '../models/dashboard_stats.dart';
import '../theme/app_text_color.dart';

/// Простой линейный график без сторонней библиотеки — тот же подход
/// (CustomPainter), что уже используется для анимаций в упражнениях
/// (memory_release_screen.dart и др.), не тянем новую зависимость ради
/// одного графика в админке.
class ActivityLineChart extends StatelessWidget {
  final List<ActivityDay> data;
  const ActivityLineChart({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) {
      return SizedBox(
        height: 180,
        child: Center(
          child: Text('Нет данных за этот период', style: TextStyle(color: context.onSurfaceFaded(0.4), fontSize: 12.5)),
        ),
      );
    }
    return SizedBox(
      height: 180,
      child: CustomPaint(
        size: Size.infinite,
        painter: _ActivityChartPainter(data: data, lineColor: const Color(0xFF6C5CE7), gridColor: context.onSurfaceFaded(0.08)),
      ),
    );
  }
}

class _ActivityChartPainter extends CustomPainter {
  final List<ActivityDay> data;
  final Color lineColor;
  final Color gridColor;
  _ActivityChartPainter({required this.data, required this.lineColor, required this.gridColor});

  @override
  void paint(Canvas canvas, Size size) {
    const leftPadding = 4.0;
    const bottomPadding = 4.0;
    final chartWidth = size.width - leftPadding;
    final chartHeight = size.height - bottomPadding;

    final maxValue = data.map((d) => d.messages).fold<int>(0, (a, b) => a > b ? a : b);
    final safeMax = maxValue == 0 ? 1 : maxValue;

    final gridPaint = Paint()
      ..color = gridColor
      ..strokeWidth = 1;
    for (var i = 0; i <= 3; i++) {
      final y = chartHeight * i / 3;
      canvas.drawLine(Offset(leftPadding, y), Offset(size.width, y), gridPaint);
    }

    if (data.length < 2) {
      if (data.isNotEmpty) {
        final x = leftPadding + chartWidth / 2;
        final y = chartHeight - (data.first.messages / safeMax) * chartHeight;
        canvas.drawCircle(Offset(x, y), 4, Paint()..color = lineColor);
      }
      return;
    }

    final path = Path();
    final fillPath = Path();
    for (var i = 0; i < data.length; i++) {
      final x = leftPadding + chartWidth * i / (data.length - 1);
      final y = chartHeight - (data[i].messages / safeMax) * chartHeight;
      if (i == 0) {
        path.moveTo(x, y);
        fillPath.moveTo(x, chartHeight);
        fillPath.lineTo(x, y);
      } else {
        path.lineTo(x, y);
        fillPath.lineTo(x, y);
      }
    }
    fillPath.lineTo(leftPadding + chartWidth, chartHeight);
    fillPath.close();

    canvas.drawPath(fillPath, Paint()..color = lineColor.withValues(alpha: 0.12));
    canvas.drawPath(
      path,
      Paint()
        ..color = lineColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5
        ..strokeCap = StrokeCap.round,
    );

    for (var i = 0; i < data.length; i++) {
      final x = leftPadding + chartWidth * i / (data.length - 1);
      final y = chartHeight - (data[i].messages / safeMax) * chartHeight;
      canvas.drawCircle(Offset(x, y), 3, Paint()..color = lineColor);
    }
  }

  @override
  bool shouldRepaint(covariant _ActivityChartPainter oldDelegate) => oldDelegate.data != data;
}
