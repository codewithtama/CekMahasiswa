class PtResultModel {
  final String id;
  final String kode;
  final String nama;
  final String singkatan;
  final String provinsi;
  final String kotaKab;
  final String jenisLembaga;
  final String kelompokLembaga;
  final String akreditasi;
  final String statusPt;

  const PtResultModel({
    required this.id,
    required this.kode,
    required this.nama,
    required this.singkatan,
    required this.provinsi,
    required this.kotaKab,
    required this.jenisLembaga,
    required this.kelompokLembaga,
    required this.akreditasi,
    required this.statusPt,
  });

  factory PtResultModel.fromJson(Map<String, dynamic> json) => PtResultModel(
        id: json['id']?.toString().trim() ?? '',
        kode: json['kode']?.toString().trim() ?? '',
        nama: json['nama']?.toString().trim() ?? '',
        singkatan: json['nama_singkat']?.toString().trim() ?? json['singkatan']?.toString().trim() ?? '',
        provinsi: json['provinsi']?.toString().trim() ?? '',
        kotaKab: json['kota_kab']?.toString().trim() ?? json['kab_kota']?.toString().trim() ?? '',
        jenisLembaga: json['jenis_lembaga']?.toString().trim() ?? '',
        kelompokLembaga: json['kelompok_lembaga']?.toString().trim() ?? '',
        akreditasi: json['akreditasi']?.toString().trim() ?? '-',
        statusPt: json['status_pt']?.toString().trim() ?? '',
      );
}
