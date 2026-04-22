import 'package:flutter/material.dart';

class CampaignBanner {
  const CampaignBanner({
    required this.title,
    required this.subtitle,
    required this.imagePath,
    required this.linkUrl,
  });

  final String title;
  final String subtitle;
  final String imagePath;
  final String linkUrl;
}

class CampaignCarousel extends StatelessWidget {
  const CampaignCarousel({
    super.key,
    required this.controller,
    required this.campaigns,
    required this.selectedIndex,
    required this.onTap,
  });

  final PageController controller;
  final List<CampaignBanner> campaigns;
  final int selectedIndex;
  final ValueChanged<CampaignBanner> onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 170,
      child: PageView.builder(
        controller: controller,
        itemCount: campaigns.length,
        itemBuilder: (context, index) {
          final campaign = campaigns[index];

          return Material(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              onTap: () => onTap(campaign),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Image.asset(campaign.imagePath, fit: BoxFit.cover),
                  DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                        colors: [
                          Colors.black.withValues(alpha: 0.68),
                          Colors.black.withValues(alpha: 0.08),
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(18, 18, 18, 18),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(
                          campaign.subtitle,
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          campaign.title,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 12,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(campaigns.length, (dotIndex) {
                        final dotSelected = dotIndex == selectedIndex;
                        return AnimatedContainer(
                          duration: const Duration(milliseconds: 180),
                          width: dotSelected ? 18 : 8,
                          height: 8,
                          margin: const EdgeInsets.symmetric(horizontal: 3),
                          decoration: BoxDecoration(
                            color: dotSelected
                                ? Colors.white
                                : Colors.white.withValues(alpha: 0.4),
                            borderRadius: BorderRadius.circular(999),
                            boxShadow: dotSelected
                                ? const [
                                    BoxShadow(
                                      color: Color(0x22000000),
                                      blurRadius: 4,
                                    ),
                                  ]
                                : null,
                          ),
                        );
                      }),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
