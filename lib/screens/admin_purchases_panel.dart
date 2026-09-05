import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/dashboard_stats.dart';
import '../services/stats_service.dart';
import '../state/auth_store.dart';
import '../theme/app_text_color.dart';
import '../widgets/export_buttons.dart';
import '../widgets/glass_panel.dart';

/// Встраивается как содержимое в AdminShellScreen (не отдельный Scaffold
/// со своей шапкой/кнопкой назад) - в новой оболочке навигация уже
/// сайдбаром, дублировать её здесь незачем.
class AdminPurchasesPanel extends StatefulWidget {
  final AuthStore authStore;
  const AdminPurchasesPanel({super.key, required this.authStore});

  @override
  State<AdminPurchasesPanel> createState() => _AdminPurchasesPanelState();
}

class _AdminPurchasesPanelState extends State<AdminPurchasesPanel> {
  final _service = StatsService();
  List<AdminPurchase> _purchases = [];
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
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final purchases = await _service.getPurchases(baseUrl: widget.authStore.baseUrl, token: token, limit: 100);
      if (mounted) setState(() => _purchases = purchases);
    } on StatsException catch (e) {
      if (mounted) setState(() => _error = e.message);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading && _purchases.isEmpty) {
      return const Center(child: CircularProgressIndicator(color: Color(0xFF6C5CE7)));
    }

    return RefreshIndicator(
      onRefresh: _load,
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Row(
            children: [
              Text('Покупки', style: TextStyle(color: context.onSurface, fontSize: 20, fontWeight: FontWeight.w700)),
              const Spacer(),
              ExportButtonsRow(
                filename: 'Покупки',
                columns: const ['Пользователь', 'Тариф', 'Сумма', 'Дата'],
                rows: _purchases
                    .map((p) => [
                          p.userEmail ?? '(аккаунт удалён)',
                          p.tariff,
                          p.formattedAmount,
                          p.createdAt.toIso8601String(),
                        ])
                    .toList(),
              ),
              IconButton(icon: Icon(Icons.refresh_rounded, color: context.onSurfaceFaded(0.5)), onPressed: _load),
            ],
          ),
          if (_error != null) ...[
            const SizedBox(height: 8),
            Text(_error!, style: const TextStyle(color: Color(0xFFFFB4B4), fontSize: 13)),
          ],
          const SizedBox(height: 16),
          if (_purchases.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 40),
              child: Center(
                child: Text('Покупок пока нет.', style: TextStyle(color: context.onSurfaceFaded(0.4))),
              ),
            )
          else
            GlassPanel(
              opacity: 0.06,
              borderRadius: BorderRadius.circular(16),
              padding: EdgeInsets.zero,
              child: Column(
                children: [
                  _buildHeaderRow(),
                  Divider(height: 1, color: context.onSurfaceFaded(0.08)),
                  ..._purchases.asMap().entries.map((entry) => _buildRow(entry.value, entry.key)),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildHeaderRow() {
    final style = TextStyle(color: context.onSurfaceFaded(0.4), fontSize: 11.5, fontWeight: FontWeight.w600, letterSpacing: 0.5);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Expanded(flex: 3, child: Text('ПОЛЬЗОВАТЕЛЬ', style: style)),
          Expanded(flex: 2, child: Text('ТАРИФ', style: style)),
          Expanded(flex: 2, child: Text('СУММА', style: style)),
          Expanded(flex: 3, child: Text('ДАТА', style: style)),
        ],
      ),
    );
  }

  Widget _buildRow(AdminPurchase p, int index) {
    return Container(
      decoration: BoxDecoration(
        color: index.isEven ? Colors.transparent : context.onSurfaceFaded(0.03),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Text(
              p.userEmail ?? '(аккаунт удалён)',
              style: TextStyle(
                color: p.userEmail == null ? context.onSurfaceFaded(0.35) : context.onSurface,
                fontSize: 13,
                fontStyle: p.userEmail == null ? FontStyle.italic : FontStyle.normal,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Expanded(
            flex: 2,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              margin: const EdgeInsets.only(right: 8),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: const Color(0xFF6C5CE7).withValues(alpha: 0.15),
              ),
              child: Text(
                p.tariff,
                style: const TextStyle(color: Color(0xFF6C5CE7), fontSize: 11.5, fontWeight: FontWeight.w600),
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              p.formattedAmount,
              style: TextStyle(color: context.onSurface, fontSize: 13, fontWeight: FontWeight.w600),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              DateFormat('dd.MM.yyyy HH:mm').format(p.createdAt.toLocal()),
              style: TextStyle(color: context.onSurfaceFaded(0.5), fontSize: 12.5),
            ),
          ),
        ],
      ),
    );
  }
}
