class TelegramSettings {
  final String channelLink;
  final String channelChatId;
  final String botUsername;
  final bool botTokenIsSet;
  final int bonusRequests;

  TelegramSettings({
    required this.channelLink,
    required this.channelChatId,
    required this.botUsername,
    required this.botTokenIsSet,
    required this.bonusRequests,
  });

  factory TelegramSettings.fromJson(Map<String, dynamic> json) => TelegramSettings(
        channelLink: json['telegram_channel_link'] as String? ?? '',
        channelChatId: json['telegram_channel_chat_id'] as String? ?? '',
        botUsername: json['telegram_bot_username'] as String? ?? '',
        botTokenIsSet: json['telegram_bot_token_is_set'] as bool? ?? false,
        bonusRequests: json['telegram_bonus_requests'] as int? ?? 5,
      );
}
