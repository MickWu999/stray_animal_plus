import 'package:flutter/material.dart';

import '../app_theme.dart';
import '../widgets/app_bottom_nav.dart';
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
  int _selectedTabIndex = 0;

  @override
  Widget build(BuildContext context) {
    final pages = [
      HomeTabPage(
        onOpenAnimals: () {
          setState(() {
            _selectedTabIndex = 2;
          });
        },
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
            tooltip: '毛孩資訊',
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
