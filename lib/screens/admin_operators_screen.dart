import 'package:flutter/material.dart';

import '../models/operator_stats.dart';
import '../services/operators_service.dart';
import '../state/auth_store.dart';
import '../theme/app_text_color.dart';
import '../widgets/app_background.dart';
import '../widgets/glass_panel.dart';
import 'operator_detail_screen.dart';

/// Список тех, кому выдан доступ к живой помощи — с реальной картиной
/// того, как они справляются, не просто списком email.
class AdminOperatorsScreen extends StatefulWidget {
  final AuthStore authStore;
  final VoidCallback? onBack;
  const AdminOperatorsScreen({super.key, required this.authStore, this.onBack});

  @override
  State<AdminOperatorsScreen> createState() => _AdminOperatorsScreenState();
}

class _AdminOperatorsScreenState extends State<AdminOperatorsScreen> {
  final _service = OperatorsService();
  List<OperatorStats> _operators = [];
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
      final operators = await _service.listOperators(baseUrl: widget.authStore.baseUrl, token: token);
      if (!mounted) return;
      setState(() => _operators = operators);
    } on OperatorsException catch (e) {
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
                      'Доктора',
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
                                constraints: const BoxConstraints(maxWidth: 560),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.stretch,
                                  children: [
                                    if (_error != null) ...[
                                      Text(_error!, style: const TextStyle(color: Color(0xFFFFB4B4), fontSize: 13)),
                                      const SizedBox(height: 12),
                                    ],
                                    if (_operators.isEmpty)
                                      Padding(
                                        padding: const EdgeInsets.symmetric(vertical: 40),
                                        child: Center(
                                          child: Text(
                                            'Пока никому не выдан доступ к живой помощи',
                                            style: TextStyle(color: context.onSurfaceFaded(0.4)),
                                          ),
                                        ),
                                      )
                                    else
                                      ..._operators.map(_buildOperatorTile),
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

  Widget _buildOperatorTile(OperatorStats operator) {
    final hasWarnings = operator.warningsCount > 0;
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: GlassPanel(
        opacity: 0.08,
        borderRadius: BorderRadius.circular(16),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: () => Navigator.of(context)
                .push(
                  MaterialPageRoute(
                    builder: (_) => OperatorDetailScreen(authStore: widget.authStore, operator: operator),
                  ),
                )
                .then((_) => _load()),
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                operator.email,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: operator.isActive ? context.onSurface : context.onSurfaceFaded(0.4),
                                  fontWeight: FontWeight.w600,
                                  fontSize: 13.5,
                                ),
                              ),
                            ),
                            if (!operator.isActive) ...[
                              const SizedBox(width: 6),
                              _badge('заблокирован', context.onSurface),
                            ],
                          ],
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            _buildStars(operator.avgRating),
                            const SizedBox(width: 8),
                            Text(
                              operator.avgRating != null
                                  ? '${operator.avgRating!.toStringAsFixed(1)} · ${operator.ratedSessionsCount} оценок'
                                  : 'Пока нет оценок',
                              style: TextStyle(color: context.onSurfaceFaded(0.45), fontSize: 11.5),
                            ),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${operator.totalClaimedSessions} обращений принято',
                          style: TextStyle(color: context.onSurfaceFaded(0.35), fontSize: 11),
                        ),
                      ],
                    ),
                  ),
                  if (hasWarnings) ...[
                    const SizedBox(width: 8),
                    _badge('${operator.warningsCount} выговор(а)', const Color(0xFFFF6B6B)),
                  ],
                  const SizedBox(width: 8),
                  Icon(Icons.chevron_right_rounded, color: context.onSurfaceFaded(0.3)),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStars(double? rating) {
    final filled = rating?.round() ?? 0;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (i) {
        return Icon(
          i < filled ? Icons.star_rounded : Icons.star_border_rounded,
          size: 14,
          color: i < filled ? const Color(0xFFFFD166) : context.onSurfaceFaded(0.2),
        );
      }),
    );
  }

  Widget _badge(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(8), color: color.withValues(alpha: 0.18)),
      child: Text(text, style: TextStyle(color: color, fontSize: 10.5, fontWeight: FontWeight.w600)),
    );
  }
}
