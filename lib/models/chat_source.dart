/// Источник ответа модели из загруженных документов (RAG) — файл и
/// номер страницы, откуда взят фрагмент. Присылается сервером ТОЛЬКО
/// для админов (main.py сам решает, включать ли sources в ответ — не
/// проверка на стороне Flutter, а серверная).
class ChatSource {
  final String filename;
  final int? page;
  final double similarity;

  ChatSource({required this.filename, required this.page, required this.similarity});

  factory ChatSource.fromJson(Map<String, dynamic> json) {
    return ChatSource(
      filename: json['filename'] as String? ?? 'неизвестно',
      page: json['page'] as int?,
      similarity: (json['similarity'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() => {
        'filename': filename,
        'page': page,
        'similarity': similarity,
      };
}
