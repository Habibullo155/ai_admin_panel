import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/blog_post.dart';

class BlogException implements Exception {
  final String message;
  BlogException(this.message);
  @override
  String toString() => message;
}

class BlogService {
  final http.Client _client = http.Client();

  Map<String, String> _headers(String token) => {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      };

  String? _extractError(String body) {
    try {
      final data = jsonDecode(body) as Map<String, dynamic>;
      final detail = data['detail'];
      return detail is String ? detail : null;
    } catch (_) {
      return null;
    }
  }

  // --- Публичная сторона ---

  Future<List<BlogPostSummary>> listPublishedPosts({required String baseUrl, required String token}) async {
    final res = await _client
        .get(Uri.parse('$baseUrl/api/blog/posts'), headers: _headers(token))
        .timeout(const Duration(seconds: 15));
    if (res.statusCode >= 400) {
      throw BlogException(_extractError(res.body) ?? 'Не удалось загрузить блог.');
    }
    return (jsonDecode(res.body) as List<dynamic>)
        .map((e) => BlogPostSummary.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<BlogPost> getPost({required String baseUrl, required String token, required int postId}) async {
    final res = await _client
        .get(Uri.parse('$baseUrl/api/blog/posts/$postId'), headers: _headers(token))
        .timeout(const Duration(seconds: 15));
    if (res.statusCode >= 400) {
      throw BlogException(_extractError(res.body) ?? 'Не удалось загрузить пост.');
    }
    return BlogPost.fromJson(jsonDecode(res.body) as Map<String, dynamic>);
  }

  // --- Admin-only ---

  Future<List<BlogPostSummary>> adminListPosts({required String baseUrl, required String token}) async {
    final res = await _client
        .get(Uri.parse('$baseUrl/api/blog/admin/posts'), headers: _headers(token))
        .timeout(const Duration(seconds: 15));
    if (res.statusCode >= 400) {
      throw BlogException(_extractError(res.body) ?? 'Не удалось загрузить список постов.');
    }
    return (jsonDecode(res.body) as List<dynamic>)
        .map((e) => BlogPostSummary.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<BlogPost> adminGetPost({required String baseUrl, required String token, required int postId}) async {
    final res = await _client
        .get(Uri.parse('$baseUrl/api/blog/admin/posts/$postId'), headers: _headers(token))
        .timeout(const Duration(seconds: 15));
    if (res.statusCode >= 400) {
      throw BlogException(_extractError(res.body) ?? 'Не удалось загрузить пост.');
    }
    return BlogPost.fromJson(jsonDecode(res.body) as Map<String, dynamic>);
  }

  Future<BlogPost> createPost({
    required String baseUrl,
    required String token,
    required String title,
    required String content,
    String? coverImageBase64,
    bool isPublished = false,
  }) async {
    final res = await _client
        .post(
          Uri.parse('$baseUrl/api/blog/admin/posts'),
          headers: _headers(token),
          body: jsonEncode({
            'title': title,
            'content': content,
            if (coverImageBase64 != null) 'cover_image_base64': coverImageBase64,
            'is_published': isPublished,
          }),
        )
        .timeout(const Duration(seconds: 20));
    if (res.statusCode >= 400) {
      throw BlogException(_extractError(res.body) ?? 'Не удалось создать пост.');
    }
    return BlogPost.fromJson(jsonDecode(res.body) as Map<String, dynamic>);
  }

  Future<BlogPost> updatePost({
    required String baseUrl,
    required String token,
    required int postId,
    String? title,
    String? content,
    String? coverImageBase64,
    bool clearCoverImage = false,
    bool? isPublished,
  }) async {
    final body = <String, dynamic>{};
    if (title != null) body['title'] = title;
    if (content != null) body['content'] = content;
    if (coverImageBase64 != null) body['cover_image_base64'] = coverImageBase64;
    if (clearCoverImage) body['clear_cover_image'] = true;
    if (isPublished != null) body['is_published'] = isPublished;

    final res = await _client
        .patch(
          Uri.parse('$baseUrl/api/blog/admin/posts/$postId'),
          headers: _headers(token),
          body: jsonEncode(body),
        )
        .timeout(const Duration(seconds: 20));
    if (res.statusCode >= 400) {
      throw BlogException(_extractError(res.body) ?? 'Не удалось сохранить пост.');
    }
    return BlogPost.fromJson(jsonDecode(res.body) as Map<String, dynamic>);
  }

  Future<void> deletePost({required String baseUrl, required String token, required int postId}) async {
    final res = await _client
        .delete(Uri.parse('$baseUrl/api/blog/admin/posts/$postId'), headers: _headers(token))
        .timeout(const Duration(seconds: 15));
    if (res.statusCode >= 400) {
      throw BlogException(_extractError(res.body) ?? 'Не удалось удалить пост.');
    }
  }

  // --- Лайки и комментарии (доступно любому вошедшему пользователю,
  // только для опубликованных постов — тот же уровень доступа, что и
  // у чтения самих постов) ---

  Future<BlogPost> toggleLike({required String baseUrl, required String token, required int postId}) async {
    final res = await _client
        .post(Uri.parse('$baseUrl/api/blog/posts/$postId/like'), headers: _headers(token))
        .timeout(const Duration(seconds: 15));
    if (res.statusCode >= 400) {
      throw BlogException(_extractError(res.body) ?? 'Не удалось поставить лайк.');
    }
    return BlogPost.fromJson(jsonDecode(res.body) as Map<String, dynamic>);
  }

  Future<List<BlogComment>> listComments({required String baseUrl, required String token, required int postId}) async {
    final res = await _client
        .get(Uri.parse('$baseUrl/api/blog/posts/$postId/comments'), headers: _headers(token))
        .timeout(const Duration(seconds: 15));
    if (res.statusCode >= 400) {
      throw BlogException(_extractError(res.body) ?? 'Не удалось загрузить комментарии.');
    }
    return (jsonDecode(res.body) as List<dynamic>)
        .map((e) => BlogComment.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<BlogComment> addComment({
    required String baseUrl,
    required String token,
    required int postId,
    required String content,
  }) async {
    final res = await _client
        .post(
          Uri.parse('$baseUrl/api/blog/posts/$postId/comments'),
          headers: _headers(token),
          body: jsonEncode({'content': content}),
        )
        .timeout(const Duration(seconds: 15));
    if (res.statusCode >= 400) {
      throw BlogException(_extractError(res.body) ?? 'Не удалось отправить комментарий.');
    }
    return BlogComment.fromJson(jsonDecode(res.body) as Map<String, dynamic>);
  }

  Future<void> deleteComment({required String baseUrl, required String token, required int commentId}) async {
    final res = await _client
        .delete(Uri.parse('$baseUrl/api/blog/comments/$commentId'), headers: _headers(token))
        .timeout(const Duration(seconds: 15));
    if (res.statusCode >= 400) {
      throw BlogException(_extractError(res.body) ?? 'Не удалось удалить комментарий.');
    }
  }

  void dispose() => _client.close();
}
