import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/response_report.dart';
import '../services/reports_service.dart';
import '../state/auth_store.dart';
import '../widgets/app_background.dart';
import '../widgets/glass_panel.dart';

/// Собственные жалобы пользователя на ответы ИИ — раньше их вообще
/// негде было посмотреть после отправки. Теперь виден статус и, если
/// админ ответил, его текстовый ответ по существу.
class MyReportsScreen extends StatefulWidget {
  final AuthStore authStore;
  const MyReportsScreen({super.key, required this.authStore});

  @override
  State<MyReportsScreen> createState() => _MyReportsScreenState();
}

class _MyReportsScreenState extends State<MyReportsScreen> {
  final _service = ReportsService();
  List<ResponseReport> _reports = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _service.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    final token = widget.authStore.token;
    if (token == null) return;
    setState(() => _isLoading = true);
    try {
      final reports = await _service.myReports(baseUrl: widget.authStore.baseUrl, token: token);
      if (!mounted) return;
      setState(() => _reports = reports);
    } on ReportsException catch (e) {
      if (!mounted) return;
      setState(() => _error = e.message);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

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
                    IconButton(
                      icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                    const Text(
                      'Мои жалобы',
                      style: TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 640),
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
                                        child: Text(
                                          'Жалоб пока нет',
                                          style: TextStyle(color: Colors.white.withOpacity(0.4)),
                                        ),
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
    final hasReply = report.adminReply != null && report.adminReply!.trim().isNotEmpty;
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: GlassPanel(
        opacity: 0.08,
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
                    color: (isResolved ? const Color(0xFF00E6A0) : const Color(0xFFFFD166)).withOpacity(0.18),
                  ),
                  child: Text(
                    isResolved ? 'Разобрано' : 'На рассмотрении',
                    style: TextStyle(
                      color: isResolved ? const Color(0xFF00E6A0) : const Color(0xFFFFD166),
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const Spacer(),
                Text(
                  DateFormat.yMMMd().add_Hm().format(report.createdAt),
                  style: TextStyle(color: Colors.white.withOpacity(0.3), fontSize: 11),
                ),
              ],
            ),
            const SizedBox(height: 10),
            _buildLabeledText('Твой вопрос', report.userMessage, Colors.white.withOpacity(0.55)),
            const SizedBox(height: 6),
            _buildLabeledText('Ответ ИИ, на который пожаловался(-ась)', report.aiResponse, Colors.white.withOpacity(0.7)),
            if (report.reason != null && report.reason!.trim().isNotEmpty) ...[
              const SizedBox(height: 6),
              _buildLabeledText('Причина жалобы', report.reason!, Colors.white.withOpacity(0.6)),
            ],
            if (hasReply) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: const Color(0xFF6C5CE7).withOpacity(0.12),
                  border: Border.all(color: const Color(0xFF6C5CE7).withOpacity(0.3)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'ОТВЕТ ОТ КОМАНДЫ',
                      style: TextStyle(color: const Color(0xFF6C5CE7).withOpacity(0.8), fontSize: 10, letterSpacing: 0.8),
                    ),
                    const SizedBox(height: 4),
                    Text(report.adminReply!, style: const TextStyle(color: Colors.white, fontSize: 13, height: 1.4)),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildLabeledText(String label, String text, Color textColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label.toUpperCase(), style: TextStyle(color: Colors.white.withOpacity(0.35), fontSize: 10, letterSpacing: 0.8)),
        const SizedBox(height: 2),
        Text(text, style: TextStyle(color: textColor, fontSize: 13, height: 1.4)),
      ],
    );
  }
}
