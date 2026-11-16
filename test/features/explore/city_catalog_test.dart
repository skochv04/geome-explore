import 'package:flutter_test/flutter_test.dart';

import 'package:geome_explore/features/explore/data/city_catalog.dart';
import 'package:geome_explore/features/explore/data/explore_filter.dart';

void main() {
  CityPost post(int id, int duration, int saves, List<int> categories) =>
      CityPost(
        id: id,
        title: 'Collection $id',
        durationMinutes: duration,
        createdAt: DateTime(2026, 1, id),
        categoryIds: categories,
        placeNames: ['Castle'],
        visibleSaveCount: saves,
      );

  final catalog = CityCatalog(
    posts: [
      post(1, 120, 2, [1]),
      post(2, 300, 8, [2]),
      post(3, 90, 4, [1]),
    ],
    categories: [],
    places: [],
  );

  test('search, duration and category filters combine', () {
    final result = catalog.filteredPosts(
      const ExploreFilter(
        query: ' CASTLE ',
        maxDuration: 120,
        categoryId: 1,
        sort: PostSort.shortest,
      ),
    );
    expect(result.map((post) => post.id), [3, 1]);
    expect(
      catalog.filteredPosts(const ExploreFilter(query: 'missing')),
      isEmpty,
    );
  });

  test('sorting uses visible saves or creation time', () {
    expect(
      catalog
          .filteredPosts(const ExploreFilter(sort: PostSort.mostSaved))
          .map((post) => post.id),
      [2, 3, 1],
    );
    expect(
      catalog.filteredPosts(const ExploreFilter()).map((post) => post.id),
      [3, 2, 1],
    );
  });
  test(
    'unavailable save counts remain unknown and sorting falls back to newest',
    () {
      final post = CityPost.fromMap({
        'id': 4,
        'title': 'Collection',
        'description': null,
        'cover_url': null,
        'duration_minutes': 60,
        'created_at': '2026-01-04T00:00:00Z',
        'post_categories': [
          {'category_id': 1},
        ],
        'post_places': [
          {'places': null},
          {
            'places': {'name': 'Castle'},
          },
        ],
      });
      expect(post.visibleSaveCount, isNull);
      expect(post.placeNames, ['Castle']);
      expect(post.categoryIds, [1]);
      final unavailable = CityCatalog(
        posts: catalog.posts,
        categories: [],
        places: [],
        canRankBySaves: false,
      );
      expect(
        unavailable
            .filteredPosts(const ExploreFilter(sort: PostSort.mostSaved))
            .map((post) => post.id),
        [3, 2, 1],
      );
    },
  );
}
