class MatchaRecipe {
  final String id;
  final String title;
  final String description;
  final List<String> ingredients;
  final List<String> steps;
  final String imageUrl;
  final int servings;
  final int prepTime;
  final String difficulty;
  final String authorId;
  final String authorName;
  final DateTime createdAt;

  const MatchaRecipe({
    required this.id,
    required this.title,
    required this.description,
    required this.ingredients,
    required this.steps,
    required this.imageUrl,
    required this.servings,
    required this.prepTime,
    required this.difficulty,
    required this.authorId,
    required this.authorName,
    required this.createdAt,
  });

  factory MatchaRecipe.fromJson(Map<String, dynamic> json) => MatchaRecipe(
    id: json['id']?.toString() ?? '',
    title: json['title'] ?? '',
    description: json['description'] ?? '',
    ingredients: List<String>.from(json['ingredients'] ?? []),
    steps: List<String>.from(json['steps'] ?? []),
    imageUrl: json['image_url'] ?? '',
    servings: json['servings'] ?? 1,
    prepTime: json['prep_time'] ?? 0,
    difficulty: json['difficulty'] ?? 'Mudah',
    authorId: json['author_id'] ?? '',
    authorName: json['author_name'] ?? '',
    createdAt: DateTime.tryParse(json['created_at'] ?? '') ?? DateTime.now(),
  );

  Map<String, dynamic> toJson() => {
    'id': id, 'title': title, 'description': description,
    'ingredients': ingredients, 'steps': steps, 'image_url': imageUrl,
    'servings': servings, 'prep_time': prepTime, 'difficulty': difficulty,
    'author_id': authorId, 'author_name': authorName,
    'created_at': createdAt.toIso8601String(),
  };

  MatchaRecipe copyWith({String? id, String? title, String? description}) =>
    MatchaRecipe(
      id: id ?? this.id, title: title ?? this.title, description: description ?? this.description,
      ingredients: ingredients, steps: steps, imageUrl: imageUrl, servings: servings,
      prepTime: prepTime, difficulty: difficulty, authorId: authorId, authorName: authorName,
      createdAt: createdAt,
    );
}
