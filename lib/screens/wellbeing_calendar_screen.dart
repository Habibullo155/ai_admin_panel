import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/custom_test.dart';
import '../services/asrs_service.dart';
import '../services/custom_tests_service.dart';
import '../services/gad7_service.dart';
import '../services/phq9_service.dart';
import '../services/wellbeing_service.dart';
import '../state/auth_store.dart';
import '../theme/app_text_color.dart';
import '../widgets/app_background.dart';
import '../widgets/glass_panel.dart';
import 'wellbeing_screen.dart';

/// Один день может содержать записи сразу нескольких опросников —
/// собираем их в общий список, не пытаясь свести к одному "баллу дня".
class _DayEntry {
  final DateTime date;
  final String label;
  final String score;
  final Color color;
  const _DayEntry({required this.date, required this.label, required this.score, required this.color});
}

/// Календарь со статистикой самочувствия — сводит воедино все четыре
/// локальных опросника (ВОЗ-5, PHQ-9, GAD-7, ASRS). Собственная сетка на
/// базовых виджетах, без нового пакета-зависимости — календарь простой
/// (месяц, отметки дней), полноценный пакет ради этого не нужен.
class WellbeingCalendarScreen extends StatefulWidget {
  final String userId;
  final AuthStore? authStore;
  const WellbeingCalendarScreen({super.key, required this.userId, this.authStore});

  @override
  State<WellbeingCalendarScreen> createState() => _WellbeingCalendarScreenState();
}

class _WellbeingCalendarScreenState extends State<WellbeingCalendarScreen> {
  bool _isLoading = true;
  DateTime _month = DateTime(DateTime.now().year, DateTime.now().month);
  DateTime? _selectedDay;

  // ключ - дата без времени (год-месяц-день), значение - все записи в этот день
  final Map<DateTime, List<_DayEntry>> _entriesByDay = {};

  @override
  void initState() {
    super.initState();
    _load();
  }

  DateTime _dayKey(DateTime d) => DateTime(d.year, d.month, d.day);

  Future<void> _load() async {
    setState(() => _isLoading = true);

    final who5 = await WellbeingService().loadCheckins(widget.userId);
    final phq9 = await Phq9Service().loadCheckins(widget.userId);
    final gad7 = await Gad7Service().loadCheckins(widget.userId);
    final asrs = await AsrsService().loadCheckins(widget.userId);
    // свои тесты (конструктор в админке) - отдельный сервис, нужен токен,
    // не просто userId, как у остальных четырёх; если токена нет (не должно
    // случиться на этом экране, но на всякий случай) - просто пропускаем,
    // остальной календарь всё равно должен показаться
    List<CustomTestResultHistory> customResults = [];
    final token = widget.authStore?.token;
    if (token != null) {
      try {
        customResults = await CustomTestsService().myResults(baseUrl: widget.authStore!.baseUrl, token: token);
      } on CustomTestsException {
        customResults = [];
      }
    }

    final map = <DateTime, List<_DayEntry>>{};

    void add(_DayEntry entry) {
      final key = _dayKey(entry.date);
      map.putIfAbsent(key, () => []).add(entry);
    }

    for (final c in who5) {
      add(_DayEntry(
        date: c.date,
        label: 'ВОЗ-5',
        score: '${c.percentScore}%',
        color: c.suggestsFurtherAssessment ? const Color(0xFFFFD166) : const Color(0xFF00E6A0),
      ));
    }
    for (final c in phq9) {
      add(_DayEntry(
        date: c.date,
        label: 'PHQ-9',
        score: '${c.rawScore}/27',
        color: c.suggestsFurtherAssessment ? const Color(0xFFFFD166) : const Color(0xFF00E6A0),
      ));
    }
    for (final c in gad7) {
      add(_DayEntry(
        date: c.date,
        label: 'GAD-7',
        score: '${c.rawScore}/21',
        color: c.suggestsFurtherAssessment ? const Color(0xFFFFD166) : const Color(0xFF00E6A0),
      ));
    }
    for (final c in asrs) {
      add(_DayEntry(
        date: c.date,
        label: 'ASRS',
        score: '${c.shadedCount}/6',
        color: c.suggestsFurtherAssessment ? const Color(0xFFFFD166) : const Color(0xFF00E6A0),
      ));
    }
    for (final r in customResults) {
      // у своих тестов нет встроенного понятия "стоит обратить внимание" -
      // подпись результата и есть вся интерпретация, отдельным цветом
      // тревоги её дублировать не пытаемся
      add(_DayEntry(
        date: r.createdAt,
        label: r.testTitle,
        score: r.resultLabel ?? '${r.totalScore} балл(ов)',
        color: const Color(0xFF6C5CE7),
      ));
    }

    if (!mounted) return;
    setState(() {
      _entriesByDay
        ..clear()
        ..addAll(map);
      _isLoading = false;
    });
  }

  void _changeMonth(int delta) {
    setState(() {
      _month = DateTime(_month.year, _month.month + delta);
      _selectedDay = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final selectedEntries = _selectedDay != null ? _entriesByDay[_dayKey(_selectedDay!)] ?? [] : <_DayEntry>[];

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
                        'Календарь самочувствия',
                        style: TextStyle(color: context.onSurface, fontSize: 18, fontWeight: FontWeight.w600),
                      ),
                    ),
                    TextButton.icon(
                      onPressed: () async {
                        // возвращаемся сюда после теста - обновляем
                        // календарь, чтобы свежая запись сразу появилась
                        await Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => WellbeingScreen(userId: widget.userId, authStore: widget.authStore)),
                        );
                        _load();
                      },
                      icon: const Icon(Icons.add_task_rounded, color: Color(0xFF00E6A0), size: 18),
                      label: const Text('Пройти тест', style: TextStyle(color: Color(0xFF00E6A0), fontSize: 13)),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Center(
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Color(0xFF6C5CE7))
                      : SingleChildScrollView(
                          padding: const EdgeInsets.all(16),
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 480),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                _buildMonthHeader(),
                                const SizedBox(height: 12),
                                _buildGrid(),
                                if (selectedEntries.isNotEmpty) ...[
                                  const SizedBox(height: 20),
                                  Text(
                                    DateFormat.yMMMMd().format(_selectedDay!),
                                    style: TextStyle(color: context.onSurface, fontWeight: FontWeight.w600, fontSize: 14),
                                  ),
                                  const SizedBox(height: 10),
                                  ...selectedEntries.map((e) => Padding(
                                        padding: const EdgeInsets.only(bottom: 8),
                                        child: GlassPanel(
                                          opacity: 0.07,
                                          blurred: false,
                                          borderRadius: BorderRadius.circular(12),
                                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                                          child: Row(
                                            children: [
                                              Container(width: 8, height: 8, decoration: BoxDecoration(shape: BoxShape.circle, color: e.color)),
                                              const SizedBox(width: 10),
                                              Expanded(
                                                child: Text(e.label, style: TextStyle(color: context.onSurface, fontSize: 13.5)),
                                              ),
                                              Text(e.score, style: TextStyle(color: context.onSurface, fontWeight: FontWeight.w600)),
                                            ],
                                          ),
                                        ),
                                      )),
                                ] else if (_entriesByDay.isEmpty) ...[
                                  const SizedBox(height: 30),
                                  Center(
                                    child: Text(
                                      'Пока нет пройденных опросников — они появятся здесь\nпосле прохождения в разделе «Самочувствие».',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(color: context.onSurfaceFaded(0.4), fontSize: 13, height: 1.5),
                                    ),
                                  ),
                                ],
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

  Widget _buildMonthHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(
          icon: const Icon(Icons.chevron_left_rounded, color: Colors.white70),
          onPressed: () => _changeMonth(-1),
        ),
        Text(
          DateFormat.yMMMM().format(_month),
          style: TextStyle(color: context.onSurface, fontSize: 15.5, fontWeight: FontWeight.w600),
        ),
        IconButton(
          icon: const Icon(Icons.chevron_right_rounded, color: Colors.white70),
          onPressed: () => _changeMonth(1),
        ),
      ],
    );
  }

  Widget _buildGrid() {
    final firstOfMonth = DateTime(_month.year, _month.month, 1);
    // понедельник = 1 ... воскресенье = 7, сдвигаем на пустые ячейки в начале
    final leadingEmpty = firstOfMonth.weekday - 1;
    final daysInMonth = DateTime(_month.year, _month.month + 1, 0).day;
    final today = _dayKey(DateTime.now());

    const weekdayLabels = ['Пн', 'Вт', 'Ср', 'Чт', 'Пт', 'Сб', 'Вс'];

    return GlassPanel(
      opacity: 0.07,
      borderRadius: BorderRadius.circular(18),
      padding: const EdgeInsets.all(12),
      child: Column(
        children: [
          Row(
            children: weekdayLabels
                .map((d) => Expanded(
                      child: Center(
                        child: Text(d, style: TextStyle(color: context.onSurfaceFaded(0.35), fontSize: 11)),
                      ),
                    ))
                .toList(),
          ),
          const SizedBox(height: 6),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: leadingEmpty + daysInMonth,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 7),
            itemBuilder: (context, i) {
              if (i < leadingEmpty) return const SizedBox.shrink();
              final day = i - leadingEmpty + 1;
              final date = DateTime(_month.year, _month.month, day);
              final key = _dayKey(date);
              final entries = _entriesByDay[key];
              final isToday = key == today;
              final isSelected = _selectedDay != null && _dayKey(_selectedDay!) == key;

              return Padding(
                padding: const EdgeInsets.all(2),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(10),
                    onTap: () => setState(() => _selectedDay = date),
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: isSelected ? const Color(0xFF6C5CE7).withValues(alpha: 0.35) : Colors.transparent,
                        border: isToday ? Border.all(color: context.onSurfaceFaded(0.4)) : null,
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('$day', style: TextStyle(color: context.onSurfaceFaded(0.85), fontSize: 12.5)),
                          const SizedBox(height: 3),
                          if (entries != null)
                            Wrap(
                              spacing: 2,
                              children: entries
                                  .take(3)
                                  .map((e) => Container(
                                        width: 4,
                                        height: 4,
                                        decoration: BoxDecoration(shape: BoxShape.circle, color: e.color),
                                      ))
                                  .toList(),
                            )
                          else
                            const SizedBox(height: 4),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
