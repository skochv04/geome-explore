import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:geome_explore/features/explore/data/explore_filter.dart';
import 'package:geome_explore/features/explore/data/explore_repository.dart';

void main() {
  late HttpServer server;
  late SupabaseClient client;
  late ExploreRepository repository;
  final requests = <Uri>[];
  List<Map<String, dynamic>> responseRows = [];
  var statusCode = 200;

  Map<String, dynamic> post(int id) => {
    'id': id,
    'title': 'Collection $id',
    'description': null,
    'cover_url': null,
    'duration_minutes': 60,
    'created_at': '2026-01-01T00:00:00Z',
  };

  setUp(() async {
    requests.clear();
    responseRows = [];
    statusCode = 200;
    server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
    server.listen((request) async {
      requests.add(request.uri);
      request.response.statusCode = statusCode;
      request.response.headers.contentType = ContentType.json;
      request.response.write(
        jsonEncode(
          statusCode == 200
              ? responseRows
              : {'code': '42501', 'message': 'Access denied'},
        ),
      );
      await request.response.close();
    });
    client = SupabaseClient('http://127.0.0.1:${server.port}', 'test-key');
    repository = ExploreRepository(client: client);
  });

  tearDown(() async {
    await client.dispose();
    await server.close(force: true);
  });

  test(
    'one request loads a bounded page and the next offset is explicit',
    () async {
      responseRows = List.generate(21, post);
      final first = await repository.getPosts(7);
      expect(first.items.length, 20);
      expect(first.hasMore, isTrue);
      expect(requests.length, 1);
      expect(requests.single.queryParameters['limit'], '21');
      expect(requests.single.queryParameters['offset'], '0');
      expect(
        requests.single.queryParameters['order'],
        'created_at.desc.nullslast,id.desc.nullslast',
      );

      responseRows = [post(20)];
      final second = await repository.getPosts(7, offset: first.items.length);
      expect(second.items.single.id, 20);
      expect(second.hasMore, isFalse);
      expect(requests.last.queryParameters['offset'], '20');
    },
  );

  test(
    'city, duration, category, text and ordering are sent to the server',
    () async {
      await repository.getPosts(
        7,
        filter: const ExploreFilter(
          query: 'Castle',
          maxDuration: 120,
          categoryId: 3,
          sort: PostSort.shortest,
        ),
      );
      final query = requests.single.queryParameters;
      expect(query['city_id'], 'eq.7');
      expect(query['duration_minutes'], 'lte.120');
      expect(query['matching_categories.category_id'], 'eq.3');
      expect(
        query['select'],
        contains('matching_categories:post_categories!inner()'),
      );
      expect(
        query['select'],
        contains('matching_places:post_places(places!inner())'),
      );
      expect(query['matching_places.places.name'], 'ilike.%Castle%');
      expect(query['or'], contains('matching_places.not.is.null'));
      expect(
        query['order'],
        'duration_minutes.asc.nullslast,id.desc.nullslast',
      );
    },
  );

  test(
    'places are not loaded without a search and are paged when searching',
    () async {
      final empty = await repository.getPlaces(7, search: ' ');
      expect(empty.items, isEmpty);
      expect(requests, isEmpty);
      await repository.getPlaces(7, search: 'Castle', offset: 20);
      final query = requests.single.queryParameters;
      expect(query['city_id'], 'eq.7');
      expect(query['or'], '(name.ilike."%Castle%",address.ilike."%Castle%")');
      expect(query['offset'], '20');
      expect(query['limit'], '21');
    },
  );

  test('search punctuation stays inside a quoted filter value', () async {
    await repository.getPosts(
      7,
      filter: const ExploreFilter(query: 'a",id.gt.0'),
    );
    expect(
      requests.single.queryParameters['or'],
      '(title.ilike."%a\\",id.gt.0%",description.ilike."%a\\",id.gt.0%",matching_places.not.is.null)',
    );
  });

  test('categories have a stable order and a bounded page', () async {
    responseRows = List.generate(
      21,
      (id) => {'id': id, 'name': 'Category $id'},
    );
    final page = await repository.getCategories(offset: 20);
    expect(page.items.length, 20);
    expect(page.hasMore, isTrue);
    expect(requests.single.queryParameters['offset'], '20');
    expect(
      requests.single.queryParameters['order'],
      'name.asc.nullslast,id.asc.nullslast',
    );
  });

  test(
    'query errors propagate for retry and popularity never ranks one page',
    () async {
      statusCode = 403;
      await expectLater(
        repository.getPosts(7),
        throwsA(isA<PostgrestException>()),
      );
      requests.clear();
      await expectLater(
        repository.getPosts(
          7,
          filter: const ExploreFilter(sort: PostSort.mostSaved),
        ),
        throwsUnsupportedError,
      );
      expect(requests, isEmpty);
    },
  );
}
