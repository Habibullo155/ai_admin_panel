import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/help_session.dart';
import '../services/help_service.dart';
import '../state/auth_store.dart';
import '../theme/app_text_color.dart';
import '../widgets/app_background.dart';
import '../widgets/crisis_resources_panel.dart';
import '../widgets/glass_panel.dart';
import 'help_session_chat_screen.dart';

/// Запрос живой помощи — пользователь САМ явно нажимает кнопку (никакого
/// автоматического распознавания фраз в переписке с ИИ). Намеренно НЕ
/// называем это "врачом" — нет способа проверить квалификацию тех, кому
/// админ выдал доступ; честная формулировка — "живой человек из команды".
/// Экстренная медицинская помощь и кризисные линии — отдельно и всегда
/// на виду, это не замена им.
class MyHelpScreen extends StatefulWidget {
  final AuthStore authStore;
  const MyHelpScreen({super.key, required this.authStore});

  @override
  State<MyHelpScreen> createState() => _MyHelpScreenState();
}

class _MyHelpScreenState extends State<MyHelpScreen> {
  final _service = HelpService();
  final _reasonController = TextEditingController();
  List<HelpSession> _sessions = [];
  bool _isLoading = true;
  bool _isCreating = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _service.dispose();
    _reasonController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    final token = widget.authStore.token;
    if (token == null) return;
    setState(() => _isLoading = true);
    try {
      final sessions = await _service.mySessions(baseUrl: widget.authStore.baseUrl, token: token);
      if (!mounted) return;
      setState(() => _sessions = sessions);
    } on HelpException catch (e) {
      if (!mounted) return;
      setState(() => _error = e.message);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _requestHelp() async {
    final token = widget.authStore.token;
    if (token == null) return;
    setState(() => _isCreating = true);
    try {
      final session = await _service.createSession(
        baseUrl: widget.authStore.baseUrl,
        token: token,
        reason: _reasonController.text.trim().isEmpty ? null : _reasonController.text.trim(),
      );
      _reasonController.clear();
      if (!mounted) return;
      setState(() => _sessions = [session, ..._sessions]);
      _openSession(session);
    } on HelpException catch (e) {
      if (mounted) setState(() => _error = e.message);
    } finally {
      if (mounted) setState(() => _isCreating = false);
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
                      'Живая помощь',
                      style: TextStyle(color: context.onSurface, fontSize: 18, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Center(
                  child: RefreshIndicator(
                    onRefresh: _load,
                    child: ListView(
                      padding: const EdgeInsets.all(16),
                      children: [
                        ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 560),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              GlassPanel(
                                opacity: 0.09,
                                borderRadius: BorderRadius.circular(20),
                                padding: const EdgeInsets.all(18),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Позвать человека на помощь',
                                      style: TextStyle(color: context.onSurface, fontWeight: FontWeight.w600, fontSize: 15),
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      'Подключится врач или специалист из команды. Это не '
                                      'замена экстренной службе — если ситуация требует срочной '
                                      'медицинской помощи, звони 103 или обратись в скорую напрямую.',
                                      style: TextStyle(color: context.onSurfaceFaded(0.6), fontSize: 12.5, height: 1.5),
                                    ),
                                    const SizedBox(height: 14),
                                    TextField(
                                      controller: _reasonController,
                                      minLines: 1,
                                      maxLines: 3,
                                      style: TextStyle(color: context.onSurface, fontSize: 13.5),
                                      decoration: InputDecoration(
                                        filled: true,
                                        fillColor: context.onSurfaceFaded(0.07),
                                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                                        hintText: 'Коротко, что случилось (необязательно)',
                                        hintStyle: TextStyle(color: context.onSurfaceFaded(0.3)),
                                      ),
                                    ),
                                    const SizedBox(height: 14),
                                    Material(
                                      color: Colors.transparent,
                                      child: InkWell(
                                        borderRadius: BorderRadius.circular(14),
                                        onTap: _isCreating ? null : _requestHelp,
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(vertical: 13),
                                          alignment: Alignment.center,
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(14),
                                            gradient: const LinearGradient(colors: [Color(0xFF6C5CE7), Color(0xFF00B4D8)]),
                                          ),
                                          child: _isCreating
                                              ? const SizedBox(
                                                  width: 18,
                                                  height: 18,
                                                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                                                )
                                              : const Text('Позвать на помощь', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 16),
                              const CrisisResourcesPanel(),
                              if (_error != null) ...[
                                const SizedBox(height: 12),
                                Text(_error!, style: const TextStyle(color: Color(0xFFFFB4B4), fontSize: 13)),
                              ],
                              if (_sessions.isNotEmpty) ...[
                                const SizedBox(height: 20),
                                Text(
                                  'МОИ ОБРАЩЕНИЯ',
                                  style: TextStyle(color: context.onSurfaceFaded(0.4), fontSize: 11, letterSpacing: 1.2, fontWeight: FontWeight.w600),
                                ),
                                const SizedBox(height: 10),
                                ..._sessions.map(_buildSessionTile),
                              ],
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

  Widget _buildSessionTile(HelpSession session) {
    final (label, color) = switch (session.status) {
      HelpSessionStatus.pending => ('Ждём подключения', const Color(0xFFFFD166)),
      HelpSessionStatus.active => ('Подключено', const Color(0xFF00E6A0)),
      HelpSessionStatus.closed => ('Закрыто', Colors.white38),
    };
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: GlassPanel(
        opacity: 0.07,
        blurred: false,
        borderRadius: BorderRadius.circular(14),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(14),
            onTap: () => _openSession(session),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          DateFormat.yMMMd().add_Hm().format(session.createdAt),
                          style: TextStyle(color: context.onSurface, fontSize: 13.5, fontWeight: FontWeight.w500),
                        ),
                        if (session.reason != null && session.reason!.isNotEmpty) ...[
                          const SizedBox(height: 2),
                          Text(
                            session.reason!,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(color: context.onSurfaceFaded(0.45), fontSize: 12),
                          ),
                        ],
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                    decoration: BoxDecoration(borderRadius: BorderRadius.circular(8), color: color.withValues(alpha: 0.18)),
                    child: Text(label, style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w600)),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
