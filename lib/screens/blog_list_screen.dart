import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/blog_post.dart';
import '../services/blog_service.dart';
import '../state/auth_store.dart';
import '../theme/app_text_color.dart';
import '../widgets/app_background.dart';
import '../widgets/glass_panel.dart';
import 'blog_post_screen.dart';

class BlogListScreen extends StatefulWidget {
  final AuthStore authStore;
  const BlogListScreen({super.key, required this.authStore});

  @override
  State<BlogListScreen> createState() => _BlogListScreenState();
}

class _BlogListScreenState extends State<BlogListScreen> {
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
      final posts = await _service.listPublishedPosts(baseUrl: widget.authStore.baseUrl, token: token);
      if (mounted) setState(() => _posts = posts);
    } on BlogException catch (e) {
      if (mounted) setState(() => _error = e.message);
    } finally {
      if (mounted) setState(() => _isLoading = false);
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
                      'Блог',
                      style: TextStyle(color: context.onSurface, fontSize: 18, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Center(
                  child: RefreshIndicator(
                    onRefresh: _load,
                    child: _isLoading
                        ? const Center(child: CircularProgressIndicator(color: Color(0xFF6C5CE7)))
                        : _error != null
                            ? Center(
                                child: Text(_error!, style: const TextStyle(color: Color(0xFFFFB4B4))),
                              )
                            : _posts.isEmpty
                                ? Center(
                                    child: Text(
                                      'Постов пока нет — загляни позже.',
                                      style: TextStyle(color: context.onSurfaceFaded(0.4)),
                                    ),
                                  )
                                : ListView(
                                    padding: const EdgeInsets.all(16),
                                    children: [
                                      Center(
                                        child: ConstrainedBox(
                                          constraints: const BoxConstraints(maxWidth: 560),
                                          child: Column(
                                            children: _posts
                                                .map((p) => Padding(
                                                      padding: const EdgeInsets.only(bottom: 12),
                                                      child: _PostTile(
                                                        post: p,
                                                        onTap: () => Navigator.of(context).push(
                                                          MaterialPageRoute(
                                                            builder: (_) => BlogPostScreen(
                                                              authStore: widget.authStore,
                                                              postId: p.id,
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    ))
                                                .toList(),
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

class _PostTile extends StatelessWidget {
  final BlogPostSummary post;
  final VoidCallback onTap;
  const _PostTile({required this.post, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: GlassPanel(
          opacity: 0.08,
          borderRadius: BorderRadius.circular(18),
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      post.title,
                      style: TextStyle(color: context.onSurface, fontSize: 15.5, fontWeight: FontWeight.w600),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      post.publishedAt != null ? DateFormat.yMMMd().format(post.publishedAt!) : '',
                      style: TextStyle(color: context.onSurfaceFaded(0.4), fontSize: 12),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Icon(Icons.favorite_rounded, size: 13, color: context.onSurfaceFaded(0.35)),
                        const SizedBox(width: 4),
                        Text('${post.likeCount}', style: TextStyle(color: context.onSurfaceFaded(0.4), fontSize: 11.5)),
                        const SizedBox(width: 12),
                        Icon(Icons.chat_bubble_rounded, size: 12, color: context.onSurfaceFaded(0.35)),
                        const SizedBox(width: 4),
                        Text('${post.commentCount}', style: TextStyle(color: context.onSurfaceFaded(0.4), fontSize: 11.5)),
                      ],
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right_rounded, color: context.onSurfaceFaded(0.3)),
            ],
          ),
        ),
      ),
    );
  }
}
