import 'package:flutter/material.dart';

import '../app_theme.dart';

class AppResponsive {
  const AppResponsive._();

  static bool isCompact(BuildContext context) =>
      MediaQuery.sizeOf(context).width < 390;

  static bool isWide(BuildContext context) =>
      MediaQuery.sizeOf(context).width >= 700;

  static double pageInset(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    if (width >= 900) {
      return 32;
    }
    if (width >= 700) {
      return 24;
    }
    if (width < 390) {
      return 14;
    }
    return 16;
  }

  static double sectionGap(BuildContext context) {
    return isCompact(context) ? 14 : 18;
  }

  static double cardRadius(BuildContext context) {
    return isCompact(context) ? 20 : 24;
  }

  static double titleSize(BuildContext context) {
    return isCompact(context) ? 27 : 30;
  }
}

class AppPagePadding extends StatelessWidget {
  const AppPagePadding({
    super.key,
    required this.child,
    this.top = 12,
    this.bottom = 24,
  });

  final Widget child;
  final double top;
  final double bottom;

  @override
  Widget build(BuildContext context) {
    final inset = AppResponsive.pageInset(context);
    return Padding(
      padding: EdgeInsets.fromLTRB(inset, top, inset, bottom),
      child: child,
    );
  }
}

class AppSectionHeader extends StatelessWidget {
  const AppSectionHeader({
    super.key,
    required this.title,
    required this.subtitle,
    this.trailing,
  });

  final String title;
  final String subtitle;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: Theme.of(context).textTheme.headlineMedium),
              const SizedBox(height: 4),
              Text(subtitle, style: Theme.of(context).textTheme.bodyMedium),
            ],
          ),
        ),
        if (trailing != null) ...[const SizedBox(width: 12), trailing!],
      ],
    );
  }
}

class AppSurfaceCard extends StatelessWidget {
  const AppSurfaceCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(18),
    this.radius,
  });

  final Widget child;
  final EdgeInsets padding;
  final double? radius;

  @override
  Widget build(BuildContext context) {
    final resolvedRadius = radius ?? AppResponsive.cardRadius(context);
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(resolvedRadius),
        border: Border.all(color: AppTheme.border),
        boxShadow: const [
          BoxShadow(
            color: Color(0x10000000),
            blurRadius: 12,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: child,
    );
  }
}

class AppInfoPill extends StatelessWidget {
  const AppInfoPill({
    super.key,
    required this.label,
    this.icon,
    this.foreground = AppTheme.text,
    this.background = AppTheme.surfaceSoft,
  });

  final String label;
  final IconData? icon;
  final Color foreground;
  final Color background;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 16, color: foreground),
            const SizedBox(width: 6),
          ],
          Text(
            label,
            style: TextStyle(color: foreground, fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }
}

class AppTopCircleButton extends StatelessWidget {
  const AppTopCircleButton({
    super.key,
    required this.icon,
    required this.onTap,
    this.active = false,
  });

  final IconData icon;
  final VoidCallback onTap;
  final bool active;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppTheme.surface,
      shape: const CircleBorder(),
      elevation: 4,
      shadowColor: const Color(0x22000000),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: SizedBox(
          width: 42,
          height: 42,
          child: Icon(
            icon,
            size: 20,
            color: active ? const Color(0xFFE45D4F) : AppTheme.text,
          ),
        ),
      ),
    );
  }
}
