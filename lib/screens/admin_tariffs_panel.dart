import 'package:flutter/material.dart';

import '../models/subscription_tier.dart';
import '../services/tariff_admin_service.dart';
import '../state/auth_store.dart';
import '../theme/app_text_color.dart';
import '../widgets/glass_panel.dart';

/// Тарифы (цены, лимиты токенов) - раньше жили в .env, требовали
/// перезапуска сервера при смене. Теперь редактируются прямо здесь,
/// подхватываются сразу.
class AdminTariffsPanel extends StatefulWidget {
  final AuthStore authStore;
  const AdminTariffsPanel({super.key, required this.authStore});

  @override
  State<AdminTariffsPanel> createState() => _AdminTariffsPanelState();
}

class _AdminTariffsPanelState extends State<AdminTariffsPanel> {
  final _service = TariffAdminService();
  List<SubscriptionTier> _tiers = [];
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
      final tiers = await _service.list(baseUrl: widget.authStore.baseUrl, token: token);
      if (!mounted) return;
      setState(() => _tiers = tiers);
    } on TariffAdminException catch (e) {
      if (mounted) setState(() => _error = e.message);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _toggleActive(SubscriptionTier tier) async {
    final token = widget.authStore.token;
    if (token == null) return;
    try {
      final updated = await _service.update(
        baseUrl: widget.authStore.baseUrl,
        token: token,
        key: tier.key,
        isActive: !tier.isActive,
      );
      if (!mounted) return;
      setState(() {
        final index = _tiers.indexWhere((t) => t.key == tier.key);
        if (index != -1) _tiers[index] = updated;
      });
    } on TariffAdminException catch (e) {
      if (mounted) setState(() => _error = e.message);
    }
  }

  Future<void> _editTier(SubscriptionTier tier) async {
    final result = await showDialog<SubscriptionTier>(
      context: context,
      builder: (context) => _EditTierDialog(tier: tier, authStore: widget.authStore, service: _service),
    );
    if (result != null && mounted) {
      setState(() {
        final index = _tiers.indexWhere((t) => t.key == result.key);
        if (index != -1) _tiers[index] = result;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading && _tiers.isEmpty) {
      return const Center(child: CircularProgressIndicator(color: Color(0xFF6C5CE7)));
    }

    return RefreshIndicator(
      onRefresh: _load,
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Row(
            children: [
              Text('Тарифы', style: TextStyle(color: context.onSurface, fontSize: 20, fontWeight: FontWeight.w700)),
              const Spacer(),
              IconButton(icon: Icon(Icons.refresh_rounded, color: context.onSurfaceFaded(0.5)), onPressed: _load),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'Цены и лимиты токенов применяются сразу, без перезапуска сервера. '
            'Тариф "free" — единственный с ограничением по количеству запросов в день, '
            'остальные ограничены месячным расходом токенов.',
            style: TextStyle(color: context.onSurfaceFaded(0.4), fontSize: 12, height: 1.4),
          ),
          if (_error != null) ...[
            const SizedBox(height: 8),
            Text(_error!, style: const TextStyle(color: Color(0xFFFFB4B4), fontSize: 13)),
          ],
          const SizedBox(height: 16),
          ..._tiers.map(_buildTierCard),
        ],
      ),
    );
  }

  Widget _buildTierCard(SubscriptionTier tier) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: GlassPanel(
        opacity: 0.06,
        borderRadius: BorderRadius.circular(16),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    '${tier.nameRu} / ${tier.nameEn}',
                    style: TextStyle(color: context.onSurface, fontSize: 15, fontWeight: FontWeight.w600),
                  ),
                ),
                Switch(
                  value: tier.isActive,
                  activeThumbColor: const Color(0xFF6C5CE7),
                  onChanged: (_) => _toggleActive(tier),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text('key: ${tier.key}', style: TextStyle(color: context.onSurfaceFaded(0.35), fontSize: 11)),
            const SizedBox(height: 8),
            Text(
              tier.priceRubCents == 0
                  ? 'Бесплатно'
                  : '${(tier.priceRubCents / 100).toStringAsFixed(0)} ₽ / \$${(tier.priceUsdCents / 100).toStringAsFixed(2)} · ${tier.durationDays} дней',
              style: TextStyle(color: context.onSurfaceFaded(0.6), fontSize: 13),
            ),
            const SizedBox(height: 4),
            Text(
              tier.dailyFreeRequests != null
                  ? 'Дневной лимит: ${tier.dailyFreeRequests} запросов/день'
                  : tier.monthlyTokenLimit != null
                      ? 'Месячный лимит: ${tier.monthlyTokenLimit} токенов'
                      : 'Без лимита токенов',
              style: TextStyle(color: context.onSurfaceFaded(0.5), fontSize: 12.5),
            ),
            const SizedBox(height: 10),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                onPressed: () => _editTier(tier),
                icon: Icon(Icons.edit_outlined, size: 16, color: context.onSurfaceFaded(0.6)),
                label: Text('Изменить', style: TextStyle(color: context.onSurfaceFaded(0.6), fontSize: 12.5)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EditTierDialog extends StatefulWidget {
  final SubscriptionTier tier;
  final AuthStore authStore;
  final TariffAdminService service;
  const _EditTierDialog({required this.tier, required this.authStore, required this.service});

  @override
  State<_EditTierDialog> createState() => _EditTierDialogState();
}

class _EditTierDialogState extends State<_EditTierDialog> {
  late final _nameRuController = TextEditingController(text: widget.tier.nameRu);
  late final _nameEnController = TextEditingController(text: widget.tier.nameEn);
  late final _priceRubController = TextEditingController(text: (widget.tier.priceRubCents / 100).toStringAsFixed(0));
  late final _priceUsdController = TextEditingController(text: (widget.tier.priceUsdCents / 100).toStringAsFixed(2));
  late final _tokenLimitController = TextEditingController(text: widget.tier.monthlyTokenLimit?.toString() ?? '');
  late final _dailyRequestsController = TextEditingController(text: widget.tier.dailyFreeRequests?.toString() ?? '');
  late final _durationController = TextEditingController(text: widget.tier.durationDays.toString());
  bool _isSaving = false;
  String? _error;

  @override
  void dispose() {
    _nameRuController.dispose();
    _nameEnController.dispose();
    _priceRubController.dispose();
    _priceUsdController.dispose();
    _tokenLimitController.dispose();
    _dailyRequestsController.dispose();
    _durationController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final token = widget.authStore.token;
    if (token == null) return;
    setState(() {
      _isSaving = true;
      _error = null;
    });
    try {
      final tokenLimitText = _tokenLimitController.text.trim();
      final dailyRequestsText = _dailyRequestsController.text.trim();
      final updated = await widget.service.update(
        baseUrl: widget.authStore.baseUrl,
        token: token,
        key: widget.tier.key,
        nameRu: _nameRuController.text.trim(),
        nameEn: _nameEnController.text.trim(),
        priceRubCents: ((double.tryParse(_priceRubController.text.trim()) ?? 0) * 100).round(),
        priceUsdCents: ((double.tryParse(_priceUsdController.text.trim()) ?? 0) * 100).round(),
        monthlyTokenLimit: tokenLimitText.isEmpty ? null : int.tryParse(tokenLimitText),
        clearMonthlyTokenLimit: tokenLimitText.isEmpty,
        dailyFreeRequests: dailyRequestsText.isEmpty ? null : int.tryParse(dailyRequestsText),
        clearDailyFreeRequests: dailyRequestsText.isEmpty,
        durationDays: int.tryParse(_durationController.text.trim()),
      );
      if (mounted) Navigator.of(context).pop(updated);
    } on TariffAdminException catch (e) {
      if (mounted) setState(() => _error = e.message);
    } finally {
      if (mounted) setState(() => _isSaving = false);
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
          constraints: const BoxConstraints(maxWidth: 420),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Тариф: ${widget.tier.key}',
                  style: TextStyle(color: context.onSurface, fontSize: 16, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 16),
                _buildField(_nameRuController, 'Название (RU)'),
                const SizedBox(height: 10),
                _buildField(_nameEnController, 'Название (EN)'),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(child: _buildField(_priceRubController, 'Цена, ₽', keyboardType: TextInputType.number)),
                    const SizedBox(width: 10),
                    Expanded(child: _buildField(_priceUsdController, 'Цена, \$', keyboardType: TextInputType.number)),
                  ],
                ),
                const SizedBox(height: 10),
                _buildField(
                  _tokenLimitController,
                  'Месячный лимит токенов',
                  keyboardType: TextInputType.number,
                  hint: 'пусто = без лимита',
                ),
                const SizedBox(height: 10),
                _buildField(
                  _dailyRequestsController,
                  'Дневной лимит запросов (только free)',
                  keyboardType: TextInputType.number,
                  hint: 'пусто = не использовать дневной лимит',
                ),
                const SizedBox(height: 10),
                _buildField(_durationController, 'Срок действия, дней', keyboardType: TextInputType.number),
                if (_error != null) ...[
                  const SizedBox(height: 10),
                  Text(_error!, style: const TextStyle(color: Color(0xFFFFB4B4), fontSize: 12.5)),
                ],
                const SizedBox(height: 18),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: _isSaving ? null : () => Navigator.of(context).pop(),
                      child: Text('Отмена', style: TextStyle(color: context.onSurfaceFaded(0.6))),
                    ),
                    const SizedBox(width: 8),
                    FilledButton(
                      style: FilledButton.styleFrom(backgroundColor: const Color(0xFF6C5CE7)),
                      onPressed: _isSaving ? null : _save,
                      child: _isSaving
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                            )
                          : const Text('Сохранить'),
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

  Widget _buildField(
    TextEditingController controller,
    String label, {
    TextInputType? keyboardType,
    String? hint,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      style: TextStyle(color: context.onSurface),
      decoration: InputDecoration(
        filled: true,
        fillColor: context.onSurfaceFaded(0.08),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        labelText: label,
        labelStyle: TextStyle(color: context.onSurfaceFaded(0.5)),
        hintText: hint,
        hintStyle: TextStyle(color: context.onSurfaceFaded(0.3), fontSize: 12),
      ),
    );
  }
}
