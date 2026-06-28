class DosenResultModel {
  final String id;
  final String nama;
  final String namaProdi;
  final String namaUniversitas;
  final String jabatanAkademik;
  final String pendidikanTertinggi;
  final String status;

  const DosenResultModel({
    required this.id,
    required this.nama,
    required this.namaProdi,
    required this.namaUniversitas,
    required this.jabatanAkademik,
    required this.pendidikanTertinggi,
    required this.status,
  });

  factory DosenResultModel.fromJson(Map<String, dynamic> json) => DosenResultModel(
        id: json['id']?.toString() ?? '',
        nama: json['nama']?.toString() ?? '',
        namaProdi: json['nama_prodi']?.toString() ?? '',
        namaUniversitas: json['nama_pt']?.toString() ?? '',
        jabatanAkademik: json['jabatan_akademik']?.toString() ?? '',
        pendidikanTertinggi: json['pendidikan_tertinggi']?.toString() ?? '',
        status: json['status']?.toString() ?? '',
      );
}
