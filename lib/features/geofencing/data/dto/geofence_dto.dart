import 'package:equatable/equatable.dart';

class GeofenceDto extends Equatable {
  const GeofenceDto({
    required this.id,
    required this.name,
    required this.latitude,
    required this.longitude,
    required this.radius,
    required this.isActive,
    this.description,
    this.mediaItemId,
    this.createdAt,
    this.lastTriggeredAt,
  });

  final String id;
  final String name;
  final double latitude;
  final double longitude;
  final double radius;
  final bool isActive;
  final String? description;
  final String? mediaItemId;
  final String? createdAt; // ISO string format
  final String? lastTriggeredAt; // ISO string format

  // From JSON (SharedPreferences/Local Storage)
  factory GeofenceDto.fromJson(Map<String, dynamic> json) {
    return GeofenceDto(
      id: json['id'] as String,
      name: json['name'] as String,
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      radius: (json['radius'] as num).toDouble(),
      isActive: json['isActive'] as bool,
      description: json['description'] as String?,
      mediaItemId: json['mediaItemId'] as String?,
      createdAt: json['createdAt'] as String?,
      lastTriggeredAt: json['lastTriggeredAt'] as String?,
    );
  }

  // To JSON (SharedPreferences/Local Storage)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'latitude': latitude,
      'longitude': longitude,
      'radius': radius,
      'isActive': isActive,
      'description': description,
      'mediaItemId': mediaItemId,
      'createdAt': createdAt,
      'lastTriggeredAt': lastTriggeredAt,
    };
  }

  // For flutter_background_geolocation
  Map<String, dynamic> toBackgroundGeolocationConfig() {
    return {
      'identifier': id,
      'latitude': latitude,
      'longitude': longitude,
      'radius': radius,
      'notifyOnEntry': true,
      'notifyOnExit': true,
      'notifyOnDwell': false,
      'loiteringDelay': 30000, // 30 seconds
    };
  }

  @override
  List<Object?> get props => [
        id,
        name,
        latitude,
        longitude,
        radius,
        isActive,
        description,
        mediaItemId,
        createdAt,
        lastTriggeredAt,
      ];
}