class OperatorStats {
  final int id;
  final String email;
  final bool isActive;
  final double? avgRating;
  final int ratedSessionsCount;
  final int totalClaimedSessions;
  final int warningsCount;

  OperatorStats({
    required this.id,
    required this.email,
    required this.isActive,
    required this.avgRating,
    required this.ratedSessionsCount,
    required this.totalClaimedSessions,
    required this.warningsCount,
  });

  factory OperatorStats.fromJson(Map<String, dynamic> json) {
    return OperatorStats(
      id: json['id'] as int,
      email: json['email'] as String,
      isActive: json['is_active'] as bool? ?? true,
      avgRating: (json['avg_rating'] as num?)?.toDouble(),
      ratedSessionsCount: json['rated_sessions_count'] as int? ?? 0,
      totalClaimedSessions: json['total_claimed_sessions'] as int? ?? 0,
      warningsCount: json['warnings_count'] as int? ?? 0,
    );
  }
}

class OperatorWarning {
  final int id;
  final int operatorId;
  final String? issuedByEmail;
  final String reason;
  final DateTime createdAt;

  OperatorWarning({
    required this.id,
    required this.operatorId,
    required this.issuedByEmail,
    required this.reason,
    required this.createdAt,
  });

  factory OperatorWarning.fromJson(Map<String, dynamic> json) {
    return OperatorWarning(
      id: json['id'] as int,
      operatorId: json['operator_id'] as int,
      issuedByEmail: json['issued_by_email'] as String?,
      reason: json['reason'] as String? ?? '',
      createdAt: DateTime.tryParse(json['created_at'] as String? ?? '') ?? DateTime.now(),
    );
  }
}
