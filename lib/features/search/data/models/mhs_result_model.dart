class MhsResultModel {
  final String id;
  final String nama;
  final String nim;
  final String namaProdi;
  final String namaUniversitas;
  final String jenisKelamin;
  final String statusMahasiswa;
  final String angkatan;

  const MhsResultModel({
    required this.id,
    required this.nama,
    required this.nim,
    required this.namaProdi,
    required this.namaUniversitas,
    required this.jenisKelamin,
    required this.statusMahasiswa,
    required this.angkatan,
  });

  factory MhsResultModel.fromJson(Map<String, dynamic> json) => MhsResultModel(
        id: json['id']?.toString() ?? '',
        nama: json['nama']?.toString() ?? '',
        nim: json['nim']?.toString() ?? '',
        namaProdi: json['nama_prodi']?.toString() ?? '',
        namaUniversitas: json['sinkatan_pt']?.toString() ?? json['nama_pt']?.toString() ?? '',
        jenisKelamin: json['jenis_kelamin']?.toString() ?? '',
        statusMahasiswa: json['status_mahasiswa']?.toString() ?? '',
        angkatan: json['angkatan']?.toString() ?? '',
      );
}
