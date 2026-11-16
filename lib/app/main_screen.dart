import 'package:flutter/material.dart';

import '../features/city/screens/city_screen.dart';
import '../features/profile/screens/profile_screen.dart';
import 'theme/app_colors.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  static const List<String> _titles = [
    'City',
    'Explore',
    'Saved',
    'Profile',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          Offstage(
            offstage: _selectedIndex != 0,
            child: const CityScreen(),
          ),
          if (_selectedIndex != 0)
            _selectedIndex == 3
                ? const ProfileScreen()
                : Center(
                    child: Text(
                      _titles[_selectedIndex],
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                  ),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) {
          setState(() {
            _selectedIndex = index;
          });
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
    );
  }
}