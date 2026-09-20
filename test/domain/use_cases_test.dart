import 'package:flutter_test/flutter_test.dart';
import 'package:compass_itinerary/core/utils/exceptions.dart';
import 'package:compass_itinerary/core/utils/result.dart';
import 'package:compass_itinerary/data/models/destination.dart';
import 'package:compass_itinerary/data/models/itinerary.dart';
import 'package:compass_itinerary/domain/use_cases/book_itinerary_use_case.dart';
import 'package:compass_itinerary/domain/use_cases/create_custom_itinerary_use_case.dart';
import 'package:compass_itinerary/domain/use_cases/filter_destinations_use_case.dart';

import '../testing/fakes.dart';

void main() {
  group('FilterDestinationsUseCase', () {
    const useCase = FilterDestinationsUseCase();

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
        isFavorite: true,
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
        highlights: ['Matterhorn', 'Glacier Paradise'],
        isFavorite: false,
      ),
      const Destination(
        id: 'dest_3',
        name: 'Santorini Sunset Haven',
        location: 'Oia, Greece',
        country: 'Greece',
        description: 'Whitewashed cliffs and caldera views',
        imageUrl: 'https://example.com/santorini.jpg',
        pricePerNight: 390.0,
        rating: 4.7,
        reviewsCount: 450,
        category: 'Beach',
        highlights: ['Caldera Cruise', 'Oia Sunset'],
        isFavorite: false,
      ),
    ];

    test('returns all items sorted by rating when no filters applied', () {
      final results = useCase(destinations: testDestinations);
      expect(results.length, 3);
      expect(results.first.id, 'dest_1'); // 4.9 > 4.8 > 4.7
    });

    test('filters by search query matching name or location or highlights', () {
      final matchByName = useCase(
        destinations: testDestinations,
        searchQuery: 'Kyoto',
      );
      expect(matchByName.length, 1);
      expect(matchByName.first.id, 'dest_1');

      final matchByHighlight = useCase(
        destinations: testDestinations,
        searchQuery: 'Matterhorn',
      );
      expect(matchByHighlight.length, 1);
      expect(matchByHighlight.first.id, 'dest_2');
    });

    test('filters by category', () {
      final cultural = useCase(
        destinations: testDestinations,
        selectedCategory: 'Cultural',
      );
      expect(cultural.length, 1);
      expect(cultural.first.category, 'Cultural');
    });

    test('filters by maxPrice', () {
      final affordable = useCase(
        destinations: testDestinations,
        maxPrice: 300.0,
      );
      expect(affordable.length, 1);
      expect(affordable.first.id, 'dest_1');
    });

    test('filters by onlyFavorites', () {
      final favorites = useCase(
        destinations: testDestinations,
        onlyFavorites: true,
      );
      expect(favorites.length, 1);
      expect(favorites.first.id, 'dest_1');
    });
  });

  group('BookItineraryUseCase', () {
    late FakeBookingRepository fakeRepo;
    late BookItineraryUseCase useCase;

    setUp(() {
      fakeRepo = FakeBookingRepository();
      useCase = BookItineraryUseCase(bookingRepository: fakeRepo);
    });

    test(
      'rejects booking if checkout date is before or same as checkin date',
      () async {
        final now = DateTime.now();
        final request = BookingRequest(
          destinationId: 'dest_1',
          destinationName: 'Kyoto Sanctuary',
          destinationLocation: 'Kyoto, Japan',
          imageUrl: 'https://example.com/kyoto.jpg',
          startDate: now,
          endDate: now, // Same day
          guestsCount: 2,
          pricePerNight: 280.0,
          activities: [],
        );

        final result = await useCase(request);
        expect(result, isA<Error<Itinerary>>());
        expect((result as Error).error, isA<ValidationException>());
      },
    );

    test('rejects booking if guestsCount <= 0', () async {
      final now = DateTime.now();
      final request = BookingRequest(
        destinationId: 'dest_1',
        destinationName: 'Kyoto Sanctuary',
        destinationLocation: 'Kyoto, Japan',
        imageUrl: 'https://example.com/kyoto.jpg',
        startDate: now,
        endDate: now.add(const Duration(days: 3)),
        guestsCount: 0,
        pricePerNight: 280.0,
        activities: [],
      );

      final result = await useCase(request);
      expect(result, isA<Error<Itinerary>>());
      expect((result as Error).error, isA<ValidationException>());
    });

    test('detects booking date conflicts for the same destination', () async {
      final now = DateTime.now();
      final existingBooking = BookingRequest(
        destinationId: 'dest_1',
        destinationName: 'Kyoto Sanctuary',
        destinationLocation: 'Kyoto, Japan',
        imageUrl: 'https://example.com/kyoto.jpg',
        startDate: now.add(const Duration(days: 2)),
        endDate: now.add(const Duration(days: 5)),
        guestsCount: 2,
        pricePerNight: 250,
        activities: [],
      );
      await fakeRepo.createBooking(existingBooking);

      // Overlapping request
      final conflictRequest = BookingRequest(
        destinationId: 'dest_1',
        destinationName: 'Kyoto Sanctuary',
        destinationLocation: 'Kyoto, Japan',
        imageUrl: 'https://example.com/kyoto.jpg',
        startDate: now.add(const Duration(days: 3)),
        endDate: now.add(const Duration(days: 6)),
        guestsCount: 1,
        pricePerNight: 250,
        activities: [],
      );

      final result = await useCase(conflictRequest);
      expect(result, isA<Error<Itinerary>>());
      expect((result as Error).error, isA<BookingConflictException>());
    });

    test('creates booking successfully when valid', () async {
      final now = DateTime.now();
      final validRequest = BookingRequest(
        destinationId: 'dest_1',
        destinationName: 'Kyoto Sanctuary',
        destinationLocation: 'Kyoto, Japan',
        imageUrl: 'https://example.com/kyoto.jpg',
        startDate: now.add(const Duration(days: 10)),
        endDate: now.add(const Duration(days: 14)),
        guestsCount: 2,
        pricePerNight: 200.0,
        activities: [],
      );

      final result = await useCase(validRequest);
      expect(result, isA<Ok<Itinerary>>());
      expect((result as Ok<Itinerary>).value.destinationId, 'dest_1');
      expect(fakeRepo.bookings.length, 1);
    });
  });

  group('CreateCustomItineraryUseCase', () {
    late FakeBookingRepository fakeRepo;
    late BookItineraryUseCase bookUseCase;
    late CreateCustomItineraryUseCase useCase;

    setUp(() {
      fakeRepo = FakeBookingRepository();
      bookUseCase = BookItineraryUseCase(bookingRepository: fakeRepo);
      useCase = CreateCustomItineraryUseCase(
        bookingRepository: fakeRepo,
        bookUseCase: bookUseCase,
      );
    });

    test(
      'generates day-by-day scheduled activities and creates booking',
      () async {
        final now = DateTime.now();
        const destination = Destination(
          id: 'dest_1',
          name: 'Kyoto Sanctuary',
          location: 'Kyoto, Japan',
          country: 'Japan',
          description: 'Historic temples',
          imageUrl: 'https://example.com/kyoto.jpg',
          pricePerNight: 200,
          rating: 4.9,
          reviewsCount: 100,
          category: 'Cultural',
          highlights: ['Temple Visit', 'Tea Ceremony'],
        );

        final draft = ItineraryCustomDraft(
          destination: destination,
          startDate: now.add(const Duration(days: 1)),
          endDate: now.add(const Duration(days: 4)), // 3 nights
          guestsCount: 2,
          selectedActivityNames: ['Temple Visit', 'Tea Ceremony'],
          notes: 'Vegetarian meals preferred',
        );

        final result = await useCase(draft);

        expect(result, isA<Ok<Itinerary>>());
        final itinerary = (result as Ok<Itinerary>).value;
        expect(itinerary.activities.isNotEmpty, true);
        expect(itinerary.guestsCount, 2);
        expect(itinerary.notes, 'Vegetarian meals preferred');
        expect(fakeRepo.bookings.length, 1);
      },
    );
  });
}
