import 'package:flutter_test/flutter_test.dart';
import 'package:compass_itinerary/data/models/destination.dart';
import 'package:compass_itinerary/features/explore/ui/explore_view_model.dart';

import '../testing/fakes.dart';

void main() {
  group('ExploreViewModel', () {
    late FakeDestinationRepository fakeRepo;
    late ExploreViewModel viewModel;

    final List<Destination> testDestinations = [
      const Destination(
        id: 'dest_1',
        name: 'Kyoto Sanctuary',
        location: 'Kyoto, Japan',
        country: 'Japan',
        description: 'Historic temples and gardens',
        imageUrl: 'https://example.com/kyoto.jpg',
        pricePerNight: 280.0,
        rating: 4.9,
        reviewsCount: 320,
        category: 'Cultural',
        highlights: ['Arashiyama', 'Fushimi Inari'],
        isFavorite: false,
      ),
      const Destination(
        id: 'dest_2',
        name: 'Swiss Alpine Valley',
        location: 'Zermatt, Switzerland',
        country: 'Switzerland',
        description: 'Majestic peaks and skiing',
        imageUrl: 'https://example.com/zermatt.jpg',
        pricePerNight: 450.0,
        rating: 4.8,
        reviewsCount: 190,
        category: 'Adventure',
        highlights: ['Matterhorn'],
        isFavorite: true,
      ),
    ];

    setUp(() {
      fakeRepo = FakeDestinationRepository()
        ..destinations = List.of(testDestinations);
      viewModel = ExploreViewModel(destinationRepository: fakeRepo);
    });

    test('initializes and executes loadDestinations', () async {
      await Future.delayed(Duration.zero);

      expect(viewModel.destinations.length, 2);
      expect(viewModel.totalCount, 2);
      expect(viewModel.favoritesCount, 1);
    });

    test('filters destinations when category selected', () async {
      await Future.delayed(Duration.zero);

      viewModel.selectCategory('Cultural');
      expect(viewModel.destinations.length, 1);
      expect(viewModel.destinations.first.name, 'Kyoto Sanctuary');
    });

    test('searches destinations by query', () async {
      await Future.delayed(Duration.zero);

      await viewModel.search.execute('Matterhorn');
      expect(viewModel.destinations.length, 1);
      expect(viewModel.destinations.first.name, 'Swiss Alpine Valley');
    });

    test(
      'toggles favorite status optimistically and updates repository',
      () async {
        await Future.delayed(Duration.zero);

        expect(
          viewModel.destinations.firstWhere((d) => d.id == 'dest_1').isFavorite,
          false,
        );

        await viewModel.toggleFavorite.execute('dest_1');

        expect(
          viewModel.destinations.firstWhere((d) => d.id == 'dest_1').isFavorite,
          true,
        );
        expect(viewModel.favoritesCount, 2);
        expect(
          fakeRepo.destinations.firstWhere((d) => d.id == 'dest_1').isFavorite,
          true,
        );
      },
    );

    test('toggles favorite only filter', () async {
      await Future.delayed(Duration.zero);

      viewModel.toggleFavoritesFilter();
      expect(viewModel.destinations.length, 1);
      expect(viewModel.destinations.first.id, 'dest_2');
    });
  });
}
