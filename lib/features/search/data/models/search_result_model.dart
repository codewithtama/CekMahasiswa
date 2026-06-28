import 'pt_result_model.dart';
import 'prodi_result_model.dart';
import 'dosen_result_model.dart';
import 'mhs_result_model.dart';

class SearchResultModel {
  final List<PtResultModel> pt;
  final List<ProdiResultModel> prodi;
  final List<DosenResultModel> dosen;
  final List<MhsResultModel> mahasiswa;

  const SearchResultModel({
    required this.pt,
    required this.prodi,
    required this.dosen,
    required this.mahasiswa,
  });

  factory SearchResultModel.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>? ?? {};
    return SearchResultModel(
      pt: (data['pt'] as List? ?? [])
          .map((e) => PtResultModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      prodi: (data['prodi'] as List? ?? [])
          .map((e) => ProdiResultModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      dosen: (data['dosen'] as List? ?? [])
          .map((e) => DosenResultModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      mahasiswa: (data['mahasiswa'] as List? ?? [])
          .map((e) => MhsResultModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  int get totalResults => pt.length + prodi.length + dosen.length + mahasiswa.length;
  bool get isEmpty => totalResults == 0;
}
