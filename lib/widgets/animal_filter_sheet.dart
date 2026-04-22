import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../app_theme.dart';
import '../models/animal.dart';
import '../providers/animal_browser_provider.dart';

Future<void> showAnimalFilterSheet(BuildContext context, WidgetRef ref) async {
  final browserState = ref.read(animalBrowserProvider);
  final cityOptions = ref.read(cityOptionsProvider);

  AnimalFilterCategory tempCategory = browserState.category;
  String? tempGender = browserState.gender;
  String? tempCity = browserState.city;

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
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900),
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
                    children: AnimalFilterCategory.values.map((category) {
                      return ChoiceChip(
                        label: Text(filterCategoryLabel(category)),
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
                    children: [
                      ChoiceChip(
                        label: const Text('全部地區'),
                        selected: tempCity == null,
                        onSelected: (_) {
                          setSheetState(() {
                            tempCity = null;
                          });
                        },
                      ),
                      ...cityOptions.map((city) {
                        return ChoiceChip(
                          label: Text(city),
                          selected: tempCity == city,
                          onSelected: (_) {
                            setSheetState(() {
                              tempCity = city;
                            });
                          },
                        );
                      }),
                    ],
                  ),
                  const SizedBox(height: 18),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {
                            ref
                                .read(animalBrowserProvider.notifier)
                                .clearFilters();
                            Navigator.of(context).pop();
                          },
                          child: const Text('重設'),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            ref
                                .read(animalBrowserProvider.notifier)
                                .applyFilters(
                                  category: tempCategory,
                                  gender: tempGender,
                                  city: tempCity,
                                );
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

String filterCategoryLabel(AnimalFilterCategory category) {
  switch (category) {
    case AnimalFilterCategory.all:
      return '全部';
    case AnimalFilterCategory.dog:
      return '狗狗';
    case AnimalFilterCategory.cat:
      return '貓咪';
    case AnimalFilterCategory.other:
      return '其他';
  }
}
