import 'package:dio/dio.dart';

class ApiException implements Exception {
  final String message;
  final int? statusCode;

  const ApiException({required this.message, this.statusCode});

  factory ApiException.fromDioException(DioException e) {
    if (e.response?.statusCode == 503) {
      return const ApiException(
        message: 'Server sedang sibuk karena tingginya traffic. Coba lagi dalam beberapa saat.',
        statusCode: 503,
      );
    }
    if (e.type == DioExceptionType.connectionError) {
      return const ApiException(message: 'Tidak ada koneksi internet.');
    }
    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout) {
      return const ApiException(message: 'Koneksi timeout. Periksa jaringan Anda.');
    }
    return ApiException(
      message: e.message ?? 'Terjadi kesalahan tidak diketahui.',
      statusCode: e.response?.statusCode,
    );
  }

  @override
  String toString() => 'ApiException: $message (status: $statusCode)';
}
