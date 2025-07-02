import 'dart:async';
import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:live_activities/live_activities.dart';
import '../../../../shared/base_domain/failures/failure.dart';
import '../../domain/services/live_activity_service.dart';
import '../../domain/models/live_activity.dart';
import '../../../geofencing/domain/models/location_event.dart';
import '../../../geofencing/domain/models/geofence.dart';
import '../../../media_management/domain/services/media_service.dart';
import '../mappers/live_activity_mapper.dart';

class LiveActivityServiceImpl implements LiveActivityService {
  LiveActivityServiceImpl({
    required this.liveActivitiesPlugin,
    this.mediaService,
  });

  final LiveActivities liveActivitiesPlugin;
  final MediaService? mediaService;
  final StreamController<Either<Failure, LiveActivity>> _activityUpdatesController = 
      StreamController<Either<Failure, LiveActivity>>.broadcast();

  @override
  Stream<Either<Failure, LiveActivity>> get liveActivityUpdates => 
      _activityUpdatesController.stream;

  @override
  Future<Either<Failure, bool>> isLiveActivitiesSupported() async {
    try {
      final isSupported = await liveActivitiesPlugin.areActivitiesEnabled();
      return Right(isSupported);
    } catch (e) {
      debugPrint("Error checking Live Activities support: $e");
      return Left(LiveActivityFailure(message: 'Failed to check Live Activities support: $e'));
    }
  }

  @override
  Future<Either<Failure, bool>> isLiveActivitiesEnabled() async {
    try {
      final isEnabled = await liveActivitiesPlugin.areActivitiesEnabled();
      return Right(isEnabled);
    } catch (e) {
      debugPrint("Error checking Live Activities enabled: $e");
      return Left(LiveActivityFailure(message: 'Failed to check if Live Activities are enabled: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> requestLiveActivitiesPermission() async {
    try {
      // The live_activities plugin handles permissions automatically
      // This is a placeholder for any future permission request logic
      return const Right(null);
    } catch (e) {
      debugPrint("Error requesting Live Activities permission: $e");
      return Left(LiveActivityFailure(message: 'Failed to request Live Activities permission: $e'));
    }
  }

  @override
  Future<Either<Failure, LiveActivity>> startLiveActivity(LiveActivity activity) async {
    try {
      final createData = LiveActivityMapper.toCreateData(activity);
      final createdActivityId = await liveActivitiesPlugin.createActivity(
        activity.id,
        createData,
        removeWhenAppIsKilled: false,
      );
      
      if (createdActivityId != null) {
        final startedActivity = activity.copyWith(
          id: createdActivityId,
          status: LiveActivityStatus.active,
          updatedAt: DateTime.now(),
        );
        
        _activityUpdatesController.add(Right(startedActivity));
        debugPrint("Started Live Activity: $createdActivityId");
        return Right(startedActivity);
      } else {
        return Left(LiveActivityFailure(message: 'Failed to start Live Activity'));
      }
    } catch (e) {
      debugPrint("Error starting Live Activity: $e");
      return Left(LiveActivityFailure(message: 'Failed to start Live Activity: $e'));
    }
  }

  @override
  Future<Either<Failure, LiveActivity>> updateLiveActivity(LiveActivity activity) async {
    try {
      final updateData = LiveActivityMapper.toUpdateData(activity);
      await liveActivitiesPlugin.updateActivity(activity.id, updateData);
      
      final updatedActivity = activity.copyWith(updatedAt: DateTime.now());
      _activityUpdatesController.add(Right(updatedActivity));
      debugPrint("Updated Live Activity: ${activity.id}");
      return Right(updatedActivity);
    } catch (e) {
      debugPrint("Error updating Live Activity: $e");
      return Left(LiveActivityFailure(message: 'Failed to update Live Activity: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> endLiveActivity(String activityId) async {
    try {
      await liveActivitiesPlugin.endActivity(activityId);
      debugPrint("Ended Live Activity: $activityId");
      return const Right(null);
    } catch (e) {
      debugPrint("Error ending Live Activity: $e");
      return Left(LiveActivityFailure(message: 'Failed to end Live Activity: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> endAllLiveActivities() async {
    try {
      await liveActivitiesPlugin.endAllActivities();
      debugPrint("Ended all Live Activities");
      return const Right(null);
    } catch (e) {
      debugPrint("Error ending all Live Activities: $e");
      return Left(LiveActivityFailure(message: 'Failed to end all Live Activities: $e'));
    }
  }

  @override
  Future<Either<Failure, List<LiveActivity>>> getActiveLiveActivities() async {
    try {
      // The live_activities plugin doesn't provide a direct way to list all activities
      // This would require custom implementation or plugin enhancement
      debugPrint("Getting all Live Activities is not supported by the plugin");
      return const Right([]);
    } catch (e) {
      debugPrint("Error getting all Live Activities: $e");
      return Left(LiveActivityFailure(message: 'Failed to get all Live Activities: $e'));
    }
  }

  @override
  Future<Either<Failure, LiveActivity?>> getLiveActivityById(String id) async {
    try {
      // The live_activities plugin doesn't provide a direct way to get activity by ID
      // This would require custom implementation or plugin enhancement
      debugPrint("Getting Live Activity by ID is not supported by the plugin");
      return const Right(null);
    } catch (e) {
      debugPrint("Error getting Live Activity: $e");
      return Left(LiveActivityFailure(message: 'Failed to get Live Activity: $e'));
    }
  }

  @override
  Future<Either<Failure, List<LiveActivity>>> getLiveActivityHistory({
    DateTime? startDate,
    DateTime? endDate,
    int? limit,
  }) async {
    try {
      // This would require custom storage implementation
      debugPrint("Live Activity history is not implemented");
      return const Right([]);
    } catch (e) {
      debugPrint("Error getting Live Activity history: $e");
      return Left(LiveActivityFailure(message: 'Failed to get Live Activity history: $e'));
    }
  }

  @override
  Future<Either<Failure, LiveActivity>> createActivityForLocationEvent(
    LocationEvent event,
    Geofence geofence, {
    String? mediaItemId,
    Map<String, dynamic>? customData,
  }) async {
    try {
      final activityId = 'geofence-${geofence.id}-${DateTime.now().millisecondsSinceEpoch}';
      
      // Create meaningful title and subtitle based on event type and geofence
      final title = _createNotificationTitle(event, geofence);
      final subtitle = _createNotificationSubtitle(event, geofence);
      
      // Load media item if available
      String? imageData;
      String? imageUrl;
      
      final targetMediaItemId = mediaItemId ?? geofence.mediaItemId;
      if (targetMediaItemId != null && mediaService != null) {
        final mediaResult = await mediaService!.getMediaItemById(targetMediaItemId);
        mediaResult.fold(
          (failure) => debugPrint('Failed to load media for Live Activity: ${failure.message}'),
          (mediaItem) {
            imageData = mediaItem.base64Data;
            imageUrl = mediaItem.filePath;
          },
        );
      }
      
      final liveActivity = LiveActivity(
        id: activityId,
        activityType: 'geofence',
        title: title,
        subtitle: subtitle,
        status: LiveActivityStatus.active,
        contentType: _getContentTypeFromEvent(event),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        geofenceId: geofence.id,
        locationName: geofence.name,
        imageData: imageData,
        imageUrl: imageUrl,
        customData: customData,
      );

      return await startLiveActivity(liveActivity);
    } catch (e) {
      debugPrint("Error creating activity for location event: $e");
      return Left(LiveActivityFailure(message: 'Failed to create activity for location event: $e'));
    }
  }

  /// Create a meaningful notification title based on the event and geofence
  String _createNotificationTitle(LocationEvent event, Geofence geofence) {
    switch (event.eventType) {
      case LocationEventType.enter:
        // Use geofence description as title if available, otherwise create meaningful default
        if (geofence.description != null && geofence.description!.isNotEmpty) {
          return geofence.description!;
        }
        return "You've arrived at ${geofence.name}!";
      
      case LocationEventType.exit:
        return "You've left ${geofence.name}";
      
      case LocationEventType.dwell:
        return "Still at ${geofence.name}";
    }
  }

  /// Create a meaningful notification subtitle
  String _createNotificationSubtitle(LocationEvent event, Geofence geofence) {
    final accuracy = event.accuracy?.toStringAsFixed(0) ?? "Unknown";
    final timestamp = event.timestamp;
    final timeString = "${timestamp.hour.toString().padLeft(2, '0')}:${timestamp.minute.toString().padLeft(2, '0')}";
    
    switch (event.eventType) {
      case LocationEventType.enter:
        return "Entered at $timeString • ${accuracy}m accuracy";
      
      case LocationEventType.exit:
        return "Left at $timeString • ${accuracy}m accuracy";
      
      case LocationEventType.dwell:
        return "Dwelling since $timeString • ${accuracy}m accuracy";
    }
  }

  @override
  Future<Either<Failure, void>> handleGeofenceEntry(
    LocationEvent event,
    Geofence geofence, {
    String? mediaItemId,
  }) async {
    try {
      final createResult = await createActivityForLocationEvent(
        event,
        geofence,
        mediaItemId: mediaItemId,
      );
      
      return createResult.fold(
        (failure) => Left(failure),
        (_) => const Right(null),
      );
    } catch (e) {
      debugPrint("Error handling geofence entry: $e");
      return Left(LiveActivityFailure(message: 'Failed to handle geofence entry: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> handleGeofenceExit(
    LocationEvent event,
    Geofence geofence,
  ) async {
    try {
      // For geofence exit, we might want to end existing activities or create a new one
      // This is a placeholder implementation
      debugPrint("Handling geofence exit for: ${geofence.name}");
      return const Right(null);
    } catch (e) {
      debugPrint("Error handling geofence exit: $e");
      return Left(LiveActivityFailure(message: 'Failed to handle geofence exit: $e'));
    }
  }

  @override
  Future<Either<Failure, LiveActivity>> attachMediaToActivity(
    String activityId,
    String mediaItemId,
  ) async {
    try {
      // This would require integration with media management feature
      // For now, return a placeholder implementation
      debugPrint("Attaching media to activity is not yet implemented");
      return Left(LiveActivityFailure(message: 'Media attachment not yet implemented'));
    } catch (e) {
      debugPrint("Error attaching media to activity: $e");
      return Left(LiveActivityFailure(message: 'Failed to attach media to activity: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> cleanupOldActivities({
    Duration? maxAge,
    int? maxCount,
  }) async {
    try {
      // This would require custom implementation to track and cleanup old activities
      debugPrint("Cleanup old activities is not yet implemented");
      return const Right(null);
    } catch (e) {
      debugPrint("Error cleaning up old activities: $e");
      return Left(LiveActivityFailure(message: 'Failed to cleanup old activities: $e'));
    }
  }

  LiveActivityContentType _getContentTypeFromEvent(LocationEvent event) {
    switch (event.eventType.name.toLowerCase()) {
      case 'geofence_enter':
      case 'enter':
        return LiveActivityContentType.geofenceEntry;
      case 'geofence_exit':
      case 'exit':
        return LiveActivityContentType.geofenceExit;
      case 'geofence_dwell':
      case 'dwell':
        return LiveActivityContentType.geofenceDwell;
      default:
        return LiveActivityContentType.locationUpdate;
    }
  }
}

class LiveActivityFailure extends Failure {
  const LiveActivityFailure({required super.message});
}