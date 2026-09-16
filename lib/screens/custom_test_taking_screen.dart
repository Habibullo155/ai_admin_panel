import 'package:flutter/material.dart';

import '../models/custom_test.dart';
import '../services/custom_tests_service.dart';
import '../state/auth_store.dart';
import '../theme/app_text_color.dart';
import '../widgets/app_background.dart';
import '../widgets/glass_panel.dart';

enum _Stage { loading, intro, testing, result, error }

/// Единый экран для ЛЮБОГО опроса, созданного в конструкторе админки -
/// в отличие от PHQ-9/GAD-7/ASRS (у каждого свой экран под конкретную
/// зашитую методику), этот один умеет пройти произвольный тест, потому
/// что вопросы/варианты/баллы приходят с сервера, а не зашиты в код.
class CustomTestTakingScreen extends StatefulWidget {
  final AuthStore authStore;
  final int testId;
  final Future<void> Function(String summary)? onDiscussWithAi;
  const CustomTestTakingScreen({super.key, required this.authStore, required this.testId, this.onDiscussWithAi});

  @override
  State<CustomTestTakingScreen> createState() => _CustomTestTakingScreenState();
}

class _CustomTestTakingScreenState extends State<CustomTestTakingScreen> {
  final _service = CustomTestsService();
  _Stage _stage = _Stage.loading;
  CustomTest? _test;
  String? _error;
  int _currentQuestion = 0;
  final Map<int, int> _answers = {}; // questionIndex -> optionIndex
  CustomTestResult? _result;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _service.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    final token = widget.authStore.token;
    if (token == null) return;
    setState(() => _stage = _Stage.loading);
    try {
      final test = await _service.get(baseUrl: widget.authStore.baseUrl, token: token, testId: widget.testId);
      if (!mounted) return;
      setState(() {
        _test = test;
        _stage = _Stage.intro;
      });
    } on CustomTestsException catch (e) {
      if (mounted) {
        setState(() {
          _error = e.message;
          _stage = _Stage.error;
        });
      }
    }
  }

  void _selectAnswer(int optionIndex) {
    setState(() => _answers[_currentQuestion] = optionIndex);
    final test = _test!;
    if (_currentQuestion < test.questions.length - 1) {
      Future.delayed(const Duration(milliseconds: 180), () {
        if (mounted) setState(() => _currentQuestion++);
      });
    } else {
      Future.delayed(const Duration(milliseconds: 180), _submit);
    }
  }

  Future<void> _submit() async {
    final token = widget.authStore.token;
    if (token == null) return;
    setState(() => _isSubmitting = true);
    try {
      final answers = _answers.entries.map((e) => {'question_index': e.key, 'option_index': e.value}).toList();
      final result = await _service.submit(baseUrl: widget.authStore.baseUrl, token: token, testId: widget.testId, answers: answers);
      if (!mounted) return;
      setState(() {
        _result = result;
        _stage = _Stage.result;
      });
    } on CustomTestsException catch (e) {
      if (mounted) setState(() => _error = e.message);
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
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
                        _test?.title ?? 'Тест',
                        style: TextStyle(color: context.onSurface, fontSize: 17, fontWeight: FontWeight.w600),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
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
                        _Stage.loading => const Padding(
                            padding: EdgeInsets.symmetric(vertical: 60),
                            child: Center(child: CircularProgressIndicator(color: Color(0xFF6C5CE7))),
                          ),
                        _Stage.error => Text(_error ?? 'Не удалось загрузить тест.', style: const TextStyle(color: Color(0xFFFFB4B4))),
                        _Stage.intro => _buildIntro(),
                        _Stage.testing => _buildQuestion(),
                        _Stage.result => _buildResult(),
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
    final test = _test!;
    return GlassPanel(
      opacity: 0.08,
      borderRadius: BorderRadius.circular(20),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(test.title, style: TextStyle(color: context.onSurface, fontSize: 19, fontWeight: FontWeight.w700)),
          if (test.description != null && test.description!.isNotEmpty) ...[
            const SizedBox(height: 10),
            Text(test.description!, style: TextStyle(color: context.onSurfaceFaded(0.65), fontSize: 13.5, height: 1.5)),
          ],
          const SizedBox(height: 8),
          Text('${test.questions.length} вопрос(ов)', style: TextStyle(color: context.onSurfaceFaded(0.4), fontSize: 12)),
          const SizedBox(height: 20),
          Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(14),
              onTap: () => setState(() => _stage = _Stage.testing),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 13),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
                  gradient: const LinearGradient(colors: [Color(0xFF6C5CE7), Color(0xFF00B4D8)]),
                ),
                child: const Text('Начать', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuestion() {
    final test = _test!;
    final question = test.questions[_currentQuestion];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: List.generate(
            test.questions.length,
            (i) => Expanded(
              child: Container(
                margin: EdgeInsets.only(right: i < test.questions.length - 1 ? 4 : 0),
                height: 4,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(2),
                  color: i <= _currentQuestion ? const Color(0xFF6C5CE7) : context.onSurfaceFaded(0.12),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 6),
        Text('Вопрос ${_currentQuestion + 1} из ${test.questions.length}', style: TextStyle(color: context.onSurfaceFaded(0.4), fontSize: 11.5)),
        const SizedBox(height: 16),
        GlassPanel(
          opacity: 0.08,
          borderRadius: BorderRadius.circular(20),
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                question.text,
                style: TextStyle(color: context.onSurface, fontSize: 15.5, fontWeight: FontWeight.w500, height: 1.4),
              ),
              const SizedBox(height: 16),
              if (_isSubmitting)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 20),
                  child: Center(child: CircularProgressIndicator(color: Color(0xFF6C5CE7))),
                )
              else
                ...question.options.asMap().entries.map((e) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: _buildOptionTile(e.key, e.value.text),
                    )),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildOptionTile(int optionIndex, String text) {
    final selected = _answers[_currentQuestion] == optionIndex;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => _selectAnswer(optionIndex),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: selected ? const Color(0xFF6C5CE7).withValues(alpha: 0.25) : context.onSurfaceFaded(0.05),
            border: Border.all(color: selected ? const Color(0xFF6C5CE7) : context.onSurfaceFaded(0.1)),
          ),
          child: Text(text, style: TextStyle(color: context.onSurface, fontSize: 13.5)),
        ),
      ),
    );
  }

  Widget _buildResult() {
    final result = _result!;
    return GlassPanel(
      opacity: 0.08,
      borderRadius: BorderRadius.circular(20),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text('${result.totalScore}', style: TextStyle(color: context.onSurface, fontSize: 44, fontWeight: FontWeight.w700)),
          const SizedBox(height: 4),
          Text('баллов', style: TextStyle(color: context.onSurfaceFaded(0.4), fontSize: 12.5)),
          const SizedBox(height: 16),
          if (result.resultLabel != null)
            Text(
              result.resultLabel!,
              textAlign: TextAlign.center,
              style: TextStyle(color: context.onSurface, fontSize: 16, fontWeight: FontWeight.w600),
            ),
          const SizedBox(height: 20),
          if (widget.onDiscussWithAi != null)
            SizedBox(
              width: double.infinity,
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(14),
                  onTap: () async {
                    final text = 'Я прошёл(ла) тест «${_test!.title}»: ${result.totalScore} '
                        'балл(ов)${result.resultLabel != null ? " — результат: «${result.resultLabel}»" : ""}. '
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
            ),
          const SizedBox(height: 10),
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Закрыть', style: TextStyle(color: context.onSurfaceFaded(0.6))),
          ),
        ],
      ),
    );
  }
}
