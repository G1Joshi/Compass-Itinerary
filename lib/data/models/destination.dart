/// Immutable Destination Domain Model.
class Destination {
  const Destination({
    required this.id,
    required this.name,
    required this.location,
    required this.country,
    required this.category,
    required this.rating,
    required this.reviewsCount,
    required this.pricePerNight,
    required this.imageUrl,
    required this.description,
    required this.highlights,
    this.isFavorite = false,
  });

  final String id;
  final String name;
  final String location;
  final String country;
  final String category; // 'Beach', 'Mountain', 'Cultural', 'Adventure', 'City'
  final double rating;
  final int reviewsCount;
  final double pricePerNight;
  final String imageUrl;
  final String description;
  final List<String> highlights;
  final bool isFavorite;

  Destination copyWith({
    String? id,
    String? name,
    String? location,
    String? country,
    String? category,
    double? rating,
    int? reviewsCount,
    double? pricePerNight,
    String? imageUrl,
    String? description,
    List<String>? highlights,
    bool? isFavorite,
  }) {
    return Destination(
      id: id ?? this.id,
      name: name ?? this.name,
      location: location ?? this.location,
      country: country ?? this.country,
      category: category ?? this.category,
      rating: rating ?? this.rating,
      reviewsCount: reviewsCount ?? this.reviewsCount,
      pricePerNight: pricePerNight ?? this.pricePerNight,
      imageUrl: imageUrl ?? this.imageUrl,
      description: description ?? this.description,
      highlights: highlights ?? this.highlights,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }

  factory Destination.fromJson(Map<String, dynamic> json) {
    return Destination(
      id: json['id'] as String,
      name: json['name'] as String,
      location: json['location'] as String,
      country: json['country'] as String,
      category: json['category'] as String,
      rating: (json['rating'] as num).toDouble(),
      reviewsCount: json['reviewsCount'] as int,
      pricePerNight: (json['pricePerNight'] as num).toDouble(),
      imageUrl: json['imageUrl'] as String,
      description: json['description'] as String,
      highlights: List<String>.from(json['highlights'] as List),
      isFavorite: json['isFavorite'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'location': location,
    'country': country,
    'category': category,
    'rating': rating,
    'reviewsCount': reviewsCount,
    'pricePerNight': pricePerNight,
    'imageUrl': imageUrl,
    'description': description,
    'highlights': highlights,
    'isFavorite': isFavorite,
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Destination &&
          other.id == id &&
          other.isFavorite == isFavorite);

  @override
  int get hashCode => Object.hash(id, isFavorite);
}
