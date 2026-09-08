import '../../../../core/network/dio_client.dart';
import '../../../../core/constants/api_constants.dart';
import '../models/search_result_model.dart';
import '../models/pt_result_model.dart';
import '../models/prodi_result_model.dart';
import '../models/dosen_result_model.dart';
import '../models/mhs_result_model.dart';

class SearchRepository {
  final DioClient _client;

  SearchRepository(this._client);

  List<T> _parseList<T>(dynamic raw, T Function(Map<String, dynamic>) fromJson) {
    if (raw is! List) return [];
    return raw
        .whereType<Map>()
        .map((e) => fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }

  Future<SearchResultModel> searchAll(String keyword) async {
    final trimmed = keyword.trim();
    if (trimmed.isEmpty) {
      return const SearchResultModel(
        pt: [],
        prodi: [],
        dosen: [],
        mahasiswa: [],
      );
    }

    final encoded = Uri.encodeComponent(trimmed);

    final results = await Future.wait([
      _client
          .get('${ApiConstants.searchPt}/$encoded')
          .catchError((_) => <String, dynamic>{'data': []}),
      _client
          .get('${ApiConstants.searchProdi}/$encoded')
          .catchError((_) => <String, dynamic>{'data': []}),
      _client
          .get('${ApiConstants.searchDosen}/$encoded')
          .catchError((_) => <String, dynamic>{'data': []}),
      _client
          .get('${ApiConstants.searchMhs}/$encoded')
          .catchError((_) => <String, dynamic>{'data': []}),
    ]);

    return SearchResultModel(
      pt: _parseList(results[0]['data'], PtResultModel.fromJson),
      prodi: _parseList(results[1]['data'], ProdiResultModel.fromJson),
      dosen: _parseList(results[2]['data'], DosenResultModel.fromJson),
      mahasiswa: _parseList(results[3]['data'], MhsResultModel.fromJson),
    );
  }

  Future<List<PtResultModel>> searchPt(String keyword) async {
    final trimmed = keyword.trim();
    if (trimmed.isEmpty) return [];
    final encoded = Uri.encodeComponent(trimmed);
    final res = await _client.get('${ApiConstants.searchPt}/$encoded');
    return _parseList(res['data'], PtResultModel.fromJson);
  }

  Future<List<ProdiResultModel>> searchProdi(String keyword) async {
    final trimmed = keyword.trim();
    if (trimmed.isEmpty) return [];
    final encoded = Uri.encodeComponent(trimmed);
    final res = await _client.get('${ApiConstants.searchProdi}/$encoded');
    return _parseList(res['data'], ProdiResultModel.fromJson);
  }

  Future<List<DosenResultModel>> searchDosen(String keyword) async {
    final trimmed = keyword.trim();
    if (trimmed.isEmpty) return [];
    final encoded = Uri.encodeComponent(trimmed);
    final res = await _client.get('${ApiConstants.searchDosen}/$encoded');
    return _parseList(res['data'], DosenResultModel.fromJson);
  }

  Future<List<MhsResultModel>> searchMahasiswa(String keyword) async {
    final trimmed = keyword.trim();
    if (trimmed.isEmpty) return [];
    final encoded = Uri.encodeComponent(trimmed);
    final res = await _client.get('${ApiConstants.searchMhs}/$encoded');
    return _parseList(res['data'], MhsResultModel.fromJson);
  }
}

