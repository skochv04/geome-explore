import 'package:flutter/material.dart';

import '../../../shared/widgets/cover_image.dart';
import '../data/city_catalog.dart';

class PostCard extends StatelessWidget {
  const PostCard({super.key, required this.post});

  final CityPost post;

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            CoverImage(url: post.coverUrl, height: 140),
            const SizedBox(height: 12),
            Text(
              post.title,
              style: Theme.of(context).textTheme.bodyMedium
                  ?.copyWith(fontWeight: FontWeight.w600),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 8),
            Text('${post.durationMinutes} min'),
            if (post.description?.trim().isNotEmpty ?? false) ...[
              const SizedBox(height: 8),
              Text(
                post.description!,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
