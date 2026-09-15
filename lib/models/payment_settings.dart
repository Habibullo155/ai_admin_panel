class PaymentSettings {
  final bool stripeEnabled;
  final bool yoomoneyEnabled;
  final String yoomoneyWallet;
  final bool yoomoneySecretIsSet;

  PaymentSettings({
    required this.stripeEnabled,
    required this.yoomoneyEnabled,
    required this.yoomoneyWallet,
    required this.yoomoneySecretIsSet,
  });

  factory PaymentSettings.fromJson(Map<String, dynamic> json) => PaymentSettings(
        stripeEnabled: json['stripe_enabled'] as bool? ?? true,
        yoomoneyEnabled: json['yoomoney_enabled'] as bool? ?? false,
        yoomoneyWallet: json['yoomoney_wallet'] as String? ?? '',
        yoomoneySecretIsSet: json['yoomoney_secret_is_set'] as bool? ?? false,
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
