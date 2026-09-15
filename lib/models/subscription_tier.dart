class SubscriptionTier {
  final String key;
  final String nameRu;
  final String nameEn;
  final int priceRubCents;
  final int priceUsdCents;
  final int? monthlyTokenLimit;
  final int? dailyFreeRequests;
  final bool isActive;
  final int sortOrder;
  final int durationDays;

  SubscriptionTier({
    required this.key,
    required this.nameRu,
    required this.nameEn,
    required this.priceRubCents,
    required this.priceUsdCents,
    required this.monthlyTokenLimit,
    required this.dailyFreeRequests,
    required this.isActive,
    required this.sortOrder,
    required this.durationDays,
  });

  factory SubscriptionTier.fromJson(Map<String, dynamic> json) => SubscriptionTier(
        key: json['key'] as String,
        nameRu: json['name_ru'] as String,
        nameEn: json['name_en'] as String,
        priceRubCents: json['price_rub_cents'] as int? ?? 0,
        priceUsdCents: json['price_usd_cents'] as int? ?? 0,
        monthlyTokenLimit: json['monthly_token_limit'] as int?,
        dailyFreeRequests: json['daily_free_requests'] as int?,
        isActive: json['is_active'] as bool? ?? true,
        sortOrder: json['sort_order'] as int? ?? 0,
        durationDays: json['duration_days'] as int? ?? 30,
      );
}
