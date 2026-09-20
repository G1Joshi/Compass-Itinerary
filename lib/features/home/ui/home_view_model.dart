import 'dart:collection';

import 'package:flutter/foundation.dart';

import '../../../core/utils/command.dart';
import '../../../core/utils/result.dart';
import '../../../data/models/itinerary.dart';
import '../../../data/models/user_profile.dart';
import '../../../data/repositories/booking_repository.dart';
import '../../../data/repositories/user_repository.dart';

class HomeViewModel extends ChangeNotifier {
  HomeViewModel({
    required this.bookingRepository,
    required this.userRepository,
  }) {
    loadHome = Command0(_loadHome)..execute();
    logout = Command0(_logout);
    deleteItinerary = Command1(_deleteItinerary);
  }

  final BookingRepository bookingRepository;
  final UserRepository userRepository;

  late final Command0<void> loadHome;
  late final Command0<void> logout;
  late final Command1<void, String> deleteItinerary;

  List<Itinerary> _bookings = [];
  UnmodifiableListView<Itinerary> get bookings =>
      UnmodifiableListView(_bookings);

  UserProfile get user => userRepository.currentUser;
  int get activeTripsCount =>
      _bookings.where((b) => b.status == BookingStatus.confirmed).length;

  Future<Result<void>> _loadHome() async {
    final result = await bookingRepository.getItineraries();
    switch (result) {
      case Ok(:final value):
        _bookings = List.of(value);
        notifyListeners();
        return const Result.ok(null);
      case Error(:final error):
        return Result.error(error);
    }
  }

  Future<Result<void>> _logout() async {
    return await userRepository.logout();
  }

  Future<Result<void>> _deleteItinerary(String id) async {
    final result = await bookingRepository.cancelBooking(id);
    if (result is Ok) {
      final idx = _bookings.indexWhere((b) => b.id == id);
      if (idx != -1) {
        _bookings[idx] = _bookings[idx].copyWith(
          status: BookingStatus.cancelled,
        );
        notifyListeners();
      }
    }
    return result;
  }
}
