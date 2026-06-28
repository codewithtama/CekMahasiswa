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
