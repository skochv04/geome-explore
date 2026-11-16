import 'package:flutter/material.dart';

import '../../../shared/widgets/app_button.dart';
import '../../explore/data/explore_filter.dart';
import '../data/city_selection.dart';
import '../widgets/city_landing.dart';
import '../widgets/city_picker.dart';

class CityScreen extends StatelessWidget {
  const CityScreen({super.key, required this.onExplore});

  final ValueChanged<ExploreFilter> onExplore;

  Future<void> _changeCity(
    BuildContext context,
    CitySelection selection,
  ) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (sheetContext) => FractionallySizedBox(
        heightFactor: 0.85,
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: CityPicker(
            cities: selection.cities,
            selectedId: selection.selectedCity?.id,
            onSelected: (city) async {
              await selection.select(city);
              if (sheetContext.mounted) Navigator.of(sheetContext).pop();
            },
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final selection = CitySelectionScope.of(context);
    if (selection.isLoading) {
      return const SafeArea(child: Center(child: CircularProgressIndicator()));
    }
    if (selection.hasError) {
      return SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Could not load cities or restore your selection.'),
                const SizedBox(height: 16),
                AppButton(label: 'Try again', onPressed: selection.restore),
              ],
            ),
          ),
        ),
      );
    }
    final city = selection.selectedCity;
    return SafeArea(
      child: city == null
          ? Padding(
              padding: const EdgeInsets.all(24),
              child: CityPicker(
                cities: selection.cities,
                onSelected: selection.select,
              ),
            )
          : CityLanding(
              key: ValueKey(city.id),
              city: city,
              onChangeCity: () => _changeCity(context, selection),
              onExplore: onExplore,
            ),
    );
  }
}
