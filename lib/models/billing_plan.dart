class BillingPlan {
  final String tariff;
  final String label;
  final int durationDays;
  final String displayPrice;
  final bool available;

  BillingPlan({
    required this.tariff,
    required this.label,
    required this.durationDays,
    required this.displayPrice,
    required this.available,
  });

  factory BillingPlan.fromJson(Map<String, dynamic> json) {
    return BillingPlan(
      tariff: json['tariff'] as String,
      label: json['label'] as String? ?? json['tariff'] as String,
      durationDays: json['duration_days'] as int? ?? 30,
      displayPrice: json['display_price'] as String? ?? '—',
      available: json['available'] as bool? ?? false,
    );
  }
}
