import 'package:flutter/material.dart';

import '../features/city/data/city_selection.dart';
import '../features/city/screens/city_screen.dart';
import '../features/explore/data/explore_filter.dart';
import '../features/explore/screens/explore_screen.dart';
import '../features/profile/screens/profile_screen.dart';
import 'theme/app_colors.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  final _citySelection = CitySelection();
  int _selectedIndex = 0;
  ExploreFilter _exploreFilter = const ExploreFilter();
  int _exploreRevision = 0;
  int? _filterCityId;

  @override
  void initState() {
    super.initState();
    _citySelection.addListener(_onCityChanged);
    _citySelection.restore();
  }

  void _onCityChanged() {
    final cityId = _citySelection.selectedCity?.id;
    if (_filterCityId != cityId) {
      _filterCityId = cityId;
      _exploreFilter = const ExploreFilter();
      _exploreRevision++;
    }
    setState(() {});
  }

  @override
  void dispose() {
    _citySelection.removeListener(_onCityChanged);
    _citySelection.dispose();
    super.dispose();
  }

  void _openExplore(ExploreFilter filter) {
    setState(() {
      _exploreFilter = filter;
      _exploreRevision++;
      _selectedIndex = 1;
    });
  }

  Widget _explore() {
    if (_citySelection.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    final city = _citySelection.selectedCity;
    if (city == null) {
      return Center(
        child: TextButton(
          onPressed: () => setState(() => _selectedIndex = 0),
          child: const Text('Choose a city in the City tab'),
        ),
      );
    }
    return ExploreScreen(
      key: ValueKey('${city.id}-$_exploreRevision'),
      city: city,
      initialFilter: _exploreFilter,
      onFilterChanged: (filter) => _exploreFilter = filter,
    );
  }

  @override
  Widget build(BuildContext context) {
    return CitySelectionScope(
      selection: _citySelection,
      child: Scaffold(
        body: Stack(
          fit: StackFit.expand,
          children: [
            Offstage(
              offstage: _selectedIndex != 0,
              child: CityScreen(onExplore: _openExplore),
            ),
            if (_selectedIndex == 1) _explore(),
            if (_selectedIndex == 2)
              Center(
                child: Text(
                  'Saved',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
              ),
            if (_selectedIndex == 3) const ProfileScreen(),
          ],
        ),
        bottomNavigationBar: NavigationBar(
          selectedIndex: _selectedIndex,
          onDestinationSelected: (index) {
            setState(() => _selectedIndex = index);
          },
          backgroundColor: AppColors.white,
          indicatorColor: AppColors.lightBlue,
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.location_city_outlined),
              selectedIcon: Icon(Icons.location_city),
              label: 'City',
            ),
            NavigationDestination(
              icon: Icon(Icons.explore_outlined),
              selectedIcon: Icon(Icons.explore),
              label: 'Explore',
            ),
            NavigationDestination(
              icon: Icon(Icons.bookmark_border),
              selectedIcon: Icon(Icons.bookmark),
              label: 'Saved',
            ),
            NavigationDestination(
              icon: Icon(Icons.person_outline),
              selectedIcon: Icon(Icons.person),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }
}
