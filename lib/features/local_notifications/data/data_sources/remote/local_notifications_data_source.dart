import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:dartz/dartz.dart';
import '../../../../../shared/base_domain/failures/failure.dart';
import '../../../../../shared/utils/logger.dart';

/// Data source for managing local notifications using flutter_local_notifications
abstract class LocalNotificationsDataSource {
  /// Initialize the notification plugin
  Future<Either<Failure, void>> initialize();
  
  /// Show a notification
  Future<Either<Failure, void>> showNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
  });
  
  /// Cancel a specific notification
  Future<Either<Failure, void>> cancelNotification(int id);
  
  /// Cancel all notifications
  Future<Either<Failure, void>> cancelAllNotifications();
  
  /// Check if notifications are enabled
  Future<Either<Failure, bool>> areNotificationsEnabled();
  
  /// Request notification permissions (iOS)
  Future<Either<Failure, bool>> requestPermissions();
}

class LocalNotificationsDataSourceImpl implements LocalNotificationsDataSource {
  LocalNotificationsDataSourceImpl();
  
  late final FlutterLocalNotificationsPlugin _notificationsPlugin;
  bool _isInitialized = false;

  @override
  Future<Either<Failure, void>> initialize() async {
    try {
      if (_isInitialized) {
        return const Right(null);
      }

      _notificationsPlugin = FlutterLocalNotificationsPlugin();

      // iOS/macOS initialization settings
      const DarwinInitializationSettings iosSettings = DarwinInitializationSettings(
        requestSoundPermission: true,
        requestBadgePermission: true,
        requestAlertPermission: true,
        requestCriticalPermission: false,
        requestProvisionalPermission: false,
      );

      // Android initialization settings (for future use)
      const AndroidInitializationSettings androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');

      const InitializationSettings initializationSettings = InitializationSettings(
        iOS: iosSettings,
        macOS: iosSettings,
        android: androidSettings,
      );

      final bool? initialized = await _notificationsPlugin.initialize(
        initializationSettings,
        onDidReceiveNotificationResponse: _onNotificationTap,
      );

      if (initialized == true) {
        _isInitialized = true;
        AppLogger.info('Local notifications initialized successfully');
        return const Right(null);
      } else {
        return Left(NotificationFailure(message: 'Failed to initialize local notifications'));
      }
    } catch (e, stackTrace) {
      AppLogger.error('Error initializing local notifications', e, stackTrace);
      return Left(NotificationFailure(message: 'Error initializing notifications: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> showNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
  }) async {
    try {
      if (!_isInitialized) {
        final initResult = await initialize();
        if (initResult.isLeft()) {
          return initResult;
        }
      }

      // iOS notification details
      const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
        interruptionLevel: InterruptionLevel.active,
      );

      // Android notification details (for future use)
      const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
        'geofence_notifications',
        'Geofence Notifications',
        channelDescription: 'Notifications triggered by geofence events',
        importance: Importance.high,
        priority: Priority.high,
      );

      const NotificationDetails notificationDetails = NotificationDetails(
        iOS: iosDetails,
        macOS: iosDetails,
        android: androidDetails,
      );

      await _notificationsPlugin.show(
        id,
        title,
        body,
        notificationDetails,
        payload: payload,
      );

      AppLogger.info('Notification shown: $title - $body');
      return const Right(null);
    } catch (e, stackTrace) {
      AppLogger.error('Error showing notification', e, stackTrace);
      return Left(NotificationFailure(message: 'Error showing notification: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> cancelNotification(int id) async {
    try {
      if (!_isInitialized) {
        return Left(NotificationFailure(message: 'Notifications not initialized'));
      }

      await _notificationsPlugin.cancel(id);
      AppLogger.info('Notification cancelled: $id');
      return const Right(null);
    } catch (e, stackTrace) {
      AppLogger.error('Error cancelling notification', e, stackTrace);
      return Left(NotificationFailure(message: 'Error cancelling notification: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> cancelAllNotifications() async {
    try {
      if (!_isInitialized) {
        return Left(NotificationFailure(message: 'Notifications not initialized'));
      }

      await _notificationsPlugin.cancelAll();
      AppLogger.info('All notifications cancelled');
      return const Right(null);
    } catch (e, stackTrace) {
      AppLogger.error('Error cancelling all notifications', e, stackTrace);
      return Left(NotificationFailure(message: 'Error cancelling all notifications: $e'));
    }
  }

  @override
  Future<Either<Failure, bool>> areNotificationsEnabled() async {
    try {
      if (!_isInitialized) {
        final initResult = await initialize();
        if (initResult.isLeft()) {
          return Left(NotificationFailure(message: 'Failed to initialize notifications'));
        }
      }

      // For iOS, check if notifications are enabled
      final bool? enabled = await _notificationsPlugin
          .resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>()
          ?.requestPermissions(
            alert: true,
            badge: true,
            sound: true,
          );

      return Right(enabled ?? false);
    } catch (e, stackTrace) {
      AppLogger.error('Error checking notification permissions', e, stackTrace);
      return Left(NotificationFailure(message: 'Error checking permissions: $e'));
    }
  }

  @override
  Future<Either<Failure, bool>> requestPermissions() async {
    try {
      if (!_isInitialized) {
        final initResult = await initialize();
        if (initResult.isLeft()) {
          return Left(NotificationFailure(message: 'Failed to initialize notifications'));
        }
      }

      // Request permissions on iOS
      final bool? granted = await _notificationsPlugin
          .resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>()
          ?.requestPermissions(
            alert: true,
            badge: true,
            sound: true,
          );

      AppLogger.info('Notification permissions requested, granted: $granted');
      return Right(granted ?? false);
    } catch (e, stackTrace) {
      AppLogger.error('Error requesting notification permissions', e, stackTrace);
      return Left(NotificationFailure(message: 'Error requesting permissions: $e'));
    }
  }

  void _onNotificationTap(NotificationResponse response) {
    AppLogger.info('Notification tapped: ${response.payload}');
    // Handle notification tap if needed
  }
}