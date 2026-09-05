import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:speech_to_text/speech_to_text.dart';

import '../models/voice_settings.dart';
import '../services/app_settings_service.dart';
import '../services/cloud_tts_service.dart';
import '../services/pronunciation_service.dart';
import '../services/voice_settings_service.dart';

// разбивает поток текста на предложения по .!?\n — не идеально (не
// отличит "г." от конца фразы), но для тайминга озвучки этого хватает
final _sentenceBoundary = RegExp(r'[^.!?\n]*[.!?\n]+');

final _hasLatinLetters = RegExp(r'[a-zA-Z]');
final _latinWord = RegExp(r'[a-zA-Z]+');

// грубая транслитерация англ. слов на слух, для случаев без записи в
// словаре произношения. Диграфы (sh, ch...) проверяются раньше одиночных
// букв, иначе "sh" распадётся на с+х
const _enToRuMap = {
  'sh': 'ш', 'ch': 'ч', 'th': 'з', 'ph': 'ф', 'ck': 'к', 'qu': 'кв',
  'oo': 'у', 'ee': 'и', 'ea': 'и',
  'a': 'а', 'b': 'б', 'c': 'к', 'd': 'д', 'e': 'е', 'f': 'ф', 'g': 'г',
  'h': 'х', 'i': 'и', 'j': 'дж', 'k': 'к', 'l': 'л', 'm': 'м', 'n': 'н',
  'o': 'о', 'p': 'п', 'q': 'к', 'r': 'р', 's': 'с', 't': 'т', 'u': 'а',
  'v': 'в', 'w': 'в', 'x': 'кс', 'y': 'и', 'z': 'з',
};

class VoiceStore extends ChangeNotifier {
  final FlutterTts _tts = FlutterTts();
  final SpeechToText _stt = SpeechToText();
  final AudioPlayer _audioPlayer = AudioPlayer();
  final VoiceSettingsService _settingsService = VoiceSettingsService();
  final AppSettingsService _appSettingsService = AppSettingsService();
  final PronunciationService _pronunciationService = PronunciationService();
  final CloudTtsService _cloudTtsService = CloudTtsService();

  String _baseUrl = '';
  String? _authToken;

  // словарь произношения от админа, общий для всех (personal-версию убрали)
  Map<String, String> globalPronunciation = {};

  VoiceSettings settings = const VoiceSettings();

  bool isSttAvailable = false; // микрофон + системный движок распознавания есть

  bool isVoiceFeatureEnabled = true; // глобальный тумблер админа, не про железо

  bool isCloudTtsAvailable = false; // настроен ли Silero-сервер в .env

  // и админ должен разрешить, и юзер сам не выключил у себя
  bool get isVoiceAvailable => isVoiceFeatureEnabled && settings.voiceUiEnabled;

  bool isListening = false;
  bool isSpeaking = false;
  List<Map<String, String>> availableVoices = [];
  String? lastError;

  // потоковое чтение: Silero сам не умеет стримить (отдаёт готовый WAV
  // целиком), но можно синтезировать и играть по одному предложению -
  // пока играет N, уже синтезируется N+1, звучит почти непрерывно
  String? _streamingMessageId;
  String _streamingBuffer = '';
  int _streamingSpokenLength = 0;
  final List<String> _sentenceQueue = [];
  bool _isSynthesizing = false;
  bool _isPlayingQueue = false;

  Future<void> init(String baseUrl, {String? authToken}) async {
    _baseUrl = baseUrl;
    _authToken = authToken;

    final hadSavedSettings = await _settingsService.hasSaved();
    settings = await _settingsService.load();
    final publicSettings = await _appSettingsService.getPublicSettings(baseUrl);
    isVoiceFeatureEnabled = publicSettings.voiceEnabled;
    isCloudTtsAvailable = publicSettings.cloudTtsEnabled;
    globalPronunciation = await _pronunciationService.getPublicDictionary(baseUrl);

    // дефолт от админа применяем на новом устройстве или если сохранённый
    // голос стал недействителен. Не различаем "выбрал сам то же самое,
    // что дефолт" от "просто остался дефолт" - редкий крайний случай
    if (isCloudTtsAvailable) {
      final currentIsValid = sileroCloudVoices.any((v) => v.name == settings.cloudVoiceName);
      final adminDefaultIsValid = sileroCloudVoices.any((v) => v.name == publicSettings.defaultVoice);
      if (!hadSavedSettings || !currentIsValid) {
        final fallback = adminDefaultIsValid ? publicSettings.defaultVoice : sileroCloudVoices.first.name;
        settings = settings.copyWith(cloudVoiceName: fallback);
        await _settingsService.save(settings);
      }
    }

    if (isVoiceFeatureEnabled) {
      try {
        isSttAvailable = await _stt.initialize(
          onStatus: (status) {
            isListening = status == 'listening';
            notifyListeners();
          },
          onError: (error) {
            lastError = error.errorMsg;
            isListening = false;
            notifyListeners();
          },
        );
      } catch (_) {
        isSttAvailable = false;
      }

      // список голосов устройства - только запасной вариант, если облако
      // настроено, используются 4 фиксированных голоса из cloud_voice.dart
      if (!isCloudTtsAvailable) {
        try {
          final voices = await _tts.getVoices;
          if (voices is List) {
            availableVoices = voices
                .whereType<Map>()
                .map((v) => {
                      'name': v['name']?.toString() ?? '',
                      'locale': v['locale']?.toString() ?? '',
                    })
                .where((v) => v['name']!.isNotEmpty)
                .toList();
          }
        } catch (_) {
          availableVoices = [];
        }
      }

      // если юзер сам ещё не выбирал язык распознавания - предпочитаем
      // русский, если доступен, а не отдаём на откуп системе
      if (settings.sttLocaleId == null && isSttAvailable) {
        try {
          final locales = await _stt.locales();
          String? russianLocaleId;
          for (final l in locales) {
            if (l.localeId.toLowerCase().startsWith('ru')) {
              russianLocaleId = l.localeId;
              break;
            }
          }
          if (russianLocaleId != null) {
            settings = settings.copyWith(sttLocaleId: russianLocaleId);
            await _settingsService.save(settings);
          }
        } catch (_) {
          // не критично, останется системный дефолт
        }
      }

      _tts.setCompletionHandler(() {
        isSpeaking = false;
        notifyListeners();
      });
      _tts.setCancelHandler(() {
        isSpeaking = false;
        notifyListeners();
      });
      _tts.setErrorHandler((_) {
        isSpeaking = false;
        notifyListeners();
      });
      // ожидание конца конкретного клипа делает _playAndWait, не общий
      // слушатель - иначе сбрасывал бы isSpeaking после первого предложения
      // из нескольких в очереди

      if (!isCloudTtsAvailable) {
        await _applyOnDeviceTtsSettings();
      }
    }

    notifyListeners();
  }

  Future<void> _applyOnDeviceTtsSettings() async {
    try {
      await _tts.setSpeechRate(settings.rate);
      await _tts.setPitch(settings.pitch);
      if (settings.voiceName != null && settings.voiceLocale != null) {
        await _tts.setVoice({'name': settings.voiceName!, 'locale': settings.voiceLocale!});
      }
    } catch (_) {
      // голос мог перестать существовать (сменилось устройство/ОС) - не критично
    }
  }

  Future<void> updateSettings(VoiceSettings newSettings) async {
    settings = newSettings;
    notifyListeners();
    await _settingsService.save(newSettings);
    if (!isCloudTtsAvailable) {
      await _applyOnDeviceTtsSettings();
    }
  }

  // тестовая фраза выбранным голосом, не сохраняя его как текущий - для
  // облачных голосов используй previewCloudVoice
  Future<void> previewVoice(String name, String locale) async {
    if (!isVoiceAvailable || isCloudTtsAvailable) return;
    await stopSpeaking();
    try {
      await _tts.setVoice({'name': name, 'locale': locale});
      isSpeaking = true;
      notifyListeners();
      await _tts.speak('Привет! Так звучит этот голос.');
    } catch (_) {
      isSpeaking = false;
      notifyListeners();
    } finally {
      await _applyOnDeviceTtsSettings();
    }
  }

  /// Прослушать конкретный облачный голос без сохранения выбора.
  Future<void> previewCloudVoice(String voiceName) async {
    if (!isVoiceAvailable || !isCloudTtsAvailable) return;
    await _speakCloud('Привет! Так звучит этот голос.', voiceOverride: voiceName);
  }

  // замена по границам слова, не по подстроке - раньше был баг, простой
  // replaceAll находил "ИИ" внутри "лИИния" и т.п. Обычный \b тут не
  // годится, он не считает кириллицу буквами - отсюда \p{L} + unicode: true
  String _applyPronunciation(String text) {
    var result = text;
    for (final entry in globalPronunciation.entries) {
      if (entry.key.isEmpty) continue;
      final pattern = '(?<![\\p{L}\\p{N}])${RegExp.escape(entry.key)}(?![\\p{L}\\p{N}])';
      result = result.replaceAll(
        RegExp(pattern, caseSensitive: false, unicode: true),
        entry.value,
      );
    }
    return _transliterateLatinFallback(result);
  }

  // голоса Silero - русские модели, латиницу либо пропускают, либо
  // коверкают. Для важных слов (бренды, термины) лучше словарь
  // произношения; это запасной вариант для всего остального -
  // побуквенная транслитерация на слух, не точное произношение
  String _transliterateLatinFallback(String text) {
    if (!_hasLatinLetters.hasMatch(text)) return text;
    return text.splitMapJoin(
      _latinWord,
      onMatch: (m) => _transliterateWord(m.group(0)!),
      onNonMatch: (s) => s,
    );
  }

  String _transliterateWord(String word) {
    final buffer = StringBuffer();
    var i = 0;
    final lower = word.toLowerCase();
    while (i < lower.length) {
      var matched = false;
      // Сначала более длинные буквосочетания (диграфы), потом одиночные
      // буквы — иначе "sh" распалось бы на "с"+"х" вместо единого "ш".
      for (final len in [2, 1]) {
        if (i + len > lower.length) continue;
        final chunk = lower.substring(i, i + len);
        final replacement = _enToRuMap[chunk];
        if (replacement != null) {
          buffer.write(replacement);
          i += len;
          matched = true;
          break;
        }
      }
      if (!matched) {
        buffer.write(lower[i]);
        i++;
      }
    }
    return buffer.toString();
  }

  Future<void> speak(String text) async {
    if (!isVoiceAvailable || text.trim().isEmpty) return;
    if (isCloudTtsAvailable) {
      await _speakCloud(text);
    } else {
      await _speakOnDevice(text);
    }
  }

  Future<void> _speakOnDevice(String text) async {
    await stopSpeaking();
    isSpeaking = true;
    notifyListeners();
    try {
      await _tts.speak(_applyPronunciation(text));
    } catch (_) {
      isSpeaking = false;
      notifyListeners();
    }
  }

  Future<void> _speakCloud(String text, {String? voiceOverride}) async {
    final token = _authToken;
    if (token == null) return;
    await stopSpeaking();
    isSpeaking = true;
    lastError = null;
    notifyListeners();
    try {
      final bytes = await _cloudTtsService.synthesize(
        baseUrl: _baseUrl,
        token: token,
        text: _applyPronunciation(text),
        voiceName: voiceOverride ?? settings.cloudVoiceName,
      );
      await _playAndWait(bytes);
    } on CloudTtsException catch (e) {
      lastError = e.message;
    } catch (e) {
      lastError = '$e';
    } finally {
      isSpeaking = false;
      notifyListeners();
    }
  }

  // временная подписка на каждый вызов, не постоянный слушатель на весь
  // плеер - тот конфликтовал бы с очередью из нескольких клипов, см. init()
  Future<void> _playAndWait(Uint8List bytes) async {
    final completer = Completer<void>();
    late StreamSubscription<void> sub;
    sub = _audioPlayer.onPlayerComplete.listen((_) {
      sub.cancel();
      if (!completer.isCompleted) completer.complete();
    });
    try {
      await _audioPlayer.play(BytesSource(bytes));
    } catch (e) {
      sub.cancel();
      if (!completer.isCompleted) completer.completeError(e);
      rethrow;
    }
    await completer.future;
  }

  // вызывается на каждый апдейт текста, который ещё генерируется
  // (chat_store.dart: onAssistantTextChunk) - если автоозвучка включена и
  // облако доступно, ставит в очередь на синтез каждое законченное
  // предложение сразу, не дожидаясь конца ответа. Для голоса на
  // устройстве стриминг не делаем, там speak() читает целиком
  void onIncomingText({required String messageId, required String fullContent, required bool isDone}) {
    if (!settings.autoReadEnabled || !isVoiceAvailable || !isCloudTtsAvailable) return;

    if (_streamingMessageId != messageId) {
      _resetStreamingState(messageId);
    }

    if (fullContent.length > _streamingSpokenLength) {
      _streamingBuffer += fullContent.substring(_streamingSpokenLength);
      _streamingSpokenLength = fullContent.length;
    }

    final matches = _sentenceBoundary.allMatches(_streamingBuffer).toList();
    if (matches.isNotEmpty) {
      for (final m in matches) {
        final sentence = m.group(0)?.trim() ?? '';
        if (sentence.isNotEmpty) _sentenceQueue.add(sentence);
      }
      _streamingBuffer = _streamingBuffer.substring(matches.last.end);
    }

    // длинное предложение без точки раньше блокировало синтез до самого
    // конца - принудительно режем по последнему пробелу, если накопилось
    // больше порога
    const forceBreakThreshold = 90;
    if (_streamingBuffer.length > forceBreakThreshold) {
      final lastSpace = _streamingBuffer.lastIndexOf(' ', forceBreakThreshold);
      final cut = lastSpace > 0 ? lastSpace : forceBreakThreshold;
      final chunk = _streamingBuffer.substring(0, cut).trim();
      if (chunk.isNotEmpty) _sentenceQueue.add(chunk);
      _streamingBuffer = _streamingBuffer.substring(cut).trimLeft();
    }

    if (isDone && _streamingBuffer.trim().isNotEmpty) {
      _sentenceQueue.add(_streamingBuffer.trim());
      _streamingBuffer = '';
    }

    unawaited(_pumpQueue());
  }

  void _resetStreamingState(String? newMessageId) {
    _streamingMessageId = newMessageId;
    _streamingBuffer = '';
    _streamingSpokenLength = 0;
    _sentenceQueue.clear();
  }

  // два независимых цикла: этот синтезирует предложения из очереди по
  // одному и сразу шлёт готовый звук на воспроизведение (не ждёт, пока
  // доиграет предыдущий клип), _pumpPlayback ниже играет их по порядку.
  // Оба ленивые - если уже работают, повторный вызов no-op
  Future<void> _pumpQueue() async {
    if (_isSynthesizing) return;
    _isSynthesizing = true;
    final token = _authToken;
    try {
      while (_sentenceQueue.isNotEmpty) {
        final sentence = _sentenceQueue.removeAt(0);
        if (token == null) continue;
        try {
          final bytes = await _cloudTtsService.synthesize(
            baseUrl: _baseUrl,
            token: token,
            text: _applyPronunciation(sentence),
            voiceName: settings.cloudVoiceName,
          );
          _playbackQueue.add(bytes);
          unawaited(_pumpPlayback());
        } on CloudTtsException catch (e) {
          // Один неудавшийся кусок не должен обрывать всё чтение целиком —
          // просто пропускаем его, остальная очередь продолжает работать.
          lastError = e.message;
        } catch (e) {
          lastError = '$e';
        }
      }
    } finally {
      _isSynthesizing = false;
    }
  }

  final List<Uint8List> _playbackQueue = [];

  get sileroCloudVoices => null;

  Future<void> _pumpPlayback() async {
    if (_isPlayingQueue) return;
    _isPlayingQueue = true;
    isSpeaking = true;
    notifyListeners();
    try {
      while (_playbackQueue.isNotEmpty) {
        final bytes = _playbackQueue.removeAt(0);
        try {
          await _playAndWait(bytes);
        } catch (_) {
          // Проблема с конкретным клипом — идём дальше по очереди, не
          // обрываем всё чтение целиком.
        }
      }
    } finally {
      _isPlayingQueue = false;
      isSpeaking = false;
      notifyListeners();
    }
  }

  Future<void> stopSpeaking() async {
    _resetStreamingState(null);
    _playbackQueue.clear();
    try {
      await _tts.stop();
    } catch (_) {
      // игнорируем — stop() на уже остановленном движке иногда бросает на некоторых платформах
    }
    try {
      await _audioPlayer.stop();
    } catch (_) {
      // аналогично — не критично
    }
    isSpeaking = false;
    notifyListeners();
  }

  // токен нужен для запросов к облачной озвучке, обновляется после init()
  void updateAuthToken(String? token) {
    _authToken = token;
  }

  // вызывает onResult на каждый промежуточный/финальный результат, обычно
  // подставляют текст в поле ввода
  Future<void> startListening({required ValueChanged<String> onResult}) async {
    if (!isVoiceAvailable || !isSttAvailable || isListening) return;
    lastError = null;
    try {
      await _stt.listen(
        onResult: (result) => onResult(result.recognizedWords),
        localeId: settings.sttLocaleId,
      );
      isListening = true;
      notifyListeners();
    } catch (e) {
      lastError = '$e';
      isListening = false;
      notifyListeners();
    }
  }

  Future<void> stopListening() async {
    try {
      await _stt.stop();
    } catch (_) {
      // игнорируем
    }
    isListening = false;
    notifyListeners();
  }

  @override
  void dispose() {
    _tts.stop();
    _stt.stop();
    _audioPlayer.dispose();
    _appSettingsService.dispose();
    _pronunciationService.dispose();
    _cloudTtsService.dispose();
    super.dispose();
  }
}
