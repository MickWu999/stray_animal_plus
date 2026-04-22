import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/mock_animals_gov.dart';
import '../models/animal.dart';
import '../state/animal_browser_state.dart';

final animalRepositoryProvider = Provider<List<Animal>>((ref) {
  return mockAnimalsGov;
});

class AnimalBrowserNotifier extends Notifier<AnimalBrowserState> {
  @override
  AnimalBrowserState build() {
    return const AnimalBrowserState();
  }

  void setKeyword(String keyword) {
    state = state.copyWith(keyword: keyword);
  }

  void setCategory(AnimalFilterCategory category) {
    state = state.copyWith(category: category);
  }

  void setGender(String? gender) {
    state = state.copyWith(gender: gender);
  }

  void setCity(String? city) {
    state = state.copyWith(city: city);
  }

  void applyFilters({
    required AnimalFilterCategory category,
    required String? gender,
    required String? city,
  }) {
    state = state.copyWith(category: category, gender: gender, city: city);
  }

  void clearFilters() {
    state = state.resetFilters();
  }
}

final animalBrowserProvider =
    NotifierProvider<AnimalBrowserNotifier, AnimalBrowserState>(
      AnimalBrowserNotifier.new,
    );

final cityOptionsProvider = Provider<List<String>>((ref) {
  final animals = ref.watch(animalRepositoryProvider);
  final cities =
      animals
          .map((animal) => animal.cityName)
          .whereType<String>()
          .toSet()
          .toList()
        ..sort();
  return cities;
});

final filteredAnimalsProvider = Provider<List<Animal>>((ref) {
  final animals = ref.watch(animalRepositoryProvider);
  final state = ref.watch(animalBrowserProvider);

  return animals
      .where((animal) {
        final bool matchesCategory =
            state.category == AnimalFilterCategory.all ||
            animal.filterCategory == state.category;
        if (!matchesCategory) {
          return false;
        }

        if (state.gender != null && animal.sexText != state.gender) {
          return false;
        }

        if (state.city != null && animal.cityName != state.city) {
          return false;
        }

        return animal.matchesKeyword(state.keyword);
      })
      .toList(growable: false);
});
