class UsageInfo {
  final String tariff;
  final int tokensUsedThisMonth;
  final int? tokensLimit; // null = без лимита
  final DateTime periodStart;

  UsageInfo({
    required this.tariff,
    required this.tokensUsedThisMonth,
    required this.tokensLimit,
    required this.periodStart,
  });

  double? get usageFraction {
    if (tokensLimit == null || tokensLimit == 0) return null;
    return (tokensUsedThisMonth / tokensLimit!).clamp(0.0, 1.0);
  }

  factory UsageInfo.fromJson(Map<String, dynamic> json) {
    return UsageInfo(
      tariff: json['tariff'] as String? ?? 'free',
      tokensUsedThisMonth: json['tokens_used_this_month'] as int? ?? 0,
      tokensLimit: json['tokens_limit'] as int?,
      periodStart: DateTime.tryParse(json['period_start'] as String? ?? '') ?? DateTime.now(),
    );
  }
}
