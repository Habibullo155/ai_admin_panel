enum HelpSessionStatus { pending, active, closed }

HelpSessionStatus _parseStatus(String? raw) {
  switch (raw) {
    case 'active':
      return HelpSessionStatus.active;
    case 'closed':
      return HelpSessionStatus.closed;
    default:
      return HelpSessionStatus.pending;
  }
}

class HelpSession {
  final int id;
  final int userId;
  final String? userEmail;
  final int? operatorId;
  final String? operatorEmail;
  final HelpSessionStatus status;
  final String? reason;
  final String? chatContext;
  final int? rating;
  final String? ratingComment;
  final DateTime createdAt;
  final DateTime? claimedAt;
  final DateTime? closedAt;

  HelpSession({
    required this.id,
    required this.userId,
    required this.userEmail,
    required this.operatorId,
    required this.operatorEmail,
    required this.status,
    required this.reason,
    required this.chatContext,
    required this.rating,
    required this.ratingComment,
    required this.createdAt,
    required this.claimedAt,
    required this.closedAt,
  });

  factory HelpSession.fromJson(Map<String, dynamic> json) {
    return HelpSession(
      id: json['id'] as int,
      userId: json['user_id'] as int,
      userEmail: json['user_email'] as String?,
      operatorId: json['operator_id'] as int?,
      operatorEmail: json['operator_email'] as String?,
      status: _parseStatus(json['status'] as String?),
      reason: json['reason'] as String?,
      chatContext: json['chat_context'] as String?,
      rating: json['rating'] as int?,
      ratingComment: json['rating_comment'] as String?,
      createdAt: DateTime.tryParse(json['created_at'] as String? ?? '') ?? DateTime.now(),
      claimedAt: json['claimed_at'] != null ? DateTime.tryParse(json['claimed_at'] as String) : null,
      closedAt: json['closed_at'] != null ? DateTime.tryParse(json['closed_at'] as String) : null,
    );
  }
}

class HelpMessage {
  final int id;
  final int sessionId;
  final int senderId;
  final String? senderEmail;
  final String content;
  final List<String>? images;
  final DateTime createdAt;

  HelpMessage({
    required this.id,
    required this.sessionId,
    required this.senderId,
    required this.senderEmail,
    required this.content,
    required this.images,
    required this.createdAt,
  });

  factory HelpMessage.fromJson(Map<String, dynamic> json) {
    return HelpMessage(
      id: json['id'] as int,
      sessionId: json['session_id'] as int,
      senderId: json['sender_id'] as int,
      senderEmail: json['sender_email'] as String?,
      content: json['content'] as String? ?? '',
      images: (json['images'] as List<dynamic>?)?.map((e) => e as String).toList(),
      createdAt: DateTime.tryParse(json['created_at'] as String? ?? '') ?? DateTime.now(),
    );
  }
}
