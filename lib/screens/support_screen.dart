import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/support_ticket.dart';
import '../services/support_service.dart';
import '../state/auth_store.dart';
import '../theme/app_text_color.dart';
import '../widgets/app_background.dart';
import '../widgets/glass_panel.dart';

class SupportScreen extends StatefulWidget {
  final AuthStore authStore;
  const SupportScreen({super.key, required this.authStore});

  @override
  State<SupportScreen> createState() => _SupportScreenState();
}

class _SupportScreenState extends State<SupportScreen> {
  final _service = SupportService();
  final _messageController = TextEditingController();
  List<SupportTicket> _tickets = [];
  bool _isLoading = true;
  bool _isSending = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _service.dispose();
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    final token = widget.authStore.token;
    if (token == null) return;
    setState(() => _isLoading = true);
    try {
      final tickets = await _service.myTickets(baseUrl: widget.authStore.baseUrl, token: token);
      if (!mounted) return;
      setState(() => _tickets = tickets);
    } on SupportException catch (e) {
      if (!mounted) return;
      setState(() => _error = e.message);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _send() async {
    final text = _messageController.text.trim();
    final token = widget.authStore.token;
    if (text.isEmpty || token == null || _isSending) return;

    setState(() {
      _isSending = true;
      _error = null;
    });
    try {
      final ticket = await _service.createTicket(
        baseUrl: widget.authStore.baseUrl,
        token: token,
        message: text,
      );
      if (!mounted) return;
      setState(() {
        _tickets = [ticket, ..._tickets];
        _messageController.clear();
      });
    } on SupportException catch (e) {
      if (!mounted) return;
      setState(() => _error = e.message);
    } finally {
      if (mounted) setState(() => _isSending = false);
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
                      icon: Icon(Icons.arrow_back_rounded, color: context.onSurface),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                    Text(
                      'Поддержка',
                      style: TextStyle(color: context.onSurface, fontSize: 18, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 560),
                    child: ListView(
                      padding: const EdgeInsets.all(16),
                      children: [
                        _buildComposer(),
                        if (_error != null) ...[
                          const SizedBox(height: 10),
                          Text(_error!, style: const TextStyle(color: Color(0xFFFFB4B4), fontSize: 13)),
                        ],
                        const SizedBox(height: 24),
                        Text(
                          'ТВОИ ОБРАЩЕНИЯ',
                          style: TextStyle(
                            color: context.onSurfaceFaded(0.4),
                            fontSize: 11,
                            letterSpacing: 1.2,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 10),
                        if (_isLoading)
                          const Center(child: CircularProgressIndicator(color: Color(0xFF6C5CE7)))
                        else if (_tickets.isEmpty)
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 24),
                            child: Center(
                              child: Text('Обращений пока нет', style: TextStyle(color: context.onSurfaceFaded(0.4))),
                            ),
                          )
                        else
                          ..._tickets.map(_buildTicketTile),
                      ],
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

  Widget _buildComposer() {
    return GlassPanel(
      opacity: 0.10,
      borderRadius: BorderRadius.circular(20),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Опиши проблему — мы посмотрим и ответим',
            style: TextStyle(color: context.onSurfaceFaded(0.6), fontSize: 13),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _messageController,
            maxLines: 4,
            style: TextStyle(color: context.onSurface),
            decoration: InputDecoration(
              filled: true,
              fillColor: context.onSurfaceFaded(0.06),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              hintText: 'Например: не приходит ответ от модели на длинные вопросы…',
              hintStyle: TextStyle(color: context.onSurfaceFaded(0.3)),
              contentPadding: const EdgeInsets.all(12),
            ),
          ),
          const SizedBox(height: 12),
          Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(14),
              onTap: _isSending ? null : _send,
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
                  gradient: LinearGradient(
                    colors: _isSending
                        ? [context.onSurfaceFaded(0.24), context.onSurfaceFaded(0.10)]
                        : [const Color(0xFF6C5CE7), const Color(0xFF00B4D8)],
                  ),
                ),
                child: Text(
                  _isSending ? 'Отправляю…' : 'Отправить',
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTicketTile(SupportTicket ticket) {
    final isClosed = ticket.status == TicketStatus.closed;
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: GlassPanel(
        opacity: 0.07,
        blurred: false, // рендерится по одному на тикет в списке
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
                    color: isClosed ? context.onSurfaceFaded(0.08) : const Color(0xFF00D9C0).withValues(alpha: 0.18),
                  ),
                  child: Text(
                    isClosed ? 'Закрыто' : 'Открыто',
                    style: TextStyle(
                      color: isClosed ? context.onSurfaceFaded(0.5) : const Color(0xFF00D9C0),
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const Spacer(),
                Text(
                  DateFormat.yMMMd().add_Hm().format(ticket.createdAt),
                  style: TextStyle(color: context.onSurfaceFaded(0.3), fontSize: 11),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(ticket.message, style: TextStyle(color: context.onSurfaceFaded(0.85), fontSize: 13.5)),
          ],
        ),
      ),
    );
  }
}
