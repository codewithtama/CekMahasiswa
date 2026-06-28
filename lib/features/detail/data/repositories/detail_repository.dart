import '../../../../core/network/dio_client.dart';
import '../../../../core/constants/api_constants.dart';

class DetailRepository {
  final DioClient _client;
  DetailRepository(this._client);

  Future<Map<String, dynamic>> getPtDetail(String id) async =>
      _client.get('${ApiConstants.ptDetail}/$id');

  Future<Map<String, dynamic>> getPtRasio(String id) async =>
      _client.get('${ApiConstants.ptRasio}/$id');

  Future<Map<String, dynamic>> getPtBiayaKuliah(String id) async =>
      _client.get('${ApiConstants.ptBiayaKuliah}/$id');

  Future<Map<String, dynamic>> getPtJumlahProdi(String id) async =>
      _client.get('/pt/jumlah-prodi/$id');

  Future<Map<String, dynamic>> getPtJumlahMhs(String id) async =>
      _client.get('/pt/jumlah-mahasiswa/$id');

  Future<Map<String, dynamic>> getPtJumlahDosen(String id) async =>
      _client.get('/pt/jumlah-dosen/$id');

  Future<Map<String, dynamic>> getProdiDetail(String id) async =>
      _client.get('${ApiConstants.prodiDetail}/$id');

  Future<Map<String, dynamic>> getProdiDesc(String id) async =>
      _client.get('${ApiConstants.prodiDesc}/$id');

  Future<Map<String, dynamic>> getDosenProfile(String id) async =>
      _client.get('${ApiConstants.dosenProfile}/$id');

  Future<Map<String, dynamic>> getDosenStudyHistory(String id) async =>
      _client.get('${ApiConstants.dosenStudyHistory}/$id');

  Future<Map<String, dynamic>> getDosenTeachingHistory(String id) async =>
      _client.get('${ApiConstants.dosenTeachingHistory}/$id');

  Future<Map<String, dynamic>> getDosenPenelitian(String id) async =>
      _client.get('${ApiConstants.dosenPenelitian}/$id');

  Future<Map<String, dynamic>> getDosenPengabdian(String id) async =>
      _client.get('${ApiConstants.dosenPengabdian}/$id');

  Future<Map<String, dynamic>> getDosenKarya(String id) async =>
      _client.get('${ApiConstants.dosenKarya}/$id');

  Future<Map<String, dynamic>> getDosenPaten(String id) async =>
      _client.get('${ApiConstants.dosenPaten}/$id');

  Future<Map<String, dynamic>> getMhsDetail(String id) async =>
      _client.get('${ApiConstants.mhsDetail}/$id');
}
