class City {
  const City({required this.id, required this.name, required this.country});

  final int id;
  final String name;
  final String country;

  factory City.fromMap(Map<String, dynamic> map) {
    return City(
      id: map['id'] as int,
      name: map['name'] as String,
      country: map['country'] as String,
    );
  }
}
