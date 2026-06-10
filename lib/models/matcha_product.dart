class MatchaProduct {
  final String id;
  final String name;
  final String description;
  final String category;
  final double price;
  final String imageUrl;
  final double rating;
  final String origin;
  final String grade;

  const MatchaProduct({
    required this.id,
    required this.name,
    required this.description,
    required this.category,
    required this.price,
    required this.imageUrl,
    required this.rating,
    required this.origin,
    required this.grade,
  });

  factory MatchaProduct.fromJson(Map<String, dynamic> json) => MatchaProduct(
    id: json['id']?.toString() ?? '',
    name: json['name'] ?? '',
    description: json['description'] ?? '',
    category: json['category'] ?? '',
    price: double.tryParse(json['price']?.toString() ?? '0') ?? 0,
    imageUrl: json['image_url'] ?? '',
    rating: double.tryParse(json['rating']?.toString() ?? '0') ?? 0,
    origin: json['origin'] ?? '',
    grade: json['grade'] ?? '',
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'description': description,
    'category': category,
    'price': price,
    'image_url': imageUrl,
    'rating': rating,
    'origin': origin,
    'grade': grade,
  };

  MatchaProduct copyWith({
    String? id, String? name, String? description, String? category,
    double? price, String? imageUrl, double? rating, String? origin, String? grade,
  }) => MatchaProduct(
    id: id ?? this.id, name: name ?? this.name, description: description ?? this.description,
    category: category ?? this.category, price: price ?? this.price,
    imageUrl: imageUrl ?? this.imageUrl, rating: rating ?? this.rating,
    origin: origin ?? this.origin, grade: grade ?? this.grade,
  );
}
