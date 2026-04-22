import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/animal_api_service.dart';
import '../data/mock_animals_gov.dart';
import '../models/animal.dart';
import '../state/animal_browser_state.dart';

final animalApiServiceProvider = Provider<AnimalApiService>((ref) {
  return AnimalApiService();
});

final animalFeedProvider = FutureProvider<List<Animal>>((ref) async {
  final api = ref.watch(animalApiServiceProvider);
  try {
    final animals = await api.fetchAnimals();
    if (animals.isNotEmpty) {
      return animals;
    }
  } catch (_) {}
  return mockAnimalsGov;
});

final animalRepositoryProvider = Provider<AsyncValue<List<Animal>>>((ref) {
  return ref.watch(animalFeedProvider);
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

final cityOptionsProvider = Provider<AsyncValue<List<String>>>((ref) {
  final asyncAnimals = ref.watch(animalFeedProvider);
  return asyncAnimals.whenData((animals) {
    final cities =
        animals
            .map((animal) => animal.cityName)
            .whereType<String>()
            .toSet()
            .toList()
          ..sort();
    return cities;
  });
});

final filteredAnimalsProvider = Provider<AsyncValue<List<Animal>>>((ref) {
  final asyncAnimals = ref.watch(animalFeedProvider);
  final state = ref.watch(animalBrowserProvider);

  return asyncAnimals.whenData((animals) {
    return animals
        .where((animal) {
          final matchesCategory =
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
});

class FavoriteAnimalsNotifier extends Notifier<Set<int>> {
  @override
  Set<int> build() {
    return <int>{};
  }

  void toggle(int? animalId) {
    if (animalId == null) {
      return;
    }

    final next = Set<int>.from(state);
    if (!next.add(animalId)) {
      next.remove(animalId);
    }
    state = next;
  }

  bool contains(int? animalId) {
    if (animalId == null) {
      return false;
    }
    return state.contains(animalId);
  }

  void clearAll() {
    state = <int>{};
  }
}

final favoriteAnimalIdsProvider =
    NotifierProvider<FavoriteAnimalsNotifier, Set<int>>(
      FavoriteAnimalsNotifier.new,
    );

final favoriteAnimalsProvider = Provider<AsyncValue<List<Animal>>>((ref) {
  final favoriteIds = ref.watch(favoriteAnimalIdsProvider);
  final asyncAnimals = ref.watch(animalFeedProvider);

  return asyncAnimals.whenData((animals) {
    return animals
        .where((animal) => favoriteIds.contains(animal.animalId))
        .toList(growable: false);
  });
});
