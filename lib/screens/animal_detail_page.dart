import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

import '../app_theme.dart';
import '../models/animal.dart';
import '../providers/animal_browser_provider.dart';
import '../widgets/app_ui.dart';
import '../widgets/animal_network_image.dart';

class AnimalDetailPage extends ConsumerWidget {
  const AnimalDetailPage({super.key, required this.animal});

  final Animal animal;

  Future<void> _callShelter(BuildContext context) async {
    final tel = animal.shelterTel;
    if ((tel ?? '').isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('目前沒有可撥打的收容所電話')));
      return;
    }

    final uri = Uri(scheme: 'tel', path: tel);
    final opened = await launchUrl(uri);
    if (!opened && context.mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('目前無法撥打電話')));
    }
  }

  Future<void> _shareAnimal(BuildContext context) async {
    final content = [
      animal.headlineTitle,
      '${animal.animalKind ?? '毛孩'}｜${animal.sexText}｜${animal.ageText}｜${animal.bodyTypePetText}',
      '品種：${animal.animalVariety ?? '未提供'}',
      '花色：${animal.animalColour ?? '未提供'}',
      '收容所：${animal.shelterName ?? animal.primaryLocation}',
      if ((animal.shelterTel ?? '').isNotEmpty) '電話：${animal.shelterTel}',
    ].join('\n');

    await Clipboard.setData(ClipboardData(text: content));
    if (context.mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('已複製分享資訊')));
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    const heroHeight = 340.0;
    final sexColor = animal.sexText == '公'
        ? const Color(0xFF3572D4)
        : animal.sexText == '母'
        ? const Color(0xFFD25A72)
        : const Color(0xFF5A544D);
    final isFavorite = ref.watch(
      favoriteAnimalIdsProvider.select((ids) => ids.contains(animal.animalId)),
    );
    final identityChips = [
      animal.statusText,
      animal.animalKind ?? '毛孩',
      animal.animalColour ?? '花色未提供',
      animal.animalVariety ?? '品種未提供',
    ];

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: Stack(
          children: [
            CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: SizedBox(
                    height: heroHeight,
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        AnimalNetworkImage(
                          imageUrl: animal.albumFile,
                          fit: BoxFit.cover,
                        ),
                        DecoratedBox(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.bottomCenter,
                              end: Alignment.topCenter,
                              colors: [
                                Colors.black.withValues(alpha: 0.34),
                                Colors.black.withValues(alpha: 0.08),
                              ],
                            ),
                          ),
                        ),
                        Positioned(
                          left: 16,
                          right: 16,
                          bottom: 16,
                          child: Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              _PhotoInfoPill(
                                icon: animal.animalSex == 'M'
                                    ? Icons.male_rounded
                                    : animal.animalSex == 'F'
                                    ? Icons.female_rounded
                                    : Icons.help_outline_rounded,
                                label: animal.sexText,
                                foreground: sexColor,
                              ),
                              _PhotoInfoPill(
                                icon: Icons.cake_outlined,
                                label: animal.ageText,
                              ),
                              _PhotoInfoPill(
                                icon: Icons.straighten_rounded,
                                label: animal.bodyTypePetText,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Container(
                    decoration: const BoxDecoration(
                      color: AppTheme.background,
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(30),
                      ),
                    ),
                    padding: EdgeInsets.fromLTRB(
                      AppResponsive.pageInset(context),
                      18,
                      AppResponsive.pageInset(context),
                      28,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _HeroSummaryCard(
                          animal: animal,
                          identityChips: identityChips,
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: _MetricCard(
                                title: '來園多久',
                                value: animal.stayDurationLabel,
                                dateLabel: animal.createDateLabel,
                                icon: Icons.calendar_today_outlined,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _MetricCard(
                                title: '認養狀態',
                                value: animal.statusText,
                                icon: Icons.volunteer_activism_outlined,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        _SectionCard(
                          title: '基本資料',
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _InfoRow(
                                icon: animal.animalSex == 'M'
                                    ? Icons.male_rounded
                                    : animal.animalSex == 'F'
                                    ? Icons.female_rounded
                                    : Icons.help_outline_rounded,
                                text: '性別 ${animal.sexText}',
                                iconColor: sexColor,
                              ),
                              const SizedBox(height: 10),
                              _InfoRow(
                                icon: Icons.pets_outlined,
                                text: '品種 ${animal.animalVariety ?? '未提供'}',
                              ),
                              const SizedBox(height: 10),
                              _InfoRow(
                                icon: Icons.palette_outlined,
                                text: '花色 ${animal.animalColour ?? '未提供'}',
                              ),
                              const SizedBox(height: 10),
                              _InfoRow(
                                icon: Icons.category_outlined,
                                text: '種類 ${animal.animalKind ?? '未提供'}',
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),
                        _SectionCard(
                          title: '照護狀態',
                          child: Wrap(
                            spacing: 10,
                            runSpacing: 10,
                            children: [
                              _CarePill(
                                label: animal.sterilizationText,
                                positive: animal.animalSterilization == 'T',
                              ),
                              _CarePill(
                                label: animal.bacterinText,
                                positive: animal.animalBacterin == 'T',
                                warning: animal.animalBacterin == 'F',
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),
                        _SectionCard(
                          title: '收容與來源',
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _InfoRow(
                                icon: Icons.home_work_outlined,
                                text:
                                    animal.shelterName ??
                                    animal.primaryLocation,
                              ),
                              const SizedBox(height: 10),
                              _InfoRow(
                                icon: Icons.place_outlined,
                                text:
                                    animal.shelterAddress ??
                                    animal.primaryLocation,
                              ),
                              const SizedBox(height: 10),
                              _InfoRow(
                                icon: Icons.pin_drop_outlined,
                                text: animal.sourceLocationText,
                              ),
                              if ((animal.shelterTel ?? '').isNotEmpty) ...[
                                const SizedBox(height: 10),
                                _InfoRow(
                                  icon: Icons.phone_outlined,
                                  text: animal.shelterTel!,
                                ),
                              ],
                            ],
                          ),
                        ),
                        if (animal.notePreview != null) ...[
                          const SizedBox(height: 12),
                          _SectionCard(
                            title: '補充資訊',
                            child: Text(
                              animal.notePreview!,
                              style: const TextStyle(
                                fontSize: 16,
                                color: AppTheme.text,
                                height: 1.5,
                              ),
                            ),
                          ),
                        ],
                        const SizedBox(height: 12),
                        _SectionCard(
                          title: '資料資訊',
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _InfoRow(
                                icon: Icons.badge_outlined,
                                text: 'ID: ${animal.animalId ?? '--'}',
                              ),
                              if ((animal.animalSubid ?? '').isNotEmpty) ...[
                                const SizedBox(height: 10),
                                _InfoRow(
                                  icon: Icons.sell_outlined,
                                  text: animal.animalSubid!,
                                ),
                              ],
                              const SizedBox(height: 10),
                              _InfoRow(
                                icon: Icons.update_outlined,
                                text: '資料更新日期 ${animal.updateDateLabel}',
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 22),
                        SizedBox(
                          width: double.infinity,
                          height: 56,
                          child: ElevatedButton.icon(
                            onPressed: () => _callShelter(context),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.primaryButton,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(18),
                              ),
                            ),
                            icon: const Icon(Icons.call_outlined),
                            label: const Text(
                              '聯絡收容所',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
              child: Row(
                children: [
                  _TopActionButton(
                    icon: Icons.arrow_back_ios_new_rounded,
                    onTap: () => Navigator.of(context).pop(),
                  ),
                  const Spacer(),
                  _TopActionButton(
                    icon: Icons.ios_share_rounded,
                    onTap: () => _shareAnimal(context),
                  ),
                  const SizedBox(width: 10),
                  _TopActionButton(
                    icon: isFavorite
                        ? Icons.favorite_rounded
                        : Icons.favorite_border_rounded,
                    active: isFavorite,
                    onTap: () {
                      ref
                          .read(favoriteAnimalIdsProvider.notifier)
                          .toggle(animal.animalId);
                    },
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

class _HeroSummaryCard extends StatelessWidget {
  const _HeroSummaryCard({required this.animal, required this.identityChips});

  final Animal animal;
  final List<String> identityChips;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: const [
          BoxShadow(
            color: Color(0x12000000),
            blurRadius: 18,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            animal.headlineTitle,
            style: const TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.w900,
              color: AppTheme.text,
            ),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: identityChips
                .map((label) => _MetaChip(label: label))
                .toList(),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _SummaryLine(
                  icon: Icons.home_work_outlined,
                  text: animal.shelterName ?? animal.primaryLocation,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _SummaryLine(
                  icon: Icons.place_outlined,
                  text: animal.sourceLocationText,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _TopActionButton extends StatelessWidget {
  const _TopActionButton({
    required this.icon,
    required this.onTap,
    this.active = false,
  });

  final IconData icon;
  final VoidCallback onTap;
  final bool active;

  @override
  Widget build(BuildContext context) {
    return AppTopCircleButton(icon: icon, onTap: onTap, active: active);
  }
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({
    required this.title,
    required this.value,
    required this.icon,
    this.dateLabel,
  });

  final String title;
  final String value;
  final IconData icon;
  final String? dateLabel;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(22),
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
          Icon(icon, color: AppTheme.primaryButton),
          const SizedBox(height: 10),
          Text(
            title,
            style: const TextStyle(fontSize: 14, color: AppTheme.subText),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w900,
              color: AppTheme.text,
            ),
          ),
          if ((dateLabel ?? '').isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              dateLabel!,
              style: const TextStyle(fontSize: 13, color: AppTheme.subText),
            ),
          ],
        ],
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return AppSurfaceCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: AppTheme.subText,
            ),
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}

class _MetaChip extends StatelessWidget {
  const _MetaChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return AppInfoPill(
      label: label,
      foreground: AppTheme.text,
      background: const Color(0xFFF7F0E7),
    );
  }
}

class _CarePill extends StatelessWidget {
  const _CarePill({
    required this.label,
    this.positive = false,
    this.warning = false,
  });

  final String label;
  final bool positive;
  final bool warning;

  @override
  Widget build(BuildContext context) {
    final background = warning
        ? const Color(0xFFFFF0DE)
        : positive
        ? const Color(0xFFE9F5DA)
        : const Color(0xFFF3EFE8);
    final color = warning
        ? const Color(0xFFB57212)
        : positive
        ? const Color(0xFF4B7A2E)
        : const Color(0xFF5A544D);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: TextStyle(color: color, fontWeight: FontWeight.w700),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.icon,
    required this.text,
    this.iconColor = AppTheme.subText,
  });

  final IconData icon;
  final String text;
  final Color iconColor;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: iconColor),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 15,
              color: AppTheme.text,
              height: 1.45,
            ),
          ),
        ),
      ],
    );
  }
}

class _SummaryLine extends StatelessWidget {
  const _SummaryLine({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: AppTheme.primaryButton),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: AppTheme.text,
              fontWeight: FontWeight.w700,
              height: 1.35,
            ),
          ),
        ),
      ],
    );
  }
}

class _PhotoInfoPill extends StatelessWidget {
  const _PhotoInfoPill({
    required this.icon,
    required this.label,
    this.foreground = AppTheme.text,
  });

  final IconData icon;
  final String label;
  final Color foreground;

  @override
  Widget build(BuildContext context) {
    return AppInfoPill(label: label, icon: icon, foreground: foreground);
  }
}
