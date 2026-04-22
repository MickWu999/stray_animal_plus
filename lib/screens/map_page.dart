import 'package:flutter/material.dart';

import '../app_theme.dart';

class MapPage extends StatelessWidget {
  const MapPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const _SimpleTabPage(title: '地圖頁面');
  }
}

class _SimpleTabPage extends StatelessWidget {
  const _SimpleTabPage({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Center(
        child: Text(
          title,
          style: const TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w800,
            color: AppTheme.text,
          ),
        ),
      ),
    );
  }
}
