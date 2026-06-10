class CommunityPost {
  final String id;
  final String userId;
  final String userName;
  final String userPhoto;
  final String content;
  final String? imageUrl;
  final int likes;
  final int comments;
  final bool isLikedByMe;
  final List<String> tags;
  final DateTime createdAt;

  const CommunityPost({
    required this.id, required this.userId, required this.userName,
    required this.userPhoto, required this.content, this.imageUrl,
    required this.likes, required this.comments, required this.isLikedByMe,
    required this.tags, required this.createdAt,
  });

  factory CommunityPost.fromJson(Map<String, dynamic> json) => CommunityPost(
    id: json['id']?.toString() ?? '',
    userId: json['user_id'] ?? '',
    userName: json['user_name'] ?? '',
    userPhoto: json['user_photo'] ?? '',
    content: json['content'] ?? '',
    imageUrl: json['image_url'],
    likes: json['likes'] ?? 0,
    comments: json['comments'] ?? 0,
    isLikedByMe: json['is_liked_by_me'] == true,
    tags: List<String>.from(json['tags'] ?? []),
    createdAt: DateTime.tryParse(json['created_at'] ?? '') ?? DateTime.now(),
  );

  Map<String, dynamic> toJson() => {
    'user_id': userId, 'content': content, 'image_url': imageUrl, 'tags': tags,
  };

  CommunityPost copyWith({int? likes, bool? isLikedByMe}) => CommunityPost(
    id: id, userId: userId, userName: userName, userPhoto: userPhoto,
    content: content, imageUrl: imageUrl, likes: likes ?? this.likes,
    comments: comments, isLikedByMe: isLikedByMe ?? this.isLikedByMe,
    tags: tags, createdAt: createdAt,
  );
}
