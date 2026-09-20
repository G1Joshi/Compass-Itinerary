import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:compass_itinerary/data/models/itinerary.dart';
import 'package:compass_itinerary/features/home/ui/home_screen.dart';
import 'package:compass_itinerary/features/home/ui/home_view_model.dart';

import '../testing/fakes.dart';

void main() {
  group('HomeScreen Widget Tests', () {
    late FakeBookingRepository fakeBookingRepo;
    late FakeUserRepository fakeUserRepo;
    late HomeViewModel viewModel;

    setUp(() {
      fakeBookingRepo = FakeBookingRepository();
      fakeUserRepo = FakeUserRepository();
    });

    testWidgets('renders user profile, statistics, and empty state CTA', (
      tester,
    ) async {
      viewModel = HomeViewModel(
        bookingRepository: fakeBookingRepo,
        userRepository: fakeUserRepo,
      );

      bool navigatedToBuilder = false;
      bool navigatedToExplore = false;

      await tester.pumpWidget(
        MaterialApp(
          home: HomeScreen(
            viewModel: viewModel,
            onNavigateToBuilder: () => navigatedToBuilder = true,
            onNavigateToExplore: () => navigatedToExplore = true,
          ),
        ),
      );

      // Wait for initial load
      await tester.pumpAndSettle();

      // Verify user profile rendered
      expect(find.text('Elena Rostova'), findsOneWidget);
      expect(find.text('PLATINUM VOYAGER'), findsOneWidget);

      // Verify statistics
      expect(find.text('ACTIVE ITINERARIES'), findsOneWidget);
      expect(find.text('0'), findsOneWidget);

      // Verify 'Plan a New Itinerary' CTA
      expect(find.text('Plan a New Itinerary'), findsOneWidget);

      // Tap 'Start Itinerary Planner' button
      final buildButton = find.text('Start Itinerary Planner');
      expect(buildButton, findsOneWidget);
      await tester.tap(buildButton);
      expect(navigatedToBuilder, true);

      // Verify Empty State & Explore Catalog button
      final exploreButton = find.text('Explore Catalog');
      expect(exploreButton, findsOneWidget);
      await tester.tap(exploreButton);
      expect(navigatedToExplore, true);
    });

    testWidgets('renders booked itinerary card when bookings exist', (
      tester,
    ) async {
      await fakeBookingRepo.createBooking(
        BookingRequest(
          destinationId: 'dest_kyoto',
          destinationName: 'Kyoto Sanctuary',
          destinationLocation: 'Kyoto, Japan',
          imageUrl: 'https://example.com/kyoto.jpg',
          startDate: DateTime.now().add(const Duration(days: 10)),
          endDate: DateTime.now().add(const Duration(days: 15)),
          guestsCount: 2,
          pricePerNight: 280.0,
          activities: [],
        ),
      );

      viewModel = HomeViewModel(
        bookingRepository: fakeBookingRepo,
        userRepository: fakeUserRepo,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: HomeScreen(
            viewModel: viewModel,
            onNavigateToBuilder: () {},
            onNavigateToExplore: () {},
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Kyoto Sanctuary'), findsOneWidget);
      expect(find.text('\$2800'), findsOneWidget);
    });
  });
}
