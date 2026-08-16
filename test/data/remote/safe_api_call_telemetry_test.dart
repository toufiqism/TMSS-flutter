import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tmss/core/api_result.dart';
import 'package:tmss/data/remote/safe_api_call.dart';

import '../../core/telemetry/recording_crash_reporter.dart';

Response<dynamic> _response(int status, [dynamic body]) => Response<dynamic>(
      requestOptions: RequestOptions(path: '/requisitions'),
      statusCode: status,
      data: body,
    );

DioException _dioException(
  DioExceptionType type, {
  Response<dynamic>? response,
  Object? error,
}) =>
    DioException(
      requestOptions: RequestOptions(path: '/requisitions'),
      type: type,
      response: response,
      error: error,
    );

void main() {
  late RecordingCrashReporter reporter;

  setUp(() => reporter = RecordingCrashReporter());

  Future<ApiResult<String>> run(Future<Response<dynamic>> Function() call) {
    return safeApiCall<String>(
      call,
      decode: (body) => (body as Map<String, dynamic>)['data'] as String,
      reporter: reporter,
      operation: 'GET /requisitions',
    );
  }

  group('reported as a non-fatal — something is wrong', () {
    test('500 records, tagged with the operation and status', () async {
      await run(() async => _response(500, {'message': 'boom'}));

      expect(reporter.errors, hasLength(1));
      final recorded = reporter.errors.single;
      expect(recorded.fatal, isFalse, reason: 'an API failure must not count as a crash');
      expect(recorded.error, isA<ApiStatusFailure>());
      expect(recorded.reason, contains('HTTP 500'));
      expect(recorded.keys['operation'], 'GET /requisitions');
      expect(recorded.keys['status'], 500);
    });

    test('a timeout records — the request reached the server and then stalled', () async {
      await run(
        () async => throw _dioException(DioExceptionType.receiveTimeout),
      );

      expect(reporter.errors, hasLength(1));
      expect(reporter.errors.single.reason, contains('timeout'));
    });

    test('a rejected certificate records', () async {
      await run(() async => throw _dioException(DioExceptionType.badCertificate));

      expect(reporter.errors, hasLength(1));
      expect(reporter.errors.single.reason, contains('certificate'));
    });

    test('an undecodable 2xx records — the server logs a success nobody can see', () async {
      final result = await run(() async => _response(200, {'unexpected': 'shape'}));

      expect(result, isA<ApiError<String>>());
      expect(reporter.errors, hasLength(1));
      expect(reporter.errors.single.reason, contains('decode'));
    });

    test('a throw that is not a DioException records', () async {
      await run(() async => throw StateError('client bug'));

      expect(reporter.errors, hasLength(1));
      expect(reporter.errors.single.error, isA<StateError>());
    });
  });

  group('breadcrumb only — the system is behaving as specified', () {
    test('401 leaves a trail but files no issue', () async {
      final result = await run(() async => _response(401, {'message': 'Unauthenticated.'}));

      expect(result, isA<ApiLogout<String>>());
      expect(reporter.errors, isEmpty);
      expect(reporter.logs.single, contains('HTTP 401'));
    });

    test('422 validation is user input, not a defect', () async {
      await run(() async => _response(422, {'message': 'invalid'}));

      expect(reporter.errors, isEmpty);
      expect(reporter.logs.single, contains('HTTP 422'));
    });

    test('503 is excluded from the 5xx rule — maintenance is announced', () async {
      final result = await run(() async => _response(503));

      expect(result, isA<ApiMaintenance<String>>());
      expect(reporter.errors, isEmpty);
      expect(reporter.logs.single, contains('HTTP 503'));
    });

    test('being offline is the network, not the app', () async {
      final result = await run(
        () async => throw _dioException(DioExceptionType.connectionError),
      );

      expect(result, isA<ApiOffline<String>>());
      expect(reporter.errors, isEmpty);
      expect(reporter.logs.single, contains('offline'));
    });

    test('a SocketException surfacing bare is also just offline', () async {
      await run(() async => throw const SocketException('no route'));

      expect(reporter.errors, isEmpty);
      expect(reporter.logs.single, contains('offline'));
    });

    test('a cancelled request is not a failure to report', () async {
      await run(() async => throw _dioException(DioExceptionType.cancel));

      expect(reporter.errors, isEmpty);
      expect(reporter.logs.single, contains('cancelled'));
    });
  });

  group('quiet paths', () {
    test('a success reports nothing at all', () async {
      final result = await run(() async => _response(200, {'data': 'ok'}));

      expect(result, isA<ApiSuccess<String>>());
      expect(reporter.errors, isEmpty);
      expect(reporter.logs, isEmpty);
    });

    test('omitting the reporter still works — telemetry is optional', () async {
      final result = await safeApiCall<String>(
        () async => _response(500),
        decode: (_) => '',
      );

      expect(result, isA<ApiError<String>>());
    });
  });
}
