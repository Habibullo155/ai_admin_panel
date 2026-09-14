import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

import '../models/phq9_checkin.dart';
import '../services/phq9_service.dart';
import '../theme/app_text_color.dart';
import '../widgets/app_background.dart';
import '../widgets/crisis_resources_panel.dart';
import '../widgets/glass_panel.dart';

const _uuid = Uuid();

enum _Mode { intro, testing, result }

/// PHQ-9 — официальный, свободно распространяемый опросник для скрининга
/// выраженности депрессивных симптомов (Pfizer, с 2010 года без
/// ограничений авторского права). Не диагностика — сама методика
/// рекомендует консультацию специалиста при повышенном результате, не
/// ставит диагноз сама по себе.
///
/// Пункт 9 (мысли о смерти/самоповреждении) обрабатывается ОТДЕЛЬНО и
/// НЕМЕДЛЕННО — кризисные контакты показываются сразу под этим вопросом,
/// как только дан любой ответ кроме "совсем не беспокоило", а не только
/// в конце вместе с общим результатом.
class Phq9Screen extends StatefulWidget {
  final String userId;
  final Future<void> Function(String summary)? onDiscussWithAi;
  const Phq9Screen({super.key, required this.userId, this.onDiscussWithAi});

  @override
  State<Phq9Screen> createState() => _Phq9ScreenState();
}

class _Phq9ScreenState extends State<Phq9Screen> {
  final _service = Phq9Service();
  _Mode _mode = _Mode.intro;
  List<int?> _currentAnswers = List.filled(phq9Questions.length, null);
  int _currentQuestion = 0;
  Phq9Checkin? _lastResult;
  List<Phq9Checkin> _history = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final history = await _service.loadCheckins(widget.userId);
    if (!mounted) return;
    setState(() {
      _history = history;
      _isLoading = false;
    });
  }

  void _startTest() {
    setState(() {
      _currentAnswers = List.filled(phq9Questions.length, null);
      _currentQuestion = 0;
      _mode = _Mode.testing;
    });
  }

  Future<void> _submitTest() async {
    if (_currentAnswers.any((a) => a == null)) return;
    final checkin = Phq9Checkin(
      id: _uuid.v4(),
      date: DateTime.now(),
      answers: _currentAnswers.map((a) => a!).toList(),
    );
    final saved = await _service.addCheckin(widget.userId, checkin);
    if (!mounted) return;
    setState(() {
      _lastResult = saved ?? checkin;
      _history = [_lastResult!, ..._history];
      _mode = _Mode.result;
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
                      'PHQ-9',
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
                      constraints: const BoxConstraints(maxWidth: 520),
                      child: _isLoading
                          ? const Padding(
                              padding: EdgeInsets.symmetric(vertical: 60),
                              child: Center(child: CircularProgressIndicator(color: Color(0xFF6C5CE7))),
                            )
                          : switch (_mode) {
                              _Mode.intro => _buildIntro(),
                              _Mode.testing => _buildTest(),
                              _Mode.result => _buildResult(),
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        GlassPanel(
          opacity: 0.08,
          borderRadius: BorderRadius.circular(20),
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Опросник выраженности депрессивных симптомов',
                style: TextStyle(color: context.onSurface, fontWeight: FontWeight.w600, fontSize: 15),
              ),
              const SizedBox(height: 8),
              Text(
                'Официальный, широко используемый в первичной медицинской '
                'помощи скрининговый инструмент (Patient Health '
                'Questionnaire-9). 9 вопросов, 2-3 минуты. Это не '
                'диагностика — результат показывает выраженность симптомов '
                'за последние 2 недели, а не медицинское заключение. '
                'Проходишь и видишь результат только ты — на сервер ничего '
                'не отправляется.',
                style: TextStyle(color: context.onSurfaceFaded(0.6), fontSize: 12.5, height: 1.5),
              ),
              const SizedBox(height: 16),
              Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(14),
                  onTap: _startTest,
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 13),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(14),
                      gradient: const LinearGradient(colors: [Color(0xFF6C5CE7), Color(0xFF00B4D8)]),
                    ),
                    child: Text(
                      _history.isEmpty ? 'Пройти опросник' : 'Пройти ещё раз',
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        if (_history.isNotEmpty) ...[
          const SizedBox(height: 20),
          Text(
            'ИСТОРИЯ',
            style: TextStyle(color: context.onSurfaceFaded(0.4), fontSize: 11, letterSpacing: 1.2, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 10),
          ..._history.map((c) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: GlassPanel(
                  opacity: 0.06,
                  blurred: false,
                  borderRadius: BorderRadius.circular(12),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          DateFormat.yMMMd().add_Hm().format(c.date),
                          style: TextStyle(color: context.onSurfaceFaded(0.6), fontSize: 12.5),
                        ),
                      ),
                      Text('${c.rawScore}/27', style: TextStyle(color: context.onSurface, fontWeight: FontWeight.w600)),
                    ],
                  ),
                ),
              )),
        ],
      ],
    );
  }

  Widget _buildTest() {
    final index = _currentQuestion;
    final riskAnswered = index == phq9RiskItemIndex &&
        _currentAnswers[phq9RiskItemIndex] != null &&
        _currentAnswers[phq9RiskItemIndex]! > 0;
    final isLast = index == phq9Questions.length - 1;
    final answered = _currentAnswers[index] != null;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'За последние 2 недели, как часто вас беспокоили следующие проблемы?',
          textAlign: TextAlign.center,
          style: TextStyle(color: context.onSurfaceFaded(0.6), fontSize: 13),
        ),
        const SizedBox(height: 18),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(phq9Questions.length, (i) {
            final active = i == index;
            final done = i < index;
            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 3),
              width: active ? 20 : 7,
              height: 7,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(4),
                color: done || active ? const Color(0xFF6C5CE7) : context.onSurfaceFaded(0.15),
              ),
            );
          }),
        ),
        const SizedBox(height: 24),
        _buildQuestion(index),
        if (riskAnswered) ...[
          const SizedBox(height: 12),
          const CrisisResourcesPanel(title: 'Если тебе сейчас тяжело'),
        ],
        const SizedBox(height: 20),
        Row(
          children: [
            if (index > 0) ...[
              Expanded(
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: context.onSurfaceFaded(0.2)),
                    padding: const EdgeInsets.symmetric(vertical: 13),
                  ),
                  onPressed: () => setState(() => _currentQuestion--),
                  child: Text('Назад', style: TextStyle(color: context.onSurfaceFaded(0.8))),
                ),
              ),
              const SizedBox(width: 10),
            ],
            Expanded(
              flex: 2,
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(14),
                  onTap: !answered
                      ? null
                      : isLast
                          ? _submitTest
                          : () => setState(() => _currentQuestion++),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 13),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(14),
                      gradient: LinearGradient(
                        colors: answered
                            ? [const Color(0xFF6C5CE7), const Color(0xFF00B4D8)]
                            : [context.onSurfaceFaded(0.24), context.onSurfaceFaded(0.10)],
                      ),
                    ),
                    child: Text(
                      isLast ? 'Показать результат' : 'Далее',
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildQuestion(int index) {
    return GlassPanel(
      opacity: 0.08,
      blurred: false,
      borderRadius: BorderRadius.circular(16),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            phq9Questions[index],
            style: TextStyle(color: context.onSurface, fontSize: 15.5, fontWeight: FontWeight.w500, height: 1.35),
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: List.generate(phq9ResponseLabels.length, (optionIdx) {
              final selected = _currentAnswers[index] == optionIdx;
              return ChoiceChip(
                label: Text(phq9ResponseLabels[optionIdx]),
                selected: selected,
                onSelected: (_) => setState(() => _currentAnswers[index] = optionIdx),
                labelStyle: TextStyle(
                  color: selected ? Colors.white : context.onSurfaceFaded(0.7),
                  fontSize: 12.5,
                ),
                selectedColor: const Color(0xFF6C5CE7),
                backgroundColor: context.onSurfaceFaded(0.06),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                  side: BorderSide(color: context.onSurfaceFaded(0.12)),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildResult() {
    final result = _lastResult!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        GlassPanel(
          opacity: 0.1,
          borderRadius: BorderRadius.circular(20),
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Text('${result.rawScore}', style: TextStyle(color: context.onSurface, fontSize: 44, fontWeight: FontWeight.w700)),
              Text('из 27', style: TextStyle(color: context.onSurfaceFaded(0.4), fontSize: 13)),
              const SizedBox(height: 10),
              Text(
                'Методика описывает такой результат как: ${result.severityLabel}.',
                textAlign: TextAlign.center,
                style: TextStyle(color: context.onSurfaceFaded(0.7), fontSize: 13.5, height: 1.4),
              ),
              const SizedBox(height: 8),
              Text(
                result.suggestsFurtherAssessment
                    ? 'При таком результате методика рекомендует обсудить его со специалистом — это скрининг, не диагноз.'
                    : 'Официальная методика не считает такой результат поводом для дополнительной оценки — но если тебе тяжело, это не отменяется этой цифрой.',
                textAlign: TextAlign.center,
                style: TextStyle(color: context.onSurfaceFaded(0.55), fontSize: 12.5, height: 1.5),
              ),
            ],
          ),
        ),
        if (result.hasRiskSignal || result.suggestsFurtherAssessment) ...[
          const SizedBox(height: 16),
          const CrisisResourcesPanel(),
        ],
        if (widget.onDiscussWithAi != null) ...[
          const SizedBox(height: 16),
          Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(14),
              onTap: () async {
                // hasRiskSignal - честно упоминаем в тексте, не смягчаем:
                // у бэкенда уже есть своя проверка на сигналы дистресса
                // (main.py: is_distress_signal) - она должна увидеть это
                // прямым текстом, а не через недосказанность
                final riskNote = result.hasRiskSignal
                    ? ' В пункте про мысли о самоповреждении был отмечен положительный ответ.'
                    : '';
                final text = 'Я прошёл(ла) опросник PHQ-9 (депрессивные симптомы): '
                    '${result.rawScore}/27, методика описывает это как «${result.severityLabel}».$riskNote '
                    'Можешь прокомментировать результат и поддержать меня?';
                Navigator.of(context).pop();
                await widget.onDiscussWithAi!(text);
              },
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 13),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
                  gradient: const LinearGradient(colors: [Color(0xFF6C5CE7), Color(0xFF00B4D8)]),
                ),
                child: const Text('Обсудить с ИИ', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
              ),
            ),
          ),
        ],
        const SizedBox(height: 16),
        Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(14),
            onTap: () => setState(() => _mode = _Mode.intro),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 13),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: context.onSurfaceFaded(0.2)),
              ),
              child: Text('Готово', style: TextStyle(color: context.onSurfaceFaded(0.85), fontWeight: FontWeight.w600)),
            ),
          ),
        ),
      ],
    );
  }
}
