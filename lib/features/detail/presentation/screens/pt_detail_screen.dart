import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/detail_provider.dart';

class PtDetailScreen extends ConsumerWidget {
  final String idPt;
  const PtDetailScreen({super.key, required this.idPt});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detailAsync = ref.watch(ptDetailProvider(idPt));
    final prodiCountAsync = ref.watch(ptJumlahProdiProvider(idPt));
    final mhsCountAsync = ref.watch(ptJumlahMhsProvider(idPt));
    final dosenCountAsync = ref.watch(ptJumlahDosenProvider(idPt));

    return Scaffold(
      body: detailAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => _ErrorView(
          message: e.toString(),
          onRetry: () {
            ref.invalidate(ptDetailProvider(idPt));
            ref.invalidate(ptJumlahProdiProvider(idPt));
            ref.invalidate(ptJumlahMhsProvider(idPt));
            ref.invalidate(ptJumlahDosenProvider(idPt));
          },
        ),
        data: (json) {
          final data = json['data'] as Map<String, dynamic>? ?? {};
          return CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: 180,
                pinned: true,
                flexibleSpace: FlexibleSpaceBar(
                  title: Text(
                    data['nm_singkat']?.toString() ?? data['nama_singkat']?.toString() ?? '',
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                  ),
                  background: Container(
                    color: Theme.of(context).colorScheme.primaryContainer,
                    child: Center(
                      child: Image.network(
                        'https://api-pddikti.kemdiktisaintek.go.id/pt/logo/$idPt',
                        headers: const {
                          'Accept': 'image/*, */*',
                          'Host': 'api-pddikti.kemdiktisaintek.go.id',
                          'Origin': 'https://pddikti.kemdiktisaintek.go.id',
                          'Referer': 'https://pddikti.kemdiktisaintek.go.id/',
                          'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/131.0.0.0 Safari/537.36',
                        },
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
                    Text(data['kode_pt']?.toString() ?? '', style: Theme.of(context).textTheme.bodySmall),
                    const SizedBox(height: 16),
                    _InfoCard(items: [
                      _InfoItem('Bentuk PT', data['kelompok']?.toString() ?? '-'),
                      _InfoItem('Status', data['status_pt']?.toString() ?? '-'),
                      _InfoItem('Akreditasi', data['akreditasi_pt']?.toString() ?? '-'),
                      _InfoItem('Provinsi', data['provinsi_pt']?.toString() ?? '-'),
                      _InfoItem('Kabupaten/Kota', data['kab_kota_pt']?.toString() ?? '-'),
                      _InfoItem('Alamat', data['alamat']?.toString() ?? '-'),
                      _InfoItem('Telepon', data['no_tel']?.toString() ?? '-'),
                      _InfoItem('Website', data['website']?.toString() ?? '-'),
                      _InfoItem('Email', data['email']?.toString() ?? '-'),
                    ]),
                    const SizedBox(height: 16),
                    const _SectionTitle('Statistik'),
                    _InfoCard(items: [
                      _InfoItem('Jumlah Program Studi', prodiCountAsync.when(
                        data: (json) => (json['data']?['jumlah_prodi'] ?? json['jumlah_prodi'] ?? '-').toString(),
                        loading: () => '...',
                        error: (_, __) => '-',
                      )),
                      _InfoItem('Jumlah Mahasiswa', mhsCountAsync.when(
                        data: (json) => (json['data']?['jumlah_mahasiswa'] ?? json['jumlah_mahasiswa'] ?? '-').toString(),
                        loading: () => '...',
                        error: (_, __) => '-',
                      )),
                      _InfoItem('Jumlah Dosen', dosenCountAsync.when(
                        data: (json) => (json['data']?['jumlah_dosen'] ?? json['jumlah_dosen'] ?? '-').toString(),
                        loading: () => '...',
                        error: (_, __) => '-',
                      )),
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
              width: 120,
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
