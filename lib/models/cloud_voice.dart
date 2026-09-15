/// Стандартные голоса из библиотеки ElevenLabs - доступны на любом
/// аккаунте по умолчанию, без клонирования или дополнительной настройки.
/// voice_id подтверждены из официальной документации
/// elevenlabs.io/docs/voices (набор "Premade voices").
///
/// Честно: список статичный, не запрашивается динамически с самого
/// ElevenLabs. Если на аккаунте есть свои клонированные голоса - их
/// придётся добавить сюда вручную (voice_id виден в личном кабинете
/// ElevenLabs, раздел Voices). Динамический список через их API
/// /v1/voices был бы надёжнее, но требует отдельного бэкенд-эндпоинта.
class CloudVoice {
  final String name; // voice_id ElevenLabs
  final String label; // то, что видит пользователь
  final bool isFemale;

  const CloudVoice({required this.name, required this.label, required this.isFemale});
}

const List<CloudVoice> elevenLabsCloudVoices = [
  CloudVoice(name: '21m00Tcm4TlvDq8ikWAM', label: 'Rachel (женский)', isFemale: true),
  CloudVoice(name: 'EXAVITQu4vr4xnSDxMaL', label: 'Bella (женский)', isFemale: true),
  CloudVoice(name: 'TxGEqnHWrfWFTfGW9XjX', label: 'Josh (мужской)', isFemale: false),
  CloudVoice(name: 'pNInz6obpgDQGcFmaJgB', label: 'Adam (мужской)', isFemale: false),
];
