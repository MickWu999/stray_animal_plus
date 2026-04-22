import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../app_theme.dart';
import '../models/animal.dart';
import '../providers/animal_browser_provider.dart';
import '../widgets/app_ui.dart';

class MapPage extends ConsumerWidget {
  const MapPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final animalsAsync = ref.watch(animalFeedProvider);

    return SafeArea(
      child: animalsAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppTheme.primaryButton),
        ),
        error: (error, stackTrace) => const Center(child: Text('目前無法載入收容所資料')),
        data: (animals) {
          final openAnimals = animals
              .where((animal) => animal.isOpenForAdoption)
              .toList(growable: false);
          final shelterCards = _buildShelterCards(openAnimals);
          final cityCounts = <String, int>{};
          for (final animal in openAnimals) {
            final city = animal.cityName ?? '未標示';
            cityCounts.update(city, (value) => value + 1, ifAbsent: () => 1);
          }
          final topCities = cityCounts.entries.toList()
            ..sort((a, b) => b.value.compareTo(a.value));

          return CustomScrollView(
            slivers: [
              SliverPadding(
                padding: EdgeInsets.fromLTRB(
                  AppResponsive.pageInset(context),
                  12,
                  AppResponsive.pageInset(context),
                  24,
                ),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    const Text(
                      '收容地圖',
                      style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.w900,
                        color: AppTheme.text,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      '先用收容所與城市角度掌握認養分布。',
                      style: TextStyle(fontSize: 15, color: AppTheme.subText),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      height: 220,
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [Color(0xFFF7EBDD), Color(0xFFEED9C4)],
                        ),
                        borderRadius: BorderRadius.circular(28),
                      ),
                      child: Stack(
                        children: [
                          Positioned.fill(
                            child: Opacity(
                              opacity: 0.18,
                              child: DecoratedBox(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(24),
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                '全台開放認養概況',
                                style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.w900,
                                  color: AppTheme.text,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                '目前整理 ${shelterCards.length} 個收容所，${openAnimals.length} 隻毛孩正在等待認養。',
                                style: const TextStyle(
                                  height: 1.45,
                                  color: AppTheme.subText,
                                ),
                              ),
                              const Spacer(),
                              Wrap(
                                spacing: 10,
                                runSpacing: 10,
                                children: [
                                  _SummaryBadge(
                                    label: '收容所',
                                    value: '${shelterCards.length}',
                                  ),
                                  _SummaryBadge(
                                    label: '開放認養',
                                    value: '${openAnimals.length}',
                                  ),
                                  _SummaryBadge(
                                    label: '涵蓋城市',
                                    value: '${cityCounts.keys.length}',
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 18),
                    const AppSectionHeader(
                      title: '熱門城市',
                      subtitle: '快速查看目前資料量較多的地區。',
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      height: 46,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: topCities.take(8).length,
                        separatorBuilder: (context, index) =>
                            const SizedBox(width: 10),
                        itemBuilder: (context, index) {
                          final city = topCities[index];
                          return Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(999),
                              border: Border.all(
                                color: const Color(0xFFE5D7C7),
                              ),
                            ),
                            child: Text(
                              '${city.key} ${city.value}',
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                                color: AppTheme.text,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 18),
                    const AppSectionHeader(
                      title: '收容所列表',
                      subtitle: '先以清單方式查看聯絡資訊與認養概況。',
                    ),
                    const SizedBox(height: 12),
                    ...shelterCards.map(
                      (card) => Padding(
                        padding: const EdgeInsets.only(bottom: 14),
                        child: _ShelterCard(summary: card),
                      ),
                    ),
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

List<_ShelterSummary> _buildShelterCards(List<Animal> animals) {
  final grouped = <String, List<Animal>>{};
  for (final animal in animals) {
    final key = animal.shelterName ?? animal.primaryLocation;
    grouped.putIfAbsent(key, () => []).add(animal);
  }

  final summaries =
      grouped.entries
          .map((entry) {
            final items = entry.value;
            items.sort(
              (a, b) => (b.lastUpdateDate ?? DateTime(1900)).compareTo(
                a.lastUpdateDate ?? DateTime(1900),
              ),
            );
            final city = items.first.cityName ?? '地區待補';
            return _ShelterSummary(
              name: entry.key,
              city: city,
              address: items.first.shelterAddress ?? '地址待更新',
              tel: items.first.shelterTel ?? '電話待更新',
              openCount: items.length,
              recentAddedCount: items
                  .where((animal) => (animal.daysSinceCreate ?? 9999) <= 7)
                  .length,
              updateDateLabel: items.first.updateDateLabel,
            );
          })
          .toList(growable: false)
        ..sort((a, b) => b.openCount.compareTo(a.openCount));

  return summaries;
}

class _SummaryBadge extends StatelessWidget {
  const _SummaryBadge({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return AppSurfaceCard(
      radius: 18,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 12, color: AppTheme.subText),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
          ),
        ],
      ),
    );
  }
}

class _ShelterCard extends StatelessWidget {
  const _ShelterCard({required this.summary});

  final _ShelterSummary summary;

  @override
  Widget build(BuildContext context) {
    return AppSurfaceCard(
      radius: 24,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  summary.name,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    color: AppTheme.text,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 7,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFF7EFE5),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  summary.city,
                  style: const TextStyle(
                    color: AppTheme.primaryButton,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            summary.address,
            style: const TextStyle(color: AppTheme.subText),
          ),
          const SizedBox(height: 4),
          Text(summary.tel, style: const TextStyle(color: AppTheme.subText)),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _MiniStat(
                  label: '開放認養',
                  value: '${summary.openCount} 隻',
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _MiniStat(
                  label: '近 7 天新增',
                  value: '${summary.recentAddedCount} 隻',
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            '最近資料日期 ${summary.updateDateLabel}',
            style: const TextStyle(
              color: AppTheme.subText,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _MiniStat extends StatelessWidget {
  const _MiniStat({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return AppSurfaceCard(
      radius: 18,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 12, color: AppTheme.subText),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800),
          ),
        ],
      ),
    );
  }
}

class _ShelterSummary {
  const _ShelterSummary({
    required this.name,
    required this.city,
    required this.address,
    required this.tel,
    required this.openCount,
    required this.recentAddedCount,
    required this.updateDateLabel,
  });

  final String name;
  final String city;
  final String address;
  final String tel;
  final int openCount;
  final int recentAddedCount;
  final String updateDateLabel;
}
