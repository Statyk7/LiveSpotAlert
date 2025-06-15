import 'package:equatable/equatable.dart';

enum LiveActivityStatus {
  active,
  dismissed,
  ended,
  stale,
}

enum LiveActivityContentType {
  geofenceEntry,
  geofenceExit,
  geofenceDwell,
  locationUpdate,
}

class LiveActivity extends Equatable {
  const LiveActivity({
    required this.id,
    required this.activityType,
    required this.status,
    required this.contentType,
    required this.title,
    required this.subtitle,
    required this.createdAt,
    this.imageUrl,
    this.imageData,
    this.geofenceId,
    this.locationName,
    this.customData,
    this.dismissedAt,
    this.endedAt,
  });

  final String id;
  final String activityType;
  final LiveActivityStatus status;
  final LiveActivityContentType contentType;
  final String title;
  final String subtitle;
  final DateTime createdAt;
  final String? imageUrl;
  final String? imageData; // Base64 encoded image data
  final String? geofenceId;
  final String? locationName;
  final Map<String, dynamic>? customData;
  final DateTime? dismissedAt;
  final DateTime? endedAt;

  LiveActivity copyWith({
    String? id,
    String? activityType,
    LiveActivityStatus? status,
    LiveActivityContentType? contentType,
    String? title,
    String? subtitle,
    DateTime? createdAt,
    String? imageUrl,
    String? imageData,
    String? geofenceId,
    String? locationName,
    Map<String, dynamic>? customData,
    DateTime? dismissedAt,
    DateTime? endedAt,
  }) {
    return LiveActivity(
      id: id ?? this.id,
      activityType: activityType ?? this.activityType,
      status: status ?? this.status,
      contentType: contentType ?? this.contentType,
      title: title ?? this.title,
      subtitle: subtitle ?? this.subtitle,
      createdAt: createdAt ?? this.createdAt,
      imageUrl: imageUrl ?? this.imageUrl,
      imageData: imageData ?? this.imageData,
      geofenceId: geofenceId ?? this.geofenceId,
      locationName: locationName ?? this.locationName,
      customData: customData ?? this.customData,
      dismissedAt: dismissedAt ?? this.dismissedAt,
      endedAt: endedAt ?? this.endedAt,
    );
  }

  // Convenience getters
  bool get isActive => status == LiveActivityStatus.active;
  bool get isDismissed => status == LiveActivityStatus.dismissed;
  bool get isEnded => status == LiveActivityStatus.ended;
  bool get isStale => status == LiveActivityStatus.stale;
  
  Duration get duration {
    final endTime = endedAt ?? dismissedAt ?? DateTime.now();
    return endTime.difference(createdAt);
  }
  
  bool get hasImage => imageUrl != null || imageData != null;
  bool get hasCustomData => customData != null && customData!.isNotEmpty;
  
  @override
  List<Object?> get props => [
        id,
        activityType,
        status,
        contentType,
        title,
        subtitle,
        createdAt,
        imageUrl,
        imageData,
        geofenceId,
        locationName,
        customData,
        dismissedAt,
        endedAt,
      ];

  @override
  String toString() {
    return 'LiveActivity{id: $id, type: $contentType, status: $status, title: $title}';
  }
}