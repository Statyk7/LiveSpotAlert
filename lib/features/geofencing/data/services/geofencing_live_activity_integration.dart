import 'dart:async';
import 'package:dartz/dartz.dart';
import '../../../../shared/base_domain/failures/failure.dart';
import '../../../../shared/utils/logger.dart';
import '../../domain/models/location_event.dart';
import '../../domain/models/geofence.dart';
import '../../../live_activities/domain/services/live_activity_service.dart';
import '../../../live_activities/domain/models/live_activity.dart';
import '../../../media_management/domain/services/media_service.dart';

/// Integration service that connects geofencing events with Live Activities
class GeofencingLiveActivityIntegration {
  GeofencingLiveActivityIntegration({
    required this.liveActivityService,
    required this.mediaService,
  });
  
  final LiveActivityService liveActivityService;
  final MediaService mediaService;
  
  // Track active activities to prevent duplicates
  final Map<String, String> _activeActivities = {}; // geofenceId -> activityId
  
  /// Handle geofence entry events
  Future<Either<Failure, LiveActivity?>> handleGeofenceEntry(
    LocationEvent event,
    Geofence geofence,
  ) async {
    try {
      AppLogger.info('Handling geofence entry for: ${geofence.name}');
      
      // Check if Live Activities are supported and enabled
      final isSupported = await liveActivityService.isLiveActivitiesSupported();
      if (isSupported.isLeft()) {
        return isSupported.fold(
          (failure) => Left(failure),
          (_) => throw Exception('Unexpected right value'),
        );
      }
      
      final supported = isSupported.getOrElse(() => false);
      if (!supported) {
        AppLogger.warning('Live Activities not supported on this device');
        return const Right(null);
      }
      
      // End any existing activity for this geofence
      await _endExistingActivity(geofence.id);
      
      // Get media content if associated (placeholder implementation)
      if (geofence.mediaItemId != null) {
        final mediaResult = await mediaService.getMediaItemById(geofence.mediaItemId!);
        mediaResult.fold(
          (failure) => AppLogger.warning('Failed to load media for geofence: ${failure.message}'),
          (mediaItem) {
            // TODO: Use media item data for Live Activity
            AppLogger.debug('Media item loaded: ${mediaItem.id}');
          },
        );
      }
      
      // Create Live Activity for geofence entry
      final activityResult = await liveActivityService.createActivityForLocationEvent(
        event,
        geofence,
        mediaItemId: geofence.mediaItemId,
        customData: {
          'eventType': 'entry',
          'geofenceRadius': geofence.radius,
          'latitude': geofence.latitude,
          'longitude': geofence.longitude,
          'accuracy': event.accuracy,
          'timestamp': event.timestamp.toIso8601String(),
        },
      );
      
      return await activityResult.fold(
        (failure) => Left(failure),
        (activity) async {
          // Track the active activity
          _activeActivities[geofence.id] = activity.id;
          
          AppLogger.info('Created Live Activity for geofence entry: ${activity.id}');
          
          // Schedule automatic dismissal after configured duration
          _scheduleActivityDismissal(activity.id, geofence.id);
          
          return Right(activity);
        },
      );
    } catch (e, stackTrace) {
      AppLogger.error('Error handling geofence entry', e, stackTrace);
      return Left(LiveActivityFailure(message: 'Failed to handle geofence entry: $e'));
    }
  }
  
  /// Handle geofence exit events
  Future<Either<Failure, void>> handleGeofenceExit(
    LocationEvent event,
    Geofence geofence,
  ) async {
    try {
      AppLogger.info('Handling geofence exit for: ${geofence.name}');
      
      // End the active Live Activity for this geofence
      await _endExistingActivity(geofence.id);
      
      // Optionally create a brief exit notification
      if (geofence.isActive) {
        final exitActivityResult = await liveActivityService.createActivityForLocationEvent(
          event,
          geofence,
          customData: {
            'eventType': 'exit',
            'geofenceRadius': geofence.radius,
            'timestamp': event.timestamp.toIso8601String(),
          },
        );
        
        exitActivityResult.fold(
          (failure) => AppLogger.warning('Failed to create exit activity: ${failure.message}'),
          (activity) {
            AppLogger.info('Created exit Live Activity: ${activity.id}');
            
            // Auto-dismiss exit activity after shorter duration (e.g., 10 seconds)
            Timer(const Duration(seconds: 10), () async {
              await liveActivityService.endLiveActivity(activity.id);
            });
          },
        );
      }
      
      return const Right(null);
    } catch (e, stackTrace) {
      AppLogger.error('Error handling geofence exit', e, stackTrace);
      return Left(LiveActivityFailure(message: 'Failed to handle geofence exit: $e'));
    }
  }
  
  /// Handle geofence dwell events (user stayed in area)
  Future<Either<Failure, LiveActivity?>> handleGeofenceDwell(
    LocationEvent event,
    Geofence geofence,
  ) async {
    try {
      AppLogger.info('Handling geofence dwell for: ${geofence.name}');
      
      // Update existing activity or create new one
      final existingActivityId = _activeActivities[geofence.id];
      
      if (existingActivityId != null) {
        // Update existing activity with dwell information
        final existingActivity = await liveActivityService.getLiveActivityById(existingActivityId);
        
        return await existingActivity.fold(
          (failure) => Left(failure),
          (activity) async {
            if (activity != null && activity.isActive) {
              final updatedActivity = activity.copyWith(
                subtitle: 'You\'ve been here for ${event.dwellTime?.inMinutes ?? 0} minutes',
                customData: {
                  ...?activity.customData,
                  'dwellTime': event.dwellTime?.inSeconds,
                  'lastUpdate': DateTime.now().toIso8601String(),
                },
              );
              
              final updateResult = await liveActivityService.updateLiveActivity(updatedActivity);
              return updateResult.fold(
                (failure) => Left(failure),
                (updated) => Right(updated),
              );
            } else {
              // Activity no longer active, create new one
              return await _createDwellActivity(event, geofence);
            }
          },
        );
      } else {
        // No existing activity, create new dwell activity
        return await _createDwellActivity(event, geofence);
      }
    } catch (e, stackTrace) {
      AppLogger.error('Error handling geofence dwell', e, stackTrace);
      return Left(LiveActivityFailure(message: 'Failed to handle geofence dwell: $e'));
    }
  }
  
  Future<Either<Failure, LiveActivity?>> _createDwellActivity(
    LocationEvent event,
    Geofence geofence,
  ) async {
    final activityResult = await liveActivityService.createActivityForLocationEvent(
      event,
      geofence,
      mediaItemId: geofence.mediaItemId,
      customData: {
        'eventType': 'dwell',
        'dwellTime': event.dwellTime?.inSeconds,
        'timestamp': event.timestamp.toIso8601String(),
      },
    );
    
    return activityResult.fold(
      (failure) => Left(failure),
      (activity) {
        _activeActivities[geofence.id] = activity.id;
        _scheduleActivityDismissal(activity.id, geofence.id);
        return Right(activity);
      },
    );
  }
  
  /// End existing Live Activity for a geofence
  Future<void> _endExistingActivity(String geofenceId) async {
    final existingActivityId = _activeActivities[geofenceId];
    if (existingActivityId != null) {
      await liveActivityService.endLiveActivity(existingActivityId);
      _activeActivities.remove(geofenceId);
      AppLogger.debug('Ended existing Live Activity: $existingActivityId');
    }
  }
  
  /// Schedule automatic dismissal of Live Activity
  void _scheduleActivityDismissal(String activityId, String geofenceId) {
    // Auto-dismiss after 30 minutes (configurable)
    const dismissalDuration = Duration(minutes: 30);
    
    Timer(dismissalDuration, () async {
      try {
        await liveActivityService.endLiveActivity(activityId);
        _activeActivities.remove(geofenceId);
        AppLogger.debug('Auto-dismissed Live Activity: $activityId');
      } catch (e) {
        AppLogger.warning('Failed to auto-dismiss Live Activity: $e');
      }
    });
  }
  
  /// Clean up all tracked activities
  Future<void> cleanup() async {
    try {
      for (final activityId in _activeActivities.values) {
        await liveActivityService.endLiveActivity(activityId);
      }
      _activeActivities.clear();
      AppLogger.info('Cleaned up all Live Activities');
    } catch (e, stackTrace) {
      AppLogger.error('Error during cleanup', e, stackTrace);
    }
  }
  
  /// Get currently active activities
  Map<String, String> get activeActivities => Map.unmodifiable(_activeActivities);
  
  /// Check if a geofence has an active Live Activity
  bool hasActiveActivity(String geofenceId) {
    return _activeActivities.containsKey(geofenceId);
  }
}