import '../models/animal.dart';

class AnimalBrowserState {
  const AnimalBrowserState({
    this.keyword = '',
    this.category = AnimalFilterCategory.all,
    this.gender,
    this.city,
  });

  final String keyword;
  final AnimalFilterCategory category;
  final String? gender;
  final String? city;

  bool get hasActiveFilters {
    return category != AnimalFilterCategory.all ||
        gender != null ||
        city != null;
  }

  AnimalBrowserState copyWith({
    String? keyword,
    AnimalFilterCategory? category,
    Object? gender = _sentinel,
    Object? city = _sentinel,
  }) {
    return AnimalBrowserState(
      keyword: keyword ?? this.keyword,
      category: category ?? this.category,
      gender: identical(gender, _sentinel) ? this.gender : gender as String?,
      city: identical(city, _sentinel) ? this.city : city as String?,
    );
  }

  AnimalBrowserState resetFilters() {
    return copyWith(
      category: AnimalFilterCategory.all,
      gender: null,
      city: null,
    );
  }
}

const Object _sentinel = Object();
