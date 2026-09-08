import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pddikti_explorer/core/network/dio_client.dart';
import 'package:pddikti_explorer/features/search/data/repositories/search_repository.dart';

void main() {
  group('SearchRepository', () {
    test('returns empty SearchResultModel when keyword is empty or whitespace', () async {
      final client = DioClient(dio: Dio());
      final repo = SearchRepository(client);

      final resEmpty = await repo.searchAll('');
      expect(resEmpty.isEmpty, isTrue);

      final resWhitespace = await repo.searchAll('   ');
      expect(resWhitespace.isEmpty, isTrue);
    });

    test('searchAll queries all 4 categories and aggregates results', () async {
      final dio = Dio();
      dio.interceptors.add(InterceptorsWrapper(
        onRequest: (options, handler) {
          final path = options.path;
          if (path.contains('/pencarian/pt/')) {
            return handler.resolve(Response(
              requestOptions: options,
              statusCode: 200,
              data: {
                'status': 200,
                'data': [
                  {
                    'id': 'pt-1',
                    'kode': '001',
                    'nama': 'Universitas Indonesia',
                    'nama_singkat': 'UI',
                    'akreditasi': 'A',
                  }
                ],
              },
            ));
          } else if (path.contains('/pencarian/prodi/')) {
            return handler.resolve(Response(
              requestOptions: options,
              statusCode: 200,
              data: {
                'status': 200,
                'data': [
                  {
                    'id': 'prodi-1',
                    'nama': 'Ilmu Komputer',
                    'jenjang': 'S1',
                    'pt': 'Universitas Indonesia',
                  }
                ],
              },
            ));
          } else if (path.contains('/pencarian/dosen/')) {
            return handler.resolve(Response(
              requestOptions: options,
              statusCode: 200,
              data: {
                'status': 200,
                'data': [
                  {
                    'id': 'dosen-1',
                    'nama': 'Dr. Budi',
                    'nama_pt': 'Universitas Indonesia',
                    'nama_prodi': 'Ilmu Komputer',
                  }
                ],
              },
            ));
          } else if (path.contains('/pencarian/mhs/')) {
            return handler.resolve(Response(
              requestOptions: options,
              statusCode: 200,
              data: {
                'status': 200,
                'data': [
                  {
                    'id': 'mhs-1',
                    'nama': 'Andi',
                    'nim': '12345678',
                    'nama_pt': 'Universitas Indonesia',
                    'nama_prodi': 'Ilmu Komputer',
                  }
                ],
              },
            ));
          }

          return handler.reject(DioException(
            requestOptions: options,
            response: Response(requestOptions: options, statusCode: 404),
          ));
        },
      ));

      final client = DioClient(dio: dio);
      final repo = SearchRepository(client);

      final result = await repo.searchAll('Indonesia');

      expect(result.pt.length, 1);
      expect(result.pt.first.nama, 'Universitas Indonesia');
      expect(result.pt.first.singkatan, 'UI');

      expect(result.prodi.length, 1);
      expect(result.prodi.first.nama, 'Ilmu Komputer');

      expect(result.dosen.length, 1);
      expect(result.dosen.first.nama, 'Dr. Budi');

      expect(result.mahasiswa.length, 1);
      expect(result.mahasiswa.first.nama, 'Andi');

      expect(result.totalResults, 4);
    });

    test('searchAll handles partial network failure gracefully without throwing', () async {
      final dio = Dio();
      dio.interceptors.add(InterceptorsWrapper(
        onRequest: (options, handler) {
          final path = options.path;
          // Fail prodi request, succeed others
          if (path.contains('/pencarian/prodi/')) {
            return handler.reject(DioException(
              requestOptions: options,
              type: DioExceptionType.connectionError,
              error: 'Connection reset',
            ));
          }

          return handler.resolve(Response(
            requestOptions: options,
            statusCode: 200,
            data: {
              'status': 200,
              'data': [
                {'id': 'test-1', 'nama': 'Test Item'},
              ],
            },
          ));
        },
      ));

      final client = DioClient(dio: dio);
      final repo = SearchRepository(client);

      final result = await repo.searchAll('Test');

      expect(result.pt.length, 1);
      expect(result.prodi.length, 0); // Failed safely
      expect(result.dosen.length, 1);
      expect(result.mahasiswa.length, 1);
      expect(result.totalResults, 3);
    });
  });
}
