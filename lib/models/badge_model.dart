class BadgeModel {
  final String id;
  final String name;
  final String description;
  final String emoji;
  final bool isEarned;
  final DateTime? earnedAt;

  const BadgeModel({
    required this.id, required this.name, required this.description,
    required this.emoji, required this.isEarned, this.earnedAt,
  });

  factory BadgeModel.fromJson(Map<String, dynamic> json) => BadgeModel(
    id: json['id']?.toString() ?? '',
    name: json['name'] ?? '',
    description: json['description'] ?? '',
    emoji: json['emoji'] ?? '🏅',
    isEarned: json['is_earned'] == true || json['is_earned'] == 1,
    earnedAt: json['earned_at'] != null ? DateTime.tryParse(json['earned_at']) : null,
  );
}
