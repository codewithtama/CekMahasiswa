# AGENT PROMPT: PDDikti Explorer — Flutter MVP

## IDENTITAS PROYEK

- **Nama app:** PDDikti Explorer
- **Platform:** Flutter (Android & iOS)
- **API Base URL:** `https://pddikti.rone.dev/api/` (primary) / `https://pddikti.fastapicloud.dev/api/` (fallback)
- **Arsitektur:** MVVM + feature-first clean architecture
- **Tema:** Material Design 3, clean minimal, light/dark mode support
- **State management:** Riverpod (flutter_riverpod)
- **HTTP client:** Dio dengan interceptor retry dan fallback URL otomatis
- **Navigasi:** go_router

---

## ATURAN GLOBAL AGENT

1. Selalu gunakan MVVM dengan feature-first folder structure. Zero hardcoding string URL di luar constants file.
2. Zero RenderFlex overflow. Semua list gunakan `ListView.builder`, semua content dalam `SingleChildScrollView` atau `CustomScrollView` dengan `SliverList`.
3. Semua model wajib `fromJson` factory. Handle field null dengan safe fallback (`?? ''`, `?? 0`, `?? []`).
4. Handle status API `503 SERVICE_LIMITED_HIGH_TRAFFIC` dengan graceful UI: tampilkan pesan "Server sedang sibuk, coba lagi dalam beberapa saat" dan tombol retry.
5. Handle empty state dan error state secara eksplisit di setiap screen (jangan biarkan blank white screen).
6. Semua teks UI dalam Bahasa Indonesia.
7. Jangan hardcode warna — gunakan `Theme.of(context).colorScheme.*` saja.
8. Deliver complete file rewrites, bukan partial diff/patch.

---

## STRUKTUR FOLDER

```
lib/
├── core/
│   ├── constants/
│   │   └── api_constants.dart        # base URL, fallback URL, endpoints
│   ├── network/
│   │   ├── dio_client.dart           # Dio instance + interceptor fallback
│   │   └── api_exception.dart        # custom exception class
│   ├── theme/
│   │   └── app_theme.dart            # M3 light + dark theme
│   └── router/
│       └── app_router.dart           # go_router setup
├── features/
│   ├── search/
│   │   ├── data/
│   │   │   ├── models/
│   │   │   │   ├── search_result_model.dart
│   │   │   │   ├── pt_result_model.dart
│   │   │   │   ├── prodi_result_model.dart
│   │   │   │   ├── dosen_result_model.dart
│   │   │   │   └── mhs_result_model.dart
│   │   │   └── repositories/
│   │   │       └── search_repository.dart
│   │   ├── presentation/
│   │   │   ├── providers/
│   │   │   │   └── search_provider.dart
│   │   │   ├── screens/
│   │   │   │   └── search_screen.dart
│   │   │   └── widgets/
│   │   │       ├── search_bar_widget.dart
│   │   │       ├── filter_chip_bar.dart
│   │   │       ├── pt_result_card.dart
│   │   │       ├── prodi_result_card.dart
│   │   │       ├── dosen_result_card.dart
│   │   │       └── mhs_result_card.dart
│   ├── detail/
│   │   ├── data/
│   │   │   ├── models/
│   │   │   │   ├── pt_detail_model.dart
│   │   │   │   ├── prodi_detail_model.dart
│   │   │   │   ├── dosen_profile_model.dart
│   │   │   │   └── mhs_detail_model.dart
│   │   │   └── repositories/
│   │   │       └── detail_repository.dart
│   │   ├── presentation/
│   │   │   ├── providers/
│   │   │   │   └── detail_provider.dart
│   │   │   └── screens/
│   │   │       ├── pt_detail_screen.dart
│   │   │       ├── prodi_detail_screen.dart
│   │   │       ├── dosen_detail_screen.dart
│   │   │       └── mhs_detail_screen.dart
│   └── home/
│       └── presentation/
│           └── screens/
│               └── home_screen.dart
└── main.dart
```

---

## DEPENDENCIES (pubspec.yaml)

```yaml
name: pddikti_explorer
description: Aplikasi pencarian data pendidikan tinggi Indonesia via PDDikti API

environment:
  sdk: ">=3.0.0 <4.0.0"

dependencies:
  flutter:
    sdk: flutter
  flutter_riverpod: ^2.5.1
  riverpod_annotation: ^2.3.5
  go_router: ^14.0.0
  dio: ^5.4.3
  cached_network_image: ^3.3.1
  shimmer: ^3.0.0
  intl: ^0.19.0

dev_dependencies:
  flutter_test:
    sdk: flutter
  build_runner: ^2.4.9
  riverpod_generator: ^2.4.0
  flutter_lints: ^3.0.0

flutter:
  uses-material-design: true
```

---

## CORE: API CONSTANTS

**File: `lib/core/constants/api_constants.dart`**

```dart
class ApiConstants {
  ApiConstants._();

  static const String primaryBaseUrl = 'https://pddikti.rone.dev/api';
  static const String fallbackBaseUrl = 'https://pddikti.fastapicloud.dev/api';

  // Search
  static const String searchAll = '/search/all';
  static const String searchPt = '/search/pt';
  static const String searchProdi = '/search/prodi';
  static const String searchDosen = '/search/dosen';
  static const String searchMhs = '/search/mhs';

  // Detail
  static const String ptDetail = '/pt/detail';
  static const String ptLogo = '/pt/logo';
  static const String ptRasio = '/pt/rasio';
  static const String ptMahasiswa = '/pt/mahasiswa';
  static const String ptBiayaKuliah = '/pt/biaya-kuliah';

  static const String prodiDetail = '/prodi/detail';
  static const String prodiDesc = '/prodi/desc';
  static const String prodiNumStudentsLecturers = '/prodi/num-students-lecturers';
  static const String prodiBiayaKuliah = '/prodi/biaya-kuliah';

  static const String dosenProfile = '/dosen/profile';
  static const String dosenStudyHistory = '/dosen/study-history';
  static const String dosenTeachingHistory = '/dosen/teaching-history';
  static const String dosenPenelitian = '/dosen/penelitian';

  static const String mhsDetail = '/mhs/detail';

  static const int connectTimeout = 15000;
  static const int receiveTimeout = 15000;
}
```

---

## CORE: DIO CLIENT (dengan fallback URL)

**File: `lib/core/network/dio_client.dart`**

```dart
import 'package:dio/dio.dart';
import '../constants/api_constants.dart';
import 'api_exception.dart';

class DioClient {
  late final Dio _dio;
  String _currentBaseUrl = ApiConstants.primaryBaseUrl;

  DioClient() {
    _dio = Dio(BaseOptions(
      baseUrl: _currentBaseUrl,
      connectTimeout: Duration(milliseconds: ApiConstants.connectTimeout),
      receiveTimeout: Duration(milliseconds: ApiConstants.receiveTimeout),
      headers: {'Content-Type': 'application/json'},
    ));

    _dio.interceptors.add(InterceptorsWrapper(
      onError: (DioException e, ErrorInterceptorHandler handler) async {
        // Fallback ke URL alternatif jika primary 503 atau connection error
        if ((e.response?.statusCode == 503 || e.type == DioExceptionType.connectionError)
            && _currentBaseUrl == ApiConstants.primaryBaseUrl) {
          _currentBaseUrl = ApiConstants.fallbackBaseUrl;
          _dio.options.baseUrl = _currentBaseUrl;

          try {
            final retryResponse = await _dio.fetch(e.requestOptions);
            return handler.resolve(retryResponse);
          } catch (_) {
            _currentBaseUrl = ApiConstants.primaryBaseUrl;
            _dio.options.baseUrl = _currentBaseUrl;
          }
        }
        handler.next(e);
      },
    ));
  }

  Future<Map<String, dynamic>> get(String path) async {
    try {
      final response = await _dio.get(path);
      if (response.statusCode == 503) {
        throw ApiException(
          message: 'Server sedang sibuk karena tingginya traffic. Coba lagi dalam beberapa saat.',
          statusCode: 503,
        );
      }
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }
}
```

---

## CORE: API EXCEPTION

**File: `lib/core/network/api_exception.dart`**

```dart
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
```

---

## CORE: THEME

**File: `lib/core/theme/app_theme.dart`**

```dart
import 'package:flutter/material.dart';

class AppTheme {
  AppTheme._();

  static const Color _seedColor = Color(0xFF1565C0); // Biru PDDikti

  static ThemeData get lightTheme => ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: _seedColor,
          brightness: Brightness.light,
        ),
        appBarTheme: const AppBarTheme(centerTitle: false, elevation: 0),
        cardTheme: CardTheme(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: Colors.grey.shade200),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(28),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        ),
      );

  static ThemeData get darkTheme => ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: _seedColor,
          brightness: Brightness.dark,
        ),
        appBarTheme: const AppBarTheme(centerTitle: false, elevation: 0),
        cardTheme: CardTheme(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: Colors.grey.shade800),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(28),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        ),
      );
}
```

---

## CORE: ROUTER

**File: `lib/core/router/app_router.dart`**

```dart
import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';
import '../../features/home/presentation/screens/home_screen.dart';
import '../../features/search/presentation/screens/search_screen.dart';
import '../../features/detail/presentation/screens/pt_detail_screen.dart';
import '../../features/detail/presentation/screens/prodi_detail_screen.dart';
import '../../features/detail/presentation/screens/dosen_detail_screen.dart';
import '../../features/detail/presentation/screens/mhs_detail_screen.dart';

final appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(path: '/', builder: (_, __) => const HomeScreen()),
    GoRoute(
      path: '/search',
      builder: (context, state) {
        final query = state.uri.queryParameters['q'] ?? '';
        return SearchScreen(initialQuery: query);
      },
    ),
    GoRoute(
      path: '/pt/:id',
      builder: (context, state) => PtDetailScreen(idPt: state.pathParameters['id']!),
    ),
    GoRoute(
      path: '/prodi/:id',
      builder: (context, state) => ProdiDetailScreen(idProdi: state.pathParameters['id']!),
    ),
    GoRoute(
      path: '/dosen/:id',
      builder: (context, state) => DosenDetailScreen(idDosen: state.pathParameters['id']!),
    ),
    GoRoute(
      path: '/mhs/:id',
      builder: (context, state) => MhsDetailScreen(idMhs: state.pathParameters['id']!),
    ),
  ],
);
```

---

## FEATURE: SEARCH — MODELS

**File: `lib/features/search/data/models/search_result_model.dart`**

```dart
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
```

**File: `lib/features/search/data/models/pt_result_model.dart`**

```dart
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
        id: json['id']?.toString() ?? '',
        kode: json['kode']?.toString() ?? '',
        nama: json['nama']?.toString() ?? '',
        singkatan: json['singkatan']?.toString() ?? '',
        provinsi: json['provinsi']?.toString() ?? '',
        kotaKab: json['kota_kab']?.toString() ?? '',
        jenisLembaga: json['jenis_lembaga']?.toString() ?? '',
        kelompokLembaga: json['kelompok_lembaga']?.toString() ?? '',
        akreditasi: json['akreditasi']?.toString() ?? '-',
        statusPt: json['status_pt']?.toString() ?? '',
      );
}
```

**File: `lib/features/search/data/models/prodi_result_model.dart`**

```dart
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
        namaUniversitas: json['nama_pt']?.toString() ?? '',
        statusProdi: json['status_prodi']?.toString() ?? '',
      );
}
```

**File: `lib/features/search/data/models/dosen_result_model.dart`**

```dart
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
```

**File: `lib/features/search/data/models/mhs_result_model.dart`**

```dart
class MhsResultModel {
  final String id;
  final String nama;
  final String namaProdi;
  final String namaUniversitas;
  final String jenisKelamin;
  final String statusMahasiswa;
  final String angkatan;

  const MhsResultModel({
    required this.id,
    required this.nama,
    required this.namaProdi,
    required this.namaUniversitas,
    required this.jenisKelamin,
    required this.statusMahasiswa,
    required this.angkatan,
  });

  factory MhsResultModel.fromJson(Map<String, dynamic> json) => MhsResultModel(
        id: json['id']?.toString() ?? '',
        nama: json['nama']?.toString() ?? '',
        namaProdi: json['nama_prodi']?.toString() ?? '',
        namaUniversitas: json['nama_pt']?.toString() ?? '',
        jenisKelamin: json['jenis_kelamin']?.toString() ?? '',
        statusMahasiswa: json['status_mahasiswa']?.toString() ?? '',
        angkatan: json['angkatan']?.toString() ?? '',
      );
}
```

---

## FEATURE: SEARCH — REPOSITORY

**File: `lib/features/search/data/repositories/search_repository.dart`**

```dart
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
```

---

## FEATURE: SEARCH — PROVIDER

**File: `lib/features/search/presentation/providers/search_provider.dart`**

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/search_result_model.dart';
import '../../data/repositories/search_repository.dart';
import '../../../../core/network/dio_client.dart';

// Provider DioClient (singleton)
final dioClientProvider = Provider<DioClient>((ref) => DioClient());

// Provider Repository
final searchRepositoryProvider = Provider<SearchRepository>(
  (ref) => SearchRepository(ref.watch(dioClientProvider)),
);

// State: filter aktif
enum SearchFilter { semua, pt, prodi, dosen, mahasiswa }

final activeFilterProvider = StateProvider<SearchFilter>((ref) => SearchFilter.semua);

// State: hasil pencarian
final searchQueryProvider = StateProvider<String>((ref) => '');

final searchResultProvider = FutureProvider.autoDispose.family<SearchResultModel, String>(
  (ref, keyword) async {
    if (keyword.trim().isEmpty) {
      return const SearchResultModel(pt: [], prodi: [], dosen: [], mahasiswa: []);
    }
    final repo = ref.watch(searchRepositoryProvider);
    return repo.searchAll(keyword.trim());
  },
);
```

---

## FEATURE: SEARCH — SCREEN

**File: `lib/features/search/presentation/screens/search_screen.dart`**

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/search_provider.dart';
import '../widgets/filter_chip_bar.dart';
import '../widgets/pt_result_card.dart';
import '../widgets/prodi_result_card.dart';
import '../widgets/dosen_result_card.dart';
import '../widgets/mhs_result_card.dart';
import '../../data/models/search_result_model.dart';

class SearchScreen extends ConsumerStatefulWidget {
  final String initialQuery;
  const SearchScreen({super.key, this.initialQuery = ''});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  late TextEditingController _controller;
  final _debounce = ValueNotifier<String>('');

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialQuery);
    if (widget.initialQuery.isNotEmpty) {
      _debounce.value = widget.initialQuery;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref.read(searchQueryProvider.notifier).state = widget.initialQuery;
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onSearchChanged(String value) {
    Future.delayed(const Duration(milliseconds: 600), () {
      if (value == _controller.text) {
        ref.read(searchQueryProvider.notifier).state = value;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final query = ref.watch(searchQueryProvider);
    final filter = ref.watch(activeFilterProvider);
    final searchAsync = ref.watch(searchResultProvider(query));

    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _controller,
          autofocus: widget.initialQuery.isEmpty,
          decoration: const InputDecoration(
            hintText: 'Cari PT, prodi, dosen, mahasiswa...',
            border: InputBorder.none,
          ),
          textInputAction: TextInputAction.search,
          onChanged: _onSearchChanged,
          onSubmitted: (v) => ref.read(searchQueryProvider.notifier).state = v,
        ),
        actions: [
          if (_controller.text.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.clear),
              onPressed: () {
                _controller.clear();
                ref.read(searchQueryProvider.notifier).state = '';
              },
            ),
        ],
      ),
      body: Column(
        children: [
          const FilterChipBar(),
          Expanded(
            child: searchAsync.when(
              loading: () => _buildShimmer(),
              error: (e, _) => _buildError(e.toString()),
              data: (result) => _buildResults(result, filter),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResults(SearchResultModel result, SearchFilter filter) {
    if (ref.watch(searchQueryProvider).isEmpty) {
      return _buildEmptySearch();
    }
    if (result.isEmpty) {
      return _buildNoResults();
    }

    final items = <Widget>[];

    void addSection<T>(String label, List<T> list, Widget Function(T) builder) {
      if (list.isEmpty) return;
      if (filter != SearchFilter.semua) return;
      items.add(_SectionHeader(label: label, count: list.length));
      items.addAll(list.map(builder));
    }

    if (filter == SearchFilter.semua || filter == SearchFilter.pt) {
      if (filter == SearchFilter.semua) addSection('Perguruan Tinggi', result.pt, (e) => PtResultCard(model: e));
      if (filter == SearchFilter.pt) items.addAll(result.pt.map((e) => PtResultCard(model: e)));
    }
    if (filter == SearchFilter.semua || filter == SearchFilter.prodi) {
      if (filter == SearchFilter.semua) addSection('Program Studi', result.prodi, (e) => ProdiResultCard(model: e));
      if (filter == SearchFilter.prodi) items.addAll(result.prodi.map((e) => ProdiResultCard(model: e)));
    }
    if (filter == SearchFilter.semua || filter == SearchFilter.dosen) {
      if (filter == SearchFilter.semua) addSection('Dosen', result.dosen, (e) => DosenResultCard(model: e));
      if (filter == SearchFilter.dosen) items.addAll(result.dosen.map((e) => DosenResultCard(model: e)));
    }
    if (filter == SearchFilter.semua || filter == SearchFilter.mahasiswa) {
      if (filter == SearchFilter.semua) addSection('Mahasiswa', result.mahasiswa, (e) => MhsResultCard(model: e));
      if (filter == SearchFilter.mahasiswa) items.addAll(result.mahasiswa.map((e) => MhsResultCard(model: e)));
    }

    if (items.isEmpty) return _buildNoResults();

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: items.length,
      itemBuilder: (_, i) => items[i],
    );
  }

  Widget _buildEmptySearch() => const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.search, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text('Ketik nama untuk mulai mencari', style: TextStyle(color: Colors.grey)),
          ],
        ),
      );

  Widget _buildNoResults() => const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.search_off, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text('Tidak ada hasil ditemukan', style: TextStyle(color: Colors.grey)),
          ],
        ),
      );

  Widget _buildError(String message) => Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.cloud_off, size: 64, color: Colors.grey),
              const SizedBox(height: 16),
              Text(message, textAlign: TextAlign.center, style: const TextStyle(color: Colors.grey)),
              const SizedBox(height: 16),
              FilledButton.tonal(
                onPressed: () => ref.invalidate(searchResultProvider),
                child: const Text('Coba Lagi'),
              ),
            ],
          ),
        ),
      );

  Widget _buildShimmer() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: 6,
      itemBuilder: (_, __) => const _ShimmerCard(),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String label;
  final int count;
  const _SectionHeader({required this.label, required this.count});

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(top: 16, bottom: 8),
        child: Row(
          children: [
            Text(label, style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.w600,
                )),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text('$count', style: Theme.of(context).textTheme.labelSmall),
            ),
          ],
        ),
      );
}

class _ShimmerCard extends StatelessWidget {
  const _ShimmerCard();

  @override
  Widget build(BuildContext context) => Card(
        margin: const EdgeInsets.only(bottom: 8),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(height: 14, width: 200, color: Colors.grey.shade200),
              const SizedBox(height: 8),
              Container(height: 12, width: 140, color: Colors.grey.shade100),
            ],
          ),
        ),
      );
}
```

---

## FEATURE: SEARCH — WIDGETS

**File: `lib/features/search/presentation/widgets/filter_chip_bar.dart`**

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/search_provider.dart';

class FilterChipBar extends ConsumerWidget {
  const FilterChipBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final active = ref.watch(activeFilterProvider);

    final filters = [
      (SearchFilter.semua, 'Semua'),
      (SearchFilter.pt, 'PT'),
      (SearchFilter.prodi, 'Prodi'),
      (SearchFilter.dosen, 'Dosen'),
      (SearchFilter.mahasiswa, 'Mahasiswa'),
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: filters.map((f) {
          final selected = active == f.$1;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilterChip(
              label: Text(f.$2),
              selected: selected,
              onSelected: (_) => ref.read(activeFilterProvider.notifier).state = f.$1,
            ),
          );
        }).toList(),
      ),
    );
  }
}
```

**File: `lib/features/search/presentation/widgets/pt_result_card.dart`**

```dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../data/models/pt_result_model.dart';

class PtResultCard extends StatelessWidget {
  final PtResultModel model;
  const PtResultCard({super.key, required this.model});

  @override
  Widget build(BuildContext context) => Card(
        margin: const EdgeInsets.only(bottom: 8),
        child: ListTile(
          leading: CircleAvatar(
            backgroundColor: Theme.of(context).colorScheme.primaryContainer,
            child: Text(
              model.singkatan.isNotEmpty ? model.singkatan.substring(0, 1) : 'PT',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onPrimaryContainer,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          title: Text(model.nama, maxLines: 2, overflow: TextOverflow.ellipsis),
          subtitle: Text('${model.jenisLembaga} • ${model.kotaKab}, ${model.provinsi}'),
          trailing: _AkreditasiChip(akreditasi: model.akreditasi),
          onTap: () => context.push('/pt/${model.id}'),
        ),
      );
}

class _AkreditasiChip extends StatelessWidget {
  final String akreditasi;
  const _AkreditasiChip({required this.akreditasi});

  @override
  Widget build(BuildContext context) {
    final color = switch (akreditasi) {
      'Unggul' || 'A' => Colors.green,
      'Baik Sekali' || 'B' => Colors.blue,
      'Baik' || 'C' => Colors.orange,
      _ => Colors.grey,
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(akreditasi, style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w600)),
    );
  }
}
```

**File: `lib/features/search/presentation/widgets/prodi_result_card.dart`**

```dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../data/models/prodi_result_model.dart';

class ProdiResultCard extends StatelessWidget {
  final ProdiResultModel model;
  const ProdiResultCard({super.key, required this.model});

  @override
  Widget build(BuildContext context) => Card(
        margin: const EdgeInsets.only(bottom: 8),
        child: ListTile(
          leading: CircleAvatar(
            backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
            child: const Icon(Icons.school_outlined),
          ),
          title: Text(model.nama, maxLines: 2, overflow: TextOverflow.ellipsis),
          subtitle: Text('${model.jenjang} • ${model.namaUniversitas}', maxLines: 2, overflow: TextOverflow.ellipsis),
          trailing: Text(model.akreditasi, style: const TextStyle(fontWeight: FontWeight.w600)),
          onTap: () => context.push('/prodi/${model.id}'),
        ),
      );
}
```

**File: `lib/features/search/presentation/widgets/dosen_result_card.dart`**

```dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../data/models/dosen_result_model.dart';

class DosenResultCard extends StatelessWidget {
  final DosenResultModel model;
  const DosenResultCard({super.key, required this.model});

  @override
  Widget build(BuildContext context) => Card(
        margin: const EdgeInsets.only(bottom: 8),
        child: ListTile(
          leading: CircleAvatar(
            backgroundColor: Theme.of(context).colorScheme.tertiaryContainer,
            child: const Icon(Icons.person_outline),
          ),
          title: Text(model.nama, maxLines: 1, overflow: TextOverflow.ellipsis),
          subtitle: Text(
            '${model.jabatanAkademik} • ${model.namaUniversitas}',
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          trailing: model.pendidikanTertinggi.isNotEmpty
              ? Text(model.pendidikanTertinggi, style: const TextStyle(fontWeight: FontWeight.w600))
              : null,
          onTap: () => context.push('/dosen/${model.id}'),
        ),
      );
}
```

**File: `lib/features/search/presentation/widgets/mhs_result_card.dart`**

```dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../data/models/mhs_result_model.dart';

class MhsResultCard extends StatelessWidget {
  final MhsResultModel model;
  const MhsResultCard({super.key, required this.model});

  @override
  Widget build(BuildContext context) => Card(
        margin: const EdgeInsets.only(bottom: 8),
        child: ListTile(
          leading: CircleAvatar(
            backgroundColor: Theme.of(context).colorScheme.surfaceVariant,
            child: Text(
              model.nama.isNotEmpty ? model.nama[0].toUpperCase() : '?',
              style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
            ),
          ),
          title: Text(model.nama, maxLines: 1, overflow: TextOverflow.ellipsis),
          subtitle: Text(
            '${model.namaProdi} • ${model.namaUniversitas}',
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          trailing: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(model.angkatan, style: const TextStyle(fontWeight: FontWeight.w600)),
              Text(model.statusMahasiswa, style: const TextStyle(fontSize: 11)),
            ],
          ),
          onTap: () => context.push('/mhs/${model.id}'),
        ),
      );
}
```

---

## FEATURE: DETAIL — REPOSITORY

**File: `lib/features/detail/data/repositories/detail_repository.dart`**

```dart
import '../../../../core/network/dio_client.dart';
import '../../../../core/constants/api_constants.dart';

class DetailRepository {
  final DioClient _client;
  DetailRepository(this._client);

  Future<Map<String, dynamic>> getPtDetail(String id) async =>
      _client.get('${ApiConstants.ptDetail}/$id/');

  Future<Map<String, dynamic>> getPtRasio(String id) async =>
      _client.get('${ApiConstants.ptRasio}/$id/');

  Future<Map<String, dynamic>> getPtBiayaKuliah(String id) async =>
      _client.get('${ApiConstants.ptBiayaKuliah}/$id/');

  Future<Map<String, dynamic>> getProdiDetail(String id) async =>
      _client.get('${ApiConstants.prodiDetail}/$id/');

  Future<Map<String, dynamic>> getProdiDesc(String id) async =>
      _client.get('${ApiConstants.prodiDesc}/$id/');

  Future<Map<String, dynamic>> getProdiNumStudentsLecturers(String id) async =>
      _client.get('${ApiConstants.prodiNumStudentsLecturers}/$id/');

  Future<Map<String, dynamic>> getDosenProfile(String id) async =>
      _client.get('${ApiConstants.dosenProfile}/$id/');

  Future<Map<String, dynamic>> getDosenStudyHistory(String id) async =>
      _client.get('${ApiConstants.dosenStudyHistory}/$id/');

  Future<Map<String, dynamic>> getDosenTeachingHistory(String id) async =>
      _client.get('${ApiConstants.dosenTeachingHistory}/$id/');

  Future<Map<String, dynamic>> getMhsDetail(String id) async =>
      _client.get('${ApiConstants.mhsDetail}/$id/');
}
```

---

## FEATURE: DETAIL — PROVIDERS

**File: `lib/features/detail/presentation/providers/detail_provider.dart`**

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/detail_repository.dart';
import '../../../search/presentation/providers/search_provider.dart';

final detailRepositoryProvider = Provider<DetailRepository>(
  (ref) => DetailRepository(ref.watch(dioClientProvider)),
);

final ptDetailProvider = FutureProvider.autoDispose.family<Map<String, dynamic>, String>(
  (ref, id) => ref.watch(detailRepositoryProvider).getPtDetail(id),
);

final ptRasioProvider = FutureProvider.autoDispose.family<Map<String, dynamic>, String>(
  (ref, id) => ref.watch(detailRepositoryProvider).getPtRasio(id),
);

final ptBiayaKuliahProvider = FutureProvider.autoDispose.family<Map<String, dynamic>, String>(
  (ref, id) => ref.watch(detailRepositoryProvider).getPtBiayaKuliah(id),
);

final prodiDetailProvider = FutureProvider.autoDispose.family<Map<String, dynamic>, String>(
  (ref, id) => ref.watch(detailRepositoryProvider).getProdiDetail(id),
);

final prodiDescProvider = FutureProvider.autoDispose.family<Map<String, dynamic>, String>(
  (ref, id) => ref.watch(detailRepositoryProvider).getProdiDesc(id),
);

final prodiNumProvider = FutureProvider.autoDispose.family<Map<String, dynamic>, String>(
  (ref, id) => ref.watch(detailRepositoryProvider).getProdiNumStudentsLecturers(id),
);

final dosenProfileProvider = FutureProvider.autoDispose.family<Map<String, dynamic>, String>(
  (ref, id) => ref.watch(detailRepositoryProvider).getDosenProfile(id),
);

final dosenStudyHistoryProvider = FutureProvider.autoDispose.family<Map<String, dynamic>, String>(
  (ref, id) => ref.watch(detailRepositoryProvider).getDosenStudyHistory(id),
);

final dosenTeachingHistoryProvider = FutureProvider.autoDispose.family<Map<String, dynamic>, String>(
  (ref, id) => ref.watch(detailRepositoryProvider).getDosenTeachingHistory(id),
);

final mhsDetailProvider = FutureProvider.autoDispose.family<Map<String, dynamic>, String>(
  (ref, id) => ref.watch(detailRepositoryProvider).getMhsDetail(id),
);
```

---

## FEATURE: DETAIL — SCREENS

### PT Detail Screen

**File: `lib/features/detail/presentation/screens/pt_detail_screen.dart`**

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/detail_provider.dart';
import '../../../../core/constants/api_constants.dart';

class PtDetailScreen extends ConsumerWidget {
  final String idPt;
  const PtDetailScreen({super.key, required this.idPt});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detailAsync = ref.watch(ptDetailProvider(idPt));

    return Scaffold(
      body: detailAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => _ErrorView(message: e.toString(), onRetry: () => ref.invalidate(ptDetailProvider)),
        data: (json) {
          final data = json['data'] as Map<String, dynamic>? ?? {};
          return CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: 180,
                pinned: true,
                flexibleSpace: FlexibleSpaceBar(
                  title: Text(
                    data['nama_singkat']?.toString() ?? '',
                    style: const TextStyle(fontSize: 14),
                  ),
                  background: Container(
                    color: Theme.of(context).colorScheme.primaryContainer,
                    child: Center(
                      child: Image.network(
                        '${ApiConstants.primaryBaseUrl}${ApiConstants.ptLogo}/$idPt/',
                        height: 80,
                        errorBuilder: (_, __, ___) => Icon(
                          Icons.account_balance,
                          size: 64,
                          color: Theme.of(context).colorScheme.onPrimaryContainer,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.all(16),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    Text(data['nama_pt']?.toString() ?? '', style: Theme.of(context).textTheme.titleLarge),
                    const SizedBox(height: 4),
                    Text(data['npsn']?.toString() ?? '', style: Theme.of(context).textTheme.bodySmall),
                    const SizedBox(height: 16),
                    _InfoCard(items: [
                      _InfoItem('Bentuk PT', data['jenis_pt']?.toString() ?? '-'),
                      _InfoItem('Status', data['status']?.toString() ?? '-'),
                      _InfoItem('Akreditasi', data['akreditasi']?.toString() ?? '-'),
                      _InfoItem('Provinsi', data['provinsi']?.toString() ?? '-'),
                      _InfoItem('Kota/Kab', data['kota']?.toString() ?? '-'),
                      _InfoItem('Alamat', data['alamat']?.toString() ?? '-'),
                      _InfoItem('Telepon', data['telepon']?.toString() ?? '-'),
                      _InfoItem('Website', data['website']?.toString() ?? '-'),
                      _InfoItem('Email', data['email']?.toString() ?? '-'),
                    ]),
                    const SizedBox(height: 16),
                    _SectionTitle('Statistik'),
                    _InfoCard(items: [
                      _InfoItem('Jumlah Prodi', data['jumlah_prodi']?.toString() ?? '-'),
                      _InfoItem('Jumlah Mahasiswa', data['jumlah_mahasiswa']?.toString() ?? '-'),
                      _InfoItem('Jumlah Dosen', data['jumlah_dosen']?.toString() ?? '-'),
                    ]),
                  ]),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final List<_InfoItem> items;
  const _InfoCard({required this.items});

  @override
  Widget build(BuildContext context) => Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: items.map((item) => _InfoRow(item: item)).toList(),
          ),
        ),
      );
}

class _InfoItem {
  final String label;
  final String value;
  const _InfoItem(this.label, this.value);
}

class _InfoRow extends StatelessWidget {
  final _InfoItem item;
  const _InfoRow({required this.item});

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 130,
              child: Text(item.label, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey)),
            ),
            Expanded(
              child: Text(item.value.isNotEmpty ? item.value : '-', style: Theme.of(context).textTheme.bodyMedium),
            ),
          ],
        ),
      );
}

class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle(this.title);

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Text(title, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
      );
}

class _ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const _ErrorView({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) => Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.cloud_off, size: 64, color: Colors.grey),
              const SizedBox(height: 16),
              Text(message, textAlign: TextAlign.center),
              const SizedBox(height: 16),
              FilledButton.tonal(onPressed: onRetry, child: const Text('Coba Lagi')),
            ],
          ),
        ),
      );
}
```

### Prodi Detail Screen

**File: `lib/features/detail/presentation/screens/prodi_detail_screen.dart`**

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/detail_provider.dart';

class ProdiDetailScreen extends ConsumerWidget {
  final String idProdi;
  const ProdiDetailScreen({super.key, required this.idProdi});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detailAsync = ref.watch(prodiDetailProvider(idProdi));
    final numAsync = ref.watch(prodiNumProvider(idProdi));

    return Scaffold(
      appBar: AppBar(title: const Text('Detail Program Studi')),
      body: detailAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text(e.toString())),
        data: (json) {
          final data = json['data'] as Map<String, dynamic>? ?? {};
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text(data['nama_program_studi']?.toString() ?? '', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 4),
              InkWell(
                onTap: () => context.push('/pt/${data['id_pt']}'),
                child: Text(
                  data['nama_pt']?.toString() ?? '',
                  style: TextStyle(color: Theme.of(context).colorScheme.primary),
                ),
              ),
              const SizedBox(height: 16),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(children: [
                    _Row('Jenjang', data['jenjang']?.toString() ?? '-'),
                    _Row('Akreditasi', data['akreditasi']?.toString() ?? '-'),
                    _Row('Status', data['status_prodi']?.toString() ?? '-'),
                    _Row('Bidang Ilmu', data['bidang_ilmu']?.toString() ?? '-'),
                    _Row('Tanggal Berdiri', data['tanggal_berdiri']?.toString() ?? '-'),
                  ]),
                ),
              ),
              const SizedBox(height: 12),
              numAsync.when(
                loading: () => const LinearProgressIndicator(),
                error: (_, __) => const SizedBox(),
                data: (numJson) {
                  final d = numJson['data'] as Map<String, dynamic>? ?? {};
                  return Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(children: [
                        _Row('Jumlah Mahasiswa', d['jumlah_mahasiswa']?.toString() ?? '-'),
                        _Row('Jumlah Dosen', d['jumlah_dosen']?.toString() ?? '-'),
                      ]),
                    ),
                  );
                },
              ),
            ],
          );
        },
      ),
    );
  }
}

class _Row extends StatelessWidget {
  final String label;
  final String value;
  const _Row(this.label, this.value);

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 130,
              child: Text(label, style: const TextStyle(color: Colors.grey, fontSize: 13)),
            ),
            Expanded(child: Text(value.isNotEmpty ? value : '-')),
          ],
        ),
      );
}
```

### Dosen Detail Screen

**File: `lib/features/detail/presentation/screens/dosen_detail_screen.dart`**

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/detail_provider.dart';

class DosenDetailScreen extends ConsumerWidget {
  final String idDosen;
  const DosenDetailScreen({super.key, required this.idDosen});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(dosenProfileProvider(idDosen));
    final studyAsync = ref.watch(dosenStudyHistoryProvider(idDosen));
    final teachingAsync = ref.watch(dosenTeachingHistoryProvider(idDosen));

    return Scaffold(
      appBar: AppBar(title: const Text('Profil Dosen')),
      body: profileAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text(e.toString())),
        data: (json) {
          final data = json['data'] as Map<String, dynamic>? ?? {};
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Row(children: [
                CircleAvatar(radius: 32, child: Text(
                  (data['nama_dosen']?.toString() ?? '?')[0].toUpperCase(),
                  style: const TextStyle(fontSize: 24),
                )),
                const SizedBox(width: 16),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(data['nama_dosen']?.toString() ?? '', style: Theme.of(context).textTheme.titleMedium),
                  Text(data['jabatan_akademik']?.toString() ?? '', style: const TextStyle(color: Colors.grey)),
                ])),
              ]),
              const SizedBox(height: 16),
              Card(child: Padding(padding: const EdgeInsets.all(16), child: Column(children: [
                _Row('NIDN', data['nidn']?.toString() ?? '-'),
                _Row('Pendidikan Tertinggi', data['pendidikan_tertinggi']?.toString() ?? '-'),
                _Row('Status Ikatan Kerja', data['status_ikatan_kerja']?.toString() ?? '-'),
                _Row('Status Aktif', data['status_aktivitas']?.toString() ?? '-'),
              ]))),
              const SizedBox(height: 12),
              InkWell(
                onTap: () {
                  final idPt = data['id_pt']?.toString();
                  if (idPt != null && idPt.isNotEmpty) context.push('/pt/$idPt');
                },
                child: Card(child: Padding(padding: const EdgeInsets.all(16), child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Perguruan Tinggi', style: const TextStyle(color: Colors.grey, fontSize: 12)),
                    const SizedBox(height: 4),
                    Text(data['nama_pt']?.toString() ?? '-', style: TextStyle(color: Theme.of(context).colorScheme.primary)),
                    Text(data['nama_prodi']?.toString() ?? '-'),
                  ],
                ))),
              ),
              const SizedBox(height: 12),
              _HistorySection(title: 'Riwayat Pendidikan', asyncValue: studyAsync, field: 'riwayat_pendidikan'),
              const SizedBox(height: 12),
              _TeachingSection(asyncValue: teachingAsync),
            ],
          );
        },
      ),
    );
  }
}

class _Row extends StatelessWidget {
  final String label;
  final String value;
  const _Row(this.label, this.value);

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          SizedBox(width: 140, child: Text(label, style: const TextStyle(color: Colors.grey, fontSize: 13))),
          Expanded(child: Text(value.isNotEmpty ? value : '-')),
        ]),
      );
}

class _HistorySection extends StatelessWidget {
  final String title;
  final AsyncValue<Map<String, dynamic>> asyncValue;
  final String field;
  const _HistorySection({required this.title, required this.asyncValue, required this.field});

  @override
  Widget build(BuildContext context) => asyncValue.when(
        loading: () => const LinearProgressIndicator(),
        error: (_, __) => const SizedBox(),
        data: (json) {
          final list = json['data']?[field] as List? ?? [];
          if (list.isEmpty) return const SizedBox();
          return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(title, style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: 8),
            ...list.map((e) => Card(margin: const EdgeInsets.only(bottom: 8), child: Padding(
              padding: const EdgeInsets.all(12),
              child: Text(e.toString()),
            ))),
          ]);
        },
      );
}

class _TeachingSection extends StatelessWidget {
  final AsyncValue<Map<String, dynamic>> asyncValue;
  const _TeachingSection({required this.asyncValue});

  @override
  Widget build(BuildContext context) => asyncValue.when(
        loading: () => const LinearProgressIndicator(),
        error: (_, __) => const SizedBox(),
        data: (json) {
          final list = json['data'] as List? ?? [];
          if (list.isEmpty) return const SizedBox();
          return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Riwayat Mengajar', style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: 8),
            ...list.map((e) => Card(margin: const EdgeInsets.only(bottom: 8), child: ListTile(
              title: Text(e['nama_mata_kuliah']?.toString() ?? ''),
              subtitle: Text('${e['nama_prodi'] ?? ''} • ${e['semester'] ?? ''}'),
            ))),
          ]);
        },
      );
}
```

### Mahasiswa Detail Screen

**File: `lib/features/detail/presentation/screens/mhs_detail_screen.dart`**

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/detail_provider.dart';

class MhsDetailScreen extends ConsumerWidget {
  final String idMhs;
  const MhsDetailScreen({super.key, required this.idMhs});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detailAsync = ref.watch(mhsDetailProvider(idMhs));

    return Scaffold(
      appBar: AppBar(title: const Text('Detail Mahasiswa')),
      body: detailAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text(e.toString())),
        data: (json) {
          final data = json['data'] as Map<String, dynamic>? ?? {};
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Row(children: [
                CircleAvatar(
                  radius: 32,
                  child: Text(
                    (data['nama_mahasiswa']?.toString() ?? '?')[0].toUpperCase(),
                    style: const TextStyle(fontSize: 24),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(data['nama_mahasiswa']?.toString() ?? '', style: Theme.of(context).textTheme.titleMedium),
                  Text(data['nim']?.toString() ?? '', style: const TextStyle(color: Colors.grey)),
                ])),
              ]),
              const SizedBox(height: 16),
              Card(child: Padding(padding: const EdgeInsets.all(16), child: Column(children: [
                _Row('Jenis Kelamin', data['jenis_kelamin']?.toString() ?? '-'),
                _Row('Angkatan', data['angkatan']?.toString() ?? '-'),
                _Row('Status Mahasiswa', data['status_mahasiswa']?.toString() ?? '-'),
                _Row('Jenis Daftar', data['jenis_daftar']?.toString() ?? '-'),
              ]))),
              const SizedBox(height: 12),
              InkWell(
                onTap: () {
                  final idPt = data['id_pt']?.toString();
                  if (idPt != null && idPt.isNotEmpty) context.push('/pt/$idPt');
                },
                child: Card(child: Padding(padding: const EdgeInsets.all(16), child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Program Studi', style: const TextStyle(color: Colors.grey, fontSize: 12)),
                    const SizedBox(height: 4),
                    Text(data['nama_program_studi']?.toString() ?? '-', style: TextStyle(color: Theme.of(context).colorScheme.primary)),
                    Text(data['nama_pt']?.toString() ?? '-'),
                  ],
                ))),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _Row extends StatelessWidget {
  final String label;
  final String value;
  const _Row(this.label, this.value);

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          SizedBox(width: 140, child: Text(label, style: const TextStyle(color: Colors.grey, fontSize: 13))),
          Expanded(child: Text(value.isNotEmpty ? value : '-')),
        ]),
      );
}
```

---

## HOME SCREEN

**File: `lib/features/home/presentation/screens/home_screen.dart`**

```dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 48),
              Text('PDDikti', style: Theme.of(context).textTheme.displaySmall?.copyWith(fontWeight: FontWeight.bold)),
              Text('Explorer', style: Theme.of(context).textTheme.displaySmall?.copyWith(
                color: Theme.of(context).colorScheme.primary,
                fontWeight: FontWeight.bold,
              )),
              const SizedBox(height: 8),
              Text(
                'Cari data perguruan tinggi, program studi, dosen, dan mahasiswa Indonesia.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey),
              ),
              const SizedBox(height: 32),
              // Search bar sebagai tap-only (bukan TextField, buka SearchScreen)
              InkWell(
                onTap: () => context.push('/search'),
                borderRadius: BorderRadius.circular(28),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surfaceVariant,
                    borderRadius: BorderRadius.circular(28),
                  ),
                  child: Row(children: [
                    Icon(Icons.search, color: Theme.of(context).colorScheme.onSurfaceVariant),
                    const SizedBox(width: 12),
                    Text('Cari PT, prodi, dosen, mahasiswa...', style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    )),
                  ]),
                ),
              ),
              const SizedBox(height: 32),
              Text('Kategori', style: Theme.of(context).textTheme.titleSmall),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _CategoryChip(icon: Icons.account_balance, label: 'Perguruan Tinggi', onTap: () => context.push('/search?q=universitas')),
                  _CategoryChip(icon: Icons.school, label: 'Program Studi', onTap: () => context.push('/search?q=informatika')),
                  _CategoryChip(icon: Icons.person, label: 'Dosen', onTap: () => context.push('/search?q=dosen')),
                  _CategoryChip(icon: Icons.badge, label: 'Mahasiswa', onTap: () => context.push('/search?q=mahasiswa')),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CategoryChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _CategoryChip({required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) => ActionChip(
        avatar: Icon(icon, size: 18),
        label: Text(label),
        onPressed: onTap,
      );
}
```

---

## MAIN.DART

**File: `lib/main.dart`**

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';

void main() {
  runApp(const ProviderScope(child: PddiktiApp()));
}

class PddiktiApp extends StatelessWidget {
  const PddiktiApp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp.router(
        title: 'PDDikti Explorer',
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.system,
        routerConfig: appRouter,
        debugShowCheckedModeBanner: false,
      );
}
```

---

## CATATAN PENTING

1. **API rate limit**: Saat ini API dalam mode `limited` karena high traffic. Handler 503 sudah ada di `DioClient` — otomatis fallback ke `pddikti.fastapicloud.dev`. Jika masih 503, tampilkan pesan retry ke user.

2. **Field JSON**: Struktur response PDDikti API tidak memiliki schema eksplisit di OpenAPI-nya (schema kosong `{}`). Field names di model (`nama_pt`, `nama_prodi`, dll) sudah diinfer dari konvensi PDDikti — validasi dengan live API saat development dan sesuaikan jika ada mismatch.

3. **Logo PT**: Endpoint `/api/pt/logo/{id_pt}/` mengembalikan JSON, bukan langsung gambar. Cek response-nya dulu saat live testing — mungkin ada field `url` di dalam JSON.

4. **Shimmer**: Sudah ada placeholder shimmer sementara di search. Untuk improvement, install package `shimmer` dan replace `_ShimmerCard` dengan animasi shimmer yang proper.

5. **MVP scope**: Detail screen untuk masing-masing entitas menampilkan data dasar. Iterasi berikutnya bisa tambah: statistik PT, biaya kuliah, list prodi per PT, portofolio dosen (penelitian/karya/paten).
