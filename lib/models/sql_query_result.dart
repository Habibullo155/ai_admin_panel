class SqlQueryResult {
  final bool isSelect;
  final List<String> columns;
  final List<List<dynamic>> rows;
  final int? rowCount;
  final bool truncated;

  SqlQueryResult({
    required this.isSelect,
    required this.columns,
    required this.rows,
    required this.rowCount,
    required this.truncated,
  });

  factory SqlQueryResult.fromJson(Map<String, dynamic> json) => SqlQueryResult(
        isSelect: json['is_select'] as bool? ?? false,
        columns: (json['columns'] as List<dynamic>? ?? []).map((e) => e as String).toList(),
        rows: (json['rows'] as List<dynamic>? ?? []).map((row) => row as List<dynamic>).toList(),
        rowCount: json['row_count'] as int?,
        truncated: json['truncated'] as bool? ?? false,
      );
}
