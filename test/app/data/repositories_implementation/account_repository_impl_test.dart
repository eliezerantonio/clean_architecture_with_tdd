import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart';
import 'package:mockito/mockito.dart';
import 'package:tv/app/data/http/http.dart';
import 'package:tv/app/data/repositories_implementation/account_repository_impl.dart';
import 'package:tv/app/data/services/local/session_service.dart';
import 'package:tv/app/data/services/remote/account_api.dart';
import 'package:tv/app/domain/failures/http_request/http_request_failure.dart';
import 'package:tv/app/domain/models/media/media.dart';

import '../../mocks.dart';

void main() {
  late MockClient client;
  late MockFlutterSecureStorage secureStorage;
  late AccountRepositoryImpl repositoryImpl;

  setUp(() {
    client = MockClient();
    secureStorage = MockFlutterSecureStorage();
    final sessionService = SessionService(secureStorage);
    final accountAPI = AccountAPI(
        Http(client: client, baseUrl: '', apiKey: 'apiKey'), sessionService);

    repositoryImpl = AccountRepositoryImpl(accountAPI, sessionService);
  });

  void mockGet({
    required Map<String, dynamic> json,
    required int statusCode,
  }) {
    when(
      client.get(
        any,
        headers: anyNamed('headers'),
      ),
    ).thenAnswer((_) async => Response(
          jsonEncode(json),
          statusCode,
        ));
  }

  test('AccountRepositoryImpl > get userData', () async {
    when(secureStorage.read(key: sessionIdKey))
        .thenAnswer((_) async => 'sessionId');

    mockGet(
        json: {'id': 123, 'username': 'darwin', 'avatar': {}}, statusCode: 200);

    final user = await repositoryImpl.getUserData();

    expect(user, isNotNull);
  });

  test('AccountRepositoryImpl > getFavorites > fail', () async {
    mockGet(json: {'status_code': 3, 'status_message': ''}, statusCode: 401);

    final result = await repositoryImpl.getFavorites(MediaType.movie);

    // expect(result.value is HttpRequestFailure, true);
    expect(result.value, isA<HttpRequestFailure>());
  });

  test('AccountRepositoryImpl > getFavorites > success', () async {
    mockGet(json: {
      'page': 1,
      'results': [
        {
          'adult': false,
          'backdrop_path': '/se5Hxz7PArQZOG3Nx2bpfOhLhtV.jpg',
          'genre_ids': [28, 12, 16, 10751],
          'id': 9806,
          'original_language': 'en',
          'original_title': 'The Incredibles',
          'overview': '',
          'popularity': 71.477,
          'poster_path': '/2LqaLgk4Z226KkgPJuiOQ58wvrm.jpg',
          'release_date': '2004-10-27',
          'title': 'The Incredibles',
          'video': false,
          'vote_average': 7.702,
          'vote_count': 16162
        },
      ],
      'total_pages': 4,
      'total_results': 80
    }, statusCode: 200);

    final result = await repositoryImpl.getFavorites(MediaType.movie);

    expect(result.value, isA<Map<int, Media>>());
  });

  test('AccountRepositoryImpl > markAsFavorite success', () async {
    when(
      client.post(any, headers: anyNamed('headers'), body: anyNamed('body')),
    ).thenAnswer((_) async => Response(
        jsonEncode({
          'status_code': 12,
          'status_message': '',
        }),
        201));
    final result = await repositoryImpl.markAsFavorite(
      mediaId: 123,
      type: MediaType.movie,
      favorite: true,
    );

    
    expect(result.value is! HttpRequestFailure, true);
  });

  test('AccountRepositoryImpl > markAsFavorite > fail', () async {
    when(
      client.post(any, headers: anyNamed('headers'), body: anyNamed('body')),
    ).thenAnswer(
      (_) async => Response(
        jsonEncode({
          'status_code': 34,
          'status_message': '',
        }),
        404,
      ),
    );
    final result = await repositoryImpl.markAsFavorite(
      mediaId: 123,
      type: MediaType.movie,
      favorite: true,
    );

    expect(result.value is HttpRequestFailure, true);
  });
}
