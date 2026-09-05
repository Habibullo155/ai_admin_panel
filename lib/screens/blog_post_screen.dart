import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/blog_post.dart';
import '../services/blog_service.dart';
import '../state/auth_store.dart';
import '../theme/app_text_color.dart';
import '../utils/blog_markup.dart';
import '../widgets/app_background.dart';
import '../widgets/glass_panel.dart';

class BlogPostScreen extends StatefulWidget {
  final AuthStore authStore;
  final int postId;
  const BlogPostScreen({super.key, required this.authStore, required this.postId});

  @override
  State<BlogPostScreen> createState() => _BlogPostScreenState();
}

class _BlogPostScreenState extends State<BlogPostScreen> {
  final _service = BlogService();
  final _commentController = TextEditingController();
  BlogPost? _post;
  List<BlogComment> _comments = [];
  bool _isLoading = true;
  bool _isLiking = false;
  bool _isSendingComment = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _service.dispose();
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    final token = widget.authStore.token;
    if (token == null) return;
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final post = await _service.getPost(baseUrl: widget.authStore.baseUrl, token: token, postId: widget.postId);
      final comments = await _service.listComments(baseUrl: widget.authStore.baseUrl, token: token, postId: widget.postId);
      if (mounted) {
        setState(() {
          _post = post;
          _comments = comments;
        });
      }
    } on BlogException catch (e) {
      if (mounted) setState(() => _error = e.message);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _toggleLike() async {
    final token = widget.authStore.token;
    if (token == null || _isLiking) return;
    setState(() => _isLiking = true);
    try {
      final updated = await _service.toggleLike(baseUrl: widget.authStore.baseUrl, token: token, postId: widget.postId);
      if (mounted) setState(() => _post = updated);
    } on BlogException catch (_) {
      // не критично - лайк просто не засчитался, ничего не ломаем
    } finally {
      if (mounted) setState(() => _isLiking = false);
    }
  }

  Future<void> _sendComment() async {
    final token = widget.authStore.token;
    final text = _commentController.text.trim();
    if (token == null || text.isEmpty || _isSendingComment) return;
    setState(() => _isSendingComment = true);
    try {
      final comment = await _service.addComment(
        baseUrl: widget.authStore.baseUrl,
        token: token,
        postId: widget.postId,
        content: text,
      );
      if (mounted) {
        setState(() {
          _comments = [..._comments, comment];
          _commentController.clear();
        });
      }
    } on BlogException catch (e) {
      if (mounted) setState(() => _error = e.message);
    } finally {
      if (mounted) setState(() => _isSendingComment = false);
    }
  }

  Future<void> _deleteComment(BlogComment comment) async {
    final token = widget.authStore.token;
    if (token == null) return;
    try {
      await _service.deleteComment(baseUrl: widget.authStore.baseUrl, token: token, commentId: comment.id);
      if (mounted) setState(() => _comments = _comments.where((c) => c.id != comment.id).toList());
    } on BlogException catch (e) {
      if (mounted) setState(() => _error = e.message);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: AppBackground(
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    IconButton(
                      icon: Icon(Icons.arrow_back_rounded, color: context.onSurface),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                    Text(
                      'Пост',
                      style: TextStyle(color: context.onSurface, fontSize: 18, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Center(
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Color(0xFF6C5CE7))
                      : _post == null
                          ? Text(_error ?? 'Пост не найден.', style: const TextStyle(color: Color(0xFFFFB4B4)))
                          : SingleChildScrollView(
                              padding: const EdgeInsets.all(16),
                              child: ConstrainedBox(
                                constraints: const BoxConstraints(maxWidth: 640),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.stretch,
                                  children: [
                                    if (_error != null) ...[
                                      Text(_error!, style: const TextStyle(color: Color(0xFFFFB4B4), fontSize: 13)),
                                      const SizedBox(height: 10),
                                    ],
                                    _buildContent(_post!),
                                    const SizedBox(height: 16),
                                    _buildCommentsSection(),
                                  ],
                                ),
                              ),
                            ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContent(BlogPost post) {
    return GlassPanel(
      opacity: 0.08,
      borderRadius: BorderRadius.circular(20),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (post.coverImageBase64 != null) ...[
            ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: Image.memory(base64Decode(post.coverImageBase64!), fit: BoxFit.cover, width: double.infinity, height: 200),
            ),
            const SizedBox(height: 16),
          ],
          Text(
            post.title,
            style: TextStyle(color: context.onSurface, fontSize: 21, fontWeight: FontWeight.w700, height: 1.3),
          ),
          const SizedBox(height: 8),
          if (post.publishedAt != null)
            Text(
              DateFormat.yMMMMd().format(post.publishedAt!),
              style: TextStyle(color: context.onSurfaceFaded(0.4), fontSize: 12.5),
            ),
          const SizedBox(height: 18),
          buildBlogMarkupText(post.content, baseColor: context.onSurfaceFaded(0.9)),
          const SizedBox(height: 16),
          Divider(color: context.borderSubtle),
          const SizedBox(height: 4),
          Row(
            children: [
              Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(20),
                  onTap: _isLiking ? null : _toggleLike,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
                    child: Row(
                      children: [
                        Icon(
                          post.likedByMe ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                          color: post.likedByMe ? const Color(0xFFFF6B9D) : context.onSurfaceFaded(0.5),
                          size: 22,
                        ),
                        const SizedBox(width: 6),
                        Text('${post.likeCount}', style: TextStyle(color: context.onSurfaceFaded(0.6), fontSize: 13.5)),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 20),
              Icon(Icons.chat_bubble_outline_rounded, color: context.onSurfaceFaded(0.5), size: 19),
              const SizedBox(width: 6),
              Text('${post.commentCount}', style: TextStyle(color: context.onSurfaceFaded(0.6), fontSize: 13.5)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCommentsSection() {
    final myId = widget.authStore.user?.id;
    return GlassPanel(
      opacity: 0.08,
      borderRadius: BorderRadius.circular(20),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Комментарии', style: TextStyle(color: context.onSurface, fontSize: 15.5, fontWeight: FontWeight.w600)),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _commentController,
                  minLines: 1,
                  maxLines: 4,
                  style: TextStyle(color: context.onSurface, fontSize: 13.5),
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: context.onSurfaceFaded(0.07),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    hintText: 'Написать комментарий…',
                    hintStyle: TextStyle(color: context.onSurfaceFaded(0.3)),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                icon: _isSendingComment
                    ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF6C5CE7)))
                    : const Icon(Icons.send_rounded, color: Color(0xFF6C5CE7)),
                onPressed: _isSendingComment ? null : _sendComment,
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (_comments.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Text('Пока нет комментариев — будь первым.', style: TextStyle(color: context.onSurfaceFaded(0.4), fontSize: 12.5)),
            )
          else
            ..._comments.map((c) => _buildCommentTile(c, canDelete: c.authorId == myId || widget.authStore.user?.isAdmin == true)),
        ],
      ),
    );
  }

  Widget _buildCommentTile(BlogComment comment, {required bool canDelete}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      comment.authorEmail ?? 'Пользователь',
                      style: TextStyle(color: context.onSurfaceFaded(0.7), fontSize: 12, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(width: 8),
                    Text(DateFormat.MMMd().add_Hm().format(comment.createdAt), style: TextStyle(color: context.onSurfaceFaded(0.35), fontSize: 11)),
                  ],
                ),
                const SizedBox(height: 3),
                Text(comment.content, style: TextStyle(color: context.onSurface, fontSize: 13.5, height: 1.4)),
              ],
            ),
          ),
          if (canDelete)
            IconButton(
              icon: Icon(Icons.delete_outline_rounded, size: 17, color: context.onSurfaceFaded(0.35)),
              onPressed: () => _deleteComment(comment),
            ),
        ],
      ),
    );
  }
}
