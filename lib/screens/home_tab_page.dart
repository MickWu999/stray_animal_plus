import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../app_theme.dart';
import '../models/animal.dart';
import '../providers/animal_browser_provider.dart';
import '../widgets/app_ui.dart';
import '../widgets/animal_network_image.dart';
import '../widgets/campaign_carousel.dart';
import 'animal_detail_page.dart';
import 'all_animals_page.dart';

class HomeTabPage extends ConsumerStatefulWidget {
  const HomeTabPage({super.key, required this.onOpenAnimals});

  final VoidCallback onOpenAnimals;

  @override
  ConsumerState<HomeTabPage> createState() => _HomeTabPageState();
}

class _HomeTabPageState extends ConsumerState<HomeTabPage> {
  static const List<CampaignBanner> _campaigns = [
    CampaignBanner(
      title: '春遊野餐派對',
      subtitle: '2026 花園孩子回娘家',
      imagePath: 'assets/images/activity/banner.jpg',
      linkUrl: 'https://www.doghome.org.tw/pages/single_page.php?ID=193',
    ),
    CampaignBanner(
      title: '春遊野餐派對',
      subtitle: '2026 花園孩子回娘家',
      imagePath: 'assets/images/activity/banner.jpg',
      linkUrl: 'https://www.doghome.org.tw/pages/single_page.php?ID=193',
    ),
    CampaignBanner(
      title: '春遊野餐派對',
      subtitle: '2026 花園孩子回娘家',
      imagePath: 'assets/images/activity/banner.jpg',
      linkUrl: 'https://www.doghome.org.tw/pages/single_page.php?ID=193',
    ),
  ];

  late final PageController _campaignController;
  Timer? _campaignTimer;
  int _campaignIndex = 0;

  @override
  void initState() {
    super.initState();
    _campaignController = PageController();
    _campaignController.addListener(_handleCampaignScroll);
    _campaignTimer = Timer.periodic(const Duration(seconds: 4), (_) {
      if (!mounted ||
          !_campaignController.hasClients ||
          _campaigns.length <= 1) {
        return;
      }

      final nextPage = (_campaignIndex + 1) % _campaigns.length;
      _campaignController.animateToPage(
        nextPage,
        duration: const Duration(milliseconds: 360),
        curve: Curves.easeOutCubic,
      );
    });
  }

  void _handleCampaignScroll() {
    final nextIndex = (_campaignController.page ?? 0).round();
    if (_campaignIndex != nextIndex && mounted) {
      setState(() {
        _campaignIndex = nextIndex;
      });
    }
  }

  Future<void> _openCampaignLink(CampaignBanner campaign) async {
    final uri = Uri.parse(campaign.linkUrl);
    final openedInApp = await launchUrl(uri, mode: LaunchMode.inAppBrowserView);
    if (openedInApp) {
      return;
    }

    final openedExternal = await launchUrl(
      uri,
      mode: LaunchMode.externalApplication,
    );
    if (!openedExternal && mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('目前無法開啟活動頁面')));
    }
  }

  @override
  void dispose() {
    _campaignTimer?.cancel();
    _campaignController.removeListener(_handleCampaignScroll);
    _campaignController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final animalsAsync = ref.watch(animalFeedProvider);

    return SafeArea(
      child: animalsAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppTheme.primaryButton),
        ),
        error: (error, stackTrace) => const Center(child: Text('目前無法載入首頁資料')),
        data: (animals) {
          final adoptableAnimals = animals
              .where((animal) => animal.isOpenForAdoption)
              .toList(growable: false);
          final recentAnimals = [...adoptableAnimals]
            ..sort(
              (a, b) => (b.lastUpdateDate ?? DateTime(1900)).compareTo(
                a.lastUpdateDate ?? DateTime(1900),
              ),
            );
          final featuredAnimals = recentAnimals.take(3).toList(growable: false);
          final openCount = adoptableAnimals.length;
          final recentCount = adoptableAnimals
              .where((animal) => (animal.daysSinceCreate ?? 9999) <= 7)
              .length;
          final shelters = adoptableAnimals
              .map((animal) => animal.shelterName ?? animal.primaryLocation)
              .toSet()
              .length;

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
                    Row(
                      children: const [
                        Icon(Icons.location_on_outlined, size: 20),
                        SizedBox(width: 4),
                        Text(
                          '全台收容資訊',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Spacer(),
                        Icon(Icons.notifications_none, size: 24),
                      ],
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      '認養首頁',
                      style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.w900,
                        color: AppTheme.text,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      '先看重點，再前往毛孩頁深入瀏覽。',
                      style: TextStyle(fontSize: 15, color: AppTheme.subText),
                    ),
                    const SizedBox(height: 14),
                    CampaignCarousel(
                      controller: _campaignController,
                      campaigns: _campaigns,
                      selectedIndex: _campaignIndex,
                      onTap: _openCampaignLink,
                    ),
                    const SizedBox(height: 18),
                    const AppSectionHeader(
                      title: '快速入口',
                      subtitle: '把主要操作集中在首頁，進入毛孩頁再看完整資料。',
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: _QuickEntryCard(
                            icon: Icons.pets_rounded,
                            title: '毛孩資訊',
                            subtitle: '推薦、新入住、等待中',
                            onTap: widget.onOpenAnimals,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _QuickEntryCard(
                            icon: Icons.grid_view_rounded,
                            title: '查看全部',
                            subtitle: '直接進完整列表',
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute<void>(
                                  builder: (context) => const AllAnimalsPage(),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),
                    const AppSectionHeader(
                      title: '目前概況',
                      subtitle: '根據目前開放認養資料整理的首頁摘要。',
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: _OverviewCard(
                            label: '開放認養中',
                            value: '$openCount',
                            hint: '目前可瀏覽毛孩',
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _OverviewCard(
                            label: '近 7 天新入住',
                            value: '$recentCount',
                            hint: '最近加入收容所',
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _OverviewCard(
                            label: '收容所數量',
                            value: '$shelters',
                            hint: '資料來源據點',
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),
                    Row(
                      children: [
                        const Expanded(
                          child: AppSectionHeader(
                            title: '首頁精選',
                            subtitle: '先看幾隻近期更新的孩子。',
                          ),
                        ),
                        TextButton(
                          onPressed: widget.onOpenAnimals,
                          child: const Text(
                            '前往毛孩頁',
                            style: TextStyle(fontWeight: FontWeight.w700),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      height: 320,
                      child: featuredAnimals.isEmpty
                          ? const Center(child: Text('目前沒有可顯示的毛孩'))
                          : ListView.separated(
                              scrollDirection: Axis.horizontal,
                              itemCount: featuredAnimals.length,
                              separatorBuilder: (context, index) =>
                                  const SizedBox(width: 14),
                              itemBuilder: (context, index) {
                                final animal = featuredAnimals[index];
                                return SizedBox(
                                  width: 260,
                                  child: _FeaturedAnimalCard(animal: animal),
                                );
                              },
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

class _QuickEntryCard extends StatelessWidget {
  const _QuickEntryCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppTheme.surface,
      borderRadius: BorderRadius.circular(24),
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: AppTheme.border),
            boxShadow: const [
              BoxShadow(
                color: Color(0x10000000),
                blurRadius: 12,
                offset: Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: const Color(0xFFF7EFE5),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, color: AppTheme.primaryButton),
              ),
              const SizedBox(height: 18),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                subtitle,
                style: const TextStyle(color: AppTheme.subText, height: 1.4),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _OverviewCard extends StatelessWidget {
  const _OverviewCard({
    required this.label,
    required this.value,
    required this.hint,
  });

  final String label;
  final String value;
  final String hint;

  @override
  Widget build(BuildContext context) {
    return AppSurfaceCard(
      padding: const EdgeInsets.fromLTRB(14, 16, 14, 14),
      radius: 22,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 13, color: AppTheme.subText),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(fontSize: 30, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 6),
          Text(
            hint,
            style: const TextStyle(fontSize: 12, color: AppTheme.subText),
          ),
        ],
      ),
    );
  }
}

class _FeaturedAnimalCard extends ConsumerWidget {
  const _FeaturedAnimalCard({required this.animal});

  final Animal animal;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sexColor = animal.sexText == '公'
        ? const Color(0xFF3572D4)
        : const Color(0xFFD25A72);
    final isFavorite = ref.watch(
      favoriteAnimalIdsProvider.select((ids) => ids.contains(animal.animalId)),
    );

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(26),
      child: InkWell(
        borderRadius: BorderRadius.circular(26),
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (context) => AnimalDetailPage(animal: animal),
            ),
          );
        },
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(26),
            boxShadow: const [
              BoxShadow(
                color: Color(0x11000000),
                blurRadius: 16,
                offset: Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                children: [
                  AnimalNetworkImage(
                    imageUrl: animal.albumFile,
                    fit: BoxFit.cover,
                    height: 190,
                    width: double.infinity,
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(26),
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
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      animal.headlineTitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _MiniChip(
                          label: animal.sexText,
                          color: sexColor,
                          background: sexColor.withValues(alpha: 0.10),
                        ),
                        _MiniChip(label: animal.ageText),
                        _MiniChip(label: animal.bodyTypePetText),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(
                      animal.shelterName ?? animal.primaryLocation,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      animal.updateDurationLabel,
                      style: const TextStyle(color: AppTheme.subText),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MiniChip extends StatelessWidget {
  const _MiniChip({
    required this.label,
    this.color = const Color(0xFF4B433B),
    this.background = const Color(0xFFF7F2EC),
  });

  final String label;
  final Color color;
  final Color background;

  @override
  Widget build(BuildContext context) {
    return AppInfoPill(label: label, foreground: color, background: background);
  }
}
