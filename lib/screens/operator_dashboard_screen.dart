import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/help_session.dart';
import '../services/help_service.dart';
import '../state/auth_store.dart';
import '../theme/app_text_color.dart';
import '../widgets/app_background.dart';
import '../widgets/glass_panel.dart';
import 'help_session_chat_screen.dart';

/// Отдельный личный кабинет для тех, кому админ выдал доступ подключаться
/// к запросам живой помощи (User.is_operator) — не то же самое, что
/// админ-панель. У одного оператора может быть открыто сразу несколько
/// сессий (список "МОИ АКТИВНЫЕ").
class OperatorDashboardScreen extends StatefulWidget {
  final AuthStore authStore;
  const OperatorDashboardScreen({super.key, required this.authStore});

  @override
  State<OperatorDashboardScreen> createState() => _OperatorDashboardScreenState();
}

class _OperatorDashboardScreenState extends State<OperatorDashboardScreen> {
  final _service = HelpService();
  List<HelpSession> _pending = [];
  List<HelpSession> _active = [];
  bool _isLoading = true;
  String? _error;
  int? _claimingId;

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
      final results = await Future.wait([
        _service.pendingSessions(baseUrl: widget.authStore.baseUrl, token: token),
        _service.activeSessions(baseUrl: widget.authStore.baseUrl, token: token),
      ]);
      if (!mounted) return;
      setState(() {
        _pending = results[0];
        _active = results[1];
      });
    } on HelpException catch (e) {
      if (!mounted) return;
      setState(() => _error = e.message);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _claim(HelpSession session) async {
    final token = widget.authStore.token;
    if (token == null) return;
    setState(() => _claimingId = session.id);
    try {
      final claimed = await _service.claimSession(
        baseUrl: widget.authStore.baseUrl,
        token: token,
        sessionId: session.id,
      );
      if (!mounted) return;
      setState(() {
        _pending.removeWhere((s) => s.id == session.id);
        _active = [claimed, ..._active];
      });
      _openSession(claimed);
    } on HelpException catch (e) {
      if (mounted) setState(() => _error = e.message);
      // Заявку мог забрать кто-то другой параллельно — перезагружаем
      // списки, чтобы не показывать устаревшее "ещё доступно".
      _load();
    } finally {
      if (mounted) setState(() => _claimingId = null);
    }
  }

  void _openSession(HelpSession session) {
    Navigator.of(context)
        .push(MaterialPageRoute(builder: (_) => HelpSessionChatScreen(authStore: widget.authStore, session: session)))
        .then((_) => _load());
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
                      'Кабинет оператора',
                      style: TextStyle(color: context.onSurface, fontSize: 18, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Center(
                  child: RefreshIndicator(
                    onRefresh: _load,
                    child: _isLoading
                        ? const Center(child: CircularProgressIndicator(color: Color(0xFF6C5CE7)))
                        : ListView(
                            padding: const EdgeInsets.all(16),
                            children: [
                              ConstrainedBox(
                                constraints: const BoxConstraints(maxWidth: 640),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.stretch,
                                  children: [
                                    if (_error != null) ...[
                                      Text(_error!, style: const TextStyle(color: Color(0xFFFFB4B4), fontSize: 13)),
                                      const SizedBox(height: 12),
                                    ],
                                    if (_active.isNotEmpty) ...[
                                      Text(
                                        'МОИ АКТИВНЫЕ (${_active.length})',
                                        style: TextStyle(color: context.onSurfaceFaded(0.4), fontSize: 11, letterSpacing: 1.2, fontWeight: FontWeight.w600),
                                      ),
                                      const SizedBox(height: 10),
                                      ..._active.map(_buildActiveTile),
                                      const SizedBox(height: 20),
                                    ],
                                    Text(
                                      'ОЖИДАЮТ ПОДКЛЮЧЕНИЯ (${_pending.length})',
                                      style: TextStyle(color: context.onSurfaceFaded(0.4), fontSize: 11, letterSpacing: 1.2, fontWeight: FontWeight.w600),
                                    ),
                                    const SizedBox(height: 10),
                                    if (_pending.isEmpty)
                                      Padding(
                                        padding: const EdgeInsets.symmetric(vertical: 20),
                                        child: Center(
                                          child: Text('Пока никто не ждёт подключения', style: TextStyle(color: context.onSurfaceFaded(0.4))),
                                        ),
                                      )
                                    else
                                      ..._pending.map(_buildPendingTile),
                                  ],
                                ),
                              ),
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

  Widget _buildPendingTile(HelpSession session) {
    final isClaiming = _claimingId == session.id;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: GlassPanel(
        opacity: 0.08,
        blurred: false,
        borderRadius: BorderRadius.circular(16),
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    session.userEmail ?? 'неизвестно',
                    style: TextStyle(color: context.onSurface, fontWeight: FontWeight.w600, fontSize: 13.5),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    session.reason?.isNotEmpty == true ? session.reason! : 'Без описания',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: context.onSurfaceFaded(0.5), fontSize: 12),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    DateFormat.Hm().format(session.createdAt),
                    style: TextStyle(color: context.onSurfaceFaded(0.3), fontSize: 11),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: isClaiming ? null : () => _claim(session),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    gradient: const LinearGradient(colors: [Color(0xFF6C5CE7), Color(0xFF00B4D8)]),
                  ),
                  child: isClaiming
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                      : const Text('Принять', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActiveTile(HelpSession session) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: GlassPanel(
        opacity: 0.09,
        blurred: false,
        borderRadius: BorderRadius.circular(16),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: () => _openSession(session),
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(shape: BoxShape.circle, color: Color(0xFF00E6A0)),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      session.userEmail ?? 'неизвестно',
                      style: TextStyle(color: context.onSurface, fontWeight: FontWeight.w600, fontSize: 13.5),
                    ),
                  ),
                  Icon(Icons.chevron_right_rounded, color: context.onSurfaceFaded(0.3)),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
