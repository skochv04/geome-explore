import 'package:flutter/material.dart';

import '../../../shared/widgets/app_button.dart';
import '../data/post_details.dart';
import '../data/post_repository.dart';
import '../widgets/post_details_content.dart';

class PostDetailsScreen extends StatefulWidget {
  const PostDetailsScreen({super.key, required this.postId, this.repository});

  final int postId;
  final PostRepository? repository;

  @override
  State<PostDetailsScreen> createState() => _PostDetailsScreenState();
}

class _PostDetailsScreenState extends State<PostDetailsScreen> {
  late Future<PostDetails?> _future = _load();

  Future<PostDetails?> _load() => (widget.repository ?? PostRepository.instance)
      .getPostDetails(widget.postId);

  @override
  void didUpdateWidget(PostDetailsScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.postId != widget.postId ||
        oldWidget.repository != widget.repository) {
      _future = _load();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Collection')),
      body: SafeArea(
        child: FutureBuilder<PostDetails?>(
          future: _future,
          builder: (context, snapshot) {
            if (snapshot.connectionState != ConnectionState.done) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        'Could not load this collection. Please try again.',
                      ),
                      const SizedBox(height: 16),
                      AppButton(
                        label: 'Try again',
                        onPressed: () => setState(() {
                          _future = _load();
                        }),
                      ),
                    ],
                  ),
                ),
              );
            }
            if (snapshot.data == null) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.all(24),
                  child: Text('Collection not found or unavailable.'),
                ),
              );
            }
            return PostDetailsContent(details: snapshot.data!);
          },
        ),
      ),
    );
  }
}
