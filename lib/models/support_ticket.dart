enum TicketStatus { open, closed }

class SupportTicket {
  final int id;
  final int userId;
  final String? userEmail;
  final String message;
  final TicketStatus status;
  final DateTime createdAt;

  SupportTicket({
    required this.id,
    required this.userId,
    required this.userEmail,
    required this.message,
    required this.status,
    required this.createdAt,
  });

  factory SupportTicket.fromJson(Map<String, dynamic> json) {
    return SupportTicket(
      id: json['id'] as int,
      userId: json['user_id'] as int,
      userEmail: json['user_email'] as String?,
      message: json['message'] as String? ?? '',
      status: (json['status'] as String?) == 'closed' ? TicketStatus.closed : TicketStatus.open,
      createdAt:
          DateTime.tryParse(json['created_at'] as String? ?? '') ?? DateTime.now(),
    );
  }
}
