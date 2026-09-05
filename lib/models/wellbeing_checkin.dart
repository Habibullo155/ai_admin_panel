/// Результат прохождения ВОЗ-5 (WHO-5 Well-Being Index) — короткого,
/// бесплатного и валидированного опросника психологического благополучия
/// Всемирной организации здравоохранения. Не диагностический инструмент:
/// официальная интерпретация ВОЗ — балл ниже 50% является поводом для
/// дальнейшей оценки специалистом, а не диагнозом сам по себе.
class WellbeingCheckin {
  final String id;
  final DateTime date;

  /// 5 ответов, каждый от 0 (никогда) до 5 (всё время) — как в оригинале ВОЗ-5.
  final List<int> answers;

  WellbeingCheckin({required this.id, required this.date, required this.answers})
      : assert(answers.length == 5);

  /// Сырой балл: сумма пяти ответов, 0–25.
  int get rawScore => answers.fold(0, (sum, a) => sum + a);

  /// Балл в процентах, 0–100 — именно так ВОЗ рекомендует его показывать.
  int get percentScore => rawScore * 4;

  /// Официальный порог ВОЗ: ниже 50% — повод для дальнейшей оценки
  /// специалистом (не диагноз сам по себе).
  bool get suggestsFurtherAssessment => percentScore < 50;

  Map<String, dynamic> toJson() => {
        'id': id,
        'date': date.toIso8601String(),
        'answers': answers,
      };

  factory WellbeingCheckin.fromJson(Map<String, dynamic> json) {
    return WellbeingCheckin(
      id: json['id'] as String,
      date: DateTime.tryParse(json['date'] as String? ?? '') ?? DateTime.now(),
      answers: (json['answers'] as List<dynamic>).map((e) => e as int).toList(),
    );
  }
}
