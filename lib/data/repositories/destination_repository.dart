import 'dart:async';

import '../../core/utils/result.dart';
import '../models/destination.dart';
import '../services/local_storage_service.dart';
import '../services/travel_api_service.dart';

abstract class DestinationRepository {
  Future<Result<List<Destination>>> getDestinations({
    bool forceRefresh = false,
  });
  Future<Result<Destination>> getDestinationById(String id);
  Future<Result<void>> toggleFavorite(String id);
  List<Destination> get cachedDestinations;
}

/// Single Source of Truth for destination data.
class DestinationRepositoryImpl implements DestinationRepository {
  DestinationRepositoryImpl({
    required this.apiService,
    required this.storageService,
  });

  final TravelApiService apiService;
  final LocalStorageService storageService;

  List<Destination> _cache = [];

  @override
  List<Destination> get cachedDestinations => List.unmodifiable(_cache);

  @override
  Future<Result<List<Destination>>> getDestinations({
    bool forceRefresh = false,
  }) async {
    if (_cache.isNotEmpty && !forceRefresh) {
      return Result.ok(List.unmodifiable(_cache));
    }

    try {
      final remoteList = await apiService.fetchDestinations();
      final favoriteIds = await storageService.getFavoriteIds();

      _cache = remoteList.map((d) {
        return d.copyWith(isFavorite: favoriteIds.contains(d.id));
      }).toList();

      await storageService.cacheDestinations(_cache);
      return Result.ok(List.unmodifiable(_cache));
    } on Exception catch (e) {
      final localCache = await storageService.getCachedDestinations();
      if (localCache != null && localCache.isNotEmpty) {
        _cache = localCache;
        return Result.ok(List.unmodifiable(_cache));
      }
      return Result.error(e);
    }
  }

  @override
  Future<Result<Destination>> getDestinationById(String id) async {
    final inMemory = _cache.cast<Destination?>().firstWhere(
      (d) => d?.id == id,
      orElse: () => null,
    );
    if (inMemory != null) {
      return Result.ok(inMemory);
    }

    try {
      final item = await apiService.fetchDestinationById(id);
      final favoriteIds = await storageService.getFavoriteIds();
      final merged = item.copyWith(isFavorite: favoriteIds.contains(item.id));
      return Result.ok(merged);
    } on Exception catch (e) {
      return Result.error(e);
    }
  }

  @override
  Future<Result<void>> toggleFavorite(String id) async {
    final index = _cache.indexWhere((d) => d.id == id);
    if (index == -1) {
      return Result.error(Exception('Destination not found in cache.'));
    }

    final originalDestination = _cache[index];
    final newFavoriteStatus = !originalDestination.isFavorite;

    // 1. Optimistic update
    _cache[index] = originalDestination.copyWith(isFavorite: newFavoriteStatus);

    try {
      // 2. Call remote service
      await apiService.updateFavoriteOnServer(id, newFavoriteStatus);

      // 3. Persist locally
      final favorites = await storageService.getFavoriteIds();
      if (newFavoriteStatus) {
        favorites.add(id);
      } else {
        favorites.remove(id);
      }
      await storageService.saveFavoriteIds(favorites);

      return const Result.ok(null);
    } on Exception catch (e) {
      // 4. Rollback on failure
      _cache[index] = originalDestination;
      return Result.error(e);
    }
  }
}
