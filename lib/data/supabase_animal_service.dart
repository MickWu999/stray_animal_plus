import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/home_sections.dart';
import '../models/animal.dart';

class SupabaseAnimalService {
  SupabaseAnimalService({SupabaseClient? client})
    : _client = client ?? Supabase.instance.client;

  static const int _pageSize = 1000;

  final SupabaseClient _client;

  Future<List<Animal>> fetchAnimals({bool activeOnly = true}) async {
    final animals = <Animal>[];
    var from = 0;

    while (true) {
      var query = _client.from('v_animals_app').select();

      if (activeOnly) {
        query = query.eq('is_active', true);
      }

      final rows = await query
          .order('animal_update', ascending: false)
          .order('animal_id', ascending: false)
          .range(from, from + _pageSize - 1);
      final page = (rows as List<dynamic>)
          .cast<Map<String, dynamic>>()
          .map(Animal.fromJson)
          .toList(growable: false);

      animals.addAll(page);
      if (page.length < _pageSize) {
        break;
      }
      from += _pageSize;
    }

    return animals;
  }

  Future<HomeSections> fetchHomeSections({
    String city = '新北市',
    int limit = 12,
  }) async {
    final response = await _client.rpc(
      'get_home_sections',
      params: {'p_city': city, 'p_limit': limit},
    );

    return HomeSections.fromJson(Map<String, dynamic>.from(response as Map));
  }
}
