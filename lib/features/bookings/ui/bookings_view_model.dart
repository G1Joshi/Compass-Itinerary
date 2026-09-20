import 'dart:collection';

import 'package:flutter/foundation.dart';

import '../../../core/utils/command.dart';
import '../../../core/utils/result.dart';
import '../../../data/models/itinerary.dart';
import '../../../data/repositories/booking_repository.dart';

class BookingsViewModel extends ChangeNotifier {
  BookingsViewModel({required this.bookingRepository}) {
    loadBookings = Command0(_loadBookings)..execute();
    cancelBooking = Command1(_cancelBooking);
  }

  final BookingRepository bookingRepository;

  late final Command0<void> loadBookings;
  late final Command1<void, String> cancelBooking;

  List<Itinerary> _itineraries = [];

  UnmodifiableListView<Itinerary> get itineraries =>
      UnmodifiableListView(_itineraries);

  int get confirmedCount =>
      _itineraries.where((i) => i.status == BookingStatus.confirmed).length;

  Future<Result<void>> _loadBookings() async {
    final result = await bookingRepository.getItineraries();
    switch (result) {
      case Ok(:final value):
        _itineraries = value;
        notifyListeners();
        return const Result.ok(null);
      case Error(:final error):
        return Result.error(error);
    }
  }

  Future<Result<void>> _cancelBooking(String bookingId) async {
    final result = await bookingRepository.cancelBooking(bookingId);
    if (result is Ok) {
      final index = _itineraries.indexWhere((i) => i.id == bookingId);
      if (index != -1) {
        _itineraries[index] = _itineraries[index].copyWith(
          status: BookingStatus.cancelled,
        );
        notifyListeners();
      }
    }
    return result;
  }
}
