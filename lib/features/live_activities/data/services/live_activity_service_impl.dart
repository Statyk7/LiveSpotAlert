import 'dart:async';
import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:live_activities/live_activities.dart';
import '../../../../shared/base_domain/failures/failure.dart';
import '../../../../shared/utils/logger.dart';
import '../../domain/services/live_activity_service.dart';
import '../../domain/models/live_activity.dart';
import '../../../geofencing/domain/models/location_event.dart';
import '../../../geofencing/domain/models/geofence.dart';
import '../../../media_management/domain/services/media_service.dart';
import '../mappers/live_activity_mapper.dart';
import '../data_sources/local/live_activity_local_data_source.dart';

class LiveActivityServiceImpl implements LiveActivityService {
  LiveActivityServiceImpl({
    required this.liveActivitiesPlugin,
    required this.localDataSource,
    this.mediaService,
  });

  final LiveActivities liveActivitiesPlugin;
  final LiveActivityLocalDataSource localDataSource;
  final MediaService? mediaService;
  final StreamController<Either<Failure, LiveActivity>> _activityUpdatesController = 
      StreamController<Either<Failure, LiveActivity>>.broadcast();

  // Cache for active activities
  List<LiveActivity>? _cachedActivities;

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
        
        // Save to local storage
        final activityDto = LiveActivityMapper.toDto(startedActivity);
        await localDataSource.saveLiveActivity(activityDto);
        
        // Update cache
        _cachedActivities = null;
        
        _activityUpdatesController.add(Right(startedActivity));
        AppLogger.debug("Started Live Activity: $createdActivityId");
        return Right(startedActivity);
      } else {
        return Left(LiveActivityFailure(message: 'Failed to start Live Activity'));
      }
    } catch (e) {
      AppLogger.error('Error starting Live Activity', e);
      return Left(LiveActivityFailure(message: 'Failed to start Live Activity: $e'));
    }
  }

  @override
  Future<Either<Failure, LiveActivity>> updateLiveActivity(LiveActivity activity) async {
    try {
      final updateData = LiveActivityMapper.toUpdateData(activity);
      await liveActivitiesPlugin.updateActivity(activity.id, updateData);
      
      final updatedActivity = activity.copyWith(updatedAt: DateTime.now());
      
      // Update in local storage
      final activityDto = LiveActivityMapper.toDto(updatedActivity);
      await localDataSource.saveLiveActivity(activityDto);
      
      // Update cache
      _cachedActivities = null;
      
      _activityUpdatesController.add(Right(updatedActivity));
      AppLogger.debug("Updated Live Activity: ${activity.id}");
      return Right(updatedActivity);
    } catch (e) {
      AppLogger.error('Error updating Live Activity', e);
      return Left(LiveActivityFailure(message: 'Failed to update Live Activity: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> endLiveActivity(String activityId) async {
    try {
      await liveActivitiesPlugin.endActivity(activityId);
      
      // Update status in local storage
      final activityDto = await localDataSource.getLiveActivityById(activityId);
      if (activityDto != null) {
        final updatedDto = activityDto.copyWith(
          status: LiveActivityStatus.ended.name,
        );
        await localDataSource.saveLiveActivity(updatedDto);
      }
      
      // Update cache
      _cachedActivities = null;
      
      AppLogger.debug("Ended Live Activity: $activityId");
      return const Right(null);
    } catch (e) {
      AppLogger.error('Error ending Live Activity', e);
      return Left(LiveActivityFailure(message: 'Failed to end Live Activity: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> endAllLiveActivities() async {
    try {
      await liveActivitiesPlugin.endAllActivities();
      
      // Update all activities to ended status in local storage
      final activities = await localDataSource.getLiveActivities();
      for (final activity in activities) {
        if (activity.status != LiveActivityStatus.ended.name) {
          final updatedActivity = activity.copyWith(
            status: LiveActivityStatus.ended.name,
          );
          await localDataSource.saveLiveActivity(updatedActivity);
        }
      }
      
      // Clear cache
      _cachedActivities = null;
      
      AppLogger.debug("Ended all Live Activities");
      return const Right(null);
    } catch (e) {
      AppLogger.error('Error ending all Live Activities', e);
      return Left(LiveActivityFailure(message: 'Failed to end all Live Activities: $e'));
    }
  }

  @override
  Future<Either<Failure, List<LiveActivity>>> getActiveLiveActivities() async {
    try {
      if (_cachedActivities != null) {
        return Right(_cachedActivities!);
      }
      
      final activityDtos = await localDataSource.getLiveActivities();
      final activities = activityDtos
          .where((dto) => dto.status != LiveActivityStatus.ended.name)
          .map((dto) => LiveActivityMapper.fromDto(dto))
          .toList();
      
      _cachedActivities = activities;
      AppLogger.debug('Retrieved ${activities.length} active live activities');
      return Right(activities);
    } catch (e) {
      AppLogger.error('Error getting active Live Activities', e);
      return Left(LiveActivityFailure(message: 'Failed to get active Live Activities: $e'));
    }
  }

  @override
  Future<Either<Failure, LiveActivity?>> getLiveActivityById(String id) async {
    try {
      final activityDto = await localDataSource.getLiveActivityById(id);
      if (activityDto == null) {
        return const Right(null);
      }
      
      final activity = LiveActivityMapper.fromDto(activityDto);
      AppLogger.debug('Retrieved live activity by ID: $id');
      return Right(activity);
    } catch (e) {
      AppLogger.error('Error getting Live Activity by ID', e);
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
      final activityDtos = await localDataSource.getLiveActivityHistory(
        startDate: startDate,
        endDate: endDate,
        limit: limit,
      );
      
      final activities = activityDtos
          .map((dto) => LiveActivityMapper.fromDto(dto))
          .toList();
      
      AppLogger.debug('Retrieved ${activities.length} live activity history items');
      return Right(activities);
    } catch (e) {
      AppLogger.error('Error getting Live Activity history', e);
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
      AppLogger.debug("Cleanup old activities is not yet implemented");
      return const Right(null);
    } catch (e) {
      AppLogger.error('Error cleaning up old activities', e);
      return Left(LiveActivityFailure(message: 'Failed to cleanup old activities: $e'));
    }
  }

  /// Get the current active Live Activity configuration
  @override
  Future<Either<Failure, LiveActivity?>> getActiveConfiguration() async {
    try {
      final configDto = await localDataSource.getActiveConfiguration();
      if (configDto == null) {
        debugPrint('ServiceImpl: No active configuration found');
        return const Right(null);
      }
      
      debugPrint('ServiceImpl: Found config DTO - title: "${configDto.title}", hasImageData: ${configDto.imageData != null}');
      if (configDto.imageData != null) {
        debugPrint('ServiceImpl: ImageData length: ${configDto.imageData!.length}');
      }
      
      final config = LiveActivityMapper.fromDto(configDto);
      debugPrint('ServiceImpl: Mapped to domain - title: "${config.title}", hasImageData: ${config.imageData != null}');
      AppLogger.debug('Retrieved active Live Activity configuration: ${config.title}');
      return Right(config);
    } catch (e) {
      AppLogger.error('Error getting active Live Activity configuration', e);
      return Left(LiveActivityFailure(message: 'Failed to get active configuration: $e'));
    }
  }

  /// Save Live Activity configuration (title and image)
  @override
  Future<Either<Failure, void>> saveConfiguration({
    required String title,
    String? subtitle,
    String? imageUrl,
    String? imageData,
    String? activityType,
    Map<String, dynamic>? customData,
  }) async {
    try {
      final configId = 'config_${DateTime.now().millisecondsSinceEpoch}';
      
      debugPrint('ServiceImpl: Saving config - title: "$title", hasImageData: ${imageData != null}');
      if (imageData != null) {
        debugPrint('ServiceImpl: ImageData length: ${imageData!.length}');
        debugPrint('ServiceImpl: ImageData preview: ${imageData!.substring(0, imageData!.length > 100 ? 100 : imageData!.length)}...');
      }
      
      final config = LiveActivity(
        id: configId,
        activityType: activityType ?? 'LocationAlert',
        title: title,
        subtitle: subtitle ?? '',
        status: LiveActivityStatus.configured,
        contentType: LiveActivityContentType.configuration,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        imageUrl: imageUrl,
        imageData: imageData,
        customData: customData,
      );
      
      debugPrint('ServiceImpl: Created domain object - hasImageData: ${config.imageData != null}');
      
      final configDto = LiveActivityMapper.toDto(config);
      debugPrint('ServiceImpl: Mapped to DTO - hasImageData: ${configDto.imageData != null}');
      
      await localDataSource.saveActiveConfiguration(configDto);
      
      AppLogger.debug('Saved Live Activity configuration: $title');
      return const Right(null);
    } catch (e) {
      AppLogger.error('Error saving Live Activity configuration', e);
      return Left(LiveActivityFailure(message: 'Failed to save configuration: $e'));
    }
  }

  /// Clear the active Live Activity configuration
  @override
  Future<Either<Failure, void>> clearConfiguration() async {
    try {
      await localDataSource.clearActiveConfiguration();
      AppLogger.debug('Cleared Live Activity configuration');
      return const Right(null);
    } catch (e) {
      AppLogger.error('Error clearing Live Activity configuration', e);
      return Left(LiveActivityFailure(message: 'Failed to clear configuration: $e'));
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