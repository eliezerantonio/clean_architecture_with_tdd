import 'dart:async';
import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart';
import 'package:mockito/mockito.dart';
import 'package:tv/app/data/http/http.dart';
import 'package:tv/app/data/repositories_implementation/authentication_repository_impl.dart';
import 'package:tv/app/data/services/local/session_service.dart';
import 'package:tv/app/data/services/remote/account_api.dart';
import 'package:tv/app/data/services/remote/authentication_api.dart';
import 'package:tv/app/domain/failures/sign_in/sign_in_failure.dart';

import '../../../mocks.dart';

void main() {
  group('AuthenticationRepositoryImplementation >', () {
    late AuthenticationRepositoryImpl repository;
    late MockFlutterSecureStorage secureStorage;
    late MockClient client;
    setUp(() {
      secureStorage = MockFlutterSecureStorage();
      client = MockClient();

      final sessionService = SessionService(secureStorage);
      final http = Http(client: client, baseUrl: 'baseUrl', apiKey: 'apiKey');
      final authenticationAPI = AuthenticationAPI(http);
      final accountAPI = AccountAPI(http, sessionService);
      repository = AuthenticationRepositoryImpl(
          authenticationAPI, accountAPI, sessionService);
    });
    mockGet({
      required String path,
      required int statusCode,
      required Map<String, dynamic> response,
    }) {
      when(client.get(Uri.parse(path), headers: anyNamed('headers')))
          .thenAnswer((_) async => Response(jsonEncode(response), statusCode));
    }

    Future<void> mockPost({
      required String path,
      required int statusCode,
      required Map<String, dynamic> response,
    }) async {
      final completer = Completer();
      when(
        client.post(
          Uri.parse(path),
          headers: anyNamed('headers'),
          body: anyNamed('body'),
        ),
      ).thenAnswer((_) async {
        completer.complete();
        return Response(jsonEncode(response), statusCode);
      });

      return completer.future;
    }

    test('Signin > createRequestToken > Fail', () async {
      mockGet(
        path: '/authentication/token/new?api_key=apiKey&language=en',
        response: {
          'status_message': '',
          'success': '',
          'status_code': 7,
        },
        statusCode: 401,
      );

      final result = await repository.signIn('eliezer', 'antonio');

      expect(result.value, isA<SignInFailure>());
    });

    test(
      'Signin > createSessionWithLogin > fail',
      () async {
        mockGet(
          path: '/authentication/token/new?api_key=apiKey&language=en',
          response: {
            'success': true,
            'expires_at': '2018-07-24 04:10:26 UTC',
            'request_token': '1531f1a558c8357ce8990cf887ff196e8f5402ec'
          },
          statusCode: 200,
        );

        final future = mockPost(
          path:
              '/authentication/token/validate_with_login?api_key=apiKey&language=en',
          statusCode: 401,
          response: {
            'status_message': '', 
            'success': false,
            'status_code': 7,
          },
        );

        final result = await repository.signIn('eliezer', 'antonio');
        await future;
        expect(result.value, isA<SignInFailure>());
      },
      timeout: const Timeout(Duration(seconds: 5)),
    );
  });
}
