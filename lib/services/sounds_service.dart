import 'dart:convert';
import 'dart:typed_data';

import 'package:http/http.dart' as http;

import '../models/sound_asset.dart';

class SoundsException implements Exception {
  final String message;
  SoundsException(this.message);
  @override
  String toString() => message;
}

class SoundsService {
  final http.Client _client = http.Client();

  String? _extractError(String body) {
    try {
      final data = jsonDecode(body) as Map<String, dynamic>;
      final detail = data['detail'];
      return detail is String ? detail : null;
    } catch (_) {
      return null;
    }
  }

  Future<List<SoundAsset>> list({required String baseUrl, required String token, SoundCategory? category}) async {
    final uri = Uri.parse('$baseUrl/api/sounds').replace(
      queryParameters: category != null ? {'category': soundCategoryToString(category)} : null,
    );
    final res = await _client
        .get(uri, headers: {'Authorization': 'Bearer $token'})
        .timeout(const Duration(seconds: 15));
    if (res.statusCode >= 400) {
      throw SoundsException(_extractError(res.body) ?? 'Не удалось загрузить список звуков.');
    }
    return (jsonDecode(res.body) as List<dynamic>).map((e) => SoundAsset.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<List<SoundAsset>> adminList({required String baseUrl, required String token}) async {
    final res = await _client
        .get(Uri.parse('$baseUrl/api/sounds/admin'), headers: {'Authorization': 'Bearer $token'})
        .timeout(const Duration(seconds: 15));
    if (res.statusCode >= 400) {
      throw SoundsException(_extractError(res.body) ?? 'Не удалось загрузить список звуков.');
    }
    return (jsonDecode(res.body) as List<dynamic>).map((e) => SoundAsset.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<SoundAsset> upload({
    required String baseUrl,
    required String token,
    required String title,
    required SoundCategory category,
    required Uint8List bytes,
    required String filename,
  }) async {
    final uri = Uri.parse('$baseUrl/api/sounds/admin');
    final request = http.MultipartRequest('POST', uri)
      ..headers['Authorization'] = 'Bearer $token'
      ..fields['title'] = title
      ..fields['category'] = soundCategoryToString(category)
      ..files.add(http.MultipartFile.fromBytes('file', bytes, filename: filename));

    final streamed = await _client.send(request).timeout(const Duration(minutes: 5));
    final res = await http.Response.fromStream(streamed);
    if (res.statusCode >= 400) {
      throw SoundsException(_extractError(res.body) ?? 'Не удалось загрузить звук.');
    }
    return SoundAsset.fromJson(jsonDecode(res.body) as Map<String, dynamic>);
  }

  Future<void> delete({required String baseUrl, required String token, required int soundId}) async {
    final res = await _client
        .delete(Uri.parse('$baseUrl/api/sounds/admin/$soundId'), headers: {'Authorization': 'Bearer $token'})
        .timeout(const Duration(seconds: 15));
    if (res.statusCode >= 400) {
      throw SoundsException(_extractError(res.body) ?? 'Не удалось удалить звук.');
    }
  }

  /// Скачивает сами байты для проигрывания — тот же приём, что уже
  /// используется для предпрослушивания голоса (admin_voice_screen.dart):
  /// эндпоинт требует авторизации, а AudioPlayer (UrlSource) не умеет
  /// передавать свои заголовки, поэтому скачиваем целиком и играем через
  /// BytesSource, не через прямую ссылку.
  Future<Uint8List> fetchAudioBytes({required String baseUrl, required String token, required int soundId}) async {
    final res = await _client
        .get(Uri.parse('$baseUrl/api/sounds/$soundId/file'), headers: {'Authorization': 'Bearer $token'})
        .timeout(const Duration(seconds: 30));
    if (res.statusCode >= 400) {
      throw SoundsException('Не удалось загрузить звук (код ${res.statusCode}).');
    }
    return res.bodyBytes;
  }

  void dispose() => _client.close();
}
