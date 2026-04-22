import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../app_theme.dart';
import '../models/animal.dart';
import '../providers/animal_browser_provider.dart';
import '../widgets/app_ui.dart';
import '../widgets/animal_network_image.dart';
import 'all_animals_page.dart';
import 'animal_detail_page.dart';

class MatchPage extends ConsumerStatefulWidget {
  const MatchPage({super.key});

  @override
  ConsumerState<MatchPage> createState() => _MatchPageState();
}

class _MatchPageState extends ConsumerState<MatchPage> {
  HomeAnimalsSection _selectedSection = HomeAnimalsSection.recommend;

  @override
  Widget build(BuildContext context) {
    final animalsAsync = ref.watch(animalFeedProvider);

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          AppResponsive.pageInset(context),
          12,
          AppResponsive.pageInset(context),
          0,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '毛孩資訊',
              style: TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.w900,
                color: AppTheme.text,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              '集中瀏覽推薦、新入住、等待中與收容所資訊。',
              style: TextStyle(fontSize: 15, color: AppTheme.subText),
            ),
            const SizedBox(height: 14),
            SizedBox(
              height: 48,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  _SectionChip(
                    label: '推薦',
                    icon: Icons.pets_rounded,
                    selected: _selectedSection == HomeAnimalsSection.recommend,
                    onTap: () => setState(() {
                      _selectedSection = HomeAnimalsSection.recommend;
                    }),
                  ),
                  _SectionChip(
                    label: '新入住',
                    icon: Icons.fiber_new_outlined,
                    selected: _selectedSection == HomeAnimalsSection.newArrival,
                    onTap: () => setState(() {
                      _selectedSection = HomeAnimalsSection.newArrival;
                    }),
                  ),
                  _SectionChip(
                    label: '等待中',
                    icon: Icons.favorite_border,
                    selected: _selectedSection == HomeAnimalsSection.waiting,
                    onTap: () => setState(() {
                      _selectedSection = HomeAnimalsSection.waiting;
                    }),
                  ),
                  _SectionChip(
                    label: '收容所',
                    icon: Icons.domain_outlined,
                    selected: _selectedSection == HomeAnimalsSection.shelter,
                    onTap: () => setState(() {
                      _selectedSection = HomeAnimalsSection.shelter;
                    }),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: animalsAsync.when(
                loading: () => const Center(
                  child: CircularProgressIndicator(
                    color: AppTheme.primaryButton,
                  ),
                ),
                error: (error, stackTrace) =>
                    const Center(child: Text('目前無法載入資料')),
                data: (animals) {
                  final adoptableAnimals = animals
                      .where((animal) => animal.isOpenForAdoption)
                      .toList(growable: false);
                  final newArrivalAnimals = [...adoptableAnimals]
                    ..sort(
                      (a, b) => (b.createDate ?? DateTime(1900)).compareTo(
                        a.createDate ?? DateTime(1900),
                      ),
                    );
                  final waitingAnimals = [...adoptableAnimals]
                    ..sort(
                      (a, b) => (a.openDate ?? DateTime(2999)).compareTo(
                        b.openDate ?? DateTime(2999),
                      ),
                    );
                  final shelterSummaries = _buildShelterSummaries(
                    adoptableAnimals,
                  );

                  return AnimatedSwitcher(
                    duration: const Duration(milliseconds: 220),
                    child: switch (_selectedSection) {
                      HomeAnimalsSection.recommend => _AnimalModule(
                        key: const ValueKey('recommend'),
                        title: '推薦毛孩',
                        subtitle: '以目前開放認養資料快速瀏覽',
                        animals: adoptableAnimals,
                      ),
                      HomeAnimalsSection.newArrival => _AnimalModule(
                        key: const ValueKey('new-arrival'),
                        title: '新入住毛孩',
                        subtitle: '最近加入收容所的孩子',
                        animals: newArrivalAnimals,
                        showNewBadge: true,
                      ),
                      HomeAnimalsSection.waiting => _AnimalModule(
                        key: const ValueKey('waiting'),
                        title: '等待中的孩子',
                        subtitle: '開放認養較久、仍在等待中的毛孩',
                        animals: waitingAnimals,
                        emphasizeWaiting: true,
                      ),
                      HomeAnimalsSection.shelter => _ShelterModule(
                        key: const ValueKey('shelter'),
                        summaries: shelterSummaries,
                      ),
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

List<_ShelterSummary> _buildShelterSummaries(List<Animal> animals) {
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
            return _ShelterSummary(
              name: entry.key,
              address: items.first.shelterAddress ?? '地址待更新',
              tel: items.first.shelterTel ?? '電話待更新',
              openCount: items
                  .where((animal) => animal.isOpenForAdoption)
                  .length,
              recentAddedCount: items
                  .where((animal) => (animal.daysSinceCreate ?? 9999) <= 7)
                  .length,
              latestUpdateLabel: items.first.updateDurationLabel,
              latestUpdateDateLabel: items.first.updateDateLabel,
            );
          })
          .toList(growable: false)
        ..sort((a, b) => a.name.compareTo(b.name));

  return summaries;
}

class _SectionChip extends StatelessWidget {
  const _SectionChip({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final borderColor = selected
        ? AppTheme.primaryButton
        : const Color(0xFFD9D3CB);

    return Padding(
      padding: const EdgeInsets.only(right: 10),
      child: Material(
        color: selected ? AppTheme.primaryButton : AppTheme.surface,
        elevation: selected ? 4 : 0,
        shadowColor: const Color(0x18000000),
        borderRadius: BorderRadius.circular(999),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(999),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(999),
              border: Border.all(color: borderColor),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  icon,
                  size: 18,
                  color: selected ? Colors.white : const Color(0xFF4F4942),
                ),
                const SizedBox(width: 7),
                Text(
                  label,
                  style: TextStyle(
                    color: selected ? Colors.white : const Color(0xFF4F4942),
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _AnimalModule extends StatelessWidget {
  const _AnimalModule({
    super.key,
    required this.title,
    required this.subtitle,
    required this.animals,
    this.showNewBadge = false,
    this.emphasizeWaiting = false,
  });

  final String title;
  final String subtitle;
  final List<Animal> animals;
  final bool showNewBadge;
  final bool emphasizeWaiting;

  @override
  Widget build(BuildContext context) {
    final visibleAnimals = animals.take(12).toList(growable: false);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 15,
                      color: AppTheme.subText,
                    ),
                  ),
                ],
              ),
            ),
            TextButton.icon(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (context) => const AllAnimalsPage(),
                  ),
                );
              },
              iconAlignment: IconAlignment.end,
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xFF473F37),
              ),
              icon: const Icon(Icons.chevron_right_rounded),
              label: const Text(
                '查看全部',
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        Expanded(
          child: visibleAnimals.isEmpty
              ? const Center(child: Text('目前沒有符合條件的毛孩'))
              : ListView.separated(
                  itemCount: visibleAnimals.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: 14),
                  itemBuilder: (context, index) {
                    return _DecisionAnimalCard(
                      animal: visibleAnimals[index],
                      showNewBadge: showNewBadge,
                      emphasizeWaiting: emphasizeWaiting,
                    );
                  },
                ),
        ),
      ],
    );
  }
}

class _ShelterModule extends StatelessWidget {
  const _ShelterModule({super.key, required this.summaries});

  final List<_ShelterSummary> summaries;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '收容所',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900),
        ),
        const SizedBox(height: 4),
        const Text(
          '用收容所維度快速掌握目前開放認養資訊',
          style: TextStyle(fontSize: 15, color: AppTheme.subText),
        ),
        const SizedBox(height: 14),
        Expanded(
          child: ListView.separated(
            itemCount: summaries.length,
            separatorBuilder: (context, index) => const SizedBox(height: 14),
            itemBuilder: (context, index) {
              final summary = summaries[index];
              return AppSurfaceCard(
                radius: 22,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      summary.name,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      summary.address,
                      style: const TextStyle(
                        color: AppTheme.subText,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      summary.tel,
                      style: const TextStyle(color: AppTheme.subText),
                    ),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        Expanded(
                          child: _ShelterStat(
                            label: '目前開放認養',
                            value: '${summary.openCount} 隻',
                          ),
                        ),
                        Expanded(
                          child: _ShelterStat(
                            label: '近 7 天新增',
                            value: '${summary.recentAddedCount} 隻',
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      '${summary.latestUpdateLabel} (${summary.latestUpdateDateLabel})',
                      style: const TextStyle(
                        color: AppTheme.subText,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _ShelterStat extends StatelessWidget {
  const _ShelterStat({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      child: AppSurfaceCard(
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
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
            ),
          ],
        ),
      ),
    );
  }
}

class _DecisionAnimalCard extends ConsumerWidget {
  const _DecisionAnimalCard({
    required this.animal,
    required this.showNewBadge,
    required this.emphasizeWaiting,
  });

  final Animal animal;
  final bool showNewBadge;
  final bool emphasizeWaiting;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sexColor = animal.sexText == '公'
        ? const Color(0xFF3572D4)
        : const Color(0xFFD25A72);
    final isFavorite = ref.watch(
      favoriteAnimalIdsProvider.select((ids) => ids.contains(animal.animalId)),
    );

    return AppSurfaceCard(
      padding: EdgeInsets.zero,
      radius: 24,
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (context) => AnimalDetailPage(animal: animal),
            ),
          );
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 250,
              child: Stack(
                children: [
                  Positioned.fill(
                    child: AnimalNetworkImage(
                      imageUrl: animal.albumFile,
                      fit: BoxFit.cover,
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(24),
                      ),
                    ),
                  ),
                  if (showNewBadge && animal.isRecentArrival)
                    Positioned(
                      left: 12,
                      top: 12,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFF1D7),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: const Text(
                          'NEW',
                          style: TextStyle(
                            color: Color(0xFFC77817),
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ),
                  Positioned(
                    top: 12,
                    right: 12,
                    child: Material(
                      color: Colors.black.withValues(alpha: 0.28),
                      shape: const CircleBorder(),
                      child: InkWell(
                        customBorder: const CircleBorder(),
                        onTap: () {
                          ref
                              .read(favoriteAnimalIdsProvider.notifier)
                              .toggle(animal.animalId);
                        },
                        child: SizedBox(
                          width: 36,
                          height: 36,
                          child: Icon(
                            isFavorite
                                ? Icons.favorite_rounded
                                : Icons.favorite_border_rounded,
                            size: 20,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 14, 14, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    animal.headlineTitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _InfoChip(
                        label: animal.sexText,
                        foreground: sexColor,
                        background: sexColor.withValues(alpha: 0.10),
                      ),
                      _InfoChip(label: animal.ageText),
                      _InfoChip(label: animal.bodyTypePetText),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    emphasizeWaiting
                        ? animal.stayDurationLabel
                        : animal.updateDurationLabel,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: emphasizeWaiting
                          ? AppTheme.primaryButton
                          : AppTheme.text,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    animal.shelterName ?? animal.primaryLocation,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    animal.sourceLocationText,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppTheme.subText,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  const _InfoChip({
    required this.label,
    this.foreground = const Color(0xFF38332D),
    this.background = const Color(0xFFF7F2EC),
  });

  final String label;
  final Color foreground;
  final Color background;

  @override
  Widget build(BuildContext context) {
    return AppInfoPill(
      label: label,
      foreground: foreground,
      background: background,
    );
  }
}

class _ShelterSummary {
  const _ShelterSummary({
    required this.name,
    required this.address,
    required this.tel,
    required this.openCount,
    required this.recentAddedCount,
    required this.latestUpdateLabel,
    required this.latestUpdateDateLabel,
  });

  final String name;
  final String address;
  final String tel;
  final int openCount;
  final int recentAddedCount;
  final String latestUpdateLabel;
  final String latestUpdateDateLabel;
}
