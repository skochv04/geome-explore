import 'explore_filter.dart';

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
      categoryIds: (map['post_categories'] as List<dynamic>)
          .map((row) => row['category_id'] as int)
          .toList(),
      placeNames: (map['post_places'] as List<dynamic>)
          .where((row) => row['places'] != null)
          .map((row) => row['places']['name'] as String)
          .toList(),
      visibleSaveCount: visibleSaveCount,
    );
  }
}

class CityCatalog {
  const CityCatalog({
    required this.posts,
    required this.categories,
    required this.places,
    this.canRankBySaves = true,
  });

  final List<CityPost> posts;
  final List<PostCategory> categories;
  final List<CityPlace> places;
  final bool canRankBySaves;

  List<CityPost> filteredPosts(ExploreFilter filter) {
    final query = filter.query.trim().toLowerCase();
    final result = posts.where((post) {
      return (filter.maxDuration == null ||
              post.durationMinutes <= filter.maxDuration!) &&
          (filter.categoryId == null ||
              post.categoryIds.contains(filter.categoryId)) &&
          (query.isEmpty ||
              '${post.title} ${post.description ?? ''} ${post.placeNames.join(' ')}'
                  .toLowerCase()
                  .contains(query));
    }).toList();
    result.sort((a, b) {
      final comparison = switch (filter.sort) {
        PostSort.newest => b.createdAt.compareTo(a.createdAt),
        PostSort.mostSaved =>
          canRankBySaves
              ? (b.visibleSaveCount ?? 0).compareTo(a.visibleSaveCount ?? 0)
              : b.createdAt.compareTo(a.createdAt),
        PostSort.shortest => a.durationMinutes.compareTo(b.durationMinutes),
      };
      return comparison != 0 ? comparison : b.id.compareTo(a.id);
    });
    return result;
  }
}
