class CustomTestOption {
  String text;
  int points;
  CustomTestOption({required this.text, required this.points});

  factory CustomTestOption.fromJson(Map<String, dynamic> json) => CustomTestOption(
        text: json['text'] as String? ?? '',
        points: json['points'] as int? ?? 0,
      );

  Map<String, dynamic> toJson() => {'text': text, 'points': points};
}

class CustomTestQuestion {
  String text;
  List<CustomTestOption> options;
  CustomTestQuestion({required this.text, required this.options});

  factory CustomTestQuestion.fromJson(Map<String, dynamic> json) => CustomTestQuestion(
        text: json['text'] as String? ?? '',
        options: (json['options'] as List<dynamic>? ?? [])
            .map((o) => CustomTestOption.fromJson(o as Map<String, dynamic>))
            .toList(),
      );

  Map<String, dynamic> toJson() => {'text': text, 'options': options.map((o) => o.toJson()).toList()};
}

class CustomTestScoreRange {
  int minScore;
  int maxScore;
  String label;
  String? description;
  CustomTestScoreRange({required this.minScore, required this.maxScore, required this.label, this.description});

  factory CustomTestScoreRange.fromJson(Map<String, dynamic> json) => CustomTestScoreRange(
        minScore: json['min_score'] as int? ?? 0,
        maxScore: json['max_score'] as int? ?? 0,
        label: json['label'] as String? ?? '',
        description: json['description'] as String?,
      );

  Map<String, dynamic> toJson() => {
        'min_score': minScore,
        'max_score': maxScore,
        'label': label,
        if (description != null && description!.isNotEmpty) 'description': description,
      };
}

class CustomTestSummary {
  final int id;
  final String title;
  final String? description;
  final bool isPublished;
  final int questionCount;
  final DateTime createdAt;

  CustomTestSummary({
    required this.id,
    required this.title,
    required this.description,
    required this.isPublished,
    required this.questionCount,
    required this.createdAt,
  });

  factory CustomTestSummary.fromJson(Map<String, dynamic> json) => CustomTestSummary(
        id: json['id'] as int,
        title: json['title'] as String? ?? '',
        description: json['description'] as String?,
        isPublished: json['is_published'] as bool? ?? false,
        questionCount: json['question_count'] as int? ?? 0,
        createdAt: DateTime.tryParse(json['created_at'] as String? ?? '') ?? DateTime.now(),
      );
}

class CustomTest {
  final int id;
  final int authorId;
  final String? authorEmail;
  String title;
  String? description;
  List<CustomTestQuestion> questions;
  List<CustomTestScoreRange> scoreRanges;
  String? aiUsageHint;
  bool isPublished;
  final DateTime createdAt;
  final DateTime updatedAt;

  CustomTest({
    required this.id,
    required this.authorId,
    required this.authorEmail,
    required this.title,
    required this.description,
    required this.questions,
    required this.scoreRanges,
    required this.aiUsageHint,
    required this.isPublished,
    required this.createdAt,
    required this.updatedAt,
  });

  factory CustomTest.fromJson(Map<String, dynamic> json) => CustomTest(
        id: json['id'] as int,
        authorId: json['author_id'] as int,
        authorEmail: json['author_email'] as String?,
        title: json['title'] as String? ?? '',
        description: json['description'] as String?,
        questions: (json['questions'] as List<dynamic>? ?? [])
            .map((q) => CustomTestQuestion.fromJson(q as Map<String, dynamic>))
            .toList(),
        scoreRanges: (json['score_ranges'] as List<dynamic>? ?? [])
            .map((r) => CustomTestScoreRange.fromJson(r as Map<String, dynamic>))
            .toList(),
        aiUsageHint: json['ai_usage_hint'] as String?,
        isPublished: json['is_published'] as bool? ?? false,
        createdAt: DateTime.tryParse(json['created_at'] as String? ?? '') ?? DateTime.now(),
        updatedAt: DateTime.tryParse(json['updated_at'] as String? ?? '') ?? DateTime.now(),
      );
}

class CustomTestResult {
  final int id;
  final int testId;
  final int totalScore;
  final String? resultLabel;
  final DateTime createdAt;

  CustomTestResult({
    required this.id,
    required this.testId,
    required this.totalScore,
    required this.resultLabel,
    required this.createdAt,
  });

  factory CustomTestResult.fromJson(Map<String, dynamic> json) => CustomTestResult(
        id: json['id'] as int,
        testId: json['test_id'] as int,
        totalScore: json['total_score'] as int? ?? 0,
        resultLabel: json['result_label'] as String?,
        createdAt: DateTime.tryParse(json['created_at'] as String? ?? '') ?? DateTime.now(),
      );
}

/// Запись истории для календаря — в отличие от CustomTestResult (ответ
/// сразу после прохождения) содержит название теста явно, чтобы не
/// делать отдельный запрос на каждую запись истории.
class CustomTestResultHistory {
  final int id;
  final int testId;
  final String testTitle;
  final int totalScore;
  final String? resultLabel;
  final DateTime createdAt;

  CustomTestResultHistory({
    required this.id,
    required this.testId,
    required this.testTitle,
    required this.totalScore,
    required this.resultLabel,
    required this.createdAt,
  });

  factory CustomTestResultHistory.fromJson(Map<String, dynamic> json) => CustomTestResultHistory(
        id: json['id'] as int,
        testId: json['test_id'] as int,
        testTitle: json['test_title'] as String? ?? '',
        totalScore: json['total_score'] as int? ?? 0,
        resultLabel: json['result_label'] as String?,
        createdAt: DateTime.tryParse(json['created_at'] as String? ?? '') ?? DateTime.now(),
      );
}
