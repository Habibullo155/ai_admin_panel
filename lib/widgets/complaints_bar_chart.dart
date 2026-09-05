import 'package:flutter/material.dart';

import '../models/dashboard_stats.dart';
import '../theme/app_text_color.dart';

class ComplaintsBarChart extends StatelessWidget {
  final List<ComplaintsMonth> data;
  const ComplaintsBarChart({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) {
      return SizedBox(
        height: 180,
        child: Center(
          child: Text('Нет жалоб за этот период', style: TextStyle(color: context.onSurfaceFaded(0.4), fontSize: 12.5)),
        ),
      );
    }
    final maxValue = data.map((d) => d.count).fold<int>(0, (a, b) => a > b ? a : b);
    final safeMax = maxValue == 0 ? 1 : maxValue;

    return SizedBox(
      height: 180,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: data
            .map((d) => Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text('${d.count}', style: TextStyle(color: context.onSurfaceFaded(0.6), fontSize: 10.5)),
                        const SizedBox(height: 4),
                        Container(
                          height: 120 * (d.count / safeMax).clamp(0.04, 1.0),
                          decoration: BoxDecoration(
                            borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                            color: d.count > 0 ? const Color(0xFFFF6B6B) : context.onSurfaceFaded(0.1),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          _shortMonthLabel(d.month),
                          style: TextStyle(color: context.onSurfaceFaded(0.4), fontSize: 10),
                        ),
                      ],
                    ),
                  ),
                ))
            .toList(),
      ),
    );
  }

  // "2026-08" -> "авг" - без пакета intl ради одной короткой подписи,
  // достаточно простого маппинга номера месяца
  String _shortMonthLabel(String yyyyMm) {
    const labels = ['янв', 'фев', 'мар', 'апр', 'май', 'июн', 'июл', 'авг', 'сен', 'окт', 'ноя', 'дек'];
    final parts = yyyyMm.split('-');
    if (parts.length != 2) return yyyyMm;
    final monthIndex = int.tryParse(parts[1]);
    if (monthIndex == null || monthIndex < 1 || monthIndex > 12) return yyyyMm;
    return labels[monthIndex - 1];
  }
}
