class RagDocument {
  final int id;
  final String filename;
  final int chunkCount;
  final DateTime createdAt;

  RagDocument({
    required this.id,
    required this.filename,
    required this.chunkCount,
    required this.createdAt,
  });

  factory RagDocument.fromJson(Map<String, dynamic> json) {
    return RagDocument(
      id: json['id'] as int,
      filename: json['filename'] as String,
      chunkCount: json['chunk_count'] as int? ?? 0,
      createdAt:
          DateTime.tryParse(json['created_at'] as String? ?? '') ?? DateTime.now(),
    );
  }
}
