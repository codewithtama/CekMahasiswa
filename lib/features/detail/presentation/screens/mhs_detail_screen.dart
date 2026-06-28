import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/detail_provider.dart';
import '../widgets/share_preview_dialog.dart';

class MhsDetailScreen extends ConsumerWidget {
  final String idMhs;
  const MhsDetailScreen({super.key, required this.idMhs});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detailAsync = ref.watch(mhsDetailProvider(idMhs));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Mahasiswa'),
        actions: [
          detailAsync.when(
            data: (json) {
              final data = json['data'] as Map<String, dynamic>? ?? {};
              if (data.isEmpty) return const SizedBox.shrink();
              return IconButton(
                icon: const Icon(Icons.share_outlined),
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) => SharePreviewDialog(
                      data: data,
                      type: 'mahasiswa',
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
                    (data['nama']?.toString() ?? '?')[0].toUpperCase(),
                    style: const TextStyle(fontSize: 24),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(data['nama']?.toString() ?? '', style: Theme.of(context).textTheme.titleMedium),
                      Text(data['nim']?.toString() ?? '', style: const TextStyle(color: Colors.grey)),
                    ],
                  ),
                ),
              ]),
              const SizedBox(height: 16),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(children: [
                    _Row('Jenis Kelamin', data['jenis_kelamin']?.toString() ?? '-'),
                    _Row('Tanggal Masuk', data['tanggal_masuk']?.toString() ?? '-'),
                    _Row('Status Mahasiswa', data['status_saat_ini']?.toString() ?? '-'),
                    _Row('Jenis Daftar', data['jenis_daftar']?.toString() ?? '-'),
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
                        const Text('Program Studi', style: TextStyle(color: Colors.grey, fontSize: 12)),
                        const SizedBox(height: 4),
                        Text(
                          data['prodi']?.toString() ?? '-',
                          style: TextStyle(color: Theme.of(context).colorScheme.primary),
                        ),
                        Text(data['nama_pt']?.toString() ?? '-'),
                      ],
                    ),
                  ),
                ),
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
            SizedBox(width: 120, child: Text(label, style: const TextStyle(color: Colors.grey, fontSize: 13))),
            Expanded(child: Text(value.isNotEmpty ? value : '-')),
          ],
        ),
      );
}
