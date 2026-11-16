import 'package:flutter/material.dart';

import '../../../shared/widgets/cover_image.dart';
import '../data/post_details.dart';
import 'post_place_tile.dart';

class PostDetailsContent extends StatelessWidget {
  const PostDetailsContent({super.key, required this.details});

  final PostDetails details;

  @override
  Widget build(BuildContext context) {
    final post = details.post;
    final city = details.city;
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        Text(post.title, style: Theme.of(context).textTheme.headlineSmall),
        const SizedBox(height: 16),
        CoverImage(url: post.coverUrl, height: 220),
        const SizedBox(height: 16),
        Text(
          post.description?.trim().isNotEmpty ?? false
              ? post.description!
              : 'No description available.',
        ),
        const SizedBox(height: 24),
        Text(
          details.authorUsername?.trim().isNotEmpty ?? false
              ? 'By ${details.authorUsername}'
              : 'Author unavailable',
        ),
        const SizedBox(height: 8),
        Text(
          city == null ? 'City unavailable' : '${city.name}, ${city.country}',
        ),
        const SizedBox(height: 8),
        Text('Estimated duration: ${post.durationMinutes} min'),
        const SizedBox(height: 24),
        Text('Categories', style: Theme.of(context).textTheme.headlineSmall),
        const SizedBox(height: 12),
        if (details.categories.isEmpty)
          const Text('No categories available.')
        else
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final category in details.categories)
                Chip(label: Text(category.name)),
            ],
          ),
        const SizedBox(height: 24),
        Text('Places', style: Theme.of(context).textTheme.headlineSmall),
        const SizedBox(height: 12),
        if (details.places.isEmpty)
          const Text('No places available in this collection.')
        else
          for (var index = 0; index < details.places.length; index++)
            PostPlaceTile(entry: details.places[index], number: index + 1),
      ],
    );
  }
}
