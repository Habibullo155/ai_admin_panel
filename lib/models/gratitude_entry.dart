class GratitudeEntry {
  final String id;
  final DateTime date;
  final List<String> items;

  GratitudeEntry({required this.id, required this.date, required this.items});

  Map<String, dynamic> toJson() => {
        'id': id,
        'date': date.toIso8601String(),
        'items': items,
      };

  factory GratitudeEntry.fromJson(Map<String, dynamic> json) {
    return GratitudeEntry(
      id: json['id'] as String,
      date: DateTime.tryParse(json['date'] as String? ?? '') ?? DateTime.now(),
      items: (json['items'] as List<dynamic>? ?? []).map((e) => e.toString()).toList(),
    );
  }
}
