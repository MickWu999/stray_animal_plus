import 'dart:async';

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../app_theme.dart';
import '../widgets/app_bottom_nav.dart';
import '../widgets/campaign_carousel.dart';
import 'favorites_page.dart';
import 'home_tab_page.dart';
import 'map_page.dart';
import 'match_page.dart';
import 'profile_page.dart';

class ExplorePage extends StatefulWidget {
  const ExplorePage({super.key});

  @override
  State<ExplorePage> createState() => _ExplorePageState();
}

class _ExplorePageState extends State<ExplorePage> {
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
  int _selectedTabIndex = 0;

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
    final pages = [
      HomeTabPage(
        campaignController: _campaignController,
        campaignIndex: _campaignIndex,
        campaigns: _campaigns,
        onTapCampaign: _openCampaignLink,
      ),
      const MapPage(),
      const MatchPage(),
      const FavoritesPage(),
      const ProfilePage(),
    ];

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: IndexedStack(index: _selectedTabIndex, children: pages),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: Transform.translate(
        offset: const Offset(0, 14),
        child: SizedBox(
          width: 56,
          height: 56,
          child: FloatingActionButton(
            onPressed: () {
              setState(() {
                _selectedTabIndex = 2;
              });
            },
            backgroundColor: AppTheme.primaryButton,
            foregroundColor: Colors.white,
            elevation: 4,
            shape: const CircleBorder(),
            child: const Icon(Icons.pets_rounded, size: 30),
          ),
        ),
      ),
      bottomNavigationBar: AppBottomNav(
        selectedIndex: _selectedTabIndex,
        onSelected: (index) {
          setState(() {
            _selectedTabIndex = index;
          });
        },
      ),
    );
  }
}
