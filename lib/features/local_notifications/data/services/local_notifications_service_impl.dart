import 'package:dartz/dartz.dart';
import '../../../../shared/base_domain/failures/failure.dart';
import '../../../../shared/utils/logger.dart';
import '../../../../shared/utils/constants.dart';
import '../../domain/services/local_notifications_service.dart';
import '../../domain/models/notification_config.dart';
import '../data_sources/local/notification_config_local_data_source.dart';
import '../data_sources/remote/local_notifications_data_source.dart';

class LocalNotificationsServiceImpl implements LocalNotificationsService {
  LocalNotificationsServiceImpl({
    required this.localDataSource,
    required this.notificationsDataSource,
  });

  final NotificationConfigLocalDataSource localDataSource;
  final LocalNotificationsDataSource notificationsDataSource;

  // Use geofence ID hash for consistent notification IDs
  int _getNotificationId(String geofenceId) {
    return geofenceId.hashCode.abs() % 1000000; // Keep within reasonable range
  }

  @override
  Future<Either<Failure, void>> initialize() async {
    try {
      AppLogger.info('Initializing local notifications service');

      // Initialize the notifications plugin
      final initResult = await notificationsDataSource.initialize();
      if (initResult.isLeft()) {
        return initResult;
      }

      AppLogger.info('Local notifications service initialized successfully');
      return const Right(null);
    } catch (e, stackTrace) {
      AppLogger.error(
          'Error initializing notifications service', e, stackTrace);
      return Left(NotificationFailure(
          message: 'Failed to initialize notifications service: $e'));
    }
  }

  @override
  Future<Either<Failure, NotificationConfig>> getNotificationConfig() async {
    try {
      return await localDataSource.loadNotificationConfig();
    } catch (e, stackTrace) {
      AppLogger.error('Error loading notification config', e, stackTrace);
      return Left(CacheFailure(
          message: 'Failed to load notification configuration: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> saveNotificationConfig(
      NotificationConfig config) async {
    try {
      AppLogger.info('Saving notification config: ${config.toString()}');
      return await localDataSource.saveNotificationConfig(config);
    } catch (e, stackTrace) {
      AppLogger.error('Error saving notification config', e, stackTrace);
      return Left(CacheFailure(
          message: 'Failed to save notification configuration: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> showGeofenceNotification({
    required String geofenceId,
    required String geofenceName,
    required String customTitle,
    bool isEntry = true,
  }) async {
    try {
      // Load current configuration
      final configResult = await getNotificationConfig();
      if (configResult.isLeft()) {
        return configResult.fold(
          (failure) => Left(failure),
          (_) => throw Exception('Unexpected right value'),
        );
      }

      final config =
          configResult.getOrElse(() => NotificationConfig.defaultConfig());

      // Check if notifications are enabled
      if (!config.isEnabled) {
        AppLogger.info(
            'Notifications disabled, skipping notification for $geofenceName');
        return const Right(null);
      }

      // Check if notifications are available
      final availableResult = await areNotificationsAvailable();
      if (availableResult.isLeft()) {
        return availableResult.fold(
          (failure) => Left(failure),
          (_) => throw Exception('Unexpected right value'),
        );
      }

      final available = availableResult.getOrElse(() => false);
      if (!available) {
        AppLogger.warning(
            'Notifications not available, skipping notification for $geofenceName');
        return Left(
            NotificationFailure(message: 'Notifications not available'));
      }

      // Build notification content
      final notificationId = _getNotificationId(geofenceId);
      final title = AppConstants.appName;
      final body = isEntry
          ? '${config.title.isNotEmpty ? '${config.title} @' : 'Arrived at'} $geofenceName'
          : 'Left $geofenceName';

      // Show the notification
      final showResult = await notificationsDataSource.showNotification(
        id: notificationId,
        title: title,
        body: body,
        payload: 'geofence_${isEntry ? 'entry' : 'exit'}_$geofenceId',
      );

      if (showResult.isRight()) {
        AppLogger.info(
            'Geofence notification shown for $geofenceName (entry: $isEntry)');
      }

      return showResult;
    } catch (e, stackTrace) {
      AppLogger.error('Error showing geofence notification', e, stackTrace);
      return Left(NotificationFailure(
          message: 'Failed to show geofence notification: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> dismissGeofenceNotification(
      String geofenceId) async {
    try {
      final notificationId = _getNotificationId(geofenceId);
      final result =
          await notificationsDataSource.cancelNotification(notificationId);

      if (result.isRight()) {
        AppLogger.info('Geofence notification dismissed for $geofenceId');
      }

      return result;
    } catch (e, stackTrace) {
      AppLogger.error('Error dismissing geofence notification', e, stackTrace);
      return Left(NotificationFailure(
          message: 'Failed to dismiss geofence notification: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> dismissAllNotifications() async {
    try {
      final result = await notificationsDataSource.cancelAllNotifications();

      if (result.isRight()) {
        AppLogger.info('All notifications dismissed');
      }

      return result;
    } catch (e, stackTrace) {
      AppLogger.error('Error dismissing all notifications', e, stackTrace);
      return Left(NotificationFailure(
          message: 'Failed to dismiss all notifications: $e'));
    }
  }

  @override
  Future<Either<Failure, bool>> areNotificationsAvailable() async {
    try {
      return await notificationsDataSource.areNotificationsEnabled();
    } catch (e, stackTrace) {
      AppLogger.error(
          'Error checking notification availability', e, stackTrace);
      return Left(NotificationFailure(
          message: 'Failed to check notification availability: $e'));
    }
  }

  @override
  Future<Either<Failure, bool>> requestNotificationPermissions() async {
    try {
      AppLogger.info('Requesting notification permissions');
      return await notificationsDataSource.requestPermissions();
    } catch (e, stackTrace) {
      AppLogger.error(
          'Error requesting notification permissions', e, stackTrace);
      return Left(NotificationFailure(
          message: 'Failed to request notification permissions: $e'));
    }
  }
}
