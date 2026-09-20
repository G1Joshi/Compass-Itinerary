import 'package:flutter/foundation.dart';
import 'package:compass_itinerary/core/utils/result.dart';
import 'package:compass_itinerary/data/models/destination.dart';
import 'package:compass_itinerary/data/models/itinerary.dart';
import 'package:compass_itinerary/data/models/user_profile.dart';
import 'package:compass_itinerary/data/repositories/booking_repository.dart';
import 'package:compass_itinerary/data/repositories/destination_repository.dart';
import 'package:compass_itinerary/data/repositories/user_repository.dart';

/// Fake BookingRepository for isolated unit and widget tests.
/// Implements BookingRepository without network or disk dependencies.
class FakeBookingRepository implements BookingRepository {
  final List<Itinerary> bookings = [];

  @override
  Future<Result<List<Itinerary>>> getItineraries() async {
    return Result.ok(List.unmodifiable(bookings));
  }

  @override
  Future<Result<Itinerary>> createBooking(BookingRequest request) async {
    final nights = request.endDate.difference(request.startDate).inDays;
    final totalCost =
        (nights <= 0 ? 1 : nights) *
        request.pricePerNight *
        request.guestsCount;

    final newBooking = Itinerary(
      id: 'fake_itn_${bookings.length + 1}',
      destinationId: request.destinationId,
      destinationName: request.destinationName,
      destinationLocation: request.destinationLocation,
      imageUrl: request.imageUrl,
      startDate: request.startDate,
      endDate: request.endDate,
      guestsCount: request.guestsCount,
      totalCost: totalCost,
      status: BookingStatus.confirmed,
      bookedAt: DateTime.now(),
      activities: request.activities,
      notes: request.notes,
    );
    bookings.add(newBooking);
    return Result.ok(newBooking);
  }

  @override
  Future<Result<void>> cancelBooking(String bookingId) async {
    final idx = bookings.indexWhere((b) => b.id == bookingId);
    if (idx != -1) {
      bookings[idx] = bookings[idx].copyWith(status: BookingStatus.cancelled);
    }
    return const Result.ok(null);
  }
}

/// Fake UserRepository for isolated unit and widget tests.
class FakeUserRepository extends ChangeNotifier implements UserRepository {
  UserProfile _user = UserProfile.defaultUser();

  @override
  UserProfile get currentUser => _user;

  @override
  Future<Result<UserProfile>> refreshProfile() async {
    _user = _user.copyWith(loyaltyPoints: _user.loyaltyPoints + 50);
    notifyListeners();
    return Result.ok(_user);
  }

  @override
  Future<Result<void>> logout() async {
    notifyListeners();
    return const Result.ok(null);
  }
}

/// Fake DestinationRepository for isolated tests.
class FakeDestinationRepository implements DestinationRepository {
  List<Destination> destinations = [];

  @override
  List<Destination> get cachedDestinations => List.unmodifiable(destinations);

  @override
  Future<Result<List<Destination>>> getDestinations({
    bool forceRefresh = false,
  }) async {
    return Result.ok(List.unmodifiable(destinations));
  }

  @override
  Future<Result<Destination>> getDestinationById(String id) async {
    final match = destinations.cast<Destination?>().firstWhere(
      (d) => d?.id == id,
      orElse: () => null,
    );
    if (match != null) {
      return Result.ok(match);
    }
    return Result.error(Exception('Destination not found'));
  }

  @override
  Future<Result<void>> toggleFavorite(String id) async {
    final idx = destinations.indexWhere((d) => d.id == id);
    if (idx != -1) {
      final current = destinations[idx];
      destinations[idx] = current.copyWith(isFavorite: !current.isFavorite);
      return const Result.ok(null);
    }
    return Result.error(Exception('Not found'));
  }
}
