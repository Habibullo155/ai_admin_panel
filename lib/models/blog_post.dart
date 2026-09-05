class BlogPostSummary {
  final int id;
  final String title;
  final bool isPublished;
  final DateTime createdAt;
  final DateTime? publishedAt;
  final bool hasCoverImage;
  final int likeCount;
  final int commentCount;

  BlogPostSummary({
    required this.id,
    required this.title,
    required this.isPublished,
    required this.createdAt,
    required this.publishedAt,
    required this.hasCoverImage,
    this.likeCount = 0,
    this.commentCount = 0,
  });

  factory BlogPostSummary.fromJson(Map<String, dynamic> json) {
    return BlogPostSummary(
      id: json['id'] as int,
      title: json['title'] as String? ?? '',
      isPublished: json['is_published'] as bool? ?? false,
      createdAt: DateTime.tryParse(json['created_at'] as String? ?? '') ?? DateTime.now(),
      publishedAt: json['published_at'] != null ? DateTime.tryParse(json['published_at'] as String) : null,
      hasCoverImage: json['has_cover_image'] as bool? ?? false,
      likeCount: json['like_count'] as int? ?? 0,
      commentCount: json['comment_count'] as int? ?? 0,
    );
  }
}

class BlogPost {
  final int id;
  final int authorId;
  final String? authorEmail;
  final String title;
  final String content;
  final String? coverImageBase64;
  final bool isPublished;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? publishedAt;
  final int likeCount;
  final bool likedByMe;
  final int commentCount;

  BlogPost({
    required this.id,
    required this.authorId,
    required this.authorEmail,
    required this.title,
    required this.content,
    required this.coverImageBase64,
    required this.isPublished,
    required this.createdAt,
    required this.updatedAt,
    required this.publishedAt,
    this.likeCount = 0,
    this.likedByMe = false,
    this.commentCount = 0,
  });

  factory BlogPost.fromJson(Map<String, dynamic> json) {
    return BlogPost(
      id: json['id'] as int,
      authorId: json['author_id'] as int,
      authorEmail: json['author_email'] as String?,
      title: json['title'] as String? ?? '',
      content: json['content'] as String? ?? '',
      coverImageBase64: json['cover_image_base64'] as String?,
      isPublished: json['is_published'] as bool? ?? false,
      createdAt: DateTime.tryParse(json['created_at'] as String? ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(json['updated_at'] as String? ?? '') ?? DateTime.now(),
      publishedAt: json['published_at'] != null ? DateTime.tryParse(json['published_at'] as String) : null,
      likeCount: json['like_count'] as int? ?? 0,
      likedByMe: json['liked_by_me'] as bool? ?? false,
      commentCount: json['comment_count'] as int? ?? 0,
    );
  }
}

class BlogComment {
  final int id;
  final int postId;
  final int authorId;
  final String? authorEmail;
  final String content;
  final DateTime createdAt;

  BlogComment({
    required this.id,
    required this.postId,
    required this.authorId,
    required this.authorEmail,
    required this.content,
    required this.createdAt,
  });

  factory BlogComment.fromJson(Map<String, dynamic> json) {
    return BlogComment(
      id: json['id'] as int,
      postId: json['post_id'] as int,
      authorId: json['author_id'] as int,
      authorEmail: json['author_email'] as String?,
      content: json['content'] as String? ?? '',
      createdAt: DateTime.tryParse(json['created_at'] as String? ?? '') ?? DateTime.now(),
    );
  }
}
