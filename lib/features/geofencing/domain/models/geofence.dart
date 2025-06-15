import 'package:equatable/equatable.dart';

class Geofence extends Equatable {
  const Geofence({
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
  final double radius; // in meters
  final bool isActive;
  final String? description;
  final String? mediaItemId; // Reference to media item for Live Activity
  final DateTime? createdAt;
  final DateTime? lastTriggeredAt;

  Geofence copyWith({
    String? id,
    String? name,
    double? latitude,
    double? longitude,
    double? radius,
    bool? isActive,
    String? description,
    String? mediaItemId,
    DateTime? createdAt,
    DateTime? lastTriggeredAt,
  }) {
    return Geofence(
      id: id ?? this.id,
      name: name ?? this.name,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      radius: radius ?? this.radius,
      isActive: isActive ?? this.isActive,
      description: description ?? this.description,
      mediaItemId: mediaItemId ?? this.mediaItemId,
      createdAt: createdAt ?? this.createdAt,
      lastTriggeredAt: lastTriggeredAt ?? this.lastTriggeredAt,
    );
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

  @override
  String toString() {
    return 'Geofence{id: $id, name: $name, lat: $latitude, lng: $longitude, radius: $radius, active: $isActive}';
  }
}