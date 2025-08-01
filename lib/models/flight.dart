

/// Reservation entity class for Floor database storage
/// Represents a flight reservation record in the database
/// @author Matthew Zhang

class Flight {
  final int? id;
  final String departure;
  final String destination;
  final String departureTime;
  final String arrivalTime;

  Flight({
    this.id,
    required this.departure,
    required this.destination,
    required this.departureTime,
    required this.arrivalTime,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'departure': departure,
    'destination': destination,
    'departureTime': departureTime,
    'arrivalTime': arrivalTime,
  };

  factory Flight.fromMap(Map<String, dynamic> map) => Flight(
    id: map['id'],
    departure: map['departure'],
    destination: map['destination'],
    departureTime: map['departureTime'],
    arrivalTime: map['arrivalTime'],
  );
}
