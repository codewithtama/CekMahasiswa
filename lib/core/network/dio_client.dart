import 'package:dio/dio.dart';
import '../constants/api_constants.dart';
import 'api_exception.dart';

class DioClient {
  late final Dio _dio;
  String _currentBaseUrl = ApiConstants.primaryBaseUrl;

  DioClient() {
    _dio = Dio(BaseOptions(
      baseUrl: _currentBaseUrl,
      connectTimeout: const Duration(milliseconds: ApiConstants.connectTimeout),
      receiveTimeout: const Duration(milliseconds: ApiConstants.receiveTimeout),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json, text/plain, */*',
        'Connection': 'keep-alive',
        'Host': 'api-pddikti.kemdiktisaintek.go.id',
        'Origin': 'https://pddikti.kemdiktisaintek.go.id',
        'Referer': 'https://pddikti.kemdiktisaintek.go.id/',
        'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/131.0.0.0 Safari/537.36',
        'X-User-IP': '103.47.132.29',
        'sec-ch-ua': '"Chromium";v="131", "Not_A Brand";v="24"',
        'sec-ch-ua-mobile': '?0',
        'sec-ch-ua-platform': '"Windows"'
      },
    ));

    _dio.interceptors.add(InterceptorsWrapper(
      onError: (DioException e, ErrorInterceptorHandler handler) async {
        // Fallback ke URL alternatif jika primary 503 atau connection error
        if ((e.response?.statusCode == 503 || e.type == DioExceptionType.connectionError)
            && _currentBaseUrl == ApiConstants.primaryBaseUrl) {
          _currentBaseUrl = ApiConstants.fallbackBaseUrl;
          _dio.options.baseUrl = _currentBaseUrl;

          try {
            final retryResponse = await _dio.fetch(e.requestOptions);
            return handler.resolve(retryResponse);
          } catch (_) {
            _currentBaseUrl = ApiConstants.primaryBaseUrl;
            _dio.options.baseUrl = _currentBaseUrl;
          }
        }
        handler.next(e);
      },
    ));
  }

  Future<Map<String, dynamic>> get(String path) async {
    try {
      final response = await _dio.get(path);
      if (response.statusCode == 503) {
        throw const ApiException(
          message: 'Server sedang sibuk karena tingginya traffic. Coba lagi dalam beberapa saat.',
          statusCode: 503,
        );
      }
      
      // Wrap response data in a 'data' key to keep consistency with the models & screens
      return {'data': response.data};
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }
}
