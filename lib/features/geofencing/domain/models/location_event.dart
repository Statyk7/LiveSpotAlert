import 'package:equatable/equatable.dart';
import 'geofence.dart';

enum LocationEventType {
  enter,
  exit,
  dwell, // Stayed in geofence for extended period
}

class LocationEvent extends Equatable {
  const LocationEvent({
    required this.id,
    required this.geofence,
    required this.eventType,
    required this.timestamp,
    required this.userLatitude,
    required this.userLongitude,
    this.accuracy,
    this.dwellTime,
  });

  final String id;
  final Geofence geofence;
  final LocationEventType eventType;
  final DateTime timestamp;
  final double userLatitude;
  final double userLongitude;
  final double? accuracy; // GPS accuracy in meters
  final Duration? dwellTime; // Time spent in geofence (for dwell events)

  LocationEvent copyWith({
    String? id,
    Geofence? geofence,
    LocationEventType? eventType,
    DateTime? timestamp,
    double? userLatitude,
    double? userLongitude,
    double? accuracy,
    Duration? dwellTime,
  }) {
    return LocationEvent(
      id: id ?? this.id,
      geofence: geofence ?? this.geofence,
      eventType: eventType ?? this.eventType,
      timestamp: timestamp ?? this.timestamp,
      userLatitude: userLatitude ?? this.userLatitude,
      userLongitude: userLongitude ?? this.userLongitude,
      accuracy: accuracy ?? this.accuracy,
      dwellTime: dwellTime ?? this.dwellTime,
    );
  }

  @override
  List<Object?> get props => [
        id,
        geofence,
        eventType,
        timestamp,
        userLatitude,
        userLongitude,
        accuracy,
        dwellTime,
      ];

  @override
  String toString() {
    return 'LocationEvent{id: $id, geofence: ${geofence.name}, type: $eventType, timestamp: $timestamp}';
  }
}