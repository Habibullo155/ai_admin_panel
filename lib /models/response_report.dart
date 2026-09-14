enum ReportStatus { open, resolved }

class ResponseReport {
  final int id;
  final int userId;
  final String? userEmail;
  final String userMessage;
  final String aiResponse;
  final String? reason;
  final String? adminReply;
  final ReportStatus status;
  final DateTime createdAt;

  ResponseReport({
    required this.id,
    required this.userId,
    required this.userEmail,
    required this.userMessage,
    required this.aiResponse,
    required this.reason,
    required this.adminReply,
    required this.status,
    required this.createdAt,
  });

  factory ResponseReport.fromJson(Map<String, dynamic> json) {
    return ResponseReport(
      id: json['id'] as int,
      userId: json['user_id'] as int,
      userEmail: json['user_email'] as String?,
      userMessage: json['user_message'] as String? ?? '',
      aiResponse: json['ai_response'] as String? ?? '',
      reason: json['reason'] as String?,
      adminReply: json['admin_reply'] as String?,
      status: (json['status'] as String?) == 'resolved' ? ReportStatus.resolved : ReportStatus.open,
      createdAt: DateTime.tryParse(json['created_at'] as String? ?? '') ?? DateTime.now(),
    );
  }
}
