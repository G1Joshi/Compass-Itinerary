abstract class AppException implements Exception {
  const AppException(this.message);
  final String message;

  @override
  String toString() => message;
}

class NetworkException extends AppException {
  const NetworkException([
    super.message = 'Network connection failure. Please check connectivity.',
  ]);
}

class NotFoundException extends AppException {
  const NotFoundException([
    super.message = 'The requested resource was not found.',
  ]);
}

class BookingConflictException extends AppException {
  const BookingConflictException([
    super.message = 'Selected dates conflict with an existing itinerary.',
  ]);
}

class ValidationException extends AppException {
  const ValidationException(super.message);
}
