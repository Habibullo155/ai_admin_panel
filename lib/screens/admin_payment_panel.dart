import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../models/payment_settings.dart';
import '../services/payment_admin_service.dart';
import '../state/auth_store.dart';
import '../theme/app_text_color.dart';
import '../widgets/glass_panel.dart';

/// Оплата и реклама.
class AdminPaymentPanel extends StatefulWidget {
  final AuthStore authStore;
  const AdminPaymentPanel({super.key, required this.authStore});

  @override
  State<AdminPaymentPanel> createState() => _AdminPaymentPanelState();
}

class _AdminPaymentPanelState extends State<AdminPaymentPanel> {
  final _service = PaymentAdminService();
  final _admobAdUnitController = TextEditingController();

  PaymentsStatus? _status;
  AdMobSettings? _admob;
  bool _isLoading = true;
  bool _isSavingAdMob = false;
  bool _isCreatingLink = false;
  bool _isCheckingBank = false;
  String? _testLink;
  String? _bankCheck;
  bool? _bankCheckOk;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _admobAdUnitController.dispose();
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
      final status = await _service.fetchStatus(baseUrl: widget.authStore.baseUrl, token: token);
      final admob = await _service.fetchAdMob(baseUrl: widget.authStore.baseUrl, token: token);
      if (!mounted) return;
      setState(() {
        _status = status;
        _admob = admob;
        _admobAdUnitController.text = admob.rewardedAdUnitId;
      });
    } on PaymentAdminException catch (e) {
      if (mounted) setState(() => _error = e.message);
    } catch (_) {
      if (mounted) setState(() => _error = 'Нет связи с сервером. Проверь интернет и попробуй ещё раз.');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _createTestLink() async {
    final token = widget.authStore.token;
    if (token == null) return;
    setState(() => _isCreatingLink = true);
    try {
      final url = await _service.createYoomoneyTestLink(baseUrl: widget.authStore.baseUrl, token: token);
      await Clipboard.setData(ClipboardData(text: url));
      if (!mounted) return;
      setState(() => _testLink = url);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ссылка скопирована - открой её в браузере и оплати')),
      );
    } on PaymentAdminException catch (e) {
      if (mounted) setState(() => _error = e.message);
    } catch (_) {
      if (mounted) setState(() => _error = 'Нет связи с сервером. Проверь интернет и попробуй ещё раз.');
    } finally {
      if (mounted) setState(() => _isCreatingLink = false);
    }
  }

  Future<void> _checkBank() async {
    final token = widget.authStore.token;
    if (token == null) return;
    setState(() => _isCheckingBank = true);
    try {
      final (ok, message) = await _service.checkAlfabank(baseUrl: widget.authStore.baseUrl, token: token);
      if (mounted) {
        setState(() {
          _bankCheckOk = ok;
          _bankCheck = message;
        });
      }
    } on PaymentAdminException catch (e) {
      if (mounted) setState(() => _error = e.message);
    } catch (_) {
      if (mounted) setState(() => _error = 'Нет связи с сервером. Проверь интернет и попробуй ещё раз.');
    } finally {
      if (mounted) setState(() => _isCheckingBank = false);
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
    if (_isLoading && _status == null) {
      return const Center(child: CircularProgressIndicator(color: Color(0xFF6C5CE7)));
    }

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Row(
          children: [
            Expanded(
              child: Text('Оплата и реклама', style: TextStyle(color: context.onSurface, fontSize: 20, fontWeight: FontWeight.w700)),
            ),
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
          'Ключи задаются в .env на сервере (YOOMONEY_*, ALFABANK_*, STRIPE_*), после изменения - перезапуск '
          'бэкенда. ${_status?.inAppPaymentsNote ?? ''}',
          style: TextStyle(color: context.onSurfaceFaded(0.45), fontSize: 12, height: 1.4),
        ),
        const SizedBox(height: 10),
        for (final p in _status?.providers ?? const <PaymentProviderStatus>[]) ...[
          _buildProviderCard(p),
          const SizedBox(height: 12),
        ],
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

  Widget _buildProviderCard(PaymentProviderStatus p) {
    final (label, color) = p.ready
        ? ('Работает', const Color(0xFF00E6A0))
        : p.configured
            ? ('Выключен', const Color(0xFFFFD166))
            : ('Не подключён', context.onSurfaceFaded(0.45));
    final sourceText = switch (p.source) {
      'env' => 'ключи из .env',
      'admin' => 'ключи из старых настроек админки - перенеси в .env',
      _ => null,
    };
    return GlassPanel(
      opacity: 0.06,
      borderRadius: BorderRadius.circular(16),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(p.title, style: TextStyle(color: context.onSurface, fontSize: 15, fontWeight: FontWeight.w600)),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: color.withValues(alpha: 0.5)),
                ),
                child: Text(label, style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w600)),
              ),
            ],
          ),
          const SizedBox(height: 8),
          if (p.mode != null) _line('Режим', p.mode == 'test' ? 'тестовый (деньги не настоящие)' : 'боевой'),
          if (p.account != null && p.account!.isNotEmpty) _line('Аккаунт', p.account!),
          if (sourceText != null) _line('Откуда', sourceText),
          if (p.missing.isNotEmpty) _line('Не хватает в .env', p.missing.join(', '), warn: true),
          for (final e in p.setupUrls.entries) _copyLine(e.key, e.value),
          for (final e in p.events.entries) _line(e.key, _formatTime(e.value)),
          for (final n in p.notes)
            Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Text(n, style: TextStyle(color: context.onSurfaceFaded(0.45), fontSize: 11.5, height: 1.4)),
            ),
          if (p.key == 'yoomoney' && p.configured) ...[
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                FilledButton.icon(
                  style: FilledButton.styleFrom(backgroundColor: const Color(0xFF6C5CE7), foregroundColor: Colors.white),
                  onPressed: _isCreatingLink ? null : _createTestLink,
                  icon: const Icon(Icons.link_rounded, size: 18),
                  label: const Text('Проверочная оплата 10 ₽'),
                ),
                Text(
                  'Подписку не даёт - только проверяет, что платёж доходит до сервера',
                  style: TextStyle(color: context.onSurfaceFaded(0.45), fontSize: 11.5),
                ),
              ],
            ),
            if (_testLink != null) ...[
              const SizedBox(height: 8),
              SelectableText(_testLink!, style: TextStyle(color: context.onSurfaceFaded(0.7), fontSize: 11.5)),
            ],
          ],
          if (p.key == 'alfabank' && p.configured) ...[
            const SizedBox(height: 12),
            FilledButton.icon(
              style: FilledButton.styleFrom(backgroundColor: const Color(0xFF6C5CE7), foregroundColor: Colors.white),
              onPressed: _isCheckingBank ? null : _checkBank,
              icon: const Icon(Icons.verified_user_outlined, size: 18),
              label: const Text('Проверить доступ к банку'),
            ),
            if (_bankCheck != null) ...[
              const SizedBox(height: 8),
              Text(
                _bankCheck!,
                style: TextStyle(color: _bankCheckOk == true ? const Color(0xFF00E6A0) : const Color(0xFFFFB4B4), fontSize: 12.5),
              ),
            ],
          ],
        ],
      ),
    );
  }

  String _formatTime(String? iso) {
    if (iso == null) return 'ещё не было';
    final t = DateTime.tryParse(iso)?.toLocal();
    if (t == null) return iso;
    String two(int v) => v.toString().padLeft(2, '0');
    return '${two(t.day)}.${two(t.month)}.${t.year} ${two(t.hour)}:${two(t.minute)}';
  }

  Widget _line(String label, String value, {bool warn = false}) {
    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Text.rich(
        TextSpan(
          children: [
            TextSpan(text: '$label: ', style: TextStyle(color: context.onSurfaceFaded(0.5), fontSize: 12.5)),
            TextSpan(
              text: value,
              style: TextStyle(color: warn ? const Color(0xFFFFD166) : context.onSurface, fontSize: 12.5),
            ),
          ],
        ),
      ),
    );
  }

  Widget _copyLine(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Row(
        children: [
          Expanded(child: _line(label, value)),
          IconButton(
            tooltip: 'Скопировать',
            visualDensity: VisualDensity.compact,
            icon: Icon(Icons.copy_rounded, size: 16, color: context.onSurfaceFaded(0.5)),
            onPressed: () {
              Clipboard.setData(ClipboardData(text: value));
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Скопировано')));
            },
          ),
        ],
      ),
    );
  }

  Widget _buildToggleRow(String label, bool value, ValueChanged<bool> onChanged) {
    return Row(
      children: [
        Expanded(child: Text(label, style: TextStyle(color: context.onSurface, fontSize: 14))),
        Switch(value: value, activeColor: const Color(0xFF6C5CE7), onChanged: onChanged),
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
