class OAuthProvider {
  final String provider; // "google" | "vk" | "gosuslugi" | "max"
  final String? clientId;
  final bool clientSecretIsSet;
  final bool enabled;
  final bool isFlowImplemented;

  OAuthProvider({
    required this.provider,
    this.clientId,
    required this.clientSecretIsSet,
    required this.enabled,
    required this.isFlowImplemented,
  });

  String get displayName {
    switch (provider) {
      case 'google':
        return 'Google';
      case 'vk':
        return 'ВКонтакте';
      case 'gosuslugi':
        return 'Госуслуги';
      case 'max':
        return 'MAX';
      default:
        return provider;
    }
  }

  factory OAuthProvider.fromJson(Map<String, dynamic> json) => OAuthProvider(
        provider: json['provider'] as String,
        clientId: json['client_id'] as String?,
        clientSecretIsSet: json['client_secret_is_set'] as bool? ?? false,
        enabled: json['enabled'] as bool? ?? false,
        isFlowImplemented: json['is_flow_implemented'] as bool? ?? false,
      );
}
