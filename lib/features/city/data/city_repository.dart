import 'package:supabase_flutter/supabase_flutter.dart';

import 'city.dart';

class CityRepository {
  CityRepository._();
  static final CityRepository instance = CityRepository._();

  SupabaseClient get _db => Supabase.instance.client;

  Future<List<City>> getCities() async {
    final rows = await _db
        .from('cities')
        .select('id, name, country')
        .order('name')
        .order('country');

    return rows.map(City.fromMap).toList();
  }
}
