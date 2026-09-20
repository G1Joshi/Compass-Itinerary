import 'dart:convert';

import '../models/destination.dart';
import '../models/itinerary.dart';

/// Stateless Service handling local data persistence and caching.
class LocalStorageService {
  final Map<String, String> _storage = {};

  Future<void> saveFavoriteIds(Set<String> ids) async {
    _storage['favorites'] = jsonEncode(ids.toList());
  }

  Future<Set<String>> getFavoriteIds() async {
    final raw = _storage['favorites'];
    if (raw == null) return {};
    try {
      final list = jsonDecode(raw) as List;
      return list.cast<String>().toSet();
    } catch (_) {
      return {};
    }
  }

  Future<void> cacheDestinations(List<Destination> destinations) async {
    final listJson = destinations.map((d) => d.toJson()).toList();
    _storage['cached_destinations'] = jsonEncode(listJson);
  }

  Future<List<Destination>?> getCachedDestinations() async {
    final raw = _storage['cached_destinations'];
    if (raw == null) return null;
    try {
      final list = jsonDecode(raw) as List;
      return list
          .map((item) => Destination.fromJson(item as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return null;
    }
  }

  Future<void> saveItineraries(List<Itinerary> itineraries) async {
    final listJson = itineraries.map((i) => i.toJson()).toList();
    _storage['saved_itineraries'] = jsonEncode(listJson);
  }

  Future<List<Itinerary>> getSavedItineraries() async {
    final raw = _storage['saved_itineraries'];
    if (raw == null) return [];
    try {
      final list = jsonDecode(raw) as List;
      return list
          .map((item) => Itinerary.fromJson(item as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return [];
    }
  }
}
