import 'package:equatable/equatable.dart';

/// Represents parsed notification payload data
class NotificationPayload extends Equatable {
  const NotificationPayload({
    required this.eventType,
    required this.geofenceId,
  });

  /// The type of geofence event (entry or exit)
  final GeofenceEventType eventType;

  /// The ID of the geofence that triggered the notification
  final String geofenceId;

  /// Parse payload string in format: 'geofence_{entry|exit}_{geofenceId}'
  static NotificationPayload? fromPayloadString(String? payload) {
    if (payload == null || payload.isEmpty) {
      return null;
    }

    final parts = payload.split('_');
    if (parts.length != 3 || parts[0] != 'geofence') {
      return null;
    }

    final eventTypeString = parts[1];
    final geofenceId = parts[2];

    GeofenceEventType? eventType;
    switch (eventTypeString) {
      case 'entry':
        eventType = GeofenceEventType.entry;
        break;
      case 'exit':
        eventType = GeofenceEventType.exit;
        break;
      default:
        return null;
    }

    return NotificationPayload(
      eventType: eventType,
      geofenceId: geofenceId,
    );
  }

  /// Generate payload string for notifications
  String toPayloadString() {
    final eventTypeString = eventType == GeofenceEventType.entry ? 'entry' : 'exit';
    return 'geofence_${eventTypeString}_$geofenceId';
  }

  @override
  List<Object?> get props => [eventType, geofenceId];

  @override
  String toString() {
    return 'NotificationPayload(eventType: $eventType, geofenceId: $geofenceId)';
  }
}

/// Types of geofence events
enum GeofenceEventType {
  entry,
  exit,
}

