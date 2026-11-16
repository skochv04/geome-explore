import 'package:flutter/material.dart';

import '../../../app/theme/app_colors.dart';
import '../../../shared/widgets/app_button.dart';
import '../data/city.dart';
import '../data/city_repository.dart';

class CityScreen extends StatefulWidget {
  const CityScreen({super.key});

  @override
  State<CityScreen> createState() => _CityScreenState();
}

class _CityScreenState extends State<CityScreen> {
  late Future<List<City>> _citiesFuture = CityRepository.instance.getCities();
  int? _selectedCityId;

  void _reload() {
    setState(() {
      _citiesFuture = CityRepository.instance.getCities();
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('City', style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 8),
            const Text('Choose a city to explore.'),
            const SizedBox(height: 24),
            Expanded(
              child: FutureBuilder<List<City>>(
                future: _citiesFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState != ConnectionState.done) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.hasError) {
                    return Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text(
                            'Could not load cities. Please try again.',
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 16),
                          AppButton(label: 'Try again', onPressed: _reload),
                        ],
                      ),
                    );
                  }

                  final cities = snapshot.data!;
                  if (cities.isEmpty) {
                    return const Center(child: Text('No cities available yet.'));
                  }

                  return ListView.separated(
                    itemCount: cities.length,
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: 8),
                    itemBuilder: (context, index) {
                      final city = cities[index];
                      final isSelected = city.id == _selectedCityId;

                      return Material(
                        color: isSelected ? AppColors.lightBlue : AppColors.white,
                        borderRadius: BorderRadius.circular(12),
                        clipBehavior: Clip.antiAlias,
                        child: ListTile(
                          title: Text(city.name),
                          subtitle: Text(city.country),
                          selected: isSelected,
                          trailing: isSelected
                              ? Icon(
                                  Icons.check_circle,
                                  color: Theme.of(context).colorScheme.primary,
                                  semanticLabel: 'Selected',
                                )
                              : const Icon(Icons.circle_outlined),
                          onTap: () {
                            setState(() {
                              _selectedCityId = city.id;
                            });
                          },
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
