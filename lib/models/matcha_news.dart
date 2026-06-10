class MatchaNews {
  final String id;
  final String title;
  final String summary;
  final String content;
  final String imageUrl;
  final String source;
  final DateTime publishedAt;

  const MatchaNews({
    required this.id, required this.title, required this.summary,
    required this.content, required this.imageUrl, required this.source,
    required this.publishedAt,
  });

  factory MatchaNews.fromJson(Map<String, dynamic> json) => MatchaNews(
    id: json['id']?.toString() ?? '',
    title: json['title'] ?? '',
    summary: json['summary'] ?? '',
    content: json['content'] ?? '',
    imageUrl: json['image_url'] ?? '',
    source: json['source'] ?? '',
    publishedAt: DateTime.tryParse(json['published_at'] ?? '') ?? DateTime.now(),
  );
}
