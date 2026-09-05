import 'package:flutter/material.dart';

import '../models/payment_settings.dart';
import '../services/payment_admin_service.dart';
import '../state/auth_store.dart';
import '../theme/app_text_color.dart';
import '../widgets/glass_panel.dart';

/// Способы оплаты (Stripe/YooMoney) и реклама (AdMob) - оба провайдера
/// оплаты можно включить одновременно, человек сам выбирает на экране
/// покупки (см. flutter_app/purchase_screen.dart).
class AdminPaymentPanel extends StatefulWidget {
  final AuthStore authStore;
  const AdminPaymentPanel({super.key, required this.authStore});

  @override
  State<AdminPaymentPanel> createState() => _AdminPaymentPanelState();
}

class _AdminPaymentPanelState extends State<AdminPaymentPanel> {
  final _service = PaymentAdminService();
  final _yoomoneyWalletController = TextEditingController();
  final _yoomoneySecretController = TextEditingController();
  final _admobAdUnitController = TextEditingController();

  PaymentSettings? _payment;
  AdMobSettings? _admob;
  bool _isLoading = true;
  bool _isSavingPayment = false;
  bool _isSavingAdMob = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _service.dispose();
    _yoomoneyWalletController.dispose();
    _yoomoneySecretController.dispose();
    _admobAdUnitController.dispose();
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
      final payment = await _service.fetchPayment(baseUrl: widget.authStore.baseUrl, token: token);
      final admob = await _service.fetchAdMob(baseUrl: widget.authStore.baseUrl, token: token);
      if (!mounted) return;
      setState(() {
        _payment = payment;
        _admob = admob;
        _yoomoneyWalletController.text = payment.yoomoneyWallet;
        _admobAdUnitController.text = admob.rewardedAdUnitId;
      });
    } on PaymentAdminException catch (e) {
      if (mounted) setState(() => _error = e.message);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _toggleStripe(bool value) async {
    final token = widget.authStore.token;
    if (token == null) return;
    try {
      final updated = await _service.updatePayment(baseUrl: widget.authStore.baseUrl, token: token, stripeEnabled: value);
      if (mounted) setState(() => _payment = updated);
    } on PaymentAdminException catch (e) {
      if (mounted) setState(() => _error = e.message);
    }
  }

  Future<void> _toggleYoomoney(bool value) async {
    final token = widget.authStore.token;
    if (token == null) return;
    try {
      final updated = await _service.updatePayment(baseUrl: widget.authStore.baseUrl, token: token, yoomoneyEnabled: value);
      if (mounted) setState(() => _payment = updated);
    } on PaymentAdminException catch (e) {
      if (mounted) setState(() => _error = e.message);
    }
  }

  Future<void> _saveYoomoneyCredentials() async {
    final token = widget.authStore.token;
    if (token == null) return;
    setState(() => _isSavingPayment = true);
    try {
      final updated = await _service.updatePayment(
        baseUrl: widget.authStore.baseUrl,
        token: token,
        yoomoneyWallet: _yoomoneyWalletController.text.trim(),
        yoomoneySecret: _yoomoneySecretController.text.isNotEmpty ? _yoomoneySecretController.text : null,
      );
      if (!mounted) return;
      setState(() {
        _payment = updated;
        _yoomoneySecretController.clear();
      });
    } on PaymentAdminException catch (e) {
      if (mounted) setState(() => _error = e.message);
    } finally {
      if (mounted) setState(() => _isSavingPayment = false);
    }
  }

  Future<void> _toggleAdMob(bool value) async {
    final token = widget.authStore.token;
    if (token == null) return;
    try {
      final updated = await _service.updateAdMob(baseUrl: widget.authStore.baseUrl, token: token, enabled: value);
      if (mounted) setState(() => _admob = updated);
    } on PaymentAdminException catch (e) {
      if (mounted) setState(() => _error = e.message);
    }
  }

  Future<void> _saveAdMobUnitId() async {
    final token = widget.authStore.token;
    if (token == null) return;
    setState(() => _isSavingAdMob = true);
    try {
      final updated = await _service.updateAdMob(
        baseUrl: widget.authStore.baseUrl,
        token: token,
        rewardedAdUnitId: _admobAdUnitController.text.trim(),
      );
      if (mounted) setState(() => _admob = updated);
    } on PaymentAdminException catch (e) {
      if (mounted) setState(() => _error = e.message);
    } finally {
      if (mounted) setState(() => _isSavingAdMob = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading && _payment == null) {
      return const Center(child: CircularProgressIndicator(color: Color(0xFF6C5CE7)));
    }

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Row(
          children: [
            Text('Оплата и реклама', style: TextStyle(color: context.onSurface, fontSize: 20, fontWeight: FontWeight.w700)),
            const Spacer(),
            IconButton(icon: Icon(Icons.refresh_rounded, color: context.onSurfaceFaded(0.5)), onPressed: _load),
          ],
        ),
        if (_error != null) ...[
          const SizedBox(height: 8),
          Text(_error!, style: const TextStyle(color: Color(0xFFFFB4B4), fontSize: 13)),
        ],
        const SizedBox(height: 16),
        Text(
          'СПОСОБЫ ОПЛАТЫ',
          style: TextStyle(color: context.onSurfaceFaded(0.4), fontSize: 11, letterSpacing: 1.2, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 4),
        Text(
          'Оба способа можно включить одновременно — человек сам выбирает, чем платить, на экране покупки.',
          style: TextStyle(color: context.onSurfaceFaded(0.4), fontSize: 12, height: 1.4),
        ),
        const SizedBox(height: 10),
        GlassPanel(
          opacity: 0.06,
          borderRadius: BorderRadius.circular(16),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildToggleRow('Stripe (банковские карты)', _payment?.stripeEnabled ?? false, _toggleStripe),
              const Divider(height: 24),
              _buildToggleRow('YooMoney', _payment?.yoomoneyEnabled ?? false, _toggleYoomoney),
              const SizedBox(height: 12),
              _buildField(_yoomoneyWalletController, 'Номер кошелька YooMoney'),
              const SizedBox(height: 10),
              _buildField(
                _yoomoneySecretController,
                'Секретное слово',
                obscureText: true,
                hint: _payment?.yoomoneySecretIsSet == true ? 'уже задано, оставь пустым чтобы не менять' : null,
              ),
              const SizedBox(height: 12),
              Align(
                alignment: Alignment.centerRight,
                child: FilledButton(
                  style: FilledButton.styleFrom(backgroundColor: const Color(0xFF6C5CE7)),
                  onPressed: _isSavingPayment ? null : _saveYoomoneyCredentials,
                  child: _isSavingPayment
                      ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : const Text('Сохранить YooMoney'),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        Text(
          'РЕКЛАМА (ANDROID/IOS)',
          style: TextStyle(color: context.onSurfaceFaded(0.4), fontSize: 11, letterSpacing: 1.2, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 4),
        Text(
          'Бонус к дневному лимиту free-тарифа за просмотр рекламы — доступно только на Android/iOS, '
          'на вебе и десктопе у AdMob нет поддержки вообще.',
          style: TextStyle(color: context.onSurfaceFaded(0.4), fontSize: 12, height: 1.4),
        ),
        const SizedBox(height: 10),
        GlassPanel(
          opacity: 0.06,
          borderRadius: BorderRadius.circular(16),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildToggleRow('AdMob включён', _admob?.enabled ?? false, _toggleAdMob),
              const SizedBox(height: 12),
              _buildField(_admobAdUnitController, 'Rewarded Ad Unit ID', hint: 'ca-app-pub-.../...'),
              const SizedBox(height: 12),
              Align(
                alignment: Alignment.centerRight,
                child: FilledButton(
                  style: FilledButton.styleFrom(backgroundColor: const Color(0xFF6C5CE7)),
                  onPressed: _isSavingAdMob ? null : _saveAdMobUnitId,
                  child: _isSavingAdMob
                      ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : const Text('Сохранить AdMob'),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildToggleRow(String label, bool value, ValueChanged<bool> onChanged) {
    return Row(
      children: [
        Expanded(child: Text(label, style: TextStyle(color: context.onSurface, fontSize: 14))),
        Switch(value: value, activeThumbColor: const Color(0xFF6C5CE7), onChanged: onChanged),
      ],
    );
  }

  Widget _buildField(
    TextEditingController controller,
    String label, {
    bool obscureText = false,
    String? hint,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      style: TextStyle(color: context.onSurface),
      decoration: InputDecoration(
        filled: true,
        fillColor: context.onSurfaceFaded(0.08),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        labelText: label,
        labelStyle: TextStyle(color: context.onSurfaceFaded(0.5)),
        hintText: hint,
        hintStyle: TextStyle(color: context.onSurfaceFaded(0.3), fontSize: 12.5),
      ),
    );
  }
}
