import 'dart:math';

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../app_theme.dart';
import '../data/mock_animals.dart';
import '../models/animal.dart';
import 'all_animals_page.dart';

class ExplorePage extends StatefulWidget {
  const ExplorePage({super.key});

  @override
  State<ExplorePage> createState() => _ExplorePageState();
}

class _ExplorePageState extends State<ExplorePage> {
  static const List<String> _cityOptions = [
    '全部地區',
    '臺北市',
    '新北市',
    '台中市',
    '台南市',
    '高雄市',
  ];

  static const List<_CampaignBanner> _campaigns = [
    _CampaignBanner(
      title: '春遊野餐派對',
      subtitle: '2026 花園孩子回娘家',
      imagePath: 'assets/images/activity/banner.jpg',
      linkUrl: 'https://www.doghome.org.tw/pages/single_page.php?ID=193',
    ),
  ];

  final TextEditingController _searchController = TextEditingController();
  late final PageController _campaignController;

  AnimalCategory _selectedCategory = AnimalCategory.all;
  String? _selectedGender;
  String? _selectedCity;
  int _recommendSeed = 0;
  int _campaignIndex = 0;

  bool get _hasActiveFilters {
    return _selectedCategory != AnimalCategory.all ||
        _selectedGender != null ||
        _selectedCity != null;
  }

  @override
  void initState() {
    super.initState();
    _campaignController = PageController(viewportFraction: 0.98);
    _campaignController.addListener(_handleCampaignScroll);
  }

  void _handleCampaignScroll() {
    final int nextIndex = (_campaignController.page ?? 0).round();
    if (_campaignIndex != nextIndex && mounted) {
      setState(() {
        _campaignIndex = nextIndex;
      });
    }
  }

  List<Animal> get _filteredAnimals {
    final String keyword = _searchController.text.trim().toLowerCase();

    return mockAnimals.where((animal) {
      final bool matchCategory =
          _selectedCategory == AnimalCategory.all ||
          animal.category == _selectedCategory;
      if (!matchCategory) {
        return false;
      }

      if (_selectedGender != null && animal.gender != _selectedGender) {
        return false;
      }

      if (_selectedCity != null) {
        final String location = animal.location.replaceAll('臺', '台');
        final String city = _selectedCity!.replaceAll('臺', '台');
        if (!location.contains(city)) {
          return false;
        }
      }

      if (keyword.isEmpty) {
        return true;
      }

      return animal.name.toLowerCase().contains(keyword) ||
          animal.location.toLowerCase().contains(keyword);
    }).toList();
  }

  List<Animal> get _recommendedAnimals {
    final List<Animal> source = List<Animal>.from(_filteredAnimals);
    source.shuffle(Random(_recommendSeed));
    return source.take(6).toList();
  }

  Future<void> _openCampaignLink(_CampaignBanner campaign) async {
    final Uri uri = Uri.parse(campaign.linkUrl);

    final bool openedInApp = await launchUrl(
      uri,
      mode: LaunchMode.inAppBrowserView,
    );

    if (openedInApp) {
      return;
    }

    final bool openedExternal = await launchUrl(
      uri,
      mode: LaunchMode.externalApplication,
    );

    if (!openedExternal && mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('目前無法開啟活動頁面')));
    }
  }

  Future<void> _openFilterSheet() async {
    AnimalCategory tempCategory = _selectedCategory;
    String? tempGender = _selectedGender;
    String? tempCity = _selectedCity;

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppTheme.background,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return SafeArea(
              top: false,
              child: Padding(
                padding: EdgeInsets.fromLTRB(
                  16,
                  16,
                  16,
                  16 + MediaQuery.of(context).viewInsets.bottom,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 42,
                        height: 4,
                        decoration: BoxDecoration(
                          color: Colors.black26,
                          borderRadius: BorderRadius.circular(99),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      '篩選條件',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 14),
                    const Text(
                      '類別',
                      style: TextStyle(fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: AnimalCategory.values.map((category) {
                        return ChoiceChip(
                          label: Text(_categoryLabel(category)),
                          selected: tempCategory == category,
                          onSelected: (_) {
                            setSheetState(() {
                              tempCategory = category;
                            });
                          },
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 14),
                    const Text(
                      '性別',
                      style: TextStyle(fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        ChoiceChip(
                          label: const Text('不限'),
                          selected: tempGender == null,
                          onSelected: (_) {
                            setSheetState(() {
                              tempGender = null;
                            });
                          },
                        ),
                        ChoiceChip(
                          label: const Text('公'),
                          selected: tempGender == '公',
                          onSelected: (_) {
                            setSheetState(() {
                              tempGender = '公';
                            });
                          },
                        ),
                        ChoiceChip(
                          label: const Text('母'),
                          selected: tempGender == '母',
                          onSelected: (_) {
                            setSheetState(() {
                              tempGender = '母';
                            });
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    const Text(
                      '地區',
                      style: TextStyle(fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _cityOptions.map((city) {
                        final String? value = city == '全部地區' ? null : city;
                        return ChoiceChip(
                          label: Text(city),
                          selected: tempCity == value,
                          onSelected: (_) {
                            setSheetState(() {
                              tempCity = value;
                            });
                          },
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 18),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () {
                              setState(() {
                                _selectedCategory = AnimalCategory.all;
                                _selectedGender = null;
                                _selectedCity = null;
                                _recommendSeed = 0;
                              });
                              Navigator.of(context).pop();
                            },
                            child: const Text('重設'),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              setState(() {
                                _selectedCategory = tempCategory;
                                _selectedGender = tempGender;
                                _selectedCity = tempCity;
                                _recommendSeed = 0;
                              });
                              Navigator.of(context).pop();
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.primaryButton,
                              foregroundColor: Colors.white,
                            ),
                            child: const Text('套用'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  void dispose() {
    _campaignController.removeListener(_handleCampaignScroll);
    _campaignController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final List<Animal> recommended = _recommendedAnimals;

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
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
                    '臺北市',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                  ),
                  Icon(Icons.keyboard_arrow_down),
                  Spacer(),
                  Icon(Icons.notifications_none, size: 24),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      onChanged: (_) => setState(() {}),
                      decoration: InputDecoration(
                        hintText: '搜尋動物、品種或收容所',
                        prefixIcon: const Icon(Icons.search),
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(vertical: 0),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Material(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(14),
                      onTap: _openFilterSheet,
                      child: const SizedBox(
                        width: 52,
                        height: 52,
                        child: Icon(Icons.tune),
                      ),
                    ),
                  ),
                ],
              ),
              if (_hasActiveFilters) ...[
                const SizedBox(height: 8),
                SizedBox(
                  height: 34,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: [
                      if (_selectedCategory != AnimalCategory.all)
                        _FilterTag(label: _categoryLabel(_selectedCategory)),
                      if (_selectedGender != null)
                        _FilterTag(label: '性別 ${_selectedGender!}'),
                      if (_selectedCity != null)
                        _FilterTag(label: _selectedCity!),
                      TextButton(
                        onPressed: () {
                          setState(() {
                            _selectedCategory = AnimalCategory.all;
                            _selectedGender = null;
                            _selectedCity = null;
                            _recommendSeed = 0;
                          });
                        },
                        child: const Text('清除'),
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 10),
              _CampaignCarousel(
                controller: _campaignController,
                campaigns: _campaigns,
                selectedIndex: _campaignIndex,
                onTap: _openCampaignLink,
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  const Text(
                    '推薦毛孩',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: () {
                      setState(() {
                        _recommendSeed++;
                      });
                    },
                    tooltip: '換一批',
                    icon: const Icon(
                      Icons.refresh_rounded,
                      color: AppTheme.primaryButton,
                    ),
                  ),
                  FilledButton(
                    style: FilledButton.styleFrom(
                      backgroundColor: AppTheme.primaryButton,
                      foregroundColor: Colors.white,
                    ),
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (context) => AllAnimalsPage(
                            initialKeyword: _searchController.text,
                            initialCategory: _selectedCategory,
                          ),
                        ),
                      );
                    },
                    child: const Text('查看全部'),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Expanded(
                child: recommended.isEmpty
                    ? const Center(child: Text('目前沒有符合條件的毛孩'))
                    : GridView.builder(
                        itemCount: recommended.length,
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              mainAxisSpacing: 10,
                              crossAxisSpacing: 10,
                              childAspectRatio: 0.72,
                            ),
                        itemBuilder: (context, index) {
                          return _AnimalCard(animal: recommended[index]);
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: Transform.translate(
        offset: const Offset(0, 12),
        child: SizedBox(
          width: 56,
          height: 56,
          child: FloatingActionButton(
            onPressed: () {},
            backgroundColor: AppTheme.primaryButton,
            foregroundColor: Colors.white,
            elevation: 4,
            shape: const CircleBorder(),
            child: const Icon(Icons.pets_rounded, size: 22),
          ),
        ),
      ),
      bottomNavigationBar: const _BottomNavBar(),
    );
  }

  static String _categoryLabel(AnimalCategory category) {
    switch (category) {
      case AnimalCategory.all:
        return '全部';
      case AnimalCategory.dog:
        return '狗狗';
      case AnimalCategory.cat:
        return '貓咪';
      case AnimalCategory.other:
        return '其他';
    }
  }
}

class _CampaignCarousel extends StatelessWidget {
  const _CampaignCarousel({
    required this.controller,
    required this.campaigns,
    required this.selectedIndex,
    required this.onTap,
  });

  final PageController controller;
  final List<_CampaignBanner> campaigns;
  final int selectedIndex;
  final ValueChanged<_CampaignBanner> onTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 132,
          child: PageView.builder(
            controller: controller,
            itemCount: campaigns.length,
            itemBuilder: (context, index) {
              final _CampaignBanner campaign = campaigns[index];
              return Padding(
                padding: const EdgeInsets.only(right: 6),
                child: InkWell(
                  borderRadius: BorderRadius.circular(14),
                  onTap: () => onTap(campaign),
                  child: Ink(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x15000000),
                          blurRadius: 8,
                          offset: Offset(0, 3),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(14),
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          Image.asset(campaign.imagePath, fit: BoxFit.cover),
                          const Positioned(
                            right: 10,
                            top: 10,
                            child: DecoratedBox(
                              decoration: BoxDecoration(
                                color: Color(0xCC000000),
                                borderRadius: BorderRadius.all(
                                  Radius.circular(99),
                                ),
                              ),
                              child: Padding(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 5,
                                ),
                                child: Text(
                                  '活動資訊',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const Positioned(
                            left: 10,
                            bottom: 10,
                            child: DecoratedBox(
                              decoration: BoxDecoration(
                                color: Color(0xA6000000),
                                borderRadius: BorderRadius.all(
                                  Radius.circular(10),
                                ),
                              ),
                              child: Padding(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                child: Text(
                                  '點擊查看活動與報名',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        if (campaigns.length > 1) ...[
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(campaigns.length, (index) {
              final bool isActive = index == selectedIndex;
              return AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                margin: const EdgeInsets.symmetric(horizontal: 3),
                width: isActive ? 18 : 6,
                height: 6,
                decoration: BoxDecoration(
                  color: isActive ? AppTheme.primaryButton : Colors.black26,
                  borderRadius: BorderRadius.circular(99),
                ),
              );
            }),
          ),
        ],
      ],
    );
  }
}

class _CampaignBanner {
  const _CampaignBanner({
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

class _FilterTag extends StatelessWidget {
  const _FilterTag({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(99),
      ),
      child: Center(
        child: Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
      ),
    );
  }
}

class _AnimalCard extends StatelessWidget {
  const _AnimalCard({required this.animal});

  final Animal animal;

  @override
  Widget build(BuildContext context) {
    final bool isMale = animal.gender == '公';

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(14),
              ),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Image.asset(animal.imagePath, fit: BoxFit.cover),
                  const Positioned(
                    right: 8,
                    top: 8,
                    child: Icon(
                      Icons.favorite_border,
                      color: Colors.white,
                      size: 22,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(10, 8, 10, 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        animal.name,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    Text(
                      isMale ? '♂' : '♀',
                      style: TextStyle(
                        color: isMale ? Colors.blue : Colors.pink,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  animal.ageText,
                  style: const TextStyle(color: Colors.black54),
                ),
                Text(
                  animal.location,
                  style: const TextStyle(color: Colors.black54),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _BottomNavBar extends StatelessWidget {
  const _BottomNavBar();

  @override
  Widget build(BuildContext context) {
    return BottomAppBar(
      color: const Color(0xFFF9F7F4),
      shape: const CircularNotchedRectangle(),
      notchMargin: 7,
      elevation: 6,
      child: SizedBox(
        height: 74,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: const [
            _NavItem(icon: Icons.home_filled, label: '首頁', selected: true),
            _NavItem(icon: Icons.location_on_outlined, label: '地圖'),
            _CenterNavLabel(label: '配對'),
            _NavItem(icon: Icons.favorite_border, label: '收藏'),
            _NavItem(icon: Icons.person_outline, label: '我的'),
          ],
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.icon,
    required this.label,
    this.selected = false,
  });

  final IconData icon;
  final String label;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final Color color = selected
        ? AppTheme.primaryButton
        : const Color(0xFF8E8E8E);
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, size: 24, color: color),
        const SizedBox(height: 3),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: color,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _CenterNavLabel extends StatelessWidget {
  const _CenterNavLabel({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 64,
      child: Align(
        alignment: const Alignment(0, 0.82),
        child: Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Color(0xFF6F6F6F),
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
