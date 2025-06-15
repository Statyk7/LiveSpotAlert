import 'package:equatable/equatable.dart';
import 'geofence.dart';

enum GeofenceState {
  idle,        // Not monitoring
  monitoring,  // Actively monitoring
  triggered,   // Recently triggered
  error,       // Error in monitoring
}

class GeofenceStatus extends Equatable {
  const GeofenceStatus({
    required this.geofence,
    required this.state,
    required this.isUserInside,
    required this.lastUpdated,
    this.errorMessage,
    this.distanceToCenter,
  });

  final Geofence geofence;
  final GeofenceState state;
  final bool isUserInside;
  final DateTime lastUpdated;
  final String? errorMessage;
  final double? distanceToCenter; // Distance from user to geofence center in meters

  GeofenceStatus copyWith({
    Geofence? geofence,
    GeofenceState? state,
    bool? isUserInside,
    DateTime? lastUpdated,
    String? errorMessage,
    double? distanceToCenter,
  }) {
    return GeofenceStatus(
      geofence: geofence ?? this.geofence,
      state: state ?? this.state,
      isUserInside: isUserInside ?? this.isUserInside,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      errorMessage: errorMessage ?? this.errorMessage,
      distanceToCenter: distanceToCenter ?? this.distanceToCenter,
    );
  }

  @override
  List<Object?> get props => [
        geofence,
        state,
        isUserInside,
        lastUpdated,
        errorMessage,
        distanceToCenter,
      ];

  @override
  String toString() {
    return 'GeofenceStatus{geofence: ${geofence.name}, state: $state, inside: $isUserInside, distance: $distanceToCenter}';
  }
}