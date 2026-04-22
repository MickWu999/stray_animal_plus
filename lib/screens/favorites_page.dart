import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../app_theme.dart';
import '../providers/animal_browser_provider.dart';
import '../widgets/app_ui.dart';
import '../widgets/animal_card.dart';
import 'animal_detail_page.dart';

class FavoritesPage extends ConsumerWidget {
  const FavoritesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final favoriteIds = ref.watch(favoriteAnimalIdsProvider);
    final favoritesAsync = ref.watch(favoriteAnimalsProvider);

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          AppResponsive.pageInset(context),
          12,
          AppResponsive.pageInset(context),
          16,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '收藏',
              style: TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.w900,
                color: AppTheme.text,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              favoriteIds.isEmpty
                  ? '把喜歡的毛孩先存起來。'
                  : '你目前收藏了 ${favoriteIds.length} 隻毛孩。',
              style: const TextStyle(fontSize: 15, color: AppTheme.subText),
            ),
            const SizedBox(height: 18),
            Expanded(
              child: favoritesAsync.when(
                loading: () => const Center(
                  child: CircularProgressIndicator(
                    color: AppTheme.primaryButton,
                  ),
                ),
                error: (error, stackTrace) =>
                    const Center(child: Text('目前無法載入收藏資料')),
                data: (favorites) {
                  if (favorites.isEmpty) {
                    return _EmptyFavorites(
                      onClear: () => ref
                          .read(favoriteAnimalIdsProvider.notifier)
                          .clearAll(),
                    );
                  }

                  return Column(
                    children: [
                      AppSurfaceCard(
                        child: Row(
                          children: [
                            const Icon(
                              Icons.favorite_rounded,
                              color: AppTheme.primaryButton,
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                '已收藏 ${favorites.length} 隻，之後可以再回來比較。',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w700,
                                  color: AppTheme.text,
                                ),
                              ),
                            ),
                            TextButton(
                              onPressed: () => ref
                                  .read(favoriteAnimalIdsProvider.notifier)
                                  .clearAll(),
                              child: const Text('清空'),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 14),
                      Expanded(
                        child: GridView.builder(
                          itemCount: favorites.length,
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                mainAxisSpacing: 12,
                                crossAxisSpacing: 12,
                                childAspectRatio: 0.72,
                              ),
                          itemBuilder: (context, index) {
                            final animal = favorites[index];
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
                        ),
                      ),
                    ],
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

class _EmptyFavorites extends StatelessWidget {
  const _EmptyFavorites({required this.onClear});

  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: AppSurfaceCard(
        padding: const EdgeInsets.all(26),
        radius: 28,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: const Color(0xFFF7EFE5),
                borderRadius: BorderRadius.circular(22),
              ),
              child: const Icon(
                Icons.favorite_border_rounded,
                size: 34,
                color: AppTheme.primaryButton,
              ),
            ),
            const SizedBox(height: 18),
            const Text(
              '目前還沒有收藏',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 8),
            const Text(
              '在毛孩資訊頁或詳細頁點一下愛心，喜歡的孩子就會集中在這裡。',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppTheme.subText, height: 1.5),
            ),
            const SizedBox(height: 16),
            TextButton(onPressed: onClear, child: const Text('重新整理狀態')),
          ],
        ),
      ),
    );
  }
}
