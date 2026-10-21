/// ASRS-v1.1 Screener (6 вопросов, Часть A)
const asrsQuestions = [
  'Как часто вам трудно завершить последние детали проекта, когда основная сложная часть уже сделана?',
  'Как часто у вас возникают сложности с тем, чтобы навести порядок, когда задача требует организованности?',
  'Как часто у вас возникают проблемы с тем, чтобы не забыть о встречах или обязательствах?',
  'Когда задача требует много размышлений, как часто вы избегаете её или откладываете начало?',
  'Как часто вы ёрзаете или суетитесь руками или ногами, когда приходится долго сидеть?',
  'Как часто вы чувствуете себя чрезмерно активным(ой) и вынужденным(ой) что-то делать, будто вас подгоняет мотор?',
];

const asrsResponseLabels = ['Никогда', 'Редко', 'Иногда', 'Часто', 'Очень часто'];

class AsrsCheckin {
  final String id;
  final DateTime date;
  final List<int> answers; // 6 значений, каждое 0-4 (Никогда..Очень часто)

  AsrsCheckin({required this.id, required this.date, required this.answers});

  /// Официальная схема подсчёта ASRS Part A
  int get shadedCount {
    var count = 0;
    for (var i = 0; i < answers.length && i < 6; i++) {
      final threshold = i < 3 ? 2 : 3; // индекс "Иногда"=2, "Часто"=3
      if (answers[i] >= threshold) count++;
    }
    return count;
  }

  /// Официальный порог методики — 4 и более пункта в закрашенной зоне.
  bool get suggestsFurtherAssessment => shadedCount >= 4;

  Map<String, dynamic> toJson() => {
        'id': id,
        'date': date.toIso8601String(),
        'answers': answers,
      };

  factory AsrsCheckin.fromJson(Map<String, dynamic> json) {
    return AsrsCheckin(
      id: json['id'] as String,
      date: DateTime.tryParse(json['date'] as String? ?? '') ?? DateTime.now(),
      answers: (json['answers'] as List<dynamic>? ?? []).map((e) => e as int).toList(),
    );
  }
}
