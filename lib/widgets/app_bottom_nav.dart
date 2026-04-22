import 'package:flutter/material.dart';

import '../app_theme.dart';

class AppBottomNav extends StatelessWidget {
  const AppBottomNav({
    super.key,
    required this.selectedIndex,
    required this.onSelected,
  });

  final int selectedIndex;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    return BottomAppBar(
      height: 74,
      padding: const EdgeInsets.symmetric(horizontal: 18),
      color: Colors.white,
      shape: const CircularNotchedRectangle(),
      notchMargin: 8,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _BottomNavItem(
            icon: Icons.home_outlined,
            label: '首頁',
            selected: selectedIndex == 0,
            onTap: () => onSelected(0),
          ),
          _BottomNavItem(
            icon: Icons.map,
            label: '地圖',
            selected: selectedIndex == 1,
            onTap: () => onSelected(1),
          ),
          const SizedBox(width: 36),
          _BottomNavItem(
            icon: Icons.favorite_border,
            label: '收藏',
            selected: selectedIndex == 3,
            onTap: () => onSelected(3),
          ),
          _BottomNavItem(
            icon: Icons.person_outline,
            label: '我的',
            selected: selectedIndex == 4,
            onTap: () => onSelected(4),
          ),
        ],
      ),
    );
  }
}

class _BottomNavItem extends StatelessWidget {
  const _BottomNavItem({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = selected ? AppTheme.primaryButton : Colors.black45;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: SizedBox(
        width: 58,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 12,
                fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
