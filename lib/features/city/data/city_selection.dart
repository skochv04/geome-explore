import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'city.dart';
import 'city_repository.dart';

class CitySelection extends ChangeNotifier {
  CitySelection({Future<List<City>> Function()? loadCities})
    : _loadCities = loadCities ?? CityRepository.instance.getCities;

  final Future<List<City>> Function() _loadCities;
  bool _disposed = false;
  static const _storageKey = 'selected_city_id';

  List<City> cities = [];
  City? selectedCity;
  bool isLoading = true;
  bool hasError = false;

  Future<void> restore() async {
    isLoading = true;
    hasError = false;
    notifyListeners();
    try {
      final preferences = await SharedPreferences.getInstance();
      final storedId = preferences.getInt(_storageKey);
      final loadedCities = await _loadCities();
      if (_disposed) return;
      cities = loadedCities;
      selectedCity = null;
      for (final city in cities) {
        if (city.id == storedId) selectedCity = city;
      }
      if (storedId != null && selectedCity == null) {
        await preferences.remove(_storageKey);
      }
    } catch (_) {
      hasError = true;
    }
    if (_disposed) return;
    isLoading = false;
    notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }

  Future<void> select(City city) async {
    final preferences = await SharedPreferences.getInstance();
    final saved = await preferences.setInt(_storageKey, city.id);
    if (!saved) throw StateError('Could not save city selection.');
    if (_disposed) return;
    selectedCity = city;
    notifyListeners();
  }
}

class CitySelectionScope extends InheritedNotifier<CitySelection> {
  const CitySelectionScope({
    super.key,
    required CitySelection selection,
    required super.child,
  }) : super(notifier: selection);

  static CitySelection of(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<CitySelectionScope>()!
        .notifier!;
  }
}
