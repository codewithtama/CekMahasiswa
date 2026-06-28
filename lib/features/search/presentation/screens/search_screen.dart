import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shimmer/shimmer.dart';
import '../providers/search_provider.dart';
import '../providers/search_history_provider.dart';
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

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialQuery);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _resetFilters();
      if (widget.initialQuery.isNotEmpty) {
        ref.read(searchQueryProvider.notifier).state = widget.initialQuery;
        ref.read(searchHistoryProvider.notifier).addQuery(widget.initialQuery);
      }
    });
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
        _resetFilters();
        if (value.trim().isNotEmpty) {
          ref.read(searchHistoryProvider.notifier).addQuery(value);
        }
      }
    });
  }

  void _resetFilters() {
    ref.read(ptAccreditationFilterProvider.notifier).state = null;
    ref.read(ptProvinceFilterProvider.notifier).state = null;
    ref.read(ptTypeFilterProvider.notifier).state = null;
  }

  @override
  Widget build(BuildContext context) {
    final query = ref.watch(searchQueryProvider);
    final filter = ref.watch(activeFilterProvider);
    final searchAsync = ref.watch(searchResultProvider(query));

    return Scaffold(
      appBar: AppBar(
        title: Container(
          height: 42,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: Theme.of(context).colorScheme.outlineVariant.withValues(alpha: 0.2),
              width: 1,
            ),
          ),
          child: TextField(
            controller: _controller,
            autofocus: widget.initialQuery.isEmpty,
            decoration: InputDecoration(
              filled: false,
              hintText: 'Cari PT, prodi, dosen, mahasiswa...',
              hintStyle: TextStyle(
                fontSize: 13,
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.4),
              ),
              prefixIcon: Icon(Icons.search, size: 18, color: Theme.of(context).colorScheme.primary),
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(vertical: 8),
            ),
            style: const TextStyle(fontSize: 14),
            textInputAction: TextInputAction.search,
            onChanged: _onSearchChanged,
            onSubmitted: (v) {
              ref.read(searchQueryProvider.notifier).state = v;
              _resetFilters();
              if (v.trim().isNotEmpty) {
                ref.read(searchHistoryProvider.notifier).addQuery(v);
              }
            },
          ),
        ),
        actions: [
          if (_controller.text.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.clear),
              onPressed: () {
                _controller.clear();
                ref.read(searchQueryProvider.notifier).state = '';
                _resetFilters();
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

    // Apply PT Filters
    final selectedAcc = ref.watch(ptAccreditationFilterProvider);
    final selectedProv = ref.watch(ptProvinceFilterProvider);
    final selectedType = ref.watch(ptTypeFilterProvider);

    var filteredPt = result.pt;
    if (selectedAcc != null) {
      filteredPt = filteredPt.where((pt) => pt.akreditasi == selectedAcc).toList();
    }
    if (selectedProv != null) {
      filteredPt = filteredPt.where((pt) => pt.provinsi == selectedProv).toList();
    }
    if (selectedType != null) {
      filteredPt = filteredPt.where((pt) => pt.jenisLembaga == selectedType).toList();
    }

    final items = <Widget>[];

    void addSection<T>(String label, List<T> list, Widget Function(T) builder) {
      if (list.isEmpty) return;
      if (filter != SearchFilter.semua) return;
      items.add(_SectionHeader(label: label, count: list.length));
      items.addAll(list.map(builder));
    }

    if (filter == SearchFilter.semua || filter == SearchFilter.pt) {
      if (filter == SearchFilter.semua) addSection('Perguruan Tinggi', filteredPt, (e) => PtResultCard(model: e));
      if (filter == SearchFilter.pt) items.addAll(filteredPt.map((e) => PtResultCard(model: e)));
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

    final resultsList = items.isEmpty
        ? _buildNoResults()
        : ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            itemCount: items.length,
            itemBuilder: (_, i) => items[i],
          );

    final showFilter = result.pt.isNotEmpty && (filter == SearchFilter.semua || filter == SearchFilter.pt);

    if (showFilter) {
      return Column(
        children: [
          _buildPtFilterToolbar(context, result),
          Expanded(child: resultsList),
        ],
      );
    }

    return resultsList;
  }

  Widget _buildPtFilterToolbar(BuildContext context, SearchResultModel result) {
    final selectedAcc = ref.watch(ptAccreditationFilterProvider);
    final selectedProv = ref.watch(ptProvinceFilterProvider);
    final selectedType = ref.watch(ptTypeFilterProvider);

    final hasActiveFilter = selectedAcc != null || selectedProv != null || selectedType != null;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerLow,
        border: Border(
          bottom: BorderSide(color: Theme.of(context).colorScheme.outlineVariant, width: 0.5),
        ),
      ),
      child: Row(
        children: [
          OutlinedButton.icon(
            icon: Badge(
              isLabelVisible: hasActiveFilter,
              child: const Icon(Icons.tune, size: 16),
            ),
            label: const Text('Filter PT', style: TextStyle(fontSize: 12)),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            onPressed: () => _showFilterBottomSheet(context, result),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  if (selectedAcc != null) ...[
                    _buildActiveChip(
                      'Akreditasi: $selectedAcc',
                      () => ref.read(ptAccreditationFilterProvider.notifier).state = null,
                    ),
                    const SizedBox(width: 4),
                  ],
                  if (selectedProv != null) ...[
                    _buildActiveChip(
                      'Provinsi: $selectedProv',
                      () => ref.read(ptProvinceFilterProvider.notifier).state = null,
                    ),
                    const SizedBox(width: 4),
                  ],
                  if (selectedType != null) ...[
                    _buildActiveChip(
                      'Jenis: $selectedType',
                      () => ref.read(ptTypeFilterProvider.notifier).state = null,
                    ),
                    const SizedBox(width: 4),
                  ],
                ],
              ),
            ),
          ),
          if (hasActiveFilter)
            TextButton(
              onPressed: _resetFilters,
              child: const Text('Reset', style: TextStyle(fontSize: 12)),
            ),
        ],
      ),
    );
  }

  Widget _buildActiveChip(String label, VoidCallback onRemove) {
    return InputChip(
      label: Text(label, style: const TextStyle(fontSize: 11)),
      onDeleted: onRemove,
      deleteIcon: const Icon(Icons.close, size: 12),
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      visualDensity: VisualDensity.compact,
      padding: EdgeInsets.zero,
    );
  }

  void _showFilterBottomSheet(BuildContext context, SearchResultModel result) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => _PtFilterBottomSheet(result: result),
    );
  }

  Widget _buildEmptySearch() {
    final history = ref.watch(searchHistoryProvider);
    if (history.isEmpty) {
      return const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.search, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text('Ketik nama untuk mulai mencari', style: TextStyle(color: Colors.grey)),
          ],
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Pencarian Terakhir',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                  ),
            ),
            TextButton.icon(
              onPressed: () => ref.read(searchHistoryProvider.notifier).clearHistory(),
              icon: const Icon(Icons.delete_sweep_outlined, size: 16),
              label: const Text('Hapus Semua', style: TextStyle(fontSize: 12)),
              style: TextButton.styleFrom(
                foregroundColor: Theme.of(context).colorScheme.error,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ...history.map((query) => Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                leading: const Icon(Icons.history, size: 20),
                title: Text(query, style: const TextStyle(fontSize: 14)),
                trailing: IconButton(
                  icon: const Icon(Icons.clear, size: 16),
                  onPressed: () {
                    ref.read(searchHistoryProvider.notifier).deleteQuery(query);
                  },
                ),
                onTap: () {
                  _controller.text = query;
                  ref.read(searchQueryProvider.notifier).state = query;
                  _resetFilters();
                },
              ),
            )),
      ],
    );
  }

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
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final baseColor = isDark ? Colors.grey.shade800 : Colors.grey.shade300;
    final highlightColor = isDark ? Colors.grey.shade700 : Colors.grey.shade100;

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Shimmer.fromColors(
          baseColor: baseColor,
          highlightColor: highlightColor,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 16,
                width: 220,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const SizedBox(height: 12),
              Container(
                height: 12,
                width: 140,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PtFilterBottomSheet extends ConsumerWidget {
  final SearchResultModel result;
  const _PtFilterBottomSheet({required this.result});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final accreditations = result.pt
        .map((e) => e.akreditasi)
        .where((e) => e.trim().isNotEmpty && e != '-')
        .toSet()
        .toList()..sort();
    
    final provinces = result.pt
        .map((e) => e.provinsi)
        .where((e) => e.trim().isNotEmpty)
        .toSet()
        .toList()..sort();
        
    final types = result.pt
        .map((e) => e.jenisLembaga)
        .where((e) => e.trim().isNotEmpty)
        .toSet()
        .toList()..sort();

    final selectedAcc = ref.watch(ptAccreditationFilterProvider);
    final selectedProv = ref.watch(ptProvinceFilterProvider);
    final selectedType = ref.watch(ptTypeFilterProvider);

    final safeSelectedAcc = accreditations.contains(selectedAcc) ? selectedAcc : null;
    final safeSelectedProv = provinces.contains(selectedProv) ? selectedProv : null;
    final safeSelectedType = types.contains(selectedType) ? selectedType : null;

    return SafeArea(
      child: Container(
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
          top: 20,
          bottom: MediaQuery.of(context).viewInsets.bottom + 20,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Filter Perguruan Tinggi',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                TextButton(
                  onPressed: () {
                    ref.read(ptAccreditationFilterProvider.notifier).state = null;
                    ref.read(ptProvinceFilterProvider.notifier).state = null;
                    ref.read(ptTypeFilterProvider.notifier).state = null;
                  },
                  child: const Text('Reset'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Dropdown Akreditasi
            DropdownButtonFormField<String?>(
              key: ValueKey('acc_${safeSelectedAcc ?? 'null'}'),
              initialValue: safeSelectedAcc,
              decoration: const InputDecoration(
                labelText: 'Akreditasi',
                prefixIcon: Icon(Icons.star_outline),
              ),
              items: [
                const DropdownMenuItem(value: null, child: Text('Semua Akreditasi')),
                ...accreditations.map((acc) => DropdownMenuItem(value: acc, child: Text(acc))),
              ],
              onChanged: (val) {
                ref.read(ptAccreditationFilterProvider.notifier).state = val;
              },
            ),
            const SizedBox(height: 16),

            // Dropdown Provinsi
            DropdownButtonFormField<String?>(
              key: ValueKey('prov_${safeSelectedProv ?? 'null'}'),
              initialValue: safeSelectedProv,
              decoration: const InputDecoration(
                labelText: 'Provinsi',
                prefixIcon: Icon(Icons.map_outlined),
              ),
              items: [
                const DropdownMenuItem(value: null, child: Text('Semua Provinsi')),
                ...provinces.map((prov) => DropdownMenuItem(value: prov, child: Text(prov))),
              ],
              onChanged: (val) {
                ref.read(ptProvinceFilterProvider.notifier).state = val;
              },
            ),
            const SizedBox(height: 16),

            // Dropdown Jenis Lembaga
            DropdownButtonFormField<String?>(
              key: ValueKey('type_${safeSelectedType ?? 'null'}'),
              initialValue: safeSelectedType,
              decoration: const InputDecoration(
                labelText: 'Jenis Lembaga',
                prefixIcon: Icon(Icons.account_balance_outlined),
              ),
              items: [
                const DropdownMenuItem(value: null, child: Text('Semua Jenis')),
                ...types.map((type) => DropdownMenuItem(value: type, child: Text(type))),
              ],
              onChanged: (val) {
                ref.read(ptTypeFilterProvider.notifier).state = val;
              },
            ),
            const SizedBox(height: 24),

            // Action Button
            FilledButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Terapkan'),
            ),
          ],
        ),
      ),
    );
  }
}
