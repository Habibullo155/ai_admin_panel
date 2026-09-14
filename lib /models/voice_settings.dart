class VoiceSettings {
  final bool autoReadEnabled;
  final bool voiceUiEnabled; // личный выбор пользователя — скрыть голосовые кнопки
  final double rate; // 0.0–1.0, нормализованная шкала flutter_tts (только голос на устройстве)
  final double pitch; // 0.5–2.0 (только голос на устройстве)
  final String? voiceName; // голос на устройстве (flutter_tts), если облако недоступно
  final String? voiceLocale;
  final String? sttLocaleId;

  /// Выбор из 4 фиксированных облачных голосов (Silero TTS) — см.
  /// models/cloud_voice.dart. Используется только когда облачная озвучка
  /// вообще доступна (сервер настроен) — иначе играет голос на устройстве.
  /// Личный словарь произношения убран — за это отвечает только
  /// глобальный словарь, который задаёт админ (routers_pronunciation.py),
  /// одного места для этого достаточно.
  final String cloudVoiceName;

  const VoiceSettings({
    this.autoReadEnabled = false,
    this.voiceUiEnabled = true,
    this.rate = 0.5,
    this.pitch = 1.0,
    this.voiceName,
    this.voiceLocale,
    this.sttLocaleId,
    this.cloudVoiceName = 'baya',
  });

  VoiceSettings copyWith({
    bool? autoReadEnabled,
    bool? voiceUiEnabled,
    double? rate,
    double? pitch,
    String? voiceName,
    String? voiceLocale,
    String? sttLocaleId,
    String? cloudVoiceName,
    bool clearVoice = false,
  }) {
    return VoiceSettings(
      autoReadEnabled: autoReadEnabled ?? this.autoReadEnabled,
      voiceUiEnabled: voiceUiEnabled ?? this.voiceUiEnabled,
      rate: rate ?? this.rate,
      pitch: pitch ?? this.pitch,
      voiceName: clearVoice ? null : (voiceName ?? this.voiceName),
      voiceLocale: clearVoice ? null : (voiceLocale ?? this.voiceLocale),
      sttLocaleId: sttLocaleId ?? this.sttLocaleId,
      cloudVoiceName: cloudVoiceName ?? this.cloudVoiceName,
    );
  }

  Map<String, dynamic> toJson() => {
        'autoReadEnabled': autoReadEnabled,
        'voiceUiEnabled': voiceUiEnabled,
        'rate': rate,
        'pitch': pitch,
        'voiceName': voiceName,
        'voiceLocale': voiceLocale,
        'sttLocaleId': sttLocaleId,
        'cloudVoiceName': cloudVoiceName,
      };

  factory VoiceSettings.fromJson(Map<String, dynamic> json) {
    return VoiceSettings(
      autoReadEnabled: json['autoReadEnabled'] as bool? ?? false,
      voiceUiEnabled: json['voiceUiEnabled'] as bool? ?? true,
      rate: (json['rate'] as num?)?.toDouble() ?? 0.5,
      pitch: (json['pitch'] as num?)?.toDouble() ?? 1.0,
      voiceName: json['voiceName'] as String?,
      voiceLocale: json['voiceLocale'] as String?,
      sttLocaleId: json['sttLocaleId'] as String?,
      cloudVoiceName: json['cloudVoiceName'] as String? ?? 'baya',
      // Старые сохранённые настройки могут ещё содержать
      // pronunciationOverrides — просто игнорируем это поле, если оно
      // есть (обратная совместимость без ошибок парсинга).
    );
  }
}
