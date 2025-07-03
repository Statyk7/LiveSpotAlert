import 'package:equatable/equatable.dart';

class LocationEventDto extends Equatable {
  const LocationEventDto({
    required this.id,
    required this.geofenceId,
    required this.eventType,
    required this.timestamp,
    required this.userLatitude,
    required this.userLongitude,
    this.accuracy,
    this.dwellTime,
  });

  final String id;
  final String geofenceId;
  final String eventType; // 'enter', 'exit', 'dwell'
  final String timestamp; // ISO string format
  final double userLatitude;
  final double userLongitude;
  final double? accuracy;
  final int? dwellTime; // Duration in seconds

  // From JSON (Local Storage)
  factory LocationEventDto.fromJson(Map<String, dynamic> json) {
    return LocationEventDto(
      id: json['id'] as String,
      geofenceId: json['geofenceId'] as String,
      eventType: json['eventType'] as String,
      timestamp: json['timestamp'] as String,
      userLatitude: (json['userLatitude'] as num).toDouble(),
      userLongitude: (json['userLongitude'] as num).toDouble(),
      accuracy: json['accuracy'] != null
          ? (json['accuracy'] as num).toDouble()
          : null,
      dwellTime: json['dwellTime'] as int?,
    );
  }

  // To JSON (Local Storage)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'geofenceId': geofenceId,
      'eventType': eventType,
      'timestamp': timestamp,
      'userLatitude': userLatitude,
      'userLongitude': userLongitude,
      'accuracy': accuracy,
      'dwellTime': dwellTime,
    };
  }

  // From flutter_background_geolocation event
  factory LocationEventDto.fromBackgroundGeolocationEvent(
      Map<String, dynamic> event) {
    final location = event['location'] as Map<String, dynamic>;

    return LocationEventDto(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      geofenceId: event['identifier'] as String,
      eventType: _mapEventAction(event['action'] as String),
      timestamp: DateTime.now().toIso8601String(),
      userLatitude: (location['coords']['latitude'] as num).toDouble(),
      userLongitude: (location['coords']['longitude'] as num).toDouble(),
      accuracy: location['coords']['accuracy'] != null
          ? (location['coords']['accuracy'] as num).toDouble()
          : null,
    );
  }

  static String _mapEventAction(String action) {
    switch (action) {
      case 'ENTER':
        return 'enter';
      case 'EXIT':
        return 'exit';
      case 'DWELL':
        return 'dwell';
      default:
        return 'enter';
    }
  }

  @override
  List<Object?> get props => [
        id,
        geofenceId,
        eventType,
        timestamp,
        userLatitude,
        userLongitude,
        accuracy,
        dwellTime,
      ];
}
