import 'package:flutter/material.dart';

import '../services/reports_service.dart';
import '../state/auth_store.dart';
import 'glass_panel.dart';

Future<void> showReportDialog(
  BuildContext context, {
  required AuthStore authStore,
  required String userMessage,
  required String aiResponse,
}) {
  return showDialog(
    context: context,
    builder: (context) => _ReportDialog(
      authStore: authStore,
      userMessage: userMessage,
      aiResponse: aiResponse,
    ),
  );
}

class _ReportDialog extends StatefulWidget {
  final AuthStore authStore;
  final String userMessage;
  final String aiResponse;
  const _ReportDialog({required this.authStore, required this.userMessage, required this.aiResponse});

  @override
  State<_ReportDialog> createState() => _ReportDialogState();
}

class _ReportDialogState extends State<_ReportDialog> {
  final _service = ReportsService();
  final _reasonController = TextEditingController();
  bool _isBusy = false;
  bool _isSent = false;
  String? _error;

  @override
  void dispose() {
    _service.dispose();
    _reasonController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final token = widget.authStore.token;
    if (token == null) return;

    setState(() {
      _isBusy = true;
      _error = null;
    });
    try {
      await _service.createReport(
        baseUrl: widget.authStore.baseUrl,
        token: token,
        userMessage: widget.userMessage,
        aiResponse: widget.aiResponse,
        reason: _reasonController.text,
      );
      if (!mounted) return;
      setState(() => _isSent = true);
    } on ReportsException catch (e) {
      if (!mounted) return;
      setState(() => _error = e.message);
    } finally {
      if (mounted) setState(() => _isBusy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: GlassPanel(
        opacity: 0.18,
        borderRadius: BorderRadius.circular(20),
        padding: const EdgeInsets.all(20),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 400),
          child: _isSent ? _buildSentState() : _buildFormState(),
        ),
      ),
    );
  }

  Widget _buildSentState() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          children: [
            Icon(Icons.check_circle_rounded, color: Color(0xFF00E6A0)),
            SizedBox(width: 10),
            Text('Жалоба отправлена', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600)),
          ],
        ),
        const SizedBox(height: 10),
        Text(
          'Спасибо — мы посмотрим этот ответ. Текст вопроса и ответа передан '
          'вместе с жалобой, чтобы можно было сразу разобраться, не переспрашивая.',
          style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 13, height: 1.4),
        ),
        const SizedBox(height: 16),
        Align(
          alignment: Alignment.centerRight,
          child: FilledButton(
            style: FilledButton.styleFrom(backgroundColor: const Color(0xFF6C5CE7)),
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Закрыть'),
          ),
        ),
      ],
    );
  }

  Widget _buildFormState() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Пожаловаться на ответ',
          style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        Text(
          'Вопрос и ответ, на который жалуешься, будут переданы вместе с '
          'жалобой — иначе не получится разобраться, что именно пошло не так.',
          style: TextStyle(color: Colors.white.withOpacity(0.55), fontSize: 12.5, height: 1.4),
        ),
        const SizedBox(height: 14),
        TextField(
          controller: _reasonController,
          maxLines: 3,
          autofocus: true,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white.withOpacity(0.08),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
            contentPadding: const EdgeInsets.all(12),
            hintText: 'Что не так с этим ответом? (необязательно)',
            hintStyle: TextStyle(color: Colors.white.withOpacity(0.3)),
          ),
        ),
        if (_error != null) ...[
          const SizedBox(height: 10),
          Text(_error!, style: const TextStyle(color: Color(0xFFFFB4B4), fontSize: 13)),
        ],
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            TextButton(
              onPressed: _isBusy ? null : () => Navigator.of(context).pop(),
              child: Text('Отмена', style: TextStyle(color: Colors.white.withOpacity(0.6))),
            ),
            const SizedBox(width: 8),
            FilledButton(
              style: FilledButton.styleFrom(backgroundColor: const Color(0xFFFFD166)),
              onPressed: _isBusy ? null : _submit,
              child: _isBusy
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black),
                    )
                  : const Text('Отправить', style: TextStyle(color: Colors.black)),
            ),
          ],
        ),
      ],
    );
  }
}
