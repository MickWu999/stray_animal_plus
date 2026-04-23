import 'package:dio/dio.dart';

import '../models/animal.dart';

class AnimalApiService {
  AnimalApiService({Dio? dio}) : _dio = dio ?? _sharedDio;

  static const String endpoint ='fake';
      // 'https://data.moa.gov.tw/Service/OpenData/TransService.aspx?UnitId=QcbUEzN6E6DL';
  static final Dio _sharedDio = _buildDio();
  static const Duration _cacheTtl = Duration(minutes: 10);
  static List<Animal>? _memoryCache;
  static DateTime? _lastFetchedAt;

  final Dio _dio;

  Future<List<Animal>> fetchAnimals({
    int limit = 1000,
    bool forceRefresh = false,
  }) async {
    final cache = _memoryCache;
    final fetchedAt = _lastFetchedAt;
    final cacheStillFresh =
        !forceRefresh &&
        cache != null &&
        fetchedAt != null &&
        DateTime.now().difference(fetchedAt) < _cacheTtl;

    if (cacheStillFresh) {
      return cache.take(limit).toList(growable: false);
    }

    final response = await _dio.get<Object>(endpoint);
    if (response.data is! List) {
      throw Exception('Unexpected response format');
    }

    final decoded = response.data! as List<dynamic>;
    final animals = decoded
        .take(limit)
        .map((item) => Animal.fromJson(item as Map<String, dynamic>))
        .toList(growable: false);

    _memoryCache = animals;
    _lastFetchedAt = DateTime.now();

    return animals;
  }

  static Dio _buildDio() {
    return Dio(
      BaseOptions(
        responseType: ResponseType.json,
        connectTimeout: const Duration(seconds: 8),
        receiveTimeout: const Duration(seconds: 12),
        sendTimeout: const Duration(seconds: 8),
        headers: const {'Accept': 'application/json'},
      ),
    );
  }
}
