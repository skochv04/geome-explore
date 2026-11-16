import 'package:supabase_flutter/supabase_flutter.dart';

import 'city.dart';

class CityRepository {
  CityRepository._();
  static final CityRepository instance = CityRepository._();

  SupabaseClient get _db => Supabase.instance.client;

  Future<List<City>> getCities() async {
    final cities = <City>[];
    var offset = 0;
    while (true) {
      final rows = await _db
          .from('cities')
          .select('id, name, country, description, image_url')
          .order('name')
          .order('country')
          .order('id')
          .range(offset, offset + 499);
      if (rows.isEmpty) return cities;
      cities.addAll(rows.map(City.fromMap));
      offset += rows.length;
    }
  }
}
