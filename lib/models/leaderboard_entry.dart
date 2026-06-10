class LeaderboardEntry {
  final String userId;
  final String userName;
  final String photoUrl;
  final int points;
  final int rank;

  const LeaderboardEntry({
    required this.userId, required this.userName, required this.photoUrl,
    required this.points, required this.rank,
  });

  factory LeaderboardEntry.fromJson(Map<String, dynamic> json) => LeaderboardEntry(
    userId: json['user_id'] ?? '',
    userName: json['user_name'] ?? '',
    photoUrl: json['photo_url'] ?? '',
    points: json['points'] ?? 0,
    rank: json['rank'] ?? 0,
  );
}
