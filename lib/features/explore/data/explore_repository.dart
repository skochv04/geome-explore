import 'package:supabase_flutter/supabase_flutter.dart';

import 'city_catalog.dart';
import 'explore_filter.dart';

class ExploreRepository {
  ExploreRepository({this.client});

  static final ExploreRepository instance = ExploreRepository();
  static const pageSize = 20;
  final SupabaseClient? client;

  SupabaseClient get _db => client ?? Supabase.instance.client;

  String _pattern(String query) =>
      '%${query.trim().replaceAll('\\', '\\\\').replaceAll('%', '\\%').replaceAll('_', '\\_')}%';

  String _quoted(String value) =>
      '"${value.replaceAll('\\', '\\\\').replaceAll('"', '\\"')}"';

  Future<CatalogPage<CityPost>> getPosts(
    int cityId, {
    ExploreFilter filter = const ExploreFilter(),
    int offset = 0,
  }) async {
    if (filter.sort == PostSort.mostSaved) {
      throw UnsupportedError('Server-side popularity ranking is unavailable.');
    }
    final search = filter.query.trim();
    var query = _db
        .from('posts')
        .select(
          'id, title, description, cover_url, duration_minutes, created_at'
          '${filter.categoryId == null ? '' : ', matching_categories:post_categories!inner()'}'
          '${search.isEmpty ? '' : ', matching_places:post_places(places!inner())'}',
        )
        .eq('city_id', cityId);
    if (filter.maxDuration != null) {
      query = query.lte('duration_minutes', filter.maxDuration!);
    }
    if (filter.categoryId != null) {
      query = query.eq('matching_categories.category_id', filter.categoryId!);
    }
    if (search.isNotEmpty) {
      final pattern = _pattern(search);
      final literal = _quoted(pattern);
      query = query
          .ilike('matching_places.places.name', pattern)
          .or(
            'title.ilike.$literal,description.ilike.$literal,matching_places.not.is.null',
          );
    }
    final rows = await query
        .order(
          filter.sort == PostSort.shortest ? 'duration_minutes' : 'created_at',
          ascending: filter.sort == PostSort.shortest,
        )
        .order('id', ascending: false)
        .range(offset, offset + pageSize);
    return CatalogPage.fromRows(rows, CityPost.fromMap, pageSize);
  }

  Future<CatalogPage<PostCategory>> getCategories({int offset = 0}) async {
    final rows = await _db
        .from('categories')
        .select('id, name')
        .order('name', ascending: true)
        .order('id', ascending: true)
        .range(offset, offset + pageSize);
    return CatalogPage.fromRows(rows, PostCategory.fromMap, pageSize);
  }

  Future<CatalogPage<CityPlace>> getPlaces(
    int cityId, {
    required String search,
    int offset = 0,
  }) async {
    if (search.trim().isEmpty) {
      return const CatalogPage(items: [], hasMore: false);
    }
    final literal = _quoted(_pattern(search));
    final rows = await _db
        .from('places')
        .select('id, name, address')
        .eq('city_id', cityId)
        .or('name.ilike.$literal,address.ilike.$literal')
        .order('name', ascending: true)
        .order('id', ascending: true)
        .range(offset, offset + pageSize);
    return CatalogPage.fromRows(rows, CityPlace.fromMap, pageSize);
  }
}
