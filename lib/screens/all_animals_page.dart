import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../app_theme.dart';
import '../models/animal.dart';
import '../providers/animal_browser_provider.dart';
import '../widgets/animal_card.dart';
import '../widgets/animal_filter_sheet.dart';
import '../widgets/animal_search_field.dart';
import '../widgets/app_ui.dart';
import 'animal_detail_page.dart';

class AllAnimalsPage extends ConsumerWidget {
  const AllAnimalsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(animalBrowserProvider);
    final animalsAsync = ref.watch(filteredAnimalsProvider);
    final activeFilters = <Widget>[
      if (state.category != AnimalFilterCategory.all)
        _FilterChip(label: filterCategoryLabel(state.category)),
      if (state.gender != null) _FilterChip(label: '性別 ${state.gender!}'),
      if (state.city != null) _FilterChip(label: state.city!),
      TextButton(
        onPressed: ref.read(animalBrowserProvider.notifier).clearFilters,
        child: const Text('清除'),
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('全部毛孩'),
        backgroundColor: AppTheme.background,
      ),
      body: AppPagePadding(
        top: 10,
        bottom: 10,
        child: Column(
          children: [
            Row(
              children: [
                const Expanded(child: AnimalSearchField()),
                const SizedBox(width: 8),
                Material(
                  color: AppTheme.surface,
                  borderRadius: BorderRadius.circular(16),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(16),
                    onTap: () => showAnimalFilterSheet(context, ref),
                    child: const SizedBox(
                      width: 52,
                      height: 52,
                      child: Icon(Icons.tune),
                    ),
                  ),
                ),
              ],
            ),
            if (state.hasActiveFilters) ...[
              const SizedBox(height: 10),
              SizedBox(
                height: 40,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: activeFilters,
                ),
              ),
            ],
            const SizedBox(height: 10),
            Expanded(
              child: animalsAsync.when(
                data: (animals) {
                  if (animals.isEmpty) {
                    return const Center(child: Text('目前沒有符合條件的毛孩'));
                  }
                  return GridView.builder(
                    itemCount: animals.length,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: AppResponsive.isWide(context) ? 3 : 2,
                      mainAxisSpacing: 12,
                      crossAxisSpacing: 12,
                      childAspectRatio: AppResponsive.isCompact(context)
                          ? 0.69
                          : 0.72,
                    ),
                    itemBuilder: (context, index) {
                      final animal = animals[index];
                      return InkWell(
                        borderRadius: BorderRadius.circular(16),
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute<void>(
                              builder: (context) =>
                                  AnimalDetailPage(animal: animal),
                            ),
                          );
                        },
                        child: AnimalCard(animal: animal),
                      );
                    },
                  );
                },
                loading: () => const Center(
                  child: CircularProgressIndicator(
                    color: AppTheme.primaryButton,
                  ),
                ),
                error: (error, stackTrace) =>
                    const Center(child: Text('目前無法載入資料')),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: AppInfoPill(label: label, background: AppTheme.surface),
    );
  }
}
