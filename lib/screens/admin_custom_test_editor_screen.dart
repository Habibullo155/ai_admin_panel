import 'package:flutter/material.dart';

import '../models/custom_test.dart';
import '../services/custom_tests_service.dart';
import '../state/auth_store.dart';
import '../theme/app_text_color.dart';
import '../widgets/app_background.dart';
import '../widgets/glass_panel.dart';

/// null testId - создание нового теста, иначе - редактирование
/// существующего. В отличие от блога здесь нет отдельных контроллеров на
/// каждое текстовое поле заранее - вопросы/варианты/диапазоны добавляются
/// и убираются динамически, так что контроллеры создаются и освобождаются
/// вместе с самими элементами списков.
class AdminCustomTestEditorScreen extends StatefulWidget {
  final AuthStore authStore;
  final int? testId;
  const AdminCustomTestEditorScreen({super.key, required this.authStore, this.testId});

  @override
  State<AdminCustomTestEditorScreen> createState() => _AdminCustomTestEditorScreenState();
}

class _QuestionEditor {
  final titleController = TextEditingController();
  final options = <_OptionEditor>[];
  void dispose() {
    titleController.dispose();
    for (final o in options) {
      o.dispose();
    }
  }
}

class _OptionEditor {
  final textController = TextEditingController();
  int points;
  _OptionEditor({this.points = 0});
  void dispose() => textController.dispose();
}

class _RangeEditor {
  final minController = TextEditingController();
  final maxController = TextEditingController();
  final labelController = TextEditingController();
  final descriptionController = TextEditingController();
  void dispose() {
    minController.dispose();
    maxController.dispose();
    labelController.dispose();
    descriptionController.dispose();
  }
}

class _AdminCustomTestEditorScreenState extends State<AdminCustomTestEditorScreen> {
  final _service = CustomTestsService();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _aiUsageHintController = TextEditingController();
  final _questions = <_QuestionEditor>[];
  final _ranges = <_RangeEditor>[];
  bool _isPublished = false;
  bool _isLoading = false;
  bool _isSaving = false;
  String? _error;

  bool get _isEditing => widget.testId != null;

  @override
  void initState() {
    super.initState();
    if (_isEditing) {
      _load();
    } else {
      // новый тест начинается с одного вопроса о двумя вариантами и одного
      // диапазона - пустой конструктор без ничего был бы совсем неочевиден
      _addQuestion();
      _addRange();
    }
  }

  @override
  void dispose() {
    _service.dispose();
    _titleController.dispose();
    _descriptionController.dispose();
    _aiUsageHintController.dispose();
    for (final q in _questions) {
      q.dispose();
    }
    for (final r in _ranges) {
      r.dispose();
    }
    super.dispose();
  }

  Future<void> _load() async {
    final token = widget.authStore.token;
    if (token == null) return;
    setState(() => _isLoading = true);
    try {
      final test = await _service.adminGet(baseUrl: widget.authStore.baseUrl, token: token, testId: widget.testId!);
      if (!mounted) return;
      _titleController.text = test.title;
      _descriptionController.text = test.description ?? '';
      _aiUsageHintController.text = test.aiUsageHint ?? '';
      for (final q in test.questions) {
        final editor = _QuestionEditor()..titleController.text = q.text;
        for (final o in q.options) {
          editor.options.add(_OptionEditor(points: o.points)..textController.text = o.text);
        }
        _questions.add(editor);
      }
      for (final r in test.scoreRanges) {
        final editor = _RangeEditor()
          ..minController.text = r.minScore.toString()
          ..maxController.text = r.maxScore.toString()
          ..labelController.text = r.label
          ..descriptionController.text = r.description ?? '';
        _ranges.add(editor);
      }
      setState(() => _isPublished = test.isPublished);
    } on CustomTestsException catch (e) {
      if (mounted) setState(() => _error = e.message);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _addQuestion() {
    final q = _QuestionEditor();
    q.options.add(_OptionEditor());
    q.options.add(_OptionEditor());
    setState(() => _questions.add(q));
  }

  void _removeQuestion(int index) {
    setState(() => _questions.removeAt(index).dispose());
  }

  void _addOption(_QuestionEditor question) {
    setState(() => question.options.add(_OptionEditor()));
  }

  void _removeOption(_QuestionEditor question, int index) {
    setState(() => question.options.removeAt(index).dispose());
  }

  void _addRange() {
    setState(() => _ranges.add(_RangeEditor()));
  }

  void _removeRange(int index) {
    setState(() => _ranges.removeAt(index).dispose());
  }

  List<CustomTestQuestion>? _collectQuestions() {
    final result = <CustomTestQuestion>[];
    for (final q in _questions) {
      final text = q.titleController.text.trim();
      if (text.isEmpty) {
        setState(() => _error = 'У каждого вопроса должен быть текст.');
        return null;
      }
      final options = <CustomTestOption>[];
      for (final o in q.options) {
        final optionText = o.textController.text.trim();
        if (optionText.isEmpty) {
          setState(() => _error = 'У каждого варианта ответа должен быть текст.');
          return null;
        }
        options.add(CustomTestOption(text: optionText, points: o.points));
      }
      if (options.length < 2) {
        setState(() => _error = 'У каждого вопроса должно быть минимум 2 варианта ответа.');
        return null;
      }
      result.add(CustomTestQuestion(text: text, options: options));
    }
    if (result.isEmpty) {
      setState(() => _error = 'Добавь хотя бы один вопрос.');
      return null;
    }
    return result;
  }

  List<CustomTestScoreRange>? _collectRanges() {
    final result = <CustomTestScoreRange>[];
    for (final r in _ranges) {
      final min = int.tryParse(r.minController.text.trim());
      final max = int.tryParse(r.maxController.text.trim());
      final label = r.labelController.text.trim();
      if (min == null || max == null) {
        setState(() => _error = 'Границы диапазона результата должны быть целыми числами.');
        return null;
      }
      if (max < min) {
        setState(() => _error = 'Верхняя граница диапазона не может быть меньше нижней.');
        return null;
      }
      if (label.isEmpty) {
        setState(() => _error = 'У каждого диапазона результата должна быть подпись.');
        return null;
      }
      result.add(CustomTestScoreRange(
        minScore: min,
        maxScore: max,
        label: label,
        description: r.descriptionController.text.trim().isEmpty ? null : r.descriptionController.text.trim(),
      ));
    }
    if (result.isEmpty) {
      setState(() => _error = 'Добавь хотя бы один диапазон результата.');
      return null;
    }
    return result;
  }

  Future<void> _save({required bool publish}) async {
    final token = widget.authStore.token;
    final title = _titleController.text.trim();
    if (token == null || title.isEmpty) {
      setState(() => _error = 'Укажи название теста.');
      return;
    }

    setState(() => _error = null);
    final questions = _collectQuestions();
    if (questions == null) return;
    final ranges = _collectRanges();
    if (ranges == null) return;

    setState(() => _isSaving = true);
    try {
      final description = _descriptionController.text.trim();
      final aiUsageHint = _aiUsageHintController.text.trim();
      if (_isEditing) {
        await _service.adminUpdate(
          baseUrl: widget.authStore.baseUrl,
          token: token,
          testId: widget.testId!,
          title: title,
          description: description,
          questions: questions,
          scoreRanges: ranges,
          aiUsageHint: aiUsageHint,
          isPublished: publish,
        );
      } else {
        await _service.adminCreate(
          baseUrl: widget.authStore.baseUrl,
          token: token,
          title: title,
          description: description,
          questions: questions,
          scoreRanges: ranges,
          aiUsageHint: aiUsageHint,
          isPublished: publish,
        );
      }
      if (mounted) Navigator.of(context).pop(true);
    } on CustomTestsException catch (e) {
      if (mounted) setState(() => _error = e.message);
    } finally {
      if (mounted) setState(() => _isSaving = false);
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
                    Text(
                      _isEditing ? 'Редактировать тест' : 'Новый тест',
                      style: TextStyle(color: context.onSurface, fontSize: 18, fontWeight: FontWeight.w600),
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
                            constraints: const BoxConstraints(maxWidth: 640),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                if (_error != null) ...[
                                  Text(_error!, style: const TextStyle(color: Color(0xFFFFB4B4), fontSize: 13)),
                                  const SizedBox(height: 12),
                                ],
                                _buildTextField(_titleController, 'Название теста'),
                                const SizedBox(height: 10),
                                _buildTextField(_descriptionController, 'Краткое описание (необязательно)', maxLines: 2),
                                const SizedBox(height: 20),
                                Text('ВОПРОСЫ', style: TextStyle(color: context.onSurfaceFaded(0.4), fontSize: 11, letterSpacing: 1.2, fontWeight: FontWeight.w600)),
                                const SizedBox(height: 10),
                                ..._questions.asMap().entries.map((e) => _buildQuestionCard(e.key, e.value)),
                                OutlinedButton.icon(
                                  onPressed: _addQuestion,
                                  icon: const Icon(Icons.add_rounded, size: 18),
                                  label: const Text('Добавить вопрос'),
                                ),
                                const SizedBox(height: 24),
                                Text('ИНТЕРПРЕТАЦИЯ РЕЗУЛЬТАТА', style: TextStyle(color: context.onSurfaceFaded(0.4), fontSize: 11, letterSpacing: 1.2, fontWeight: FontWeight.w600)),
                                const SizedBox(height: 4),
                                Text(
                                  'Диапазоны суммы баллов и что они означают — например, 0-4: «Всё в порядке».',
                                  style: TextStyle(color: context.onSurfaceFaded(0.4), fontSize: 11.5),
                                ),
                                const SizedBox(height: 10),
                                ..._ranges.asMap().entries.map((e) => _buildRangeCard(e.key, e.value)),
                                OutlinedButton.icon(
                                  onPressed: _addRange,
                                  icon: const Icon(Icons.add_rounded, size: 18),
                                  label: const Text('Добавить диапазон'),
                                ),
                                const SizedBox(height: 24),
                                Text('ДЛЯ ИИ', style: TextStyle(color: context.onSurfaceFaded(0.4), fontSize: 11, letterSpacing: 1.2, fontWeight: FontWeight.w600)),
                                const SizedBox(height: 4),
                                Text(
                                  'Когда уместно предложить этот тест прямо в разговоре — '
                                  'например: «если человек несколько недель подряд плохо '
                                  'спит». Это не видно пользователю, только самому ИИ.',
                                  style: TextStyle(color: context.onSurfaceFaded(0.4), fontSize: 11.5),
                                ),
                                const SizedBox(height: 10),
                                _buildTextField(_aiUsageHintController, 'Например: если человек говорит, что не может уснуть', maxLines: 2),
                                const SizedBox(height: 24),
                                Row(
                                  children: [
                                    Expanded(
                                      child: OutlinedButton(
                                        style: OutlinedButton.styleFrom(
                                          side: BorderSide(color: context.onSurfaceFaded(0.2)),
                                          padding: const EdgeInsets.symmetric(vertical: 13),
                                        ),
                                        onPressed: _isSaving ? null : () => _save(publish: false),
                                        child: Text('Сохранить черновик', style: TextStyle(color: context.onSurfaceFaded(0.85))),
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Material(
                                        color: Colors.transparent,
                                        child: InkWell(
                                          borderRadius: BorderRadius.circular(14),
                                          onTap: _isSaving ? null : () => _save(publish: true),
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(vertical: 13),
                                            alignment: Alignment.center,
                                            decoration: BoxDecoration(
                                              borderRadius: BorderRadius.circular(14),
                                              gradient: const LinearGradient(colors: [Color(0xFF6C5CE7), Color(0xFF00B4D8)]),
                                            ),
                                            child: _isSaving
                                                ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                                                : Text(
                                                    _isPublished ? 'Сохранить' : 'Опубликовать',
                                                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                                                  ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
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

  Widget _buildTextField(TextEditingController controller, String hint, {int maxLines = 1}) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      style: TextStyle(color: context.onSurface, fontSize: 14),
      decoration: InputDecoration(
        filled: true,
        fillColor: context.onSurfaceFaded(0.07),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
        hintText: hint,
        hintStyle: TextStyle(color: context.onSurfaceFaded(0.3)),
      ),
    );
  }

  Widget _buildQuestionCard(int index, _QuestionEditor question) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: GlassPanel(
        opacity: 0.07,
        borderRadius: BorderRadius.circular(14),
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(child: _buildTextField(question.titleController, 'Вопрос ${index + 1}')),
                IconButton(
                  icon: Icon(Icons.delete_outline_rounded, size: 20, color: context.onSurfaceFaded(0.4)),
                  onPressed: () => _removeQuestion(index),
                ),
              ],
            ),
            const SizedBox(height: 8),
            ...question.options.asMap().entries.map((e) => _buildOptionRow(question, e.key, e.value)),
            TextButton.icon(
              onPressed: () => _addOption(question),
              icon: const Icon(Icons.add_rounded, size: 16),
              label: const Text('Вариант ответа', style: TextStyle(fontSize: 12.5)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOptionRow(_QuestionEditor question, int index, _OptionEditor option) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: TextField(
              controller: option.textController,
              style: TextStyle(color: context.onSurface, fontSize: 13),
              decoration: InputDecoration(
                filled: true,
                fillColor: context.onSurfaceFaded(0.05),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
                contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
                hintText: 'Вариант ${index + 1}',
                hintStyle: TextStyle(color: context.onSurfaceFaded(0.3)),
              ),
            ),
          ),
          const SizedBox(width: 6),
          SizedBox(
            width: 70,
            // отдельного TextEditingController на баллы нет нарочно - тут
            // просто целое число, key на сам объект-редактор держит
            // состояние поля стабильным между пересборками виджета
            child: TextFormField(
              key: ValueKey(option),
              initialValue: option.points.toString(),
              keyboardType: TextInputType.number,
              style: TextStyle(color: context.onSurface, fontSize: 13),
              decoration: InputDecoration(
                filled: true,
                fillColor: context.onSurfaceFaded(0.05),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
                contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 9),
                hintText: 'Баллы',
                hintStyle: TextStyle(color: context.onSurfaceFaded(0.3)),
              ),
              onChanged: (v) => option.points = int.tryParse(v) ?? 0,
            ),
          ),
          if (question.options.length > 2)
            IconButton(
              icon: Icon(Icons.close_rounded, size: 16, color: context.onSurfaceFaded(0.35)),
              onPressed: () => _removeOption(question, index),
            ),
        ],
      ),
    );
  }

  Widget _buildRangeCard(int index, _RangeEditor range) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: GlassPanel(
        opacity: 0.07,
        borderRadius: BorderRadius.circular(14),
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: range.minController,
                    keyboardType: TextInputType.number,
                    style: TextStyle(color: context.onSurface, fontSize: 13),
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: context.onSurfaceFaded(0.05),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
                      hintText: 'От',
                      hintStyle: TextStyle(color: context.onSurfaceFaded(0.3)),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: range.maxController,
                    keyboardType: TextInputType.number,
                    style: TextStyle(color: context.onSurface, fontSize: 13),
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: context.onSurfaceFaded(0.05),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
                      hintText: 'До',
                      hintStyle: TextStyle(color: context.onSurfaceFaded(0.3)),
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.delete_outline_rounded, size: 20, color: context.onSurfaceFaded(0.4)),
                  onPressed: () => _removeRange(index),
                ),
              ],
            ),
            const SizedBox(height: 8),
            _buildTextField(range.labelController, 'Подпись результата (например: «Всё в порядке»)'),
            const SizedBox(height: 8),
            _buildTextField(range.descriptionController, 'Пояснение (необязательно)', maxLines: 2),
          ],
        ),
      ),
    );
  }
}
