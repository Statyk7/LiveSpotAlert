import '../../domain/models/live_activity.dart';

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
}