class ApiConstants {
  ApiConstants._();

  static const String primaryBaseUrl = 'https://api-pddikti.kemdiktisaintek.go.id';
  static const String fallbackBaseUrl = 'https://api-pddikti.kemdiktisaintek.go.id';

  // Search
  static const String searchAll = '/pencarian/all';
  static const String searchPt = '/pencarian/pt';
  static const String searchProdi = '/pencarian/prodi';
  static const String searchDosen = '/pencarian/dosen';
  static const String searchMhs = '/pencarian/mhs';

  // Detail
  static const String ptDetail = '/pt/detail';
  static const String ptLogo = '/pt/logo';
  static const String ptRasio = '/pt/rasio';
  static const String ptMahasiswa = '/pt/mahasiswa';
  static const String ptBiayaKuliah = '/pt/cost-range';

  static const String prodiDetail = '/prodi/detail';
  static const String prodiDesc = '/prodi/desc';
  static const String prodiNumStudentsLecturers = '/prodi/num-students-lecturers';
  static const String prodiBiayaKuliah = '/prodi/cost-range';

  static const String dosenProfile = '/dosen/profile';
  static const String dosenStudyHistory = '/dosen/study-history';
  static const String dosenTeachingHistory = '/dosen/teaching-history';
  static const String dosenPenelitian = '/dosen/portofolio/penelitian';
  static const String dosenPengabdian = '/dosen/portofolio/pengabdian';
  static const String dosenKarya = '/dosen/portofolio/karya';
  static const String dosenPaten = '/dosen/portofolio/paten';

  static const String mhsDetail = '/detail/mhs';

  static const int connectTimeout = 15000;
  static const int receiveTimeout = 15000;
}
