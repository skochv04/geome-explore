import 'package:supabase_flutter/supabase_flutter.dart';

import 'city_catalog.dart';

class ExploreRepository {
  ExploreRepository._();
  static final ExploreRepository instance = ExploreRepository._();

  SupabaseClient get _db => Supabase.instance.client;

  Future<List<Map<String, dynamic>>> _readPages(
    Future<List<Map<String, dynamic>>> Function(int offset) fetch,
  ) async {
    final rows = <Map<String, dynamic>>[];
    var offset = 0;
    while (true) {
      final page = await fetch(offset);
      rows.addAll(page);
      if (page.isEmpty) return rows;
      offset += page.length;
    }
  }

  Future<CityCatalog> getCityCatalog(int cityId) async {
    final results = await Future.wait([
      _readPages(
        (offset) async => await _db
            .from('posts')
            .select(
              'id, title, description, cover_url, duration_minutes, created_at, '
              'post_categories(category_id), post_places(places(name))',
            )
            .eq('city_id', cityId)
            .order('id')
            .range(offset, offset + 499),
      ),
      _readPages(
        (offset) async => await _db
            .from('categories')
            .select('id, name')
            .order('id')
            .range(offset, offset + 499),
      ),
      _readPages(
        (offset) async => await _db
            .from('places')
            .select('id, name, address')
            .eq('city_id', cityId)
            .order('id')
            .range(offset, offset + 499),
      ),
    ]);
    Map<int, int>? saveCounts;
    try {
      final rows = await _readPages(
        (offset) async => await _db
            .from('posts')
            .select('id, saved_posts(count)')
            .eq('city_id', cityId)
            .order('id')
            .range(offset, offset + 499),
      );
      saveCounts = {
        for (final row in rows)
          row['id'] as int: (row['saved_posts'] as List).isEmpty
              ? 0
              : row['saved_posts'][0]['count'] as int,
      };
    } on Exception {
      saveCounts = null;
    }
    return CityCatalog(
      canRankBySaves: saveCounts != null,
      posts: results[0]
          .map(
            (row) =>
                CityPost.fromMap(row, visibleSaveCount: saveCounts?[row['id']]),
          )
          .toList(),
      categories: results[1].map(PostCategory.fromMap).toList(),
      places: results[2].map(CityPlace.fromMap).toList(),
    );
  }
}
