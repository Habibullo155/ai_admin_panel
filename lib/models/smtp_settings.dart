class SmtpSettings {
  final String smtpHost;
  final String smtpPort;
  final String smtpUser;
  final bool smtpPasswordIsSet;
  final String smtpFrom;
  final String smtpFromName;

  SmtpSettings({
    required this.smtpHost,
    required this.smtpPort,
    required this.smtpUser,
    required this.smtpPasswordIsSet,
    required this.smtpFrom,
    required this.smtpFromName,
  });

  bool get isConfigured => smtpHost.isNotEmpty && smtpUser.isNotEmpty && smtpPasswordIsSet;

  factory SmtpSettings.fromJson(Map<String, dynamic> json) => SmtpSettings(
        smtpHost: json['smtp_host'] as String? ?? '',
        smtpPort: json['smtp_port'] as String? ?? '587',
        smtpUser: json['smtp_user'] as String? ?? '',
        smtpPasswordIsSet: json['smtp_password_is_set'] as bool? ?? false,
        smtpFrom: json['smtp_from'] as String? ?? '',
        smtpFromName: json['smtp_from_name'] as String? ?? '',
      );
}
