import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/response_report.dart';
import '../services/reports_service.dart';
import '../state/auth_store.dart';
import '../theme/app_text_color.dart';
import '../widgets/app_background.dart';
import '../widgets/glass_panel.dart';

class AdminReportsScreen extends StatefulWidget {
  final AuthStore authStore;
  final VoidCallback? onBack;
  const AdminReportsScreen({super.key, required this.authStore, this.onBack});

  @override
  State<AdminReportsScreen> createState() => _AdminReportsScreenState();
}

class _AdminReportsScreenState extends State<AdminReportsScreen> {
  final _service = ReportsService();
  final _replyControllers = <int, TextEditingController>{};
  List<ResponseReport> _reports = [];
  bool _isLoading = true;
  String? _error;
  int? _sendingReplyForId;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _service.dispose();
    for (final c in _replyControllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  TextEditingController _controllerFor(ResponseReport report) {
    return _replyControllers.putIfAbsent(
      report.id,
      () => TextEditingController(text: report.adminReply ?? ''),
    );
  }

  Future<void> _sendReply(ResponseReport report) async {
    final token = widget.authStore.token;
    final text = _controllerFor(report).text.trim();
    if (token == null || text.isEmpty) return;

    setState(() => _sendingReplyForId = report.id);
    try {
      final updated = await _service.setReply(
        baseUrl: widget.authStore.baseUrl,
        token: token,
        reportId: report.id,
        reply: text,
      );
      if (!mounted) return;
      setState(() {
        final idx = _reports.indexWhere((r) => r.id == report.id);
        if (idx != -1) _reports[idx] = updated;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Ответ отправлен'), duration: Duration(seconds: 1)),
        );
      }
    } on ReportsException catch (e) {
      if (!mounted) return;
      setState(() => _error = e.message);
    } finally {
      if (mounted) setState(() => _sendingReplyForId = null);
    }
  }

  Future<void> _load() async {
    final token = widget.authStore.token;
    if (token == null) return;
    setState(() => _isLoading = true);
    try {
      final reports = await _service.allReports(baseUrl: widget.authStore.baseUrl, token: token);
      if (!mounted) return;
      setState(() => _reports = reports);
    } on ReportsException catch (e) {
      if (!mounted) return;
      setState(() => _error = e.message);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _toggleStatus(ResponseReport report) async {
    final token = widget.authStore.token;
    if (token == null) return;
    final newStatus = report.status == ReportStatus.open ? ReportStatus.resolved : ReportStatus.open;
    try {
      final updated = await _service.updateStatus(
        baseUrl: widget.authStore.baseUrl,
        token: token,
        reportId: report.id,
        status: newStatus,
      );
      if (!mounted) return;
      setState(() {
        final idx = _reports.indexWhere((r) => r.id == report.id);
        if (idx != -1) _reports[idx] = updated;
      });
    } on ReportsException catch (e) {
      if (!mounted) return;
      setState(() => _error = e.message);
    }
  }

  int get _openCount => _reports.where((r) => r.status == ReportStatus.open).length;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: AppBackground(
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    // сайдбар в AdminShellScreen уже даёт навигацию - кнопка "назад" была
                    // бы бессмысленной, когда экран встроен содержимым (onBack задан).
                    // Показываем её только при обычном отдельном маршруте (onBack == null).
                    if (widget.onBack == null)
                      IconButton(
                        icon: Icon(Icons.arrow_back_rounded, color: context.onSurface),
                        onPressed: () => Navigator.of(context).pop(),
                      )
                    else
                      const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Жалобы на ответы ИИ',
                        style: TextStyle(color: context.onSurface, fontSize: 17, fontWeight: FontWeight.w600),
                      ),
                    ),
                    if (_openCount > 0)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: const Color(0xFFFFD166).withValues(alpha: 0.2),
                        ),
                        child: Text(
                          '$_openCount открыто',
                          style: const TextStyle(color: Color(0xFFFFD166), fontSize: 12, fontWeight: FontWeight.w600),
                        ),
                      ),
                  ],
                ),
              ),
              Expanded(
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 680),
                    child: RefreshIndicator(
                      onRefresh: _load,
                      child: _isLoading
                          ? const Center(child: CircularProgressIndicator(color: Color(0xFF6C5CE7)))
                          : _reports.isEmpty
                              ? ListView(
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.symmetric(vertical: 60),
                                      child: Center(
                                        child: Text('Жалоб нет', style: TextStyle(color: context.onSurfaceFaded(0.4))),
                                      ),
                                    ),
                                  ],
                                )
                              : ListView(
                                  padding: const EdgeInsets.all(16),
                                  children: [
                                    if (_error != null)
                                      Padding(
                                        padding: const EdgeInsets.only(bottom: 12),
                                        child: Text(_error!, style: const TextStyle(color: Color(0xFFFFB4B4))),
                                      ),
                                    ..._reports.map(_buildReportTile),
                                  ],
                                ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildReportTile(ResponseReport report) {
    final isResolved = report.status == ReportStatus.resolved;
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: GlassPanel(
        opacity: isResolved ? 0.05 : 0.09,
        blurred: false, // список из многих жалоб — см. message_bubble.dart
        borderRadius: BorderRadius.circular(16),
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    color: (isResolved ? Colors.white24 : const Color(0xFFFFD166)).withValues(alpha: 0.18),
                  ),
                  child: Text(
                    isResolved ? 'Разобрано' : 'Открыто',
                    style: TextStyle(
                      color: isResolved ? Colors.white54 : const Color(0xFFFFD166),
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    report.userEmail ?? 'Пользователь #${report.userId}',
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: context.onSurface, fontWeight: FontWeight.w600, fontSize: 13),
                  ),
                ),
                Text(
                  DateFormat.yMMMd().add_Hm().format(report.createdAt),
                  style: TextStyle(color: context.onSurfaceFaded(0.3), fontSize: 11),
                ),
              ],
            ),
            if (report.reason != null && report.reason!.trim().isNotEmpty) ...[
              const SizedBox(height: 10),
              Text(
                report.reason!,
                style: const TextStyle(color: Color(0xFFFFD166), fontSize: 13, fontStyle: FontStyle.italic),
              ),
            ],
            const SizedBox(height: 10),
            _buildLabeledText('Вопрос', report.userMessage, context.onSurfaceFaded(0.55)),
            const SizedBox(height: 6),
            _buildLabeledText('Ответ ИИ', report.aiResponse, context.onSurfaceFaded(0.85)),
            const SizedBox(height: 12),
            _buildReplySection(report),
            const SizedBox(height: 10),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                onPressed: () => _toggleStatus(report),
                icon: Icon(
                  isResolved ? Icons.refresh_rounded : Icons.check_circle_outline_rounded,
                  size: 16,
                  color: context.onSurfaceFaded(0.7),
                ),
                label: Text(
                  isResolved ? 'Открыть заново' : 'Отметить разобранным',
                  style: TextStyle(color: context.onSurfaceFaded(0.7), fontSize: 12.5),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReplySection(ResponseReport report) {
    final controller = _controllerFor(report);
    final isSending = _sendingReplyForId == report.id;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'ОТВЕТ ПОЛЬЗОВАТЕЛЮ',
          style: TextStyle(color: context.onSurfaceFaded(0.35), fontSize: 10, letterSpacing: 0.8),
        ),
        const SizedBox(height: 4),
        Text(
          'Виден только этому пользователю в его списке жалоб.',
          style: TextStyle(color: context.onSurfaceFaded(0.3), fontSize: 10.5),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          minLines: 1,
          maxLines: 4,
          style: TextStyle(color: context.onSurface, fontSize: 13),
          decoration: InputDecoration(
            filled: true,
            fillColor: context.onSurfaceFaded(0.06),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
            contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            hintText: 'Например: разобрались, поправили модель',
            hintStyle: TextStyle(color: context.onSurfaceFaded(0.25), fontSize: 12.5),
          ),
        ),
        const SizedBox(height: 6),
        Align(
          alignment: Alignment.centerRight,
          child: TextButton.icon(
            onPressed: isSending ? null : () => _sendReply(report),
            icon: isSending
                ? const SizedBox(
                    width: 13,
                    height: 13,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF6C5CE7)),
                  )
                : const Icon(Icons.send_rounded, size: 15, color: Color(0xFF6C5CE7)),
            label: Text(
              report.adminReply == null || report.adminReply!.isEmpty ? 'Отправить ответ' : 'Обновить ответ',
              style: const TextStyle(color: Color(0xFF6C5CE7), fontSize: 12.5),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLabeledText(String label, String text, Color textColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label.toUpperCase(), style: TextStyle(color: context.onSurfaceFaded(0.35), fontSize: 10, letterSpacing: 0.8)),
        const SizedBox(height: 2),
        Text(text, style: TextStyle(color: textColor, fontSize: 13, height: 1.4)),
      ],
    );
  }
}
