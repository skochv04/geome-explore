import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:geome_explore/features/explore/data/city_catalog.dart';
import 'package:geome_explore/features/explore/widgets/post_card.dart';
import 'package:geome_explore/features/posts/data/post_details.dart';
import 'package:geome_explore/features/posts/data/post_repository.dart';
import 'package:geome_explore/features/posts/screens/post_details_screen.dart';

class _Repository extends PostRepository {
  _Repository(this.load);

  final Future<PostDetails?> Function(int) load;

  @override
  Future<PostDetails?> getPostDetails(int postId) => load(postId);
}

class _Observer extends NavigatorObserver {
  Route<dynamic>? lastRoute;

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    lastRoute = route;
  }
}

void main() {
  final post = CityPost(
    id: 7,
    title: 'Collection title',
    durationMinutes: 120,
    createdAt: DateTime(2026),
    categoryIds: [],
    placeNames: [],
    visibleSaveCount: null,
  );
  final details = PostDetails(post: post, categories: [], places: []);

  testWidgets('shows loading and empty related content with safe fallbacks', (
    tester,
  ) async {
    final result = Completer<PostDetails?>();
    await tester.pumpWidget(
      MaterialApp(
        home: PostDetailsScreen(
          postId: 7,
          repository: _Repository((_) => result.future),
        ),
      ),
    );
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    result.complete(details);
    await tester.pumpAndSettle();
    expect(find.text('Collection title'), findsOneWidget);
    expect(find.text('No description available.'), findsOneWidget);
    await tester.scrollUntilVisible(
      find.text('No places available in this collection.'),
      250,
    );
    expect(
      find.text('No places available in this collection.'),
      findsOneWidget,
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('failed loading can be retried', (tester) async {
    var calls = 0;
    await tester.pumpWidget(
      MaterialApp(
        home: PostDetailsScreen(
          postId: 7,
          repository: _Repository((_) async {
            if (calls++ == 0) throw StateError('Offline');
            return details;
          }),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Try again'), findsOneWidget);
    await tester.tap(find.text('Try again'));
    await tester.pumpAndSettle();
    expect(find.text('Collection title'), findsOneWidget);
    expect(calls, 2);
  });

  testWidgets('shows unavailable state for a missing post', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: PostDetailsScreen(
          postId: 7,
          repository: _Repository((_) async => null),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Collection not found or unavailable.'), findsOneWidget);
  });

  testWidgets('tapping a shared post card pushes details with the post ID', (
    tester,
  ) async {
    final observer = _Observer();
    await tester.pumpWidget(
      MaterialApp(
        navigatorObservers: [observer],
        home: Scaffold(body: PostCard(post: post)),
      ),
    );
    await tester.tap(find.text('Collection title'));
    final route = observer.lastRoute! as MaterialPageRoute<void>;
    final screen = route.builder(
      tester.element(find.byType(PostCard)),
    ) as PostDetailsScreen;
    expect(screen.postId, 7);
    await tester.pumpWidget(const SizedBox.shrink());
  });
}
