import 'package:flutter/material.dart';

import '../../../shared/widgets/app_text_field.dart';
import '../../city/data/city.dart';
import '../data/city_catalog.dart';
import '../data/explore_filter.dart';
import '../widgets/city_catalog_view.dart';
import '../widgets/post_card.dart';

class ExploreScreen extends StatefulWidget {
  const ExploreScreen({
    super.key,
    required this.city,
    required this.initialFilter,
    required this.onFilterChanged,
  });

  final City city;
  final ExploreFilter initialFilter;
  final ValueChanged<ExploreFilter> onFilterChanged;

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  late final _search = TextEditingController(text: widget.initialFilter.query);
  late ExploreFilter _filter = widget.initialFilter;

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  void _update(ExploreFilter filter) {
    setState(() => _filter = filter);
    widget.onFilterChanged(filter);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: CityCatalogView(
        cityId: widget.city.id,
        builder: (context, catalog) {
          final posts = catalog.filteredPosts(_filter);
          final query = _filter.query.trim();
          final places = query.isEmpty
              ? <CityPlace>[]
              : catalog.places.where((place) => place.matches(query)).toList();
          return ListView(
            padding: const EdgeInsets.all(24),
            children: [
              Text(
                'Explore ${widget.city.name}',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 16),
              AppTextField(
                controller: _search,
                label: 'Search posts and places',
                textInputAction: TextInputAction.search,
                onSubmitted: (_) => _applySearch(),
              ),
              TextButton(onPressed: _applySearch, child: const Text('Search')),
              DropdownButtonFormField<int>(
                style: Theme.of(context).textTheme.bodyMedium,
                initialValue: _filter.maxDuration ?? 0,
                decoration: const InputDecoration(
                  labelText: 'Maximum duration',
                ),
                items: [
                  DropdownMenuItem(value: 0, child: Text('Any duration')),
                  DropdownMenuItem(value: 120, child: Text('2 hours')),
                  DropdownMenuItem(value: 300, child: Text('5 hours')),
                  DropdownMenuItem(value: 1440, child: Text('Full day')),
                ],
                onChanged: (value) => _update(
                  ExploreFilter(
                    query: _filter.query,
                    maxDuration: value == 0 ? null : value,
                    categoryId: _filter.categoryId,
                    sort: _filter.sort,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<int>(
                style: Theme.of(context).textTheme.bodyMedium,
                initialValue: _filter.categoryId ?? 0,
                isExpanded: true,
                decoration: const InputDecoration(labelText: 'Category'),
                items: [
                  const DropdownMenuItem(
                    value: 0,
                    child: Text('All categories'),
                  ),
                  for (final category in catalog.categories)
                    DropdownMenuItem(
                      value: category.id,
                      child: Text(category.name),
                    ),
                ],
                onChanged: (value) => _update(
                  ExploreFilter(
                    query: _filter.query,
                    maxDuration: _filter.maxDuration,
                    categoryId: value == 0 ? null : value,
                    sort: _filter.sort,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<PostSort>(
                style: Theme.of(context).textTheme.bodyMedium,
                initialValue: _filter.sort,
                decoration: const InputDecoration(labelText: 'Sort by'),
                items: [
                  DropdownMenuItem(
                    value: PostSort.newest,
                    child: Text('Newest'),
                  ),
                  DropdownMenuItem(
                    enabled: catalog.canRankBySaves,
                    value: PostSort.mostSaved,
                    child: Text('Most saved (visible saves)'),
                  ),
                  DropdownMenuItem(
                    value: PostSort.shortest,
                    child: Text('Shortest duration'),
                  ),
                ],
                onChanged: (value) {
                  if (value == null) return;
                  _update(
                    ExploreFilter(
                      query: _filter.query,
                      maxDuration: _filter.maxDuration,
                      categoryId: _filter.categoryId,
                      sort: value,
                    ),
                  );
                },
              ),
              if (_filter.sort == PostSort.mostSaved) ...[
                const SizedBox(height: 12),
                Text(
                  catalog.canRankBySaves
                      ? 'Order uses saves visible to your account. Overall popularity may be unavailable.'
                      : 'Popularity is unavailable. Collections are ordered by newest.',
                ),
              ],
              const SizedBox(height: 24),
              Text(
                'Collections',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 12),
              if (posts.isEmpty)
                const Text('No collections match these filters.')
              else
                for (final post in posts) PostCard(post: post),
              if (query.isNotEmpty) ...[
                const SizedBox(height: 24),
                Text(
                  'Places',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const Text(
                  'Place results match your search; duration and category apply to collections.',
                ),
                if (places.isEmpty)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    child: Text('No places match your search.'),
                  )
                else
                  for (final place in places)
                    ListTile(
                      leading: const Icon(Icons.place_outlined),
                      titleTextStyle: Theme.of(context).textTheme.bodyMedium,
                      subtitleTextStyle: Theme.of(context).textTheme.bodySmall,
                      title: Text(place.name),
                      subtitle: place.address == null
                          ? null
                          : Text(place.address!),
                    ),
              ],
            ],
          );
        },
      ),
    );
  }

  void _applySearch() => _update(
    ExploreFilter(
      query: _search.text.trim(),
      maxDuration: _filter.maxDuration,
      categoryId: _filter.categoryId,
      sort: _filter.sort,
    ),
  );
}
