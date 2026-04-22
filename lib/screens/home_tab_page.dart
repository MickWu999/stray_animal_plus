import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../app_theme.dart';
import '../providers/animal_browser_provider.dart';
import '../widgets/animal_card.dart';
import '../widgets/campaign_carousel.dart';
import 'all_animals_page.dart';

class HomeTabPage extends ConsumerWidget {
  const HomeTabPage({
    super.key,
    required this.campaignController,
    required this.campaignIndex,
    required this.campaigns,
    required this.onTapCampaign,
  });

  final PageController campaignController;
  final int campaignIndex;
  final List<CampaignBanner> campaigns;
  final ValueChanged<CampaignBanner> onTapCampaign;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final animals = ref.watch(animalRepositoryProvider);
    final visibleRecommended = animals.take(6).toList(growable: false);

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: const [
                Icon(Icons.location_on_outlined, size: 20),
                SizedBox(width: 4),
                Text(
                  '全台收容資訊',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                ),
                Spacer(),
                Icon(Icons.notifications_none, size: 24),
              ],
            ),
            const SizedBox(height: 10),
            CampaignCarousel(
              controller: campaignController,
              campaigns: campaigns,
              selectedIndex: campaignIndex,
              onTap: onTapCampaign,
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                const Text(
                  '今日推薦',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900),
                ),
                const Spacer(),
                FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: AppTheme.primaryButton,
                    foregroundColor: Colors.white,
                  ),
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (context) => const AllAnimalsPage(),
                      ),
                    );
                  },
                  child: const Text('查看全部'),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Expanded(
              child: visibleRecommended.isEmpty
                  ? const Center(child: Text('目前沒有符合條件的毛孩'))
                  : GridView.builder(
                      itemCount: visibleRecommended.length,
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            mainAxisSpacing: 10,
                            crossAxisSpacing: 10,
                            childAspectRatio: 0.72,
                          ),
                      itemBuilder: (context, index) {
                        return AnimalCard(animal: visibleRecommended[index]);
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
