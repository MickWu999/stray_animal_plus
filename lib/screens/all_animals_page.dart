import 'package:flutter/material.dart';

import '../app_theme.dart';
import '../data/mock_animals.dart';
import '../models/animal.dart';

class AllAnimalsPage extends StatefulWidget {
  const AllAnimalsPage({
    super.key,
    required this.initialKeyword,
    required this.initialCategory,
  });

  final String initialKeyword;
  final AnimalCategory initialCategory;

  @override
  State<AllAnimalsPage> createState() => _AllAnimalsPageState();
}

class _AllAnimalsPageState extends State<AllAnimalsPage> {
  late final TextEditingController _searchController;
  late AnimalCategory _selectedCategory;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController(text: widget.initialKeyword);
    _selectedCategory = widget.initialCategory;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Animal> get _filteredAnimals {
    final String keyword = _searchController.text.trim().toLowerCase();
    return mockAnimals.where((animal) {
      final bool matchCategory =
          _selectedCategory == AnimalCategory.all ||
          animal.category == _selectedCategory;
      if (!matchCategory) return false;
      if (keyword.isEmpty) return true;
      return animal.name.toLowerCase().contains(keyword) ||
          animal.location.toLowerCase().contains(keyword);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final List<Animal> animals = _filteredAnimals;

    return Scaffold(
      appBar: AppBar(
        title: const Text('全部毛孩'),
        backgroundColor: AppTheme.background,
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
        child: Column(
          children: [
            TextField(
              controller: _searchController,
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(
                hintText: '搜尋動物、品種或收容所',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              height: 40,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: AnimalCategory.values.map((category) {
                  final bool selected = category == _selectedCategory;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(_categoryLabel(category)),
                      selected: selected,
                      onSelected: (_) {
                        setState(() {
                          _selectedCategory = category;
                        });
                      },
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: animals.isEmpty
                  ? const Center(child: Text('目前沒有符合條件的毛孩'))
                  : GridView.builder(
                      itemCount: animals.length,
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            mainAxisSpacing: 10,
                            crossAxisSpacing: 10,
                            childAspectRatio: 0.72,
                          ),
                      itemBuilder: (context, index) {
                        return _AnimalCard(animal: animals[index]);
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  String _categoryLabel(AnimalCategory category) {
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
              child: Image.asset(
                animal.imagePath,
                fit: BoxFit.cover,
                width: double.infinity,
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
