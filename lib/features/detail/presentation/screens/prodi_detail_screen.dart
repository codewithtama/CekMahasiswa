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
    final numAsync = ref.watch(prodiDescProvider(idProdi)); // Point to description endpoint directly

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
              Text(data['nama_prodi']?.toString() ?? '', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 4),
              InkWell(
                onTap: () {
                  final idPt = data['id_sp']?.toString(); // using id_sp as fallback for PT id
                  if (idPt != null && idPt.isNotEmpty) {
                    context.push('/pt/$idPt');
                  }
                },
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
                    _Row('Jenjang', data['jenj_didik']?.toString() ?? '-'),
                    _Row('Akreditasi', data['akreditasi']?.toString() ?? '-'),
                    _Row('Status', data['status']?.toString() ?? '-'),
                    _Row('Bidang Ilmu', data['kel_bidang']?.toString() ?? '-'),
                    _Row('Tanggal Berdiri', data['tgl_berdiri'] != null
                        ? data['tgl_berdiri'].toString().split('T')[0]
                        : '-'),
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
              width: 120,
              child: Text(label, style: const TextStyle(color: Colors.grey, fontSize: 13)),
            ),
            Expanded(child: Text(value.isNotEmpty ? value : '-')),
          ],
        ),
      );
}
