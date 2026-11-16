import 'package:flutter/material.dart';

import '../data/post_details.dart';

class PostPlaceTile extends StatelessWidget {
  const PostPlaceTile({super.key, required this.entry, required this.number});

  final PostPlace entry;
  final int number;

  @override
  Widget build(BuildContext context) {
    final place = entry.place;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(child: Text('$number')),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  place?.name ?? 'Place unavailable',
                  style: Theme.of(context).textTheme.bodyMedium
                      ?.copyWith(fontWeight: FontWeight.w600),
                ),
                if (place?.address?.trim().isNotEmpty ?? false) ...[
                  const SizedBox(height: 4),
                  Text(place!.address!),
                ],
                if (entry.description?.trim().isNotEmpty ?? false) ...[
                  const SizedBox(height: 8),
                  Text(entry.description!),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
