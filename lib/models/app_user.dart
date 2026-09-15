class AppUser {
  final int id;
  final String email;
  final String role; // "user" | "admin"
  final String tariff;
  final bool isActive;
  final bool isEmailVerified;
  final DateTime createdAt;
  final String? fullName;
  final DateTime? birthDate;
  final String? hobbies;
  final String? emergencyContact;
  final String? avatarBase64;
  final bool isOperator;

  AppUser({
    required this.id,
    required this.email,
    required this.role,
    required this.tariff,
    required this.isActive,
    required this.isEmailVerified,
    required this.createdAt,
    this.fullName,
    this.birthDate,
    this.hobbies,
    this.emergencyContact,
    this.avatarBase64,
    this.isOperator = false,
  });

  bool get isAdmin => role == 'admin';

  // возраст всегда считается на лету из даты рождения, не хранится
  // отдельным числом (то устаревало бы само по себе)
  int? get age {
    final bd = birthDate;
    if (bd == null) return null;
    final now = DateTime.now();
    var years = now.year - bd.year;
    if (now.month < bd.month || (now.month == bd.month && now.day < bd.day)) {
      years--;
    }
    return years;
  }

  factory AppUser.fromJson(Map<String, dynamic> json) {
    return AppUser(
      id: json['id'] as int,
      email: json['email'] as String,
      role: json['role'] as String? ?? 'user',
      tariff: json['tariff'] as String? ?? 'free',
      isActive: json['is_active'] as bool? ?? true,
      isEmailVerified: json['is_email_verified'] as bool? ?? false,
      createdAt:
          DateTime.tryParse(json['created_at'] as String? ?? '') ?? DateTime.now(),
      fullName: json['full_name'] as String?,
      birthDate: json['birth_date'] != null ? DateTime.tryParse(json['birth_date'] as String) : null,
      hobbies: json['hobbies'] as String?,
      emergencyContact: json['emergency_contact'] as String?,
      avatarBase64: json['avatar_base64'] as String?,
      isOperator: json['is_operator'] as bool? ?? false,
    );
  }
}
