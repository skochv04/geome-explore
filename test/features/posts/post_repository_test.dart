import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:geome_explore/features/posts/data/post_repository.dart';

void main() {
  late HttpServer server;
  late SupabaseClient client;
  late PostRepository repository;
  final requests = <Uri>[];
  List<Map<String, dynamic>> postRows = [];
  List<Map<String, dynamic>> places = [];
  List<Map<String, dynamic>> categories = [];
  var denyPlaces = false;

  Map<String, dynamic> post() => {
    'id': 7,
    'title': 'Collection',
    'description': 'Description',
    'cover_url': null,
    'duration_minutes': 120,
    'created_at': '2026-01-01T00:00:00Z',
    'city': {'id': 1, 'name': 'City', 'country': 'Country'},
    'author': {'username': 'Author'},
  };

  Map<String, dynamic> place(int id, int position) => {
    'place_id': id,
    'position': position,
    'description': 'Author notes $id',
    'places': {'name': 'Place $id', 'address': null},
  };

  setUp(() async {
    requests.clear();
    postRows = [post()];
    places = [];
    categories = [];
    denyPlaces = false;
    server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
    server.listen((request) async {
      requests.add(request.uri);
      final table = request.uri.pathSegments.last;
      final rows = switch (table) {
        'posts' => postRows,
        'post_places' => places,
        'post_categories' => categories,
        _ => <Map<String, dynamic>>[],
      };
      final offset = int.parse(request.uri.queryParameters['offset'] ?? '0');
      final limit = int.parse(request.uri.queryParameters['limit'] ?? '100');
      request.response.headers.contentType = ContentType.json;
      if (denyPlaces && table == 'post_places') {
        request.response.statusCode = 403;
        request.response.write(
          jsonEncode({'code': '42501', 'message': 'Access denied'}),
        );
      } else {
        request.response.write(
          jsonEncode(rows.skip(offset).take(limit).toList()),
        );
      }
      await request.response.close();
    });
    client = SupabaseClient('http://127.0.0.1:${server.port}', 'test-key');
    repository = PostRepository(client: client);
  });

  tearDown(() async {
    await client.dispose();
    await server.close(force: true);
  });

  test(
    'loads the requested post, author, city, categories and ordered notes',
    () async {
      places = [place(2, 30), place(1, 10)];
      categories = [
        {
          'category_id': 3,
          'categories': {'id': 3, 'name': 'Culture'},
        },
      ];
      final details = (await repository.getPostDetails(7))!;
      expect(details.post.id, 7);
      expect(details.authorUsername, 'Author');
      expect(details.city?.name, 'City');
      expect(details.categories.single.name, 'Culture');
      expect(details.places.map((entry) => entry.placeId), [1, 2]);
      expect(details.places.first.description, 'Author notes 1');
      expect(details.places.first.place?.address, isNull);
      final main = requests.first;
      expect(main.queryParameters['id'], 'eq.7');
      expect(
        main.queryParameters['select'],
        contains('profiles!posts_author_id_fkey(username)'),
      );
      for (final uri in requests.where(
        (uri) => uri.path.endsWith('post_places'),
      )) {
        expect(uri.queryParameters['post_id'], 'eq.7');
        expect(
          uri.queryParameters['order'],
          'position.asc.nullslast,place_id.asc.nullslast',
        );
      }
    },
  );

  test(
    'missing or inaccessible post returns null without loading relations',
    () async {
      postRows = [];
      expect(await repository.getPostDetails(7), isNull);
      expect(requests.length, 1);
    },
  );

  test(
    'hidden related rows retain place notes and permit missing metadata',
    () async {
      postRows.single['author'] = null;
      postRows.single['city'] = null;
      places = [place(1, 1)..['places'] = null];
      categories = [
        {'category_id': 3, 'categories': null},
      ];
      final details = (await repository.getPostDetails(7))!;
      expect(details.authorUsername, isNull);
      expect(details.city, isNull);
      expect(details.categories, isEmpty);
      expect(details.places.single.place, isNull);
      expect(details.places.single.description, 'Author notes 1');
    },
  );

  test('reads every place of a collection across server pages', () async {
    places = List.generate(101, (index) => place(index, index));
    final details = (await repository.getPostDetails(7))!;
    expect(details.places.length, 101);
    expect(details.places.last.position, 100);
    final offsets = requests
        .where((uri) => uri.path.endsWith('post_places'))
        .map((uri) => uri.queryParameters['offset']);
    expect(offsets, ['0', '100', '101']);
  });

  test(
    'permission failures are errors rather than empty place lists',
    () async {
      denyPlaces = true;
      await expectLater(
        repository.getPostDetails(7),
        throwsA(isA<PostgrestException>()),
      );
    },
  );
}
