class AdminUser {
  final int id;
  final String email;
  final String role;
  final String tariff;
  final bool isActive;
  final DateTime createdAt;
  final DateTime? lastActiveAt;
  final DateTime? tariffExpiresAt;
  final bool isOperator;

  AdminUser({
    required this.id,
    required this.email,
    required this.role,
    required this.tariff,
    required this.isActive,
    required this.createdAt,
    required this.lastActiveAt,
    required this.tariffExpiresAt,
    this.isOperator = false,
  });

  bool get isAdmin => role == 'admin';

  /// "В сети" — если был активен в последние 15 минут. Порог намеренно
  /// шире, чем троттлинг на бэкенде (5 минут между записями last_active_at),
  /// чтобы не мигало туда-сюда на границе.
  bool get isOnlineNow =>
      lastActiveAt != null && DateTime.now().difference(lastActiveAt!).inMinutes < 15;

  /// null = бессрочно. Отрицательное число = подписка уже истекла (дней назад).
  int? get daysUntilExpiry {
    if (tariffExpiresAt == null) return null;
    return tariffExpiresAt!.difference(DateTime.now()).inDays;
  }

  /// Сравнивает даты напрямую, а не через daysUntilExpiry — Duration.inDays
  /// округляет К НУЛЮ, а не вниз: если подписка истекла 30 минут назад,
  /// inDays даст 0 (не -1), и проверка через "daysUntilExpiry! < 0" почти
  /// сутки ошибочно считала бы подписку ещё активной.
  bool get isTariffExpired =>
      tariffExpiresAt != null && tariffExpiresAt!.isBefore(DateTime.now());

  factory AdminUser.fromJson(Map<String, dynamic> json) {
    return AdminUser(
      id: json['id'] as int,
      email: json['email'] as String,
      role: json['role'] as String? ?? 'user',
      tariff: json['tariff'] as String? ?? 'free',
      isActive: json['is_active'] as bool? ?? true,
      createdAt:
          DateTime.tryParse(json['created_at'] as String? ?? '') ?? DateTime.now(),
      lastActiveAt: json['last_active_at'] != null
          ? DateTime.tryParse(json['last_active_at'] as String)
          : null,
      tariffExpiresAt: json['tariff_expires_at'] != null
          ? DateTime.tryParse(json['tariff_expires_at'] as String)
          : null,
      isOperator: json['is_operator'] as bool? ?? false,
    );
  }
}
