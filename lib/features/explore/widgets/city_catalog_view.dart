import 'package:flutter/material.dart';

import '../../../shared/widgets/app_button.dart';
import '../data/city_catalog.dart';
import '../data/explore_filter.dart';
import '../data/explore_repository.dart';

class CityCatalogView extends StatefulWidget {
  const CityCatalogView({
    super.key,
    required this.cityId,
    required this.builder,
    this.filter = const ExploreFilter(),
    this.loadPosts = true,
  });

  final int cityId;
  final ExploreFilter filter;
  final bool loadPosts;
  final Widget Function(BuildContext, CityCatalog, Widget pagination) builder;

  @override
  State<CityCatalogView> createState() => _CityCatalogViewState();
}

class _CatalogPages {
  _CatalogPages(this.posts, this.categories, this.places);

  CatalogPage<CityPost> posts;
  CatalogPage<PostCategory> categories;
  CatalogPage<CityPlace> places;
}

class _CityCatalogViewState extends State<CityCatalogView> {
  final _repository = ExploreRepository.instance;
  late Future<_CatalogPages> _future = _load();
  int _generation = 0;
  bool _loadingMore = false;
  bool _pageError = false;

  Future<_CatalogPages> _load() async {
    final cityId = widget.cityId;
    final filter = widget.filter;
    final results = await Future.wait<Object>([
      widget.loadPosts
          ? _repository.getPosts(cityId, filter: filter)
          : Future.value(
              const CatalogPage<CityPost>(items: [], hasMore: false),
            ),
      _repository.getCategories(),
      widget.loadPosts
          ? _repository.getPlaces(cityId, search: filter.query)
          : Future.value(
              const CatalogPage<CityPlace>(items: [], hasMore: false),
            ),
    ]);
    return _CatalogPages(
      results[0] as CatalogPage<CityPost>,
      results[1] as CatalogPage<PostCategory>,
      results[2] as CatalogPage<CityPlace>,
    );
  }

  @override
  void didUpdateWidget(CityCatalogView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.cityId != widget.cityId ||
        oldWidget.filter != widget.filter ||
        oldWidget.loadPosts != widget.loadPosts) {
      _generation++;
      _loadingMore = false;
      _pageError = false;
      _future = _load();
    }
  }

  Future<void> _more(_CatalogPages pages, String section) async {
    if (_loadingMore) return;
    final generation = _generation;
    setState(() {
      _loadingMore = true;
      _pageError = false;
    });
    try {
      switch (section) {
        case 'posts':
          final next = await _repository.getPosts(
            widget.cityId,
            filter: widget.filter,
            offset: pages.posts.items.length,
          );
          if (!mounted || generation != _generation) return;
          pages.posts = CatalogPage(
            items: [...pages.posts.items, ...next.items],
            hasMore: next.hasMore,
          );
        case 'places':
          final next = await _repository.getPlaces(
            widget.cityId,
            search: widget.filter.query,
            offset: pages.places.items.length,
          );
          if (!mounted || generation != _generation) return;
          pages.places = CatalogPage(
            items: [...pages.places.items, ...next.items],
            hasMore: next.hasMore,
          );
        case 'categories':
          final next = await _repository.getCategories(
            offset: pages.categories.items.length,
          );
          if (!mounted || generation != _generation) return;
          pages.categories = CatalogPage(
            items: [...pages.categories.items, ...next.items],
            hasMore: next.hasMore,
          );
      }
    } catch (_) {
      if (!mounted || generation != _generation) return;
      _pageError = true;
    }
    if (!mounted || generation != _generation) return;
    setState(() => _loadingMore = false);
  }

  Widget _pagination(_CatalogPages pages) => Column(
    children: [
      if (_loadingMore)
        const Padding(
          padding: EdgeInsets.all(16),
          child: CircularProgressIndicator(),
        ),
      if (_pageError)
        const Text('Could not load more results. Please try again.'),
      for (final section in [
        if (pages.posts.hasMore) (key: 'posts', label: 'Load more collections'),
        if (pages.places.hasMore) (key: 'places', label: 'Load more places'),
        if (pages.categories.hasMore)
          (key: 'categories', label: 'Load more categories'),
      ])
        TextButton(
          onPressed: _loadingMore ? null : () => _more(pages, section.key),
          child: Text(section.label),
        ),
    ],
  );

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<_CatalogPages>(
      future: _future,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(24),
              child: CircularProgressIndicator(),
            ),
          );
        }
        if (snapshot.hasError) {
          return Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Could not load city content. Please try again.'),
                const SizedBox(height: 16),
                AppButton(
                  label: 'Try again',
                  onPressed: () => setState(() => _future = _load()),
                ),
              ],
            ),
          );
        }
        final pages = snapshot.data!;
        return widget.builder(
          context,
          CityCatalog(
            posts: pages.posts.items,
            categories: pages.categories.items,
            places: pages.places.items,
          ),
          _pagination(pages),
        );
      },
    );
  }
}
