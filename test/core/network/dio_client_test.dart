import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pddikti_explorer/core/network/api_exception.dart';
import 'package:pddikti_explorer/core/network/dio_client.dart';

void main() {
  group('DioClient response wrapping & unwrapping', () {
    test('returns response as-is when server already returns a data key', () async {
      final dio = Dio();
      dio.interceptors.add(InterceptorsWrapper(
        onRequest: (options, handler) {
          return handler.resolve(Response(
            requestOptions: options,
            statusCode: 200,
            data: {
              'status': 'success',
              'data': {'nama_pt': 'ITB', 'kode_pt': '001001'},
            },
          ));
        },
      ));

      final client = DioClient(dio: dio);
      final result = await client.get('/test');

      expect(result['status'], 'success');
      expect(result['data'], isA<Map<String, dynamic>>());
      expect(result['data']['nama_pt'], 'ITB');
    });

    test('wraps response in data key when server returns map without data key', () async {
      final dio = Dio();
      dio.interceptors.add(InterceptorsWrapper(
        onRequest: (options, handler) {
          return handler.resolve(Response(
            requestOptions: options,
            statusCode: 200,
            data: {'nama': 'Budi', 'nim': '12345'},
          ));
        },
      ));

      final client = DioClient(dio: dio);
      final result = await client.get('/test-raw');

      expect(result.containsKey('data'), isTrue);
      expect(result['data']['nama'], 'Budi');
    });

    test('wraps response in data key when server returns list', () async {
      final dio = Dio();
      dio.interceptors.add(InterceptorsWrapper(
        onRequest: (options, handler) {
          return handler.resolve(Response(
            requestOptions: options,
            statusCode: 200,
            data: [{'id': '1', 'name': 'Item 1'}],
          ));
        },
      ));

      final client = DioClient(dio: dio);
      final result = await client.get('/test-list');

      expect(result['data'], isA<List>());
      expect(result['data'].length, 1);
    });

    test('throws ApiException on 503 response', () async {
      final dio = Dio();
      dio.interceptors.add(InterceptorsWrapper(
        onRequest: (options, handler) {
          return handler.resolve(Response(
            requestOptions: options,
            statusCode: 503,
            data: 'Service Unavailable',
          ));
        },
      ));

      final client = DioClient(dio: dio);
      expect(() => client.get('/busy'), throwsA(isA<ApiException>()));
    });
  });
}
