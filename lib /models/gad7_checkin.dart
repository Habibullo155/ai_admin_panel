/// Официальный русский перевод GAD-7 (Copyright© 1999 Pfizer Inc., с 2010
/// года распространяется без ограничений авторского права и без платы).
/// Разработан докторами Spitzer, Williams, Kroenke, Löwe и коллегами.
const gad7Questions = [
  'Чувство нервозности, тревоги или напряжённости',
  'Неспособность остановить или контролировать беспокойство',
  'Слишком сильное беспокойство о разных вещах',
  'Трудности с расслаблением',
  'Такое беспокойство, что трудно усидеть на месте',
  'Лёгкая раздражительность или вспыльчивость',
  'Чувство страха, как будто может случиться что-то ужасное',
];

const gad7ResponseLabels = [
  'Совсем не беспокоило',
  'Несколько дней',
  'Более половины дней',
  'Почти каждый день',
];

class Gad7Checkin {
  final String id;
  final DateTime date;
  final List<int> answers; // 7 значений, каждое 0-3

  Gad7Checkin({required this.id, required this.date, required this.answers});

  int get rawScore => answers.fold(0, (sum, a) => sum + a);

  /// Официальный порог методики GAD-7 для рекомендации дополнительной
  /// оценки специалистом — 10 и выше.
  bool get suggestsFurtherAssessment => rawScore >= 10;

  /// Описание выраженности симптомов по официальным границам методики —
  /// не диагноз, а то, как сама методика описывает диапазон результата.
  String get severityLabel {
    if (rawScore <= 4) return 'минимальная выраженность';
    if (rawScore <= 9) return 'лёгкая выраженность';
    if (rawScore <= 14) return 'умеренная выраженность';
    return 'выраженная тяжесть симптомов';
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'date': date.toIso8601String(),
        'answers': answers,
      };

  factory Gad7Checkin.fromJson(Map<String, dynamic> json) {
    return Gad7Checkin(
      id: json['id'] as String,
      date: DateTime.tryParse(json['date'] as String? ?? '') ?? DateTime.now(),
      answers: (json['answers'] as List<dynamic>? ?? []).map((e) => e as int).toList(),
    );
  }
}
