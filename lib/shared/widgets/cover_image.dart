import 'package:flutter/material.dart';

import '../../../app/theme/app_colors.dart';

class CoverImage extends StatelessWidget {
  const CoverImage({super.key, this.url, required this.height});

  final String? url;
  final double height;

  @override
  Widget build(BuildContext context) {
    final placeholder = Container(
      height: height,
      width: double.infinity,
      color: AppColors.lightBlue,
      alignment: Alignment.center,
      child: const Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.image_outlined, size: 40),
          SizedBox(height: 8),
          Text('Image unavailable'),
        ],
      ),
    );
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: url == null || url!.trim().isEmpty
          ? placeholder
          : Image.network(
              url!,
              height: height,
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => placeholder,
              loadingBuilder: (context, child, progress) => progress == null
                  ? child
                  : SizedBox(
                      height: height,
                      child: const Center(child: CircularProgressIndicator()),
                    ),
            ),
    );
  }
}
