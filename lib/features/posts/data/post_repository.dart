import 'package:supabase_flutter/supabase_flutter.dart';

import '../../city/data/city.dart';
import '../../explore/data/city_catalog.dart';
import 'post_details.dart';

class PostRepository {
  PostRepository({this.client});

  static final PostRepository instance = PostRepository();
  final SupabaseClient? client;

  SupabaseClient get _db => client ?? Supabase.instance.client;

  Future<List<Map<String, dynamic>>> _readRows(
    Future<List<Map<String, dynamic>>> Function(int offset) fetch,
  ) async {
    final rows = <Map<String, dynamic>>[];
    while (true) {
      final page = await fetch(rows.length);
      rows.addAll(page);
      if (page.isEmpty) return rows;
    }
  }

  Future<PostDetails?> getPostDetails(int postId) async {
    final row = await _db
        .from('posts')
        .select(
          'id, title, description, cover_url, duration_minutes, created_at, '
          'city:cities(id, name, country), '
          'author:profiles!posts_author_id_fkey(username)',
        )
        .eq('id', postId)
        .maybeSingle();
    if (row == null) return null;

    final results = await Future.wait([
      _readRows(
        (offset) async => await _db
            .from('post_places')
            .select('place_id, position, description, places(name, address)')
            .eq('post_id', postId)
            .order('position', ascending: true)
            .order('place_id', ascending: true)
            .range(offset, offset + 99),
      ),
      _readRows(
        (offset) async => await _db
            .from('post_categories')
            .select('category_id, categories(id, name)')
            .eq('post_id', postId)
            .order('category_id', ascending: true)
            .range(offset, offset + 99),
      ),
    ]);
    final places = results[0].map(PostPlace.fromMap).toList()
      ..sort((a, b) {
        final order = a.position.compareTo(b.position);
        return order != 0 ? order : a.placeId.compareTo(b.placeId);
      });
    return PostDetails(
      post: CityPost.fromMap(row),
      city: row['city'] == null
          ? null
          : City.fromMap(row['city'] as Map<String, dynamic>),
      authorUsername:
          (row['author'] as Map<String, dynamic>?)?['username'] as String?,
      places: places,
      categories: results[1]
          .where((entry) => entry['categories'] != null)
          .map(
            (entry) => PostCategory.fromMap(
              entry['categories'] as Map<String, dynamic>,
            ),
          )
          .toList(),
    );
  }
}
