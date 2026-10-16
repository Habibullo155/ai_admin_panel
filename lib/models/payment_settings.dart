class PaymentSettings {
  final bool stripeEnabled;
  final bool yoomoneyEnabled;
  final String yoomoneyWallet;
  final bool yoomoneySecretIsSet;
  final bool alfabankEnabled;
  final String alfabankBaseUrl;
  final String alfabankLogin;
  final bool alfabankPasswordIsSet;
  final bool alfabankTokenIsSet;

  PaymentSettings({
    required this.stripeEnabled,
    required this.yoomoneyEnabled,
    required this.yoomoneyWallet,
    required this.yoomoneySecretIsSet,
    required this.alfabankEnabled,
    required this.alfabankBaseUrl,
    required this.alfabankLogin,
    required this.alfabankPasswordIsSet,
    required this.alfabankTokenIsSet,
  });

  factory PaymentSettings.fromJson(Map<String, dynamic> json) => PaymentSettings(
        stripeEnabled: json['stripe_enabled'] as bool? ?? true,
        yoomoneyEnabled: json['yoomoney_enabled'] as bool? ?? false,
        yoomoneyWallet: json['yoomoney_wallet'] as String? ?? '',
        yoomoneySecretIsSet: json['yoomoney_secret_is_set'] as bool? ?? false,
        alfabankEnabled: json['alfabank_enabled'] as bool? ?? false,
        alfabankBaseUrl: json['alfabank_base_url'] as String? ?? '',
        alfabankLogin: json['alfabank_login'] as String? ?? '',
        alfabankPasswordIsSet: json['alfabank_password_is_set'] as bool? ?? false,
        alfabankTokenIsSet: json['alfabank_token_is_set'] as bool? ?? false,
      );
}

class AdMobSettings {
  final bool enabled;
  final String rewardedAdUnitId;

  AdMobSettings({required this.enabled, required this.rewardedAdUnitId});

  factory AdMobSettings.fromJson(Map<String, dynamic> json) => AdMobSettings(
        enabled: json['admob_enabled'] as bool? ?? false,
        rewardedAdUnitId: json['admob_rewarded_ad_unit_id'] as String? ?? '',
      );
}
