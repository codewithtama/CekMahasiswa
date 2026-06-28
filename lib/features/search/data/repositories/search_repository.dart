import '../../../../core/network/dio_client.dart';
import '../../../../core/constants/api_constants.dart';
import '../models/search_result_model.dart';

class SearchRepository {
  final DioClient _client;

  SearchRepository(this._client);

  Future<SearchResultModel> searchAll(String keyword) async {
    final data = await _client.get('${ApiConstants.searchAll}/$keyword/');
    return SearchResultModel.fromJson(data);
  }
}
