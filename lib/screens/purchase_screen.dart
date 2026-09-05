import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../models/billing_plan.dart';
import '../models/usage_info.dart';
import '../services/billing_service.dart';
import '../services/usage_service.dart';
import '../state/auth_store.dart';
import '../theme/app_text_color.dart';
import '../widgets/app_background.dart';
import '../widgets/glass_panel.dart';

class PurchaseScreen extends StatefulWidget {
  final AuthStore authStore;
  const PurchaseScreen({super.key, required this.authStore});

  @override
  State<PurchaseScreen> createState() => _PurchaseScreenState();
}

class _PurchaseScreenState extends State<PurchaseScreen> with WidgetsBindingObserver {
  final _billingService = BillingService();
  final _usageService = UsageService();

  List<BillingPlan> _plans = [];
  UsageInfo? _usage;
  bool _isLoading = true;
  String? _error;
  String? _startingCheckoutFor;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _load();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _billingService.dispose();
    _usageService.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Пользователь мог только что вернуться из внешнего браузера, оплатив
    // подписку — обновляем статус. Нет надёжного способа поймать именно
    // "оплата прошла" без deep link'ов, поэтому просто перепроверяем при
    // каждом возврате в приложение — дёшево и достаточно.
    if (state == AppLifecycleState.resumed) {
      _loadUsage();
    }
  }

  Future<void> _load() async {
    setState(() => _isLoading = true);
    await Future.wait([_loadPlans(), _loadUsage()]);
    if (mounted) setState(() => _isLoading = false);
  }

  Future<void> _loadPlans() async {
    try {
      final plans = await _billingService.listPlans(widget.authStore.baseUrl);
      if (mounted) setState(() => _plans = plans);
    } on BillingException catch (e) {
      if (mounted) setState(() => _error = e.message);
    }
  }

  Future<void> _loadUsage() async {
    final token = widget.authStore.token;
    if (token == null) return;
    try {
      final usage = await _usageService.getMyUsage(baseUrl: widget.authStore.baseUrl, token: token);
      if (mounted) setState(() => _usage = usage);
    } on UsageException {
      // Не критично для этого экрана — просто не покажем текущий расход.
    }
  }

  Future<void> _buy(BillingPlan plan) async {
    final token = widget.authStore.token;
    if (token == null || !plan.available) return;

    setState(() {
      _startingCheckoutFor = plan.tariff;
      _error = null;
    });
    try {
      final url = await _billingService.createCheckoutUrl(
        baseUrl: widget.authStore.baseUrl,
        token: token,
        tariff: plan.tariff,
      );
      final uri = Uri.parse(url);
      final opened = await launchUrl(uri, mode: LaunchMode.externalApplication);
      if (!opened && mounted) {
        setState(() => _error = 'Не удалось открыть страницу оплаты.');
      }
    } on BillingException catch (e) {
      if (mounted) setState(() => _error = e.message);
    } finally {
      if (mounted) setState(() => _startingCheckoutFor = null);
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
                      'Подписка',
                      style: TextStyle(color: context.onSurface, fontSize: 18, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Center(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 480),
                      child: _isLoading
                          ? const Padding(
                              padding: EdgeInsets.symmetric(vertical: 60),
                              child: Center(child: CircularProgressIndicator(color: Color(0xFF6C5CE7))),
                            )
                          : _buildContent(),
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

  Widget _buildContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (_usage != null) _buildUsageCard(_usage!),
        if (_error != null) ...[
          const SizedBox(height: 12),
          Text(_error!, style: const TextStyle(color: Color(0xFFFFB4B4), fontSize: 13)),
        ],
        const SizedBox(height: 20),
        Text(
          'ДОСТУПНЫЕ ТАРИФЫ',
          style: TextStyle(color: context.onSurfaceFaded(0.4), fontSize: 11, letterSpacing: 1.2, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 10),
        if (_plans.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: Text('Тарифы пока не настроены.', style: TextStyle(color: context.onSurfaceFaded(0.4))),
          )
        else
          ..._plans.map(_buildPlanTile),
      ],
    );
  }

  Widget _buildUsageCard(UsageInfo usage) {
    final fraction = usage.usageFraction;
    return GlassPanel(
      opacity: 0.09,
      borderRadius: BorderRadius.circular(18),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text('Текущий тариф', style: TextStyle(color: context.onSurfaceFaded(0.6), fontSize: 12.5)),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  gradient: const LinearGradient(colors: [Color(0xFF6C5CE7), Color(0xFF00B4D8)]),
                ),
                child: Text(usage.tariff, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w700)),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            usage.tokensLimit == null
                ? '${usage.tokensUsedThisMonth} токенов использовано в этом месяце · без лимита'
                : '${usage.tokensUsedThisMonth} из ${usage.tokensLimit} токенов в этом месяце',
            style: TextStyle(color: context.onSurfaceFaded(0.5), fontSize: 12),
          ),
          if (fraction != null) ...[
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: fraction,
                minHeight: 6,
                backgroundColor: context.onSurfaceFaded(0.08),
                valueColor: AlwaysStoppedAnimation(fraction > 0.85 ? const Color(0xFFFF6B6B) : const Color(0xFF6C5CE7)),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildPlanTile(BillingPlan plan) {
    final isBusy = _startingCheckoutFor == plan.tariff;
    final isCurrent = _usage?.tariff == plan.tariff;
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: GlassPanel(
        opacity: 0.08,
        borderRadius: BorderRadius.circular(18),
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(plan.label, style: TextStyle(color: context.onSurface, fontWeight: FontWeight.w600, fontSize: 15)),
                      if (isCurrent) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            color: const Color(0xFF00E6A0).withValues(alpha: 0.18),
                          ),
                          child: const Text('текущий', style: TextStyle(color: Color(0xFF00E6A0), fontSize: 10.5)),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${plan.displayPrice} · ${plan.durationDays} дней',
                    style: TextStyle(color: context.onSurfaceFaded(0.5), fontSize: 12.5),
                  ),
                  if (!plan.available) ...[
                    const SizedBox(height: 4),
                    Text('Скоро будет доступно', style: TextStyle(color: context.onSurfaceFaded(0.35), fontSize: 11.5)),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 12),
            Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: plan.available && !isBusy ? () => _buy(plan) : null,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    gradient: LinearGradient(
                      colors: plan.available
                          ? [const Color(0xFF6C5CE7), const Color(0xFF00B4D8)]
                          : [context.onSurfaceFaded(0.24), context.onSurfaceFaded(0.10)],
                    ),
                  ),
                  child: isBusy
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                      : const Text('Купить', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
