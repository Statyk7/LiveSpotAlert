import 'dart:async';
import 'package:dartz/dartz.dart';
import '../../../../shared/base_domain/failures/failure.dart';
import '../../../../shared/utils/logger.dart';
import '../../domain/models/location_event.dart';
import '../../domain/models/geofence.dart';
import '../../../local_notifications/domain/services/local_notifications_service.dart';

/// Integration service that connects geofencing events with local notifications
class GeofencingNotificationIntegration {
  GeofencingNotificationIntegration({
    required this.notificationsService,
  });
  
  final LocalNotificationsService notificationsService;
  
  // Track active notifications to prevent duplicates
  final Set<String> _activeNotifications = {}; // geofenceId set
  
  /// Handle geofence entry events
  Future<Either<Failure, void>> handleGeofenceEntry(
    LocationEvent event,
    Geofence geofence,
  ) async {
    try {
      AppLogger.info('Handling geofence entry notification for: ${geofence.name}');
      
      // Load notification configuration to get custom title
      final configResult = await notificationsService.getNotificationConfig();
      
      final config = configResult.getOrElse(() => throw Exception('Failed to load config'));
      
      // Check if notifications are enabled
      if (!config.isEnabled) {
        AppLogger.info('Notifications disabled, skipping notification for ${geofence.name}');
        return const Right(null);
      }
      
      // Show entry notification
      final result = await notificationsService.showGeofenceNotification(
        geofenceId: geofence.id,
        geofenceName: geofence.name,
        customTitle: config.title,
        isEntry: true,
      );
      
      return await result.fold(
        (failure) => Left(failure),
        (_) async {
          // Track the active notification
          _activeNotifications.add(geofence.id);
          
          AppLogger.info('Geofence entry notification shown for: ${geofence.name}');
          return const Right(null);
        },
      );
    } catch (e, stackTrace) {
      AppLogger.error('Error handling geofence entry notification', e, stackTrace);
      return Left(NotificationFailure(message: 'Failed to handle geofence entry notification: $e'));
    }
  }
  
  /// Handle geofence exit events
  Future<Either<Failure, void>> handleGeofenceExit(
    LocationEvent event,
    Geofence geofence,
  ) async {
    try {
      AppLogger.info('Handling geofence exit notification for: ${geofence.name}');
      
      // Dismiss the active notification for this geofence
      if (_activeNotifications.contains(geofence.id)) {
        final dismissResult = await notificationsService.dismissGeofenceNotification(geofence.id);
        
        await dismissResult.fold(
          (failure) async {
            AppLogger.warning('Failed to dismiss geofence notification: ${failure.message}');
          },
          (_) async {
            _activeNotifications.remove(geofence.id);
            AppLogger.info('Geofence notification dismissed for: ${geofence.name}');
          },
        );
      }
      
      // Load notification configuration
      final configResult = await notificationsService.getNotificationConfig();
      final config = configResult.getOrElse(() => throw Exception('Failed to load config'));
      
      // Optionally show exit notification (if configured)
      if (config.isEnabled && geofence.isActive) {
        final exitResult = await notificationsService.showGeofenceNotification(
          geofenceId: '${geofence.id}_exit',
          geofenceName: geofence.name,
          customTitle: 'Left',
          isEntry: false,
        );
        
        exitResult.fold(
          (failure) => AppLogger.warning('Failed to show exit notification: ${failure.message}'),
          (_) {
            AppLogger.info('Geofence exit notification shown for: ${geofence.name}');
            
            // Auto-dismiss exit notification after 5 seconds
            Timer(const Duration(seconds: 5), () async {
              await notificationsService.dismissGeofenceNotification('${geofence.id}_exit');
            });
          },
        );
      }
      
      return const Right(null);
    } catch (e, stackTrace) {
      AppLogger.error('Error handling geofence exit notification', e, stackTrace);
      return Left(NotificationFailure(message: 'Failed to handle geofence exit notification: $e'));
    }
  }
  
  /// Handle geofence dwell events (user stayed in area)
  Future<Either<Failure, void>> handleGeofenceDwell(
    LocationEvent event,
    Geofence geofence,
  ) async {
    try {
      AppLogger.info('Handling geofence dwell notification for: ${geofence.name}');
      
      // Load notification configuration
      final configResult = await notificationsService.getNotificationConfig();
      final config = configResult.getOrElse(() => throw Exception('Failed to load config'));
      
      // Check if notifications are enabled
      if (!config.isEnabled) {
        return const Right(null);
      }
      
      // Show dwell notification (only if no active notification exists)
      if (!_activeNotifications.contains(geofence.id)) {
        final result = await notificationsService.showGeofenceNotification(
          geofenceId: geofence.id,
          geofenceName: geofence.name,
          customTitle: 'Still at',
          isEntry: true,
        );
        
        result.fold(
          (failure) => AppLogger.warning('Failed to show dwell notification: ${failure.message}'),
          (_) {
            _activeNotifications.add(geofence.id);
            AppLogger.info('Geofence dwell notification shown for: ${geofence.name}');
          },
        );
      }
      
      return const Right(null);
    } catch (e, stackTrace) {
      AppLogger.error('Error handling geofence dwell notification', e, stackTrace);
      return Left(NotificationFailure(message: 'Failed to handle geofence dwell notification: $e'));
    }
  }
  
  /// Clean up all tracked notifications
  Future<void> cleanup() async {
    try {
      await notificationsService.dismissAllNotifications();
      _activeNotifications.clear();
      AppLogger.info('Cleaned up all notifications');
    } catch (e, stackTrace) {
      AppLogger.error('Error during notification cleanup', e, stackTrace);
    }
  }
  
  /// Get currently active notification geofence IDs
  Set<String> get activeNotifications => Set.unmodifiable(_activeNotifications);
  
  /// Check if a geofence has an active notification
  bool hasActiveNotification(String geofenceId) {
    return _activeNotifications.contains(geofenceId);
  }
}