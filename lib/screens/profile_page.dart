import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../app_theme.dart';
import '../models/animal.dart';
import '../providers/animal_browser_provider.dart';
import '../widgets/app_ui.dart';

class ProfilePage extends ConsumerWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final favoriteIds = ref.watch(favoriteAnimalIdsProvider);
    final animalsAsync = ref.watch(animalFeedProvider);

    return SafeArea(
      child: animalsAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppTheme.primaryButton),
        ),
        error: (error, stackTrace) => const Center(child: Text('目前無法載入個人頁資料')),
        data: (animals) {
          final openCount = animals
              .where((animal) => animal.isOpenForAdoption)
              .length;
          final cities = animals
              .map((animal) => animal.cityName)
              .whereType<String>()
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
                    const Text(
                      '我的',
                      style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.w900,
                        color: AppTheme.text,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      '管理收藏、了解資料來源與認養使用方式。',
                      style: TextStyle(fontSize: 15, color: AppTheme.subText),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [Color(0xFFB38462), Color(0xFF8F6245)],
                        ),
                        borderRadius: BorderRadius.circular(28),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 56,
                                height: 56,
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(18),
                                ),
                                child: const Icon(
                                  Icons.pets_rounded,
                                  color: Colors.white,
                                  size: 30,
                                ),
                              ),
                              const SizedBox(width: 14),
                              const Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Stray Animal Plus',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 22,
                                        fontWeight: FontWeight.w900,
                                      ),
                                    ),
                                    SizedBox(height: 4),
                                    Text(
                                      '用公開資料整理更清楚的認養資訊',
                                      style: TextStyle(
                                        color: Colors.white70,
                                        height: 1.35,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 18),
                          Row(
                            children: [
                              Expanded(
                                child: _HeroStat(
                                  label: '我的收藏',
                                  value: '${favoriteIds.length}',
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: _HeroStat(
                                  label: '開放認養',
                                  value: '$openCount',
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: _HeroStat(
                                  label: '資料城市',
                                  value: '$cities',
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 18),
                    const AppSectionHeader(
                      title: '認養工具',
                      subtitle: '把常用操作集中在這裡。',
                    ),
                    const SizedBox(height: 12),
                    const _MenuCard(
                      icon: Icons.favorite_border_rounded,
                      title: '管理收藏',
                      subtitle: '前往收藏頁比較有興趣的毛孩',
                    ),
                    const SizedBox(height: 12),
                    const _MenuCard(
                      icon: Icons.location_on_outlined,
                      title: '查看收容所',
                      subtitle: '從地圖頁快速掌握各地收容資訊',
                    ),
                    const SizedBox(height: 18),
                    const AppSectionHeader(
                      title: '資料與說明',
                      subtitle: '目前使用公開資料來源與基本說明。',
                    ),
                    const SizedBox(height: 12),
                    const _InfoPanel(
                      title: '資料來源',
                      body: '農業部開放資料「動物認領養」資料集，首頁與毛孩頁都會優先顯示目前開放認養的孩子。',
                    ),
                    const SizedBox(height: 12),
                    const _InfoPanel(
                      title: '使用方式',
                      body: '先在首頁掌握概況，再到毛孩資訊頁深入瀏覽；若對某隻有興趣，可在詳細頁直接查看收容所聯絡資訊。',
                    ),
                    const SizedBox(height: 12),
                    const _InfoPanel(
                      title: '提醒',
                      body: '實際狀態仍以收容所最新公告為準，撥打電話前可先確認地址與來源地資訊。',
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

class _HeroStat extends StatelessWidget {
  const _HeroStat({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 12, color: Colors.white70),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w900,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}

class _MenuCard extends StatelessWidget {
  const _MenuCard({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return AppSurfaceCard(
      radius: 24,
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: const Color(0xFFF7EFE5),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: AppTheme.primaryButton),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(color: AppTheme.subText, height: 1.4),
                ),
              ],
            ),
          ),
          const Icon(Icons.chevron_right_rounded, color: AppTheme.subText),
        ],
      ),
    );
  }
}

class _InfoPanel extends StatelessWidget {
  const _InfoPanel({required this.title, required this.body});

  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return AppSurfaceCard(
      radius: 24,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 8),
          Text(
            body,
            style: const TextStyle(color: AppTheme.subText, height: 1.5),
          ),
        ],
      ),
    );
  }
}
