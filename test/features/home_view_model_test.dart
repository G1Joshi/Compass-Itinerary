import 'package:flutter_test/flutter_test.dart';
import 'package:compass_itinerary/core/utils/result.dart';
import 'package:compass_itinerary/data/models/itinerary.dart';
import 'package:compass_itinerary/features/home/ui/home_view_model.dart';

import '../testing/fakes.dart';

void main() {
  group('HomeViewModel', () {
    late FakeBookingRepository fakeBookingRepo;
    late FakeUserRepository fakeUserRepo;
    late HomeViewModel viewModel;

    setUp(() {
      fakeBookingRepo = FakeBookingRepository();
      fakeUserRepo = FakeUserRepository();
    });

    test('initializes and executes loadHome command', () async {
      // Seed a booking
      await fakeBookingRepo.createBooking(
        BookingRequest(
          destinationId: 'dest_1',
          destinationName: 'Kyoto Sanctuary',
          destinationLocation: 'Kyoto, Japan',
          imageUrl: 'https://example.com/kyoto.jpg',
          startDate: DateTime.now().add(const Duration(days: 5)),
          endDate: DateTime.now().add(const Duration(days: 10)),
          guestsCount: 2,
          pricePerNight: 240.0,
          activities: [],
        ),
      );

      viewModel = HomeViewModel(
        bookingRepository: fakeBookingRepo,
        userRepository: fakeUserRepo,
      );

      // Await command execution
      await Future.delayed(Duration.zero);

      expect(viewModel.bookings.length, 1);
      expect(viewModel.activeTripsCount, 1);
      expect(viewModel.user.name, 'Elena Rostova');
    });

    test(
      'deleteItinerary cancels booking and updates list optimistically',
      () async {
        final bookingResult = await fakeBookingRepo.createBooking(
          BookingRequest(
            destinationId: 'dest_1',
            destinationName: 'Kyoto Sanctuary',
            destinationLocation: 'Kyoto, Japan',
            imageUrl: 'https://example.com/kyoto.jpg',
            startDate: DateTime.now().add(const Duration(days: 5)),
            endDate: DateTime.now().add(const Duration(days: 10)),
            guestsCount: 2,
            pricePerNight: 240.0,
            activities: [],
          ),
        );
        final itinerary = (bookingResult as Ok<Itinerary>).value;

        viewModel = HomeViewModel(
          bookingRepository: fakeBookingRepo,
          userRepository: fakeUserRepo,
        );
        await Future.delayed(Duration.zero);

        expect(viewModel.activeTripsCount, 1);

        // Cancel itinerary
        await viewModel.deleteItinerary.execute(itinerary.id);

        expect(viewModel.bookings.first.status, BookingStatus.cancelled);
        expect(viewModel.activeTripsCount, 0);
      },
    );

    test('logout delegates to UserRepository', () async {
      viewModel = HomeViewModel(
        bookingRepository: fakeBookingRepo,
        userRepository: fakeUserRepo,
      );

      await viewModel.logout.execute();
      expect(viewModel.logout.completed, true);
    });
  });
}
