import '../../core/utils/exceptions.dart';
import '../../core/utils/result.dart';
import '../../data/models/itinerary.dart';
import '../../data/repositories/booking_repository.dart';

class BookItineraryUseCase {
  BookItineraryUseCase({required this.bookingRepository});

  final BookingRepository bookingRepository;

  Future<Result<Itinerary>> call(BookingRequest request) async {
    if (request.endDate.isBefore(request.startDate) ||
        request.endDate.isAtSameMomentAs(request.startDate)) {
      return const Result.error(
        ValidationException(
          'Check-out date must be at least 1 day after check-in.',
        ),
      );
    }

    if (request.guestsCount <= 0) {
      return const Result.error(
        ValidationException('Guests count must be at least 1.'),
      );
    }

    // Check for overlap with existing confirmed itineraries
    final existingResult = await bookingRepository.getItineraries();
    if (existingResult is Ok<List<Itinerary>>) {
      final hasConflict = existingResult.value.any((booking) {
        if (booking.status != BookingStatus.confirmed) return false;
        return request.startDate.isBefore(booking.endDate) &&
            request.endDate.isAfter(booking.startDate) &&
            booking.destinationId == request.destinationId;
      });

      if (hasConflict) {
        return const Result.error(
          BookingConflictException(
            'You already have a confirmed itinerary for this destination during these dates.',
          ),
        );
      }
    }

    return await bookingRepository.createBooking(request);
  }
}
