import 'package:flutter_test/flutter_test.dart';
import 'package:compass_itinerary/core/utils/result.dart';
import 'package:compass_itinerary/data/models/destination.dart';
import 'package:compass_itinerary/data/repositories/destination_repository.dart';
import 'package:compass_itinerary/data/services/local_storage_service.dart';
import 'package:compass_itinerary/data/services/travel_api_service.dart';

void main() {
  group('DestinationRepositoryImpl', () {
    late TravelApiService apiService;
    late LocalStorageService storageService;
    late DestinationRepositoryImpl repository;

    setUp(() {
      apiService = TravelApiService(
        networkLatency: Duration.zero,
        shouldSimulateErrors: false,
      );
      storageService = LocalStorageService();
      repository = DestinationRepositoryImpl(
        apiService: apiService,
        storageService: storageService,
      );
    });

    test('getDestinations loads from API, applies favorite status, and populates cache', () async {
      await storageService.saveFavoriteIds({'dest_01'});

      final result = await repository.getDestinations();
      expect(result, isA<Ok<List<Destination>>>());

      final items = (result as Ok<List<Destination>>).value;
      expect(items.isNotEmpty, true);

      final dest1 = items.firstWhere((d) => d.id == 'dest_01');
      expect(dest1.isFavorite, true);

      expect(repository.cachedDestinations.length, items.length);
    });

    test(
      'getDestinations falls back to LocalStorageService when API errors',
      () async {
        final cachedList = [
          const Destination(
            id: 'offline_1',
            name: 'Offline Oasis',
            location: 'Remote Island',
            country: 'Island',
            description: 'Offline cached island',
            imageUrl: '',
            pricePerNight: 100,
            rating: 4.5,
            reviewsCount: 10,
            category: 'Beach',
            highlights: ['Sand'],
          ),
        ];
        await storageService.cacheDestinations(cachedList);

        // Trigger error in API
        apiService.configureNetworkSimulation(simulateErrors: true);

        final result = await repository.getDestinations();
        expect(result, isA<Ok<List<Destination>>>());
        final items = (result as Ok<List<Destination>>).value;
        expect(items.length, 1);
        expect(items.first.id, 'offline_1');
      },
    );

    test('toggleFavorite performs optimistic update and rolls back on server failure', () async {
      // 1. Initial load
      await repository.getDestinations();
      final initial = repository.cachedDestinations.firstWhere(
        (d) => d.id == 'dest_01',
      );
      final originalFavoriteStatus = initial.isFavorite;

      // 2. Simulate server error
      apiService.configureNetworkSimulation(simulateErrors: true);

      // 3. Toggle favorite
      final result = await repository.toggleFavorite('dest_01');
      expect(result, isA<Error<void>>());

      // 4. Verify rollback
      final rolledBack = repository.cachedDestinations.firstWhere(
        (d) => d.id == 'dest_01',
      );
      expect(rolledBack.isFavorite, originalFavoriteStatus);
    });

    test('toggleFavorite persists change on server success', () async {
      await repository.getDestinations();
      final initial = repository.cachedDestinations.firstWhere(
        (d) => d.id == 'dest_01',
      );
      final targetStatus = !initial.isFavorite;

      final result = await repository.toggleFavorite('dest_01');
      expect(result, isA<Ok<void>>());

      final updated = repository.cachedDestinations.firstWhere(
        (d) => d.id == 'dest_01',
      );
      expect(updated.isFavorite, targetStatus);

      final storedFavorites = await storageService.getFavoriteIds();
      expect(storedFavorites.contains('dest_01'), targetStatus);
    });
  });
}
