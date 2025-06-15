import 'package:equatable/equatable.dart';

class ActivityDto extends Equatable {
  const ActivityDto({
    required this.id,
    required this.activityType,
    required this.title,
    required this.subtitle,
    required this.contentType,
    required this.createdAt,
    this.imageUrl,
    this.imageData,
    this.geofenceId,
    this.locationName,
    this.customData,
    this.status,
  });

  final String id;
  final String activityType;
  final String title;
  final String subtitle;
  final String contentType;
  final String createdAt; // ISO string
  final String? imageUrl;
  final String? imageData; // Base64 encoded
  final String? geofenceId;
  final String? locationName;
  final Map<String, dynamic>? customData;
  final String? status;

  // From JSON (Local Storage)
  factory ActivityDto.fromJson(Map<String, dynamic> json) {
    return ActivityDto(
      id: json['id'] as String,
      activityType: json['activityType'] as String,
      title: json['title'] as String,
      subtitle: json['subtitle'] as String,
      contentType: json['contentType'] as String,
      createdAt: json['createdAt'] as String,
      imageUrl: json['imageUrl'] as String?,
      imageData: json['imageData'] as String?,
      geofenceId: json['geofenceId'] as String?,
      locationName: json['locationName'] as String?,
      customData: json['customData'] as Map<String, dynamic>?,
      status: json['status'] as String?,
    );
  }

  // To JSON (Local Storage)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'activityType': activityType,
      'title': title,
      'subtitle': subtitle,
      'contentType': contentType,
      'createdAt': createdAt,
      'imageUrl': imageUrl,
      'imageData': imageData,
      'geofenceId': geofenceId,
      'locationName': locationName,
      'customData': customData,
      'status': status,
    };
  }

  // For live_activities package
  Map<String, dynamic> toLiveActivitiesData() {
    return {
      'attributes': {
        'activityType': activityType,
        'geofenceId': geofenceId,
        'locationName': locationName ?? 'Unknown Location',
        'createdAt': createdAt,
      },
      'contentState': {
        'title': title,
        'subtitle': subtitle,
        'contentType': contentType,
        'imageUrl': imageUrl,
        'imageData': imageData,
        'timestamp': DateTime.now().toIso8601String(),
        'customData': customData ?? {},
      },
    };
  }

  // Create from geofence event
  factory ActivityDto.fromGeofenceEvent({
    required String geofenceId,
    required String geofenceName,
    required String eventType, // 'enter', 'exit', 'dwell'
    String? imageUrl,
    String? imageData,
    Map<String, dynamic>? customData,
  }) {
    final now = DateTime.now();
    final id = '${geofenceId}_${eventType}_${now.millisecondsSinceEpoch}';
    
    String title;
    String subtitle;
    
    switch (eventType) {
      case 'enter':
        title = 'Arrived at $geofenceName';
        subtitle = 'Welcome! You\'ve entered the area.';
        break;
      case 'exit':
        title = 'Left $geofenceName';
        subtitle = 'You\'ve left the area.';
        break;
      case 'dwell':
        title = 'Staying at $geofenceName';
        subtitle = 'You\'ve been in this area for a while.';
        break;
      default:
        title = 'Location Update';
        subtitle = 'Activity at $geofenceName';
    }
    
    return ActivityDto(
      id: id,
      activityType: 'LocationAlert',
      title: title,
      subtitle: subtitle,
      contentType: 'geofence_$eventType',
      createdAt: now.toIso8601String(),
      imageUrl: imageUrl,
      imageData: imageData,
      geofenceId: geofenceId,
      locationName: geofenceName,
      customData: customData,
    );
  }

  ActivityDto copyWith({
    String? id,
    String? activityType,
    String? title,
    String? subtitle,
    String? contentType,
    String? createdAt,
    String? imageUrl,
    String? imageData,
    String? geofenceId,
    String? locationName,
    Map<String, dynamic>? customData,
    String? status,
  }) {
    return ActivityDto(
      id: id ?? this.id,
      activityType: activityType ?? this.activityType,
      title: title ?? this.title,
      subtitle: subtitle ?? this.subtitle,
      contentType: contentType ?? this.contentType,
      createdAt: createdAt ?? this.createdAt,
      imageUrl: imageUrl ?? this.imageUrl,
      imageData: imageData ?? this.imageData,
      geofenceId: geofenceId ?? this.geofenceId,
      locationName: locationName ?? this.locationName,
      customData: customData ?? this.customData,
      status: status ?? this.status,
    );
  }

  @override
  List<Object?> get props => [
        id,
        activityType,
        title,
        subtitle,
        contentType,
        createdAt,
        imageUrl,
        imageData,
        geofenceId,
        locationName,
        customData,
        status,
      ];
}