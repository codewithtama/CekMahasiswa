import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/detail_repository.dart';
import '../../../search/presentation/providers/search_provider.dart';

final detailRepositoryProvider = Provider<DetailRepository>(
  (ref) => DetailRepository(ref.watch(dioClientProvider)),
);

final ptDetailProvider = FutureProvider.autoDispose.family<Map<String, dynamic>, String>(
  (ref, id) => ref.watch(detailRepositoryProvider).getPtDetail(id),
);

final ptJumlahProdiProvider = FutureProvider.autoDispose.family<Map<String, dynamic>, String>(
  (ref, id) => ref.watch(detailRepositoryProvider).getPtJumlahProdi(id),
);

final ptJumlahMhsProvider = FutureProvider.autoDispose.family<Map<String, dynamic>, String>(
  (ref, id) => ref.watch(detailRepositoryProvider).getPtJumlahMhs(id),
);

final ptJumlahDosenProvider = FutureProvider.autoDispose.family<Map<String, dynamic>, String>(
  (ref, id) => ref.watch(detailRepositoryProvider).getPtJumlahDosen(id),
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

final dosenProfileProvider = FutureProvider.autoDispose.family<Map<String, dynamic>, String>(
  (ref, id) => ref.watch(detailRepositoryProvider).getDosenProfile(id),
);

final dosenStudyHistoryProvider = FutureProvider.autoDispose.family<Map<String, dynamic>, String>(
  (ref, id) => ref.watch(detailRepositoryProvider).getDosenStudyHistory(id),
);

final dosenTeachingHistoryProvider = FutureProvider.autoDispose.family<Map<String, dynamic>, String>(
  (ref, id) => ref.watch(detailRepositoryProvider).getDosenTeachingHistory(id),
);

final dosenPenelitianProvider = FutureProvider.autoDispose.family<Map<String, dynamic>, String>(
  (ref, id) => ref.watch(detailRepositoryProvider).getDosenPenelitian(id),
);

final dosenPengabdianProvider = FutureProvider.autoDispose.family<Map<String, dynamic>, String>(
  (ref, id) => ref.watch(detailRepositoryProvider).getDosenPengabdian(id),
);

final dosenKaryaProvider = FutureProvider.autoDispose.family<Map<String, dynamic>, String>(
  (ref, id) => ref.watch(detailRepositoryProvider).getDosenKarya(id),
);

final dosenPatenProvider = FutureProvider.autoDispose.family<Map<String, dynamic>, String>(
  (ref, id) => ref.watch(detailRepositoryProvider).getDosenPaten(id),
);

final mhsDetailProvider = FutureProvider.autoDispose.family<Map<String, dynamic>, String>(
  (ref, id) => ref.watch(detailRepositoryProvider).getMhsDetail(id),
);
