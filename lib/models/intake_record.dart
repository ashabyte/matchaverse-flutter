class IntakeRecord {
  final String id;
  final String userId;
  final String matchaType;
  final double gramsConsumed;
  final double caffeineAmount;
  final String notes;
  final DateTime consumedAt;

  const IntakeRecord({
    required this.id, required this.userId, required this.matchaType,
    required this.gramsConsumed, required this.caffeineAmount,
    required this.notes, required this.consumedAt,
  });

  factory IntakeRecord.fromJson(Map<String, dynamic> json) => IntakeRecord(
    id: json['id']?.toString() ?? '',
    userId: json['user_id'] ?? '',
    matchaType: json['matcha_type'] ?? '',
    gramsConsumed: double.tryParse(json['grams_consumed']?.toString() ?? '0') ?? 0,
    caffeineAmount: double.tryParse(json['caffeine_amount']?.toString() ?? '0') ?? 0,
    notes: json['notes'] ?? '',
    consumedAt: DateTime.tryParse(json['consumed_at'] ?? '') ?? DateTime.now(),
  );

  Map<String, dynamic> toJson() => {
    'id': id, 'user_id': userId, 'matcha_type': matchaType,
    'grams_consumed': gramsConsumed, 'caffeine_amount': caffeineAmount,
    'notes': notes, 'consumed_at': consumedAt.toIso8601String(),
  };

  IntakeRecord copyWith({String? id, String? matchaType, double? gramsConsumed, double? caffeineAmount}) =>
    IntakeRecord(
      id: id ?? this.id, userId: userId, matchaType: matchaType ?? this.matchaType,
      gramsConsumed: gramsConsumed ?? this.gramsConsumed, caffeineAmount: caffeineAmount ?? this.caffeineAmount,
      notes: notes, consumedAt: consumedAt,
    );
}
