import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/support_ticket.dart';
import '../services/support_service.dart';
import '../state/auth_store.dart';
import '../theme/app_text_color.dart';
import '../widgets/app_background.dart';
import '../widgets/glass_panel.dart';

class AdminSupportScreen extends StatefulWidget {
  final AuthStore authStore;
  final VoidCallback? onBack;
  const AdminSupportScreen({super.key, required this.authStore, this.onBack});

  @override
  State<AdminSupportScreen> createState() => _AdminSupportScreenState();
}

class _AdminSupportScreenState extends State<AdminSupportScreen> {
  final _service = SupportService();
  List<SupportTicket> _tickets = [];
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
      final tickets = await _service.allTickets(baseUrl: widget.authStore.baseUrl, token: token);
      if (!mounted) return;
      setState(() => _tickets = tickets);
    } on SupportException catch (e) {
      if (!mounted) return;
      setState(() => _error = e.message);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _toggleStatus(SupportTicket ticket) async {
    final token = widget.authStore.token;
    if (token == null) return;
    final newStatus = ticket.status == TicketStatus.open ? TicketStatus.closed : TicketStatus.open;
    try {
      final updated = await _service.updateStatus(
        baseUrl: widget.authStore.baseUrl,
        token: token,
        ticketId: ticket.id,
        status: newStatus,
      );
      if (!mounted) return;
      setState(() {
        final idx = _tickets.indexWhere((t) => t.id == ticket.id);
        if (idx != -1) _tickets[idx] = updated;
      });
    } on SupportException catch (e) {
      if (!mounted) return;
      setState(() => _error = e.message);
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
                    Text(
                      'Обращения пользователей',
                      style: TextStyle(color: context.onSurface, fontSize: 17, fontWeight: FontWeight.w600),
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
                          : _tickets.isEmpty
                              ? ListView(
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.symmetric(vertical: 60),
                                      child: Center(
                                        child: Text('Обращений нет', style: TextStyle(color: context.onSurfaceFaded(0.4))),
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
                                    ..._tickets.map(_buildTicketTile),
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

  Widget _buildTicketTile(SupportTicket ticket) {
    final isClosed = ticket.status == TicketStatus.closed;
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: GlassPanel(
        opacity: 0.08,
        blurred: false, // рендерится по одному на тикет в списке — см. message_bubble.dart
        borderRadius: BorderRadius.circular(16),
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    ticket.userEmail ?? 'Пользователь #${ticket.userId}',
                    style: TextStyle(color: context.onSurface, fontWeight: FontWeight.w600, fontSize: 13.5),
                  ),
                ),
                Text(
                  DateFormat.yMMMd().add_Hm().format(ticket.createdAt),
                  style: TextStyle(color: context.onSurfaceFaded(0.3), fontSize: 11),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(ticket.message, style: TextStyle(color: context.onSurfaceFaded(0.8), fontSize: 13.5)),
            const SizedBox(height: 10),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                onPressed: () => _toggleStatus(ticket),
                icon: Icon(
                  isClosed ? Icons.refresh_rounded : Icons.check_circle_outline_rounded,
                  size: 16,
                  color: context.onSurfaceFaded(0.7),
                ),
                label: Text(
                  isClosed ? 'Открыть заново' : 'Закрыть',
                  style: TextStyle(color: context.onSurfaceFaded(0.7), fontSize: 12.5),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
