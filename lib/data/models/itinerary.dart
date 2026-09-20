enum BookingStatus { confirmed, pending, completed, cancelled }

/// Represents an individual scheduled activity within a day of an itinerary.
class ItineraryActivity {
  const ItineraryActivity({
    required this.id,
    required this.dayNumber,
    required this.timeSlot,
    required this.title,
    required this.description,
    required this.location,
    required this.cost,
    required this.category,
  });

  final String id;
  final int dayNumber;
  final String timeSlot; // e.g. "09:00 AM", "02:00 PM"
  final String title;
  final String description;
  final String location;
  final double cost;
  final String category;

  factory ItineraryActivity.fromJson(Map<String, dynamic> json) =>
      ItineraryActivity(
        id: json['id'] as String,
        dayNumber: json['dayNumber'] as int,
        timeSlot: json['timeSlot'] as String,
        title: json['title'] as String,
        description: json['description'] as String,
        location: json['location'] as String,
        cost: (json['cost'] as num).toDouble(),
        category: json['category'] as String,
      );

  Map<String, dynamic> toJson() => {
    'id': id,
    'dayNumber': dayNumber,
    'timeSlot': timeSlot,
    'title': title,
    'description': description,
    'location': location,
    'cost': cost,
    'category': category,
  };
}

/// Immutable Model representing a booked Travel Itinerary.
class Itinerary {
  const Itinerary({
    required this.id,
    required this.destinationId,
    required this.destinationName,
    required this.destinationLocation,
    required this.imageUrl,
    required this.startDate,
    required this.endDate,
    required this.guestsCount,
    required this.totalCost,
    this.status = BookingStatus.confirmed,
    required this.bookedAt,
    this.activities = const [],
    this.notes = '',
  });

  final String id;
  final String destinationId;
  final String destinationName;
  final String destinationLocation;
  final String imageUrl;
  final DateTime startDate;
  final DateTime endDate;
  final int guestsCount;
  final double totalCost;
  final BookingStatus status;
  final DateTime bookedAt;
  final List<ItineraryActivity> activities;
  final String notes;

  int get totalNights => endDate.difference(startDate).inDays;

  Itinerary copyWith({
    String? id,
    String? destinationId,
    String? destinationName,
    String? destinationLocation,
    String? imageUrl,
    DateTime? startDate,
    DateTime? endDate,
    int? guestsCount,
    double? totalCost,
    BookingStatus? status,
    DateTime? bookedAt,
    List<ItineraryActivity>? activities,
    String? notes,
  }) {
    return Itinerary(
      id: id ?? this.id,
      destinationId: destinationId ?? this.destinationId,
      destinationName: destinationName ?? this.destinationName,
      destinationLocation: destinationLocation ?? this.destinationLocation,
      imageUrl: imageUrl ?? this.imageUrl,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      guestsCount: guestsCount ?? this.guestsCount,
      totalCost: totalCost ?? this.totalCost,
      status: status ?? this.status,
      bookedAt: bookedAt ?? this.bookedAt,
      activities: activities ?? this.activities,
      notes: notes ?? this.notes,
    );
  }

  factory Itinerary.fromJson(Map<String, dynamic> json) {
    return Itinerary(
      id: json['id'] as String,
      destinationId: json['destinationId'] as String,
      destinationName: json['destinationName'] as String,
      destinationLocation: json['destinationLocation'] as String,
      imageUrl: json['imageUrl'] as String,
      startDate: DateTime.parse(json['startDate'] as String),
      endDate: DateTime.parse(json['endDate'] as String),
      guestsCount: json['guestsCount'] as int,
      totalCost: (json['totalCost'] as num).toDouble(),
      status: BookingStatus.values.byName(json['status'] as String),
      bookedAt: DateTime.parse(json['bookedAt'] as String),
      activities:
          (json['activities'] as List?)
              ?.map(
                (a) => ItineraryActivity.fromJson(a as Map<String, dynamic>),
              )
              .toList() ??
          [],
      notes: json['notes'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'destinationId': destinationId,
    'destinationName': destinationName,
    'destinationLocation': destinationLocation,
    'imageUrl': imageUrl,
    'startDate': startDate.toIso8601String(),
    'endDate': endDate.toIso8601String(),
    'guestsCount': guestsCount,
    'totalCost': totalCost,
    'status': status.name,
    'bookedAt': bookedAt.toIso8601String(),
    'activities': activities.map((a) => a.toJson()).toList(),
    'notes': notes,
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) || (other is Itinerary && other.id == id);

  @override
  int get hashCode => id.hashCode;
}

class BookingRequest {
  const BookingRequest({
    required this.destinationId,
    required this.destinationName,
    required this.destinationLocation,
    required this.imageUrl,
    required this.startDate,
    required this.endDate,
    required this.guestsCount,
    required this.pricePerNight,
    this.activities = const [],
    this.notes = '',
  });

  final String destinationId;
  final String destinationName;
  final String destinationLocation;
  final String imageUrl;
  final DateTime startDate;
  final DateTime endDate;
  final int guestsCount;
  final double pricePerNight;
  final List<ItineraryActivity> activities;
  final String notes;

  int get nights => endDate.difference(startDate).inDays;
  double get totalCost =>
      (nights <= 0 ? 1 : nights) * pricePerNight +
      activities.fold(0.0, (acc, a) => acc + a.cost);
}
