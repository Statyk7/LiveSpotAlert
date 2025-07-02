import '../../domain/models/live_activity.dart';
import '../dto/activity_dto.dart';

class LiveActivityMapper {
  static Map<String, dynamic> toUpdateData(LiveActivity liveActivity) {
    return {
      'activityType': liveActivity.activityType,
      'title': liveActivity.title,
      'subtitle': liveActivity.subtitle,
      if (liveActivity.imageUrl != null) 'imageUrl': liveActivity.imageUrl!,
      if (liveActivity.imageData != null) 'imageData': liveActivity.imageData!,
      if (liveActivity.locationName != null) 'locationName': liveActivity.locationName!,
      'status': liveActivity.status.name,
      'contentType': liveActivity.contentType.name,
      ...?liveActivity.customData,
    };
  }

  static Map<String, dynamic> toCreateData(LiveActivity liveActivity) {
    return {
      'id': liveActivity.id,
      'activityType': liveActivity.activityType,
      'title': liveActivity.title,
      'subtitle': liveActivity.subtitle,
      if (liveActivity.imageUrl != null) 'imageUrl': liveActivity.imageUrl!,
      if (liveActivity.imageData != null) 'imageData': liveActivity.imageData!,
      if (liveActivity.locationName != null) 'locationName': liveActivity.locationName!,
      'status': liveActivity.status.name,
      'contentType': liveActivity.contentType.name,
      'createdAt': liveActivity.createdAt.toIso8601String(),
      'updatedAt': liveActivity.updatedAt.toIso8601String(),
      ...?liveActivity.customData,
    };
  }

  static LiveActivity fromData(Map<String, dynamic> data) {
    return LiveActivity(
      id: data['id'] as String,
      activityType: data['activityType'] as String? ?? 'geofence',
      title: data['title'] as String,
      subtitle: data['subtitle'] as String,
      imageUrl: data['imageUrl'] as String?,
      imageData: data['imageData'] as String?,
      locationName: data['locationName'] as String?,
      status: LiveActivityStatus.values.firstWhere(
        (status) => status.name == data['status'],
        orElse: () => LiveActivityStatus.active,
      ),
      contentType: LiveActivityContentType.values.firstWhere(
        (type) => type.name == data['contentType'],
        orElse: () => LiveActivityContentType.geofenceEntry,
      ),
      createdAt: DateTime.parse(data['createdAt'] as String),
      updatedAt: DateTime.parse(data['updatedAt'] as String),
      customData: Map<String, dynamic>.from(data)
        ..removeWhere((key, value) => [
              'id',
              'activityType',
              'title',
              'subtitle',
              'imageUrl',
              'imageData',
              'locationName',
              'status',
              'contentType',
              'createdAt',
              'updatedAt'
            ].contains(key)),
    );
  }

  /// Convert LiveActivity domain model to ActivityDto
  static ActivityDto toDto(LiveActivity liveActivity) {
    return ActivityDto(
      id: liveActivity.id,
      activityType: liveActivity.activityType,
      title: liveActivity.title,
      subtitle: liveActivity.subtitle,
      contentType: liveActivity.contentType.name,
      createdAt: liveActivity.createdAt.toIso8601String(),
      imageUrl: liveActivity.imageUrl,
      imageData: liveActivity.imageData,
      geofenceId: liveActivity.geofenceId,
      locationName: liveActivity.locationName,
      customData: liveActivity.customData,
      status: liveActivity.status.name,
    );
  }

  /// Convert ActivityDto to LiveActivity domain model
  static LiveActivity fromDto(ActivityDto dto) {
    return LiveActivity(
      id: dto.id,
      activityType: dto.activityType,
      title: dto.title,
      subtitle: dto.subtitle,
      status: LiveActivityStatus.values.firstWhere(
        (status) => status.name == dto.status,
        orElse: () => LiveActivityStatus.active,
      ),
      contentType: LiveActivityContentType.values.firstWhere(
        (type) => type.name == dto.contentType,
        orElse: () => LiveActivityContentType.geofenceEntry,
      ),
      createdAt: DateTime.parse(dto.createdAt),
      updatedAt: DateTime.now(), // ActivityDto doesn't have updatedAt, use current time
      imageUrl: dto.imageUrl,
      imageData: dto.imageData,
      geofenceId: dto.geofenceId,
      locationName: dto.locationName,
      customData: dto.customData,
    );
  }
}