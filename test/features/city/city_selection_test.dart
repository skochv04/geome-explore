import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:geome_explore/features/city/data/city.dart';
import 'package:geome_explore/features/city/data/city_selection.dart';

void main() {
  const krakow = City(id: 1, name: 'Krakow', country: 'Poland');
  const warsaw = City(id: 2, name: 'Warsaw', country: 'Poland');

  setUp(() => SharedPreferences.setMockInitialValues({}));

  test(
    'first launch requires a city and selection survives a new controller',
    () async {
      final selection = CitySelection(loadCities: () async => [krakow, warsaw]);
      await selection.restore();
      expect(selection.selectedCity, isNull);
      await selection.select(warsaw);
      expect(selection.selectedCity?.id, warsaw.id);
      selection.dispose();

      final restored = CitySelection(loadCities: () async => [krakow, warsaw]);
      await restored.restore();
      expect(restored.selectedCity?.id, warsaw.id);
      expect(restored.hasError, isFalse);
      restored.dispose();
    },
  );

  test('an unavailable stored city returns to selection', () async {
    SharedPreferences.setMockInitialValues({'selected_city_id': 99});
    final selection = CitySelection(loadCities: () async => [krakow]);
    await selection.restore();
    expect(selection.selectedCity, isNull);
    expect(
      (await SharedPreferences.getInstance()).getInt('selected_city_id'),
      isNull,
    );
    selection.dispose();
  });

  test('failed city loading can be retried', () async {
    var fail = true;
    final selection = CitySelection(
      loadCities: () async {
        if (fail) throw StateError('Offline');
        return [krakow];
      },
    );
    await selection.restore();
    expect(selection.hasError, isTrue);
    expect(selection.isLoading, isFalse);
    fail = false;
    await selection.restore();
    expect(selection.hasError, isFalse);
    expect(selection.cities, [krakow]);
    selection.dispose();
  });
}
