import 'package:dartz/dartz.dart';
import '../../../../shared/base_domain/failures/failure.dart';
import '../models/notification_config.dart';

/// Service interface for managing local notifications
abstract class LocalNotificationsService {
  /// Initialize the notification service
  Future<Either<Failure, void>> initialize();

  /// Get the current notification configuration
  Future<Either<Failure, NotificationConfig>> getNotificationConfig();

  /// Save notification configuration
  Future<Either<Failure, void>> saveNotificationConfig(
      NotificationConfig config);

  /// Show a geofence notification
  Future<Either<Failure, void>> showGeofenceNotification({
    required String geofenceId,
    required String geofenceName,
    required String customTitle,
    bool isEntry = true,
  });

  /// Dismiss a geofence notification
  Future<Either<Failure, void>> dismissGeofenceNotification(String geofenceId);

  /// Dismiss all notifications
  Future<Either<Failure, void>> dismissAllNotifications();

  /// Check if notifications are enabled and have permissions
  Future<Either<Failure, bool>> areNotificationsAvailable();

  /// Request notification permissions
  Future<Either<Failure, bool>> requestNotificationPermissions();
}
