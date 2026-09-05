class DashboardStats {
  final int usersTotal;
  final int usersOnlineNow;
  final int usersAdmins;
  final int ticketsOpen;
  final int reportsOpen;
  final int documentsTotal;
  final int tokensUsedInPeriod;
  final int purchasesCountInPeriod;
  final int purchasesTotalCentsInPeriod;

  DashboardStats({
    required this.usersTotal,
    required this.usersOnlineNow,
    required this.usersAdmins,
    required this.ticketsOpen,
    required this.reportsOpen,
    required this.documentsTotal,
    required this.tokensUsedInPeriod,
    required this.purchasesCountInPeriod,
    required this.purchasesTotalCentsInPeriod,
  });

  factory DashboardStats.fromJson(Map<String, dynamic> json) {
    return DashboardStats(
      usersTotal: json['users_total'] as int? ?? 0,
      usersOnlineNow: json['users_online_now'] as int? ?? 0,
      usersAdmins: json['users_admins'] as int? ?? 0,
      ticketsOpen: json['tickets_open'] as int? ?? 0,
      reportsOpen: json['reports_open'] as int? ?? 0,
      documentsTotal: json['documents_total'] as int? ?? 0,
      tokensUsedInPeriod: json['tokens_used_in_period'] as int? ?? 0,
      purchasesCountInPeriod: json['purchases_count_in_period'] as int? ?? 0,
      purchasesTotalCentsInPeriod: json['purchases_total_cents_in_period'] as int? ?? 0,
    );
  }
}

class ActivityDay {
  final DateTime date;
  final int messages;
  final int activeUsers;

  ActivityDay({required this.date, required this.messages, required this.activeUsers});

  factory ActivityDay.fromJson(Map<String, dynamic> json) => ActivityDay(
        date: DateTime.tryParse(json['date'] as String? ?? '') ?? DateTime.now(),
        messages: json['messages'] as int? ?? 0,
        activeUsers: json['active_users'] as int? ?? 0,
      );
}

class AdminPurchase {
  final int id;
  final int? userId;
  final String? userEmail;
  final String tariff;
  final int amountCents;
  final String currency;
  final DateTime createdAt;

  AdminPurchase({
    required this.id,
    required this.userId,
    required this.userEmail,
    required this.tariff,
    required this.amountCents,
    required this.currency,
    required this.createdAt,
  });

  String get formattedAmount {
    final major = amountCents / 100;
    final symbol = currency.toLowerCase() == 'usd' ? r'$' : '${currency.toUpperCase()} ';
    return '$symbol${major.toStringAsFixed(2)}';
  }

  factory AdminPurchase.fromJson(Map<String, dynamic> json) => AdminPurchase(
        id: json['id'] as int,
        userId: json['user_id'] as int?,
        userEmail: json['user_email'] as String?,
        tariff: json['tariff'] as String? ?? '',
        amountCents: json['amount_cents'] as int? ?? 0,
        currency: json['currency'] as String? ?? 'usd',
        createdAt: DateTime.tryParse(json['created_at'] as String? ?? '') ?? DateTime.now(),
      );
}

class ComplaintsMonth {
  final String month; // YYYY-MM
  final int count;

  ComplaintsMonth({required this.month, required this.count});

  factory ComplaintsMonth.fromJson(Map<String, dynamic> json) => ComplaintsMonth(
        month: json['month'] as String? ?? '',
        count: json['count'] as int? ?? 0,
      );
}

class HourlyActivity {
  final int hour; // 0..23, UTC
  final int messages;

  HourlyActivity({required this.hour, required this.messages});

  factory HourlyActivity.fromJson(Map<String, dynamic> json) => HourlyActivity(
        hour: json['hour'] as int? ?? 0,
        messages: json['messages'] as int? ?? 0,
      );
}

class TokenUsageByUser {
  final int userId;
  final String userEmail;
  final int promptTokens;
  final int completionTokens;
  final int totalTokens;
  final int requestCount;

  TokenUsageByUser({
    required this.userId,
    required this.userEmail,
    required this.promptTokens,
    required this.completionTokens,
    required this.totalTokens,
    required this.requestCount,
  });

  factory TokenUsageByUser.fromJson(Map<String, dynamic> json) => TokenUsageByUser(
        userId: json['user_id'] as int,
        userEmail: json['user_email'] as String? ?? '',
        promptTokens: json['prompt_tokens'] as int? ?? 0,
        completionTokens: json['completion_tokens'] as int? ?? 0,
        totalTokens: json['total_tokens'] as int? ?? 0,
        requestCount: json['request_count'] as int? ?? 0,
      );
}
