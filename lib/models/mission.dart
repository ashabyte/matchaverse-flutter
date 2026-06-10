class Mission {
  final String id;
  final String title;
  final String description;
  final String type; // daily / weekly
  final int pointsReward;
  final bool isCompleted;
  final String emoji;

  const Mission({
    required this.id, required this.title, required this.description,
    required this.type, required this.pointsReward, required this.isCompleted,
    required this.emoji,
  });

  factory Mission.fromJson(Map<String, dynamic> json) => Mission(
    id: json['id']?.toString() ?? '',
    title: json['title'] ?? '',
    description: json['description'] ?? '',
    type: json['type'] ?? 'daily',
    pointsReward: json['points_reward'] ?? 0,
    isCompleted: json['is_completed'] == true || json['is_completed'] == 1,
    emoji: json['emoji'] ?? '🎯',
  );

  Mission copyWith({bool? isCompleted}) => Mission(
    id: id, title: title, description: description, type: type,
    pointsReward: pointsReward, isCompleted: isCompleted ?? this.isCompleted, emoji: emoji,
  );
}
