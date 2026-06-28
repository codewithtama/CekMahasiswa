class ProdiResultModel {
  final String id;
  final String kode;
  final String nama;
  final String jenjang;
  final String akreditasi;
  final String namaUniversitas;
  final String statusProdi;

  const ProdiResultModel({
    required this.id,
    required this.kode,
    required this.nama,
    required this.jenjang,
    required this.akreditasi,
    required this.namaUniversitas,
    required this.statusProdi,
  });

  factory ProdiResultModel.fromJson(Map<String, dynamic> json) => ProdiResultModel(
        id: json['id']?.toString() ?? '',
        kode: json['kode']?.toString() ?? '',
        nama: json['nama']?.toString() ?? '',
        jenjang: json['jenjang']?.toString() ?? '',
        akreditasi: json['akreditasi']?.toString() ?? '-',
        namaUniversitas: json['pt']?.toString() ?? json['nama_pt']?.toString() ?? '',
        statusProdi: json['status_prodi']?.toString() ?? '',
      );
}
