class City {
  const City({
    required this.id,
    required this.name,
    required this.country,
    this.description,
    this.imageUrl,
  });

  final int id;
  final String name;
  final String country;
  final String? description;
  final String? imageUrl;

  factory City.fromMap(Map<String, dynamic> map) {
    return City(
      id: map['id'] as int,
      name: map['name'] as String,
      country: map['country'] as String,
      description: map['description'] as String?,
      imageUrl: map['image_url'] as String?,
    );
  }
}
