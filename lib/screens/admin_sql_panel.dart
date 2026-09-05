import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../models/sql_query_result.dart';
import '../services/sql_admin_service.dart';
import '../state/auth_store.dart';
import '../theme/app_text_color.dart';
import '../widgets/export_buttons.dart';
import '../widgets/glass_panel.dart';

/// Полноценный SQL-запросчик - выполняет любой SQL как есть, без
/// ограничения на чтение. Мощный инструмент для отладки, но одним
/// неверным запросом можно необратимо повредить данные - отсюда
/// заметное предупреждение вверху и подтверждение перед запросами,
/// похожими на изменение данных (INSERT/UPDATE/DELETE и т.п.).
class AdminSqlPanel extends StatefulWidget {
  final AuthStore authStore;
  const AdminSqlPanel({super.key, required this.authStore});

  @override
  State<AdminSqlPanel> createState() => _AdminSqlPanelState();
}

// ключевые слова запросов, которые меняют данные или саму структуру
// базы - при них перед выполнением спрашиваем подтверждение, даже если
// сам инструмент "полноценный" и в остальном ничего не блокирует
const _mutationKeywords = ['INSERT', 'UPDATE', 'DELETE', 'DROP', 'ALTER', 'TRUNCATE', 'CREATE', 'GRANT', 'REVOKE'];

class _AdminSqlPanelState extends State<AdminSqlPanel> {
  final _service = SqlAdminService();
  final _queryController = TextEditingController();
  bool _isRunning = false;
  SqlQueryResult? _result;
  String? _error;

  @override
  void dispose() {
    _service.dispose();
    _queryController.dispose();
    super.dispose();
  }

  bool _looksLikeMutation(String query) {
    final trimmed = query.trim().toUpperCase();
    return _mutationKeywords.any((kw) => trimmed.startsWith(kw));
  }

  Future<void> _run() async {
    final query = _queryController.text.trim();
    if (query.isEmpty) return;

    if (_looksLikeMutation(query)) {
      final confirmed = await showDialog<bool>(
            context: context,
            builder: (context) => AlertDialog(
              backgroundColor: const Color(0xFF1A2036),
              title: const Text('Точно выполнить?', style: TextStyle(color: Colors.white)),
              content: Text(
                'Этот запрос похож на изменение данных или структуры базы. '
                'Отменить будет нельзя.',
                style: TextStyle(color: Colors.white.withValues(alpha: 0.75)),
              ),
              actions: [
                TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('Отмена')),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  child: const Text('Выполнить', style: TextStyle(color: Color(0xFFFF6B6B))),
                ),
              ],
            ),
          ) ??
          false;
      if (!confirmed) return;
    }

    final token = widget.authStore.token;
    if (token == null) return;
    setState(() {
      _isRunning = true;
      _error = null;
    });
    try {
      final result = await _service.execute(baseUrl: widget.authStore.baseUrl, token: token, query: query);
      if (mounted) setState(() => _result = result);
    } on SqlAdminException catch (e) {
      if (mounted) setState(() => _error = e.message);
    } finally {
      if (mounted) setState(() => _isRunning = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Text('SQL-запросчик', style: TextStyle(color: context.onSurface, fontSize: 20, fontWeight: FontWeight.w700)),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            color: const Color(0xFFFF6B6B).withValues(alpha: 0.14),
            border: Border.all(color: const Color(0xFFFF6B6B).withValues(alpha: 0.4)),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.warning_amber_rounded, color: Color(0xFFFF6B6B), size: 22),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Ничего не трогать здесь, если не уверен(а), что делаешь. '
                  'Это прямой доступ к базе данных без подтверждений и без возможности отменить — '
                  'один неверный запрос может необратимо испортить или удалить данные.',
                  style: TextStyle(color: context.onSurface, fontSize: 12.5, height: 1.5, fontWeight: FontWeight.w500),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        Container(
          decoration: BoxDecoration(
            color: context.onSurfaceFaded(0.06),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: context.onSurfaceFaded(0.12)),
          ),
          child: TextField(
            controller: _queryController,
            minLines: 4,
            maxLines: 10,
            style: TextStyle(color: context.onSurface, fontSize: 13.5, fontFamily: 'monospace'),
            decoration: InputDecoration(
              border: InputBorder.none,
              contentPadding: const EdgeInsets.all(16),
              hintText: 'SELECT * FROM users LIMIT 10',
              hintStyle: TextStyle(color: context.onSurfaceFaded(0.3), fontFamily: 'monospace'),
            ),
          ),
        ),
        const SizedBox(height: 12),
        Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(14),
            onTap: _isRunning ? null : _run,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 13),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                gradient: LinearGradient(
                  colors: _isRunning
                      ? [context.onSurfaceFaded(0.2), context.onSurfaceFaded(0.1)]
                      : [const Color(0xFF6C5CE7), const Color(0xFF00B4D8)],
                ),
              ),
              child: _isRunning
                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : const Text('Выполнить', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
            ),
          ),
        ),
        if (_error != null) ...[
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: const Color(0xFFFF6B6B).withValues(alpha: 0.1),
            ),
            child: Text(_error!, style: const TextStyle(color: Color(0xFFFFB4B4), fontSize: 13, fontFamily: 'monospace')),
          ),
        ],
        if (_result != null) ...[
          const SizedBox(height: 20),
          _buildResult(_result!),
        ],
      ],
    );
  }

  Widget _buildResult(SqlQueryResult result) {
    if (!result.isSelect) {
      return GlassPanel(
        opacity: 0.06,
        borderRadius: BorderRadius.circular(14),
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            const Icon(Icons.check_circle_outline_rounded, color: Color(0xFF00E6A0), size: 20),
            const SizedBox(width: 10),
            Text(
              'Готово. Изменено строк: ${result.rowCount ?? 0}',
              style: TextStyle(color: context.onSurface, fontSize: 13.5),
            ),
          ],
        ),
      );
    }

    if (result.rows.isEmpty) {
      return GlassPanel(
        opacity: 0.06,
        borderRadius: BorderRadius.circular(14),
        padding: const EdgeInsets.all(16),
        child: Text('Запрос выполнен, строк не найдено.', style: TextStyle(color: context.onSurfaceFaded(0.5))),
      );
    }

    return GlassPanel(
      opacity: 0.06,
      borderRadius: BorderRadius.circular(14),
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (result.truncated)
                Expanded(
                  child: Text(
                    'Показаны первые ${result.rows.length} строк — результат обрезан.',
                    style: TextStyle(color: context.onSurfaceFaded(0.4), fontSize: 11.5),
                  ),
                )
              else
                const Spacer(),
              ExportButtonsRow(filename: 'SQL-результат', columns: result.columns, rows: result.rows),
              const SizedBox(width: 4),
              TextButton.icon(
                onPressed: () => _copyWholeResult(result),
                icon: Icon(Icons.copy_all_rounded, size: 16, color: context.onSurfaceFaded(0.6)),
                label: Text('Копировать всё', style: TextStyle(color: context.onSurfaceFaded(0.6), fontSize: 12)),
              ),
            ],
          ),
          const SizedBox(height: 4),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              columns: result.columns
                  .map((c) => DataColumn(
                      label: Text(c, style: TextStyle(color: context.onSurfaceFaded(0.6), fontSize: 12, fontWeight: FontWeight.w600))))
                  .toList(),
              rows: result.rows
                  .map((row) => DataRow(
                        cells: row
                            .map((cell) => DataCell(
                                  Text(
                                    cell?.toString() ?? 'NULL',
                                    style: TextStyle(
                                      color: cell == null ? context.onSurfaceFaded(0.3) : context.onSurface,
                                      fontSize: 12.5,
                                      fontStyle: cell == null ? FontStyle.italic : FontStyle.normal,
                                      fontFamily: 'monospace',
                                    ),
                                  ),
                                  // тап по ячейке копирует именно её значение -
                                  // отдельно от кнопки "Копировать всё" выше
                                  onTap: () => _copyCell(cell),
                                ))
                            .toList(),
                      ))
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }

  void _copyCell(dynamic cell) {
    Clipboard.setData(ClipboardData(text: cell?.toString() ?? 'NULL'));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Скопировано'), duration: Duration(seconds: 1)),
    );
  }

  // TSV (значения через таб) - вставляется прямо в Excel/Google Таблицы
  // отдельными ячейками по столбцам, не одной строкой текста
  void _copyWholeResult(SqlQueryResult result) {
    final buffer = StringBuffer();
    buffer.writeln(result.columns.join('\t'));
    for (final row in result.rows) {
      buffer.writeln(row.map((cell) => cell?.toString() ?? 'NULL').join('\t'));
    }
    Clipboard.setData(ClipboardData(text: buffer.toString()));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Весь результат скопирован — можно вставить в таблицу'), duration: Duration(seconds: 2)),
    );
  }
}
