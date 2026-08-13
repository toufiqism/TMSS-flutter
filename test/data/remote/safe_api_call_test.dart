import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tmss/core/api_result.dart';
import 'package:tmss/core/network_messages.dart';
import 'package:tmss/data/remote/safe_api_call.dart';

Response<dynamic> _response(int status, [dynamic body]) => Response<dynamic>(
      requestOptions: RequestOptions(path: '/requisitions'),
      statusCode: status,
      data: body,
    );

DioException _dioException(DioExceptionType type, {Response<dynamic>? response, Object? error}) =>
    DioException(
      requestOptions: RequestOptions(path: '/requisitions'),
      type: type,
      response: response,
      error: error,
    );

void main() {
  group('status mapping', () {
    test('2xx decodes into success', () async {
      final result = await safeApiCall<String>(
        () async => _response(200, {'data': 'ok'}),
        decode: (body) => (body as Map<String, dynamic>)['data'] as String,
      );

      expect(result, isA<ApiSuccess<String>>());
      expect((result as ApiSuccess<String>).response, 'ok');
    });

    test('401 becomes logout, so the session is cleared rather than retried', () async {
      final result = await safeApiCall<String>(
        () async => _response(401, {'message': 'Unauthenticated.'}),
        decode: (_) => '',
      );

      expect(result, isA<ApiLogout<String>>());
      expect((result as ApiLogout<String>).message, 'Unauthenticated.');
    });

    test('403 is a terminal permission error, not a logout', () async {
      final result = await safeApiCall<String>(
        () async => _response(403),
        decode: (_) => '',
      );

      expect(result, isA<ApiError<String>>());
      expect((result as ApiError<String>).errorCode, 403);
      expect(result.message, NetworkMessages.notPermitted);
    });

    test('409 carries its code so the caller can resync instead of just complaining', () async {
      final result = await safeApiCall<String>(
        () async => _response(409, {'message': 'Requisition is no longer pending'}),
        decode: (_) => '',
      );

      final error = result as ApiError<String>;
      expect(error.errorCode, 409);
      expect(error.message, 'Requisition is no longer pending');
    });

    test('422 flattens field errors onto the offending fields', () async {
      final result = await safeApiCall<String>(
        () async => _response(422, {
          'message': 'The given data was invalid.',
          'errors': {
            'pick_up_date_time': ['The pick up date time must be a future date.'],
            'purpose': ['The purpose field is required.'],
          },
        }),
        decode: (_) => '',
      );

      final error = result as ApiError<String>;
      expect(error.errorCode, 422);
      expect(error.fieldErrors, {
        'pick_up_date_time': 'The pick up date time must be a future date.',
        'purpose': 'The purpose field is required.',
      });
    });

    test('422 without an errors object yields no field errors rather than an empty map', () async {
      final result = await safeApiCall<String>(
        () async => _response(422, {'message': 'Invalid'}),
        decode: (_) => '',
      );

      expect((result as ApiError<String>).fieldErrors, isNull);
    });

    test('503 becomes maintenance', () async {
      final result = await safeApiCall<String>(
        () async => _response(503),
        decode: (_) => '',
      );

      expect(result, isA<ApiMaintenance<String>>());
    });

    test('404 reports the missing requisition', () async {
      final result = await safeApiCall<String>(
        () async => _response(404),
        decode: (_) => '',
      );

      expect((result as ApiError<String>).errorCode, 404);
    });

    test('an unmapped status still surfaces its code', () async {
      final result = await safeApiCall<String>(
        () async => _response(418),
        decode: (_) => '',
      );

      expect((result as ApiError<String>).errorCode, 418);
    });
  });

  group('transport failures', () {
    test('connection error is offline, not a generic failure', () async {
      final result = await safeApiCall<String>(
        () async => throw _dioException(DioExceptionType.connectionError),
        decode: (_) => '',
      );

      expect(result, isA<ApiOffline<String>>());
    });

    test('connection timeout is offline', () async {
      final result = await safeApiCall<String>(
        () async => throw _dioException(DioExceptionType.connectionTimeout),
        decode: (_) => '',
      );

      expect(result, isA<ApiOffline<String>>());
    });

    test('receive timeout is an error, since the connection itself worked', () async {
      final result = await safeApiCall<String>(
        () async => throw _dioException(DioExceptionType.receiveTimeout),
        decode: (_) => '',
      );

      expect((result as ApiError<String>).message, NetworkMessages.timeout);
    });

    test('a SocketException surfacing as an unknown DioException is still offline', () async {
      final result = await safeApiCall<String>(
        () async => throw _dioException(
          DioExceptionType.unknown,
          error: const SocketException('no route to host'),
        ),
        decode: (_) => '',
      );

      expect(result, isA<ApiOffline<String>>());
    });

    test('a thrown badResponse is mapped by status, same as a returned one', () async {
      final result = await safeApiCall<String>(
        () async => throw _dioException(
          DioExceptionType.badResponse,
          response: _response(401),
        ),
        decode: (_) => '',
      );

      expect(result, isA<ApiLogout<String>>());
    });

    test('a bare SocketException is offline', () async {
      final result = await safeApiCall<String>(
        () async => throw const SocketException('down'),
        decode: (_) => '',
      );

      expect(result, isA<ApiOffline<String>>());
    });
  });

  test('a decoder that throws reports a contract mismatch, not a crash', () async {
    final result = await safeApiCall<String>(
      () async => _response(200, {'unexpected': true}),
      decode: (_) => throw const FormatException('nope'),
    );

    expect((result as ApiError<String>).message, NetworkMessages.unexpectedResponse);
  });

  test('a 2xx with no body still reaches the decoder, for bodiless endpoints like cancel', () async {
    var decoded = false;
    final result = await safeApiCall<void>(
      () async => _response(200),
      decode: (_) => decoded = true,
    );

    expect(result, isA<ApiSuccess<void>>());
    expect(decoded, isTrue);
  });
}
