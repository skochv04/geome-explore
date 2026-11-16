import 'package:flutter/material.dart';

import '../data/city.dart';

class CityPicker extends StatefulWidget {
  const CityPicker({
    super.key,
    required this.cities,
    required this.onSelected,
    this.selectedId,
  });

  final List<City> cities;
  final int? selectedId;
  final Future<void> Function(City) onSelected;

  @override
  State<CityPicker> createState() => _CityPickerState();
}

class _CityPickerState extends State<CityPicker> {
  bool _saving = false;

  Future<void> _select(City city) async {
    setState(() => _saving = true);
    try {
      await widget.onSelected(city);
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not save your city. Try again.')),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Choose a city', style: Theme.of(context).textTheme.headlineSmall),
        const SizedBox(height: 16),
        if (_saving) const LinearProgressIndicator(),
        Expanded(
          child: widget.cities.isEmpty
              ? const Center(child: Text('No cities available yet.'))
              : ListView.builder(
                  itemCount: widget.cities.length,
                  itemBuilder: (context, index) {
                    final city = widget.cities[index];
                    return ListTile(
                      titleTextStyle: Theme.of(context).textTheme.bodyMedium,
                      subtitleTextStyle: Theme.of(context).textTheme.bodySmall,
                      title: Text(city.name),
                      subtitle: Text(city.country),
                      selected: city.id == widget.selectedId,
                      trailing: city.id == widget.selectedId
                          ? const Icon(Icons.check_circle)
                          : null,
                      onTap: _saving ? null : () => _select(city),
                    );
                  },
                ),
        ),
      ],
    );
  }
}
