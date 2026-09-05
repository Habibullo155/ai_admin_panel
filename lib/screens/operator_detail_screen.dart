import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/help_session.dart';
import '../models/operator_stats.dart';
import '../services/admin_users_service.dart';
import '../services/operators_service.dart';
import '../state/auth_store.dart';
import '../theme/app_text_color.dart';
import '../widgets/app_background.dart';
import '../widgets/glass_panel.dart';
import 'help_session_chat_screen.dart';

/// Детали одного оператора — история обращений (с оценками, чтобы найти
/// низкие и посмотреть, что там происходило), выговоры, и управление
/// доступом (снять доступ к живой помощи или удалить аккаунт целиком).
class OperatorDetailScreen extends StatefulWidget {
  final AuthStore authStore;
  final OperatorStats operator;
  const OperatorDetailScreen({super.key, required this.authStore, required this.operator});

  @override
  State<OperatorDetailScreen> createState() => _OperatorDetailScreenState();
}

class _OperatorDetailScreenState extends State<OperatorDetailScreen> {
  final _operatorsService = OperatorsService();
  final _usersService = AdminUsersService();
  List<HelpSession> _sessions = [];
  List<OperatorWarning> _warnings = [];
  bool _isLoading = true;
  bool _isBusy = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _operatorsService.dispose();
    _usersService.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    final token = widget.authStore.token;
    if (token == null) return;
    setState(() => _isLoading = true);
    try {
      final results = await Future.wait([
        _operatorsService.operatorSessions(
          baseUrl: widget.authStore.baseUrl,
          token: token,
          operatorId: widget.operator.id,
        ),
        _operatorsService.listWarnings(
          baseUrl: widget.authStore.baseUrl,
          token: token,
          operatorId: widget.operator.id,
        ),
      ]);
      if (!mounted) return;
      setState(() {
        _sessions = results[0] as List<HelpSession>;
        _warnings = results[1] as List<OperatorWarning>;
      });
    } on OperatorsException catch (e) {
      if (!mounted) return;
      setState(() => _error = e.message);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _issueWarning() async {
    final controller = TextEditingController();
    final reason = await showDialog<String>(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: GlassPanel(
          opacity: 0.18,
          borderRadius: BorderRadius.circular(20),
          padding: const EdgeInsets.all(20),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 400),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Выдать выговор', style: TextStyle(color: context.onSurface, fontSize: 16, fontWeight: FontWeight.w600)),
                const SizedBox(height: 4),
                Text(widget.operator.email, style: TextStyle(color: context.onSurfaceFaded(0.5), fontSize: 12.5)),
                const SizedBox(height: 14),
                TextField(
                  controller: controller,
                  autofocus: true,
                  maxLines: 3,
                  style: TextStyle(color: context.onSurface),
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: context.onSurfaceFaded(0.08),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                    contentPadding: const EdgeInsets.all(12),
                    hintText: 'За что — эта причина сохранится в истории',
                    hintStyle: TextStyle(color: context.onSurfaceFaded(0.3)),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: Text('Отмена', style: TextStyle(color: context.onSurfaceFaded(0.6))),
                    ),
                    const SizedBox(width: 8),
                    FilledButton(
                      style: FilledButton.styleFrom(backgroundColor: const Color(0xFFFF6B6B)),
                      onPressed: () {
                        final text = controller.text.trim();
                        if (text.isNotEmpty) Navigator.of(context).pop(text);
                      },
                      child: const Text('Выдать'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );

    if (reason == null || !mounted) return;
    final token = widget.authStore.token;
    if (token == null) return;

    setState(() => _isBusy = true);
    try {
      await _operatorsService.issueWarning(
        baseUrl: widget.authStore.baseUrl,
        token: token,
        operatorId: widget.operator.id,
        reason: reason,
      );
      await _load();
    } on OperatorsException catch (e) {
      if (mounted) setState(() => _error = e.message);
    } finally {
      if (mounted) setState(() => _isBusy = false);
    }
  }

  Future<void> _revokeAccess() async {
    final confirmed = await _confirm(
      title: 'Снять доступ к живой помощи?',
      body: '${widget.operator.email} больше не сможет принимать обращения. Аккаунт и история останутся.',
      confirmLabel: 'Снять доступ',
    );
    if (confirmed != true) return;

    final token = widget.authStore.token;
    if (token == null) return;
    setState(() => _isBusy = true);
    try {
      await _usersService.updateUser(
        baseUrl: widget.authStore.baseUrl,
        token: token,
        userId: widget.operator.id,
        isOperator: false,
      );
      if (mounted) Navigator.of(context).pop();
    } on AdminUsersException catch (e) {
      if (mounted) setState(() => _error = e.message);
    } finally {
      if (mounted) setState(() => _isBusy = false);
    }
  }

  Future<void> _deleteAccount() async {
    final confirmed = await _confirm(
      title: 'Удалить аккаунт целиком?',
      body: 'Необратимо: ${widget.operator.email} и вся история обращений будут удалены. Если нужно просто убрать доступ, не удаляя аккаунт — используй "Снять доступ".',
      confirmLabel: 'Удалить',
    );
    if (confirmed != true) return;

    final token = widget.authStore.token;
    if (token == null) return;
    setState(() => _isBusy = true);
    try {
      await _usersService.deleteUser(baseUrl: widget.authStore.baseUrl, token: token, userId: widget.operator.id);
      if (mounted) Navigator.of(context).pop();
    } on AdminUsersException catch (e) {
      if (mounted) setState(() => _error = e.message);
    } finally {
      if (mounted) setState(() => _isBusy = false);
    }
  }

  Future<bool?> _confirm({required String title, required String body, required String confirmLabel}) {
    return showDialog<bool>(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: GlassPanel(
          opacity: 0.18,
          borderRadius: BorderRadius.circular(20),
          padding: const EdgeInsets.all(20),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 380),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TextStyle(color: context.onSurface, fontSize: 16, fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                Text(body, style: TextStyle(color: context.onSurfaceFaded(0.6), fontSize: 13, height: 1.5)),
                const SizedBox(height: 18),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(false),
                      child: Text('Отмена', style: TextStyle(color: context.onSurfaceFaded(0.6))),
                    ),
                    const SizedBox(width: 8),
                    FilledButton(
                      style: FilledButton.styleFrom(backgroundColor: const Color(0xFFFF6B6B)),
                      onPressed: () => Navigator.of(context).pop(true),
                      child: Text(confirmLabel),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
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
                    Expanded(
                      child: Text(
                        widget.operator.email,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(color: context.onSurface, fontSize: 16, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Center(
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Color(0xFF6C5CE7))
                      : RefreshIndicator(
                          onRefresh: _load,
                          child: ListView(
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
                                    _buildActionsRow(),
                                    if (_warnings.isNotEmpty) ...[
                                      const SizedBox(height: 20),
                                      Text(
                                        'ВЫГОВОРЫ (${_warnings.length})',
                                        style: TextStyle(color: context.onSurfaceFaded(0.4), fontSize: 11, letterSpacing: 1.2, fontWeight: FontWeight.w600),
                                      ),
                                      const SizedBox(height: 8),
                                      ..._warnings.map(_buildWarningTile),
                                    ],
                                    const SizedBox(height: 20),
                                    Text(
                                      'ОБРАЩЕНИЯ (${_sessions.length})',
                                      style: TextStyle(color: context.onSurfaceFaded(0.4), fontSize: 11, letterSpacing: 1.2, fontWeight: FontWeight.w600),
                                    ),
                                    const SizedBox(height: 8),
                                    if (_sessions.isEmpty)
                                      Padding(
                                        padding: const EdgeInsets.symmetric(vertical: 20),
                                        child: Center(
                                          child: Text('Ещё не принимал обращений', style: TextStyle(color: context.onSurfaceFaded(0.4))),
                                        ),
                                      )
                                    else
                                      ..._sessions.map(_buildSessionTile),
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

  Widget _buildActionsRow() {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: _isBusy ? null : _issueWarning,
            style: OutlinedButton.styleFrom(
              side: BorderSide(color: const Color(0xFFFF6B6B).withValues(alpha: 0.4)),
              foregroundColor: const Color(0xFFFF6B6B),
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
            icon: const Icon(Icons.warning_amber_rounded, size: 18),
            label: const Text('Выговор'),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: OutlinedButton.icon(
            onPressed: _isBusy ? null : _revokeAccess,
            style: OutlinedButton.styleFrom(
              side: BorderSide(color: context.onSurfaceFaded(0.16)),
              foregroundColor: Colors.white70,
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
            icon: const Icon(Icons.person_off_outlined, size: 18),
            label: const Text('Снять доступ'),
          ),
        ),
        const SizedBox(width: 8),
        IconButton(
          onPressed: _isBusy ? null : _deleteAccount,
          style: IconButton.styleFrom(
            side: BorderSide(color: const Color(0xFFFF6B6B).withValues(alpha: 0.3)),
            padding: const EdgeInsets.all(12),
          ),
          icon: const Icon(Icons.delete_outline_rounded, color: Color(0xFFFF6B6B), size: 20),
          tooltip: 'Удалить аккаунт целиком',
        ),
      ],
    );
  }

  Widget _buildWarningTile(OperatorWarning warning) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: GlassPanel(
        opacity: 0.07,
        blurred: false,
        borderRadius: BorderRadius.circular(12),
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.warning_amber_rounded, size: 14, color: Color(0xFFFF6B6B)),
                const SizedBox(width: 6),
                Text(
                  DateFormat.yMMMd().add_Hm().format(warning.createdAt),
                  style: TextStyle(color: context.onSurfaceFaded(0.4), fontSize: 11),
                ),
                if (warning.issuedByEmail != null) ...[
                  const SizedBox(width: 6),
                  Text('· ${warning.issuedByEmail}', style: TextStyle(color: context.onSurfaceFaded(0.3), fontSize: 11)),
                ],
              ],
            ),
            const SizedBox(height: 4),
            Text(warning.reason, style: TextStyle(color: context.onSurface, fontSize: 13, height: 1.4)),
          ],
        ),
      ),
    );
  }

  Widget _buildSessionTile(HelpSession session) {
    final hasRating = session.rating != null;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: GlassPanel(
        opacity: hasRating && session.rating! <= 2 ? 0.13 : 0.07,
        blurred: false,
        borderRadius: BorderRadius.circular(12),
        border: hasRating && session.rating! <= 2
            ? Border.all(color: const Color(0xFFFF6B6B).withValues(alpha: 0.4))
            : null,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => HelpSessionChatScreen(authStore: widget.authStore, session: session)),
            ),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          session.userEmail ?? 'неизвестно',
                          style: TextStyle(color: context.onSurface, fontSize: 13, fontWeight: FontWeight.w500),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          DateFormat.yMMMd().add_Hm().format(session.createdAt),
                          style: TextStyle(color: context.onSurfaceFaded(0.35), fontSize: 11),
                        ),
                        if (session.ratingComment != null && session.ratingComment!.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Text(
                            '«${session.ratingComment}»',
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(color: context.onSurfaceFaded(0.5), fontSize: 11.5, fontStyle: FontStyle.italic),
                          ),
                        ],
                      ],
                    ),
                  ),
                  if (hasRating)
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: List.generate(
                        5,
                        (i) => Icon(
                          i < session.rating! ? Icons.star_rounded : Icons.star_border_rounded,
                          size: 13,
                          color: i < session.rating!
                              ? (session.rating! <= 2 ? const Color(0xFFFF6B6B) : const Color(0xFFFFD166))
                              : context.onSurfaceFaded(0.2),
                        ),
                      ),
                    )
                  else
                    Text('без оценки', style: TextStyle(color: context.onSurfaceFaded(0.3), fontSize: 11)),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
