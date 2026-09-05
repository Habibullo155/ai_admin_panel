import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:share_plus/share_plus.dart';

import '../theme/app_text_color.dart';

/// Общая логика выгрузки таблицы в CSV/PDF - переиспользуется в трёх
/// местах (покупки, расход токенов, результат SQL-запроса), чтобы не
/// дублировать генерацию файла и общий UI кнопок в каждом отдельно.
class ExportButtonsRow extends StatelessWidget {
  final String filename; // без расширения - оно добавляется само под каждый формат
  final List<String> columns;
  final List<List<dynamic>> rows;

  const ExportButtonsRow({super.key, required this.filename, required this.columns, required this.rows});

  // экранирование по правилам CSV (RFC 4180): поле с запятой, кавычкой
  // или переносом строки берётся в кавычки, кавычки внутри - удваиваются
  String _csvEscape(String field) {
    if (field.contains(',') || field.contains('"') || field.contains('\n')) {
      return '"${field.replaceAll('"', '""')}"';
    }
    return field;
  }

  Uint8List _buildCsvBytes() {
    final buffer = StringBuffer();
    buffer.writeln(columns.map((c) => _csvEscape(c)).join(','));
    for (final row in rows) {
      buffer.writeln(row.map((cell) => _csvEscape(cell?.toString() ?? '')).join(','));
    }
    // BOM в начале - без него Excel на Windows может неправильно
    // определить кодировку кириллицы в CSV как не-UTF8
    return Uint8List.fromList([0xEF, 0xBB, 0xBF, ...buffer.toString().codeUnits]);
  }

  Future<Uint8List> _buildPdfBytes() async {
    final doc = pw.Document();
    // делим на страницы по 30 строк - pw.Table.fromTextArray сам не
    // переносит содержимое на новую страницу PDF, если строк слишком много.
    // do-while - минимум одна страница даже для пустой таблицы (просто с
    // заголовком, без строк), дальше продолжаем, пока есть данные
    const rowsPerPage = 30;
    var start = 0;
    do {
      final pageRows = rows.skip(start).take(rowsPerPage).toList();
      doc.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4.landscape,
          build: (context) => pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(filename, style: const pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 10),
              pw.Table.fromTextArray(
                headers: columns,
                data: pageRows.map((row) => row.map((cell) => cell?.toString() ?? '').toList()).toList(),
                headerStyle: const pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 9),
                cellStyle: const pw.TextStyle(fontSize: 8),
                cellAlignment: pw.Alignment.centerLeft,
              ),
            ],
          ),
        ),
      );
      start += rowsPerPage;
    } while (start < rows.length);
    return doc.save();
  }

  Future<void> _exportCsv(BuildContext context) async {
    try {
      final bytes = _buildCsvBytes();
      await Share.shareXFiles([XFile.fromData(bytes, name: '$filename.csv', mimeType: 'text/csv')]);
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Не удалось экспортировать: $e')));
      }
    }
  }

  Future<void> _exportPdf(BuildContext context) async {
    try {
      final bytes = await _buildPdfBytes();
      await Share.shareXFiles([XFile.fromData(bytes, name: '$filename.pdf', mimeType: 'application/pdf')]);
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Не удалось экспортировать: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        TextButton.icon(
          onPressed: rows.isEmpty ? null : () => _exportCsv(context),
          icon: Icon(Icons.table_chart_outlined, size: 16, color: context.onSurfaceFaded(rows.isEmpty ? 0.25 : 0.6)),
          label: Text('Excel (CSV)', style: TextStyle(color: context.onSurfaceFaded(rows.isEmpty ? 0.25 : 0.6), fontSize: 12)),
        ),
        const SizedBox(width: 4),
        TextButton.icon(
          onPressed: rows.isEmpty ? null : () => _exportPdf(context),
          icon: Icon(Icons.picture_as_pdf_outlined, size: 16, color: context.onSurfaceFaded(rows.isEmpty ? 0.25 : 0.6)),
          label: Text('PDF', style: TextStyle(color: context.onSurfaceFaded(rows.isEmpty ? 0.25 : 0.6), fontSize: 12)),
        ),
      ],
    );
  }
}
