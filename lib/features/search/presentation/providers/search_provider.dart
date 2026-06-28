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

// PT Filters
final ptAccreditationFilterProvider = StateProvider<String?>((ref) => null);
final ptProvinceFilterProvider = StateProvider<String?>((ref) => null);
final ptTypeFilterProvider = StateProvider<String?>((ref) => null);

final searchResultProvider = FutureProvider.autoDispose.family<SearchResultModel, String>(
  (ref, keyword) async {
    if (keyword.trim().isEmpty) {
      return const SearchResultModel(pt: [], prodi: [], dosen: [], mahasiswa: []);
    }
    final repo = ref.watch(searchRepositoryProvider);
    return repo.searchAll(keyword.trim());
  },
);
