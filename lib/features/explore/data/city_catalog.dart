class PostCategory {
  const PostCategory({required this.id, required this.name});

  final int id;
  final String name;

  factory PostCategory.fromMap(Map<String, dynamic> map) =>
      PostCategory(id: map['id'] as int, name: map['name'] as String);
}

class CityPlace {
  const CityPlace({required this.name, this.address});

  final String name;
  final String? address;

  factory CityPlace.fromMap(Map<String, dynamic> map) => CityPlace(
    name: map['name'] as String,
    address: map['address'] as String?,
  );

  bool matches(String query) =>
      '$name ${address ?? ''}'.toLowerCase().contains(query.toLowerCase());
}

class CityPost {
  const CityPost({
    required this.id,
    required this.title,
    required this.durationMinutes,
    required this.createdAt,
    required this.categoryIds,
    required this.placeNames,
    required this.visibleSaveCount,
    this.description,
    this.coverUrl,
  });

  final int id;
  final String title;
  final String? description;
  final String? coverUrl;
  final int durationMinutes;
  final DateTime createdAt;
  final List<int> categoryIds;
  final List<String> placeNames;
  final int? visibleSaveCount;

  factory CityPost.fromMap(Map<String, dynamic> map, {int? visibleSaveCount}) {
    return CityPost(
      id: map['id'] as int,
      title: map['title'] as String,
      description: map['description'] as String?,
      coverUrl: map['cover_url'] as String?,
      durationMinutes: map['duration_minutes'] as int,
      createdAt: DateTime.parse(map['created_at'] as String),
      categoryIds: (map['post_categories'] as List<dynamic>? ?? [])
          .map((row) => row['category_id'] as int)
          .toList(),
      placeNames: (map['post_places'] as List<dynamic>? ?? [])
          .where((row) => row['places'] != null)
          .map((row) => row['places']['name'] as String)
          .toList(),
      visibleSaveCount: visibleSaveCount,
    );
  }
}

class CatalogPage<T> {
  const CatalogPage({required this.items, required this.hasMore});

  final List<T> items;
  final bool hasMore;

  factory CatalogPage.fromRows(
    List<Map<String, dynamic>> rows,
    T Function(Map<String, dynamic>) fromMap,
    int pageSize,
  ) => CatalogPage(
    items: rows.take(pageSize).map(fromMap).toList(),
    hasMore: rows.length > pageSize,
  );
}

class CityCatalog {
  const CityCatalog({
    required this.posts,
    required this.categories,
    required this.places,
  });

  final List<CityPost> posts;
  final List<PostCategory> categories;
  final List<CityPlace> places;
}
