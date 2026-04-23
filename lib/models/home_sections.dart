import 'animal.dart';

class HomeSections {
  const HomeSections({
    required this.dailyFate,
    required this.nearbyAnimals,
    required this.newOpen,
    required this.waitingLong,
    required this.mostFavorited,
    required this.recentGraduated,
  });

  final List<Animal> dailyFate;
  final List<Animal> nearbyAnimals;
  final List<Animal> newOpen;
  final List<Animal> waitingLong;
  final List<Animal> mostFavorited;
  final List<Animal> recentGraduated;

  const HomeSections.empty()
    : dailyFate = const <Animal>[],
      nearbyAnimals = const <Animal>[],
      newOpen = const <Animal>[],
      waitingLong = const <Animal>[],
      mostFavorited = const <Animal>[],
      recentGraduated = const <Animal>[];

  factory HomeSections.fromJson(Map<String, dynamic> json) {
    List<Animal> parseAnimals(String key) {
      final raw = json[key];
      if (raw is! List) {
        return const <Animal>[];
      }

      return raw
          .whereType<Map>()
          .map((item) => Animal.fromJson(Map<String, dynamic>.from(item)))
          .toList(growable: false);
    }

    return HomeSections(
      dailyFate: parseAnimals('daily_fate'),
      nearbyAnimals: parseAnimals('nearby_animals'),
      newOpen: parseAnimals('new_open'),
      waitingLong: parseAnimals('waiting_long'),
      mostFavorited: parseAnimals('most_favorited'),
      recentGraduated: parseAnimals('recent_graduated'),
    );
  }
}
