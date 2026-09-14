import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/blog_post.dart';
import '../services/blog_service.dart';
import '../state/auth_store.dart';
import '../theme/app_text_color.dart';
import '../widgets/app_background.dart';
import '../widgets/glass_panel.dart';
import 'admin_blog_editor_screen.dart';

class AdminBlogScreen extends StatefulWidget {
  final AuthStore authStore;
  final VoidCallback? onBack;
  const AdminBlogScreen({super.key, required this.authStore, this.onBack});

  @override
  State<AdminBlogScreen> createState() => _AdminBlogScreenState();
}

class _AdminBlogScreenState extends State<AdminBlogScreen> {
  final _service = BlogService();
  List<BlogPostSummary> _posts = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _service.dispose();
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
      final posts = await _service.adminListPosts(baseUrl: widget.authStore.baseUrl, token: token);
      if (mounted) setState(() => _posts = posts);
    } on BlogException catch (e) {
      if (mounted) setState(() => _error = e.message);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _openEditor({int? postId}) async {
    final saved = await Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (_) => AdminBlogEditorScreen(authStore: widget.authStore, postId: postId)),
    );
    if (saved == true) _load();
  }

  Future<void> _confirmDelete(BlogPostSummary post) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: GlassPanel(
          opacity: 0.18,
          borderRadius: BorderRadius.circular(20),
          padding: const EdgeInsets.all(20),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 360),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Удалить пост «${post.title}»?',
                  style: TextStyle(color: context.onSurface, fontSize: 16, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                Text(
                  'Действие необратимо.',
                  style: TextStyle(color: context.onSurfaceFaded(0.6), fontSize: 13),
                ),
                const SizedBox(height: 18),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(false),
                      child: Text('Отмена', style: TextStyle(color: context.onSurfaceFaded(0.6))),
                    ),
                    const SizedBox(width: 8),
                    FilledButton(
                      style: FilledButton.styleFrom(backgroundColor: const Color(0xFFFF6B6B)),
                      onPressed: () => Navigator.of(context).pop(true),
                      child: const Text('Удалить'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );

    if (confirmed != true) return;
    final token = widget.authStore.token;
    if (token == null) return;
    try {
      await _service.deletePost(baseUrl: widget.authStore.baseUrl, token: token, postId: post.id);
      _load();
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
                    // сайдбар в AdminShellScreen уже даёт навигацию - кнопка "назад" была
                    // бы бессмысленной, когда экран встроен содержимым (onBack задан).
                    // Показываем её только при обычном отдельном маршруте (onBack == null).
                    if (widget.onBack == null)
                      IconButton(
                        icon: Icon(Icons.arrow_back_rounded, color: context.onSurface),
                        onPressed: () => Navigator.of(context).pop(),
                      )
                    else
                      const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Блог',
                        style: TextStyle(color: context.onSurface, fontSize: 18, fontWeight: FontWeight.w600),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.add_rounded, color: Color(0xFF00E6A0)),
                      onPressed: () => _openEditor(),
                      tooltip: 'Новый пост',
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Center(
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Color(0xFF6C5CE7))
                      : RefreshIndicator(
                          onRefresh: _load,
                          child: ListView(
                            padding: const EdgeInsets.all(16),
                            children: [
                              Center(
                                child: ConstrainedBox(
                                  constraints: const BoxConstraints(maxWidth: 560),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.stretch,
                                    children: [
                                      if (_error != null) ...[
                                        Text(_error!, style: const TextStyle(color: Color(0xFFFFB4B4), fontSize: 13)),
                                        const SizedBox(height: 12),
                                      ],
                                      if (_posts.isEmpty)
                                        Padding(
                                          padding: const EdgeInsets.symmetric(vertical: 40),
                                          child: Center(
                                            child: Text(
                                              'Постов пока нет — нажми + сверху, чтобы добавить первый.',
                                              textAlign: TextAlign.center,
                                              style: TextStyle(color: context.onSurfaceFaded(0.4)),
                                            ),
                                          ),
                                        )
                                      else
                                        ..._posts.map((p) => Padding(
                                              padding: const EdgeInsets.only(bottom: 10),
                                              child: _AdminPostTile(
                                                post: p,
                                                onTap: () => _openEditor(postId: p.id),
                                                onDelete: () => _confirmDelete(p),
                                              ),
                                            )),
                                    ],
                                  ),
                                ),
                              ),
                            ],
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
}

class _AdminPostTile extends StatelessWidget {
  final BlogPostSummary post;
  final VoidCallback onTap;
  final VoidCallback onDelete;
  const _AdminPostTile({required this.post, required this.onTap, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: GlassPanel(
          opacity: 0.08,
          borderRadius: BorderRadius.circular(16),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: post.isPublished ? const Color(0xFF00E6A0) : context.onSurfaceFaded(0.3),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      post.title,
                      style: TextStyle(color: context.onSurface, fontSize: 14.5, fontWeight: FontWeight.w500),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      post.isPublished
                          ? 'Опубликовано ${post.publishedAt != null ? DateFormat.yMMMd().format(post.publishedAt!) : ""}'
                          : 'Черновик',
                      style: TextStyle(color: context.onSurfaceFaded(0.4), fontSize: 11.5),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: Icon(Icons.delete_outline_rounded, color: context.onSurfaceFaded(0.4), size: 20),
                onPressed: onDelete,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
