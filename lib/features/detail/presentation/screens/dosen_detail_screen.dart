import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/detail_provider.dart';
import '../widgets/share_preview_dialog.dart';

class DosenDetailScreen extends ConsumerWidget {
  final String idDosen;
  const DosenDetailScreen({super.key, required this.idDosen});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(dosenProfileProvider(idDosen));
    final studyAsync = ref.watch(dosenStudyHistoryProvider(idDosen));
    final teachingAsync = ref.watch(dosenTeachingHistoryProvider(idDosen));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profil Dosen'),
        actions: [
          profileAsync.when(
            data: (json) {
              final data = json['data'] as Map<String, dynamic>? ?? {};
              if (data.isEmpty) return const SizedBox.shrink();
              return IconButton(
                icon: const Icon(Icons.share_outlined),
                onPressed: () {
                  final eduList = studyAsync.when(
                    data: (js) {
                      const field = 'riwayat_pendidikan';
                      return js['data']?[field] as List? ?? js['data'] as List? ?? [];
                    },
                    loading: () => [],
                    error: (_, __) => [],
                  );
                  final teachingList = teachingAsync.when(
                    data: (js) => js['data'] as List? ?? [],
                    loading: () => [],
                    error: (_, __) => [],
                  );

                  showDialog(
                    context: context,
                    builder: (context) => SharePreviewDialog(
                      data: data,
                      type: 'dosen',
                      eduHistory: eduList,
                      teachingHistory: teachingList,
                    ),
                  );
                },
              );
            },
            loading: () => const SizedBox.shrink(),
            error: (_, __) => const SizedBox.shrink(),
          ),
        ],
      ),
      body: profileAsync.when(
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
                    (data['nama_dosen']?.toString() ?? '?')[0].toUpperCase(),
                    style: const TextStyle(fontSize: 24),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(data['nama_dosen']?.toString() ?? '', style: Theme.of(context).textTheme.titleMedium),
                      Text(data['jabatan_akademik']?.toString() ?? '', style: const TextStyle(color: Colors.grey)),
                    ],
                  ),
                ),
              ]),
              const SizedBox(height: 16),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(children: [
                    _Row('NIDN', data['nidn']?.toString() ?? '-'),
                    _Row('Pendidikan Tertinggi', data['pendidikan_tertinggi']?.toString() ?? '-'),
                    _Row('Status Ikatan Kerja', data['status_ikatan_kerja']?.toString() ?? '-'),
                    _Row('Status Aktif', data['status_aktivitas']?.toString() ?? '-'),
                  ]),
                ),
              ),
              const SizedBox(height: 12),
              InkWell(
                onTap: () {
                  final idPt = data['id_pt']?.toString();
                  if (idPt != null && idPt.isNotEmpty) {
                    context.push('/pt/$idPt');
                  }
                },
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Perguruan Tinggi', style: TextStyle(color: Colors.grey, fontSize: 12)),
                        const SizedBox(height: 4),
                        Text(
                          data['nama_pt']?.toString() ?? '-',
                          style: TextStyle(color: Theme.of(context).colorScheme.primary),
                        ),
                        Text(data['nama_prodi']?.toString() ?? '-'),
                      ],
                    ),
                  ),
                ),
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
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(width: 120, child: Text(label, style: const TextStyle(color: Colors.grey, fontSize: 13))),
            Expanded(child: Text(value.isNotEmpty ? value : '-')),
          ],
        ),
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
          final list = json['data']?[field] as List? ?? json['data'] as List? ?? [];
          if (list.isEmpty) return const SizedBox();
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: Theme.of(context).textTheme.titleSmall),
              const SizedBox(height: 8),
              ...list.map((e) => _HistoryCard(data: e)),
            ],
          );
        },
      );
}

class _HistoryCard extends StatelessWidget {
  final dynamic data;
  const _HistoryCard({required this.data});

  @override
  Widget build(BuildContext context) {
    if (data is Map) {
      final map = data as Map;
      final jenjang = map['jenjang']?.toString() ?? map['gelar']?.toString() ?? '-';
      final pt = map['nama_pt']?.toString() ?? map['perguruan_tinggi']?.toString() ?? map['pt']?.toString() ?? '-';
      final prodi = map['nama_prodi']?.toString() ?? map['program_studi']?.toString() ?? map['prodi']?.toString() ?? '';
      final tahun = map['tahun_lulus']?.toString() ?? map['tahun']?.toString() ?? '';
      final singkatanGelar = map['singkatan_gelar']?.toString() ?? '';
      final gelarAkademik = map['gelar_akademik']?.toString() ?? '';
      
      final titleText = prodi.isNotEmpty ? '$jenjang $prodi' : jenjang;
      final displayTitle = singkatanGelar.isNotEmpty 
          ? '$titleText, $singkatanGelar'
          : (gelarAkademik.isNotEmpty ? '$titleText ($gelarAkademik)' : titleText);
      
      return Card(
        margin: const EdgeInsets.only(bottom: 8),
        child: ListTile(
          leading: CircleAvatar(
            backgroundColor: Theme.of(context).colorScheme.primaryContainer,
            child: Text(
              jenjang.length > 2 ? jenjang.substring(0, 2) : jenjang,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onPrimaryContainer,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          title: Text(displayTitle, style: const TextStyle(fontWeight: FontWeight.w600)),
          subtitle: Text(pt),
          trailing: tahun.isNotEmpty ? Text(tahun, style: const TextStyle(fontWeight: FontWeight.w500)) : null,
        ),
      );
    }
    
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Text(data.toString()),
      ),
    );
  }
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
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Riwayat Mengajar', style: Theme.of(context).textTheme.titleSmall),
              const SizedBox(height: 8),
              ...list.map((e) => Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      title: Text(
                        e['nama_matkul']?.toString() ?? '',
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      subtitle: Text(
                        '${e['nama_pt'] ?? ''}\nKelas ${e['nama_kelas'] ?? ''} • ${e['nama_semester'] ?? ''}',
                        style: const TextStyle(fontSize: 12, height: 1.3),
                      ),
                      isThreeLine: true,
                    ),
                  )),
            ],
          );
        },
      );
}
