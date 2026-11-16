import 'package:flutter/material.dart';

import '../../../shared/widgets/app_button.dart';
import '../data/city_catalog.dart';
import '../data/explore_repository.dart';

class CityCatalogView extends StatefulWidget {
  const CityCatalogView({
    super.key,
    required this.cityId,
    required this.builder,
  });

  final int cityId;
  final Widget Function(BuildContext, CityCatalog) builder;

  @override
  State<CityCatalogView> createState() => _CityCatalogViewState();
}

class _CityCatalogViewState extends State<CityCatalogView> {
  late Future<CityCatalog> _future = _load();

  Future<CityCatalog> _load() =>
      ExploreRepository.instance.getCityCatalog(widget.cityId);

  @override
  void didUpdateWidget(CityCatalogView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.cityId != widget.cityId) _future = _load();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<CityCatalog>(
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
        return widget.builder(context, snapshot.data!);
      },
    );
  }
}
