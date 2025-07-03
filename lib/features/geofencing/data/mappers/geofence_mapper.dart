import '../../domain/models/geofence.dart';
import '../../domain/models/location_event.dart';
import '../dto/geofence_dto.dart';
import '../dto/location_event_dto.dart';

class GeofenceMapper {
  static Geofence fromDto(GeofenceDto dto) {
    return Geofence(
      id: dto.id,
      name: dto.name,
      latitude: dto.latitude,
      longitude: dto.longitude,
      radius: dto.radius,
      isActive: dto.isActive,
      description: dto.description,
      mediaItemId: dto.mediaItemId,
      createdAt: dto.createdAt != null ? DateTime.parse(dto.createdAt!) : null,
      lastTriggeredAt: dto.lastTriggeredAt != null
          ? DateTime.parse(dto.lastTriggeredAt!)
          : null,
    );
  }

  static GeofenceDto toDto(Geofence geofence) {
    return GeofenceDto(
      id: geofence.id,
      name: geofence.name,
      latitude: geofence.latitude,
      longitude: geofence.longitude,
      radius: geofence.radius,
      isActive: geofence.isActive,
      description: geofence.description,
      mediaItemId: geofence.mediaItemId,
      createdAt: geofence.createdAt?.toIso8601String(),
      lastTriggeredAt: geofence.lastTriggeredAt?.toIso8601String(),
    );
  }

  static List<Geofence> fromDtoList(List<GeofenceDto> dtos) {
    return dtos.map(fromDto).toList();
  }

  static List<GeofenceDto> toDtoList(List<Geofence> geofences) {
    return geofences.map(toDto).toList();
  }
}

class LocationEventMapper {
  static LocationEvent fromDto(LocationEventDto dto, Geofence geofence) {
    return LocationEvent(
      id: dto.id,
      geofence: geofence,
      eventType: _mapEventType(dto.eventType),
      timestamp: DateTime.parse(dto.timestamp),
      userLatitude: dto.userLatitude,
      userLongitude: dto.userLongitude,
      accuracy: dto.accuracy,
      dwellTime:
          dto.dwellTime != null ? Duration(seconds: dto.dwellTime!) : null,
    );
  }

  static LocationEventDto toDto(LocationEvent event) {
    return LocationEventDto(
      id: event.id,
      geofenceId: event.geofence.id,
      eventType: _mapEventTypeToString(event.eventType),
      timestamp: event.timestamp.toIso8601String(),
      userLatitude: event.userLatitude,
      userLongitude: event.userLongitude,
      accuracy: event.accuracy,
      dwellTime: event.dwellTime?.inSeconds,
    );
  }

  static LocationEventType _mapEventType(String eventType) {
    switch (eventType) {
      case 'enter':
        return LocationEventType.enter;
      case 'exit':
        return LocationEventType.exit;
      case 'dwell':
        return LocationEventType.dwell;
      default:
        return LocationEventType.enter;
    }
  }

  static String _mapEventTypeToString(LocationEventType eventType) {
    switch (eventType) {
      case LocationEventType.enter:
        return 'enter';
      case LocationEventType.exit:
        return 'exit';
      case LocationEventType.dwell:
        return 'dwell';
    }
  }

  static List<LocationEvent> fromDtoList(
      List<LocationEventDto> dtos, List<Geofence> geofences) {
    return dtos.map((dto) {
      final geofence = geofences.firstWhere(
        (g) => g.id == dto.geofenceId,
        orElse: () =>
            throw Exception('Geofence not found for event: ${dto.id}'),
      );
      return fromDto(dto, geofence);
    }).toList();
  }
}
