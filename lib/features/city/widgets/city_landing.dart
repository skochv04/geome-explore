import 'package:flutter/material.dart';

import '../../../shared/widgets/app_text_field.dart';
import '../../../shared/widgets/cover_image.dart';
import '../../explore/data/explore_filter.dart';
import '../../explore/widgets/city_catalog_view.dart';

import '../data/city.dart';

class CityLanding extends StatefulWidget {
  const CityLanding({
    super.key,
    required this.city,
    required this.onChangeCity,
    required this.onExplore,
  });

  final City city;
  final VoidCallback onChangeCity;
  final ValueChanged<ExploreFilter> onExplore;

  @override
  State<CityLanding> createState() => _CityLandingState();
}

class _CityLandingState extends State<CityLanding> {
  final _search = TextEditingController();

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  Widget _heading(String title) => Padding(
    padding: const EdgeInsets.only(top: 24, bottom: 12),
    child: Text(title, style: Theme.of(context).textTheme.headlineSmall),
  );

  @override
  Widget build(BuildContext context) {
    final city = widget.city;
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                city.name,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
            ),
            TextButton(
              onPressed: widget.onChangeCity,
              child: const Text('Change city'),
            ),
          ],
        ),
        Text(city.country),
        const SizedBox(height: 16),
        CoverImage(url: city.imageUrl, height: 220),
        const SizedBox(height: 16),
        Text(
          city.description?.trim().isNotEmpty ?? false
              ? city.description!
              : 'A description for this city is not available yet.',
        ),
        _heading('Search'),
        AppTextField(
          controller: _search,
          label: 'Search posts and places',
          textInputAction: TextInputAction.search,
          onSubmitted: (value) =>
              widget.onExplore(ExploreFilter(query: value.trim())),
        ),
        Align(
          alignment: Alignment.centerRight,
          child: TextButton.icon(
            onPressed: () =>
                widget.onExplore(ExploreFilter(query: _search.text.trim())),
            icon: const Icon(Icons.search),
            label: const Text('Search'),
          ),
        ),
        _heading('Time to explore'),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final option in const [
              (label: '2 hours', minutes: 120),
              (label: '5 hours', minutes: 300),
              (label: 'Full day', minutes: 1440),
            ])
              ActionChip(
                label: Text(option.label),
                onPressed: () => widget.onExplore(
                  ExploreFilter(maxDuration: option.minutes),
                ),
              ),
          ],
        ),
        const SizedBox(height: 8),
        const Text('Find collections within your available time.'),
        CityCatalogView(
          cityId: city.id,
          loadPosts: false,
          builder: (context, catalog, pagination) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _heading('Popular collections'),
                const Text(
                  'Popularity is currently unavailable. Use See all to browse collections.',
                ),
                _heading('Categories'),
                if (catalog.categories.isEmpty)
                  const Text('No categories available yet.')
                else
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      for (final category in catalog.categories)
                        ActionChip(
                          label: Text(category.name),
                          onPressed: () => widget.onExplore(
                            ExploreFilter(categoryId: category.id),
                          ),
                        ),
                    ],
                  ),
                pagination,
              ],
            );
          },
        ),
        const SizedBox(height: 24),
        OutlinedButton(
          onPressed: () => widget.onExplore(const ExploreFilter()),
          child: const Text('See all collections'),
        ),
      ],
    );
  }
}
