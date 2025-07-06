import 'dart:io';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_app_group_directory/flutter_app_group_directory.dart';
import 'package:path/path.dart' as path;
import '../../../../../shared/base_domain/failures/failure.dart';
import '../../../../../shared/utils/logger.dart';
import '../../../../../apps/live_spot_alert/router/app_router.dart';
import '../../services/notification_image_service_impl.dart';

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
    String? imagePath,
    String? imageBase64Data,
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
  LocalNotificationsDataSourceImpl({NotificationImageServiceImpl? imageService})
      : _imageService = imageService;

  late final FlutterLocalNotificationsPlugin _notificationsPlugin;
  final NotificationImageServiceImpl? _imageService;
  bool _isInitialized = false;

  @override
  Future<Either<Failure, void>> initialize() async {
    try {
      if (_isInitialized) {
        return const Right(null);
      }

      _notificationsPlugin = FlutterLocalNotificationsPlugin();

      // iOS/macOS initialization settings
      const DarwinInitializationSettings iosSettings =
          DarwinInitializationSettings(
        requestSoundPermission: true,
        requestBadgePermission: true,
        requestAlertPermission: true,
        requestCriticalPermission: false,
        requestProvisionalPermission: false,
      );

      // Android initialization settings (for future use)
      const AndroidInitializationSettings androidSettings =
          AndroidInitializationSettings('@mipmap/ic_launcher');

      const InitializationSettings initializationSettings =
          InitializationSettings(
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
        
        // Check if app was launched from a notification
        await _checkForLaunchFromNotification();
        
        return const Right(null);
      } else {
        return Left(NotificationFailure(
            message: 'Failed to initialize local notifications'));
      }
    } catch (e, stackTrace) {
      AppLogger.error('Error initializing local notifications', e, stackTrace);
      return Left(
          NotificationFailure(message: 'Error initializing notifications: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> showNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
    String? imagePath,
    String? imageBase64Data,
  }) async {
    try {
      if (!_isInitialized) {
        final initResult = await initialize();
        if (initResult.isLeft()) {
          return initResult;
        }
      }

      // iOS notification details with optional image attachment
      DarwinNotificationDetails iosDetails = const DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
        interruptionLevel: InterruptionLevel.active,
      );

      // Handle image attachment - prefer Base64 data over legacy file path
      String? imageAttachmentPath;
      
      if (imageBase64Data != null && imageBase64Data.isNotEmpty && _imageService != null) {
        AppLogger.info('Creating temporary file from Base64 image data for notification');
        
        try {
          final tempFileResult = await _imageService.createTempFileFromBase64(imageBase64Data);
          tempFileResult.fold(
            (failure) {
              AppLogger.error('Failed to create temporary file from Base64: ${failure.message}');
            },
            (tempFilePath) {
              imageAttachmentPath = tempFilePath;
              AppLogger.info('Successfully created temporary file for notification: $tempFilePath');
            },
          );
        } catch (e, stackTrace) {
          AppLogger.error('Error creating temporary file from Base64', e, stackTrace);
        }
      } else if (imagePath != null && imagePath.isNotEmpty) {
        AppLogger.info('Using legacy image path for notification: $imagePath');
        
        // Use helper method to find valid image path (legacy support)
        imageAttachmentPath = await _findValidImagePath(imagePath);
        
        if (imageAttachmentPath == null) {
          AppLogger.warning('No valid image path found for: $imagePath');
        }
      }
      
      // Add image attachment if we have a valid path
      final String? finalImagePath = imageAttachmentPath;
      if (finalImagePath != null) {
        try {
          final File imageFile = File(finalImagePath);
          final int fileSize = await imageFile.length();
          
          // Validate file size (iOS has limits)
          if (fileSize > 10 * 1024 * 1024) { // 10MB limit for iOS notifications
            AppLogger.error('Image file too large for notification: ${fileSize}bytes');
            // Continue with notification without image (don't return, just skip attachment)
          } else {
          
          // Validate file extension
          final String extension = path.extension(finalImagePath).toLowerCase();
          if (!_isValidImageExtension(extension)) {
            AppLogger.error('Invalid image extension for notification: $extension');
            // Skip attachment but continue with notification
          } else {
          
          AppLogger.info('Using valid image path: $finalImagePath (${fileSize}bytes, ext: $extension)');
          
          // Create attachment with proper file extension for type recognition
          final String uti = _getUTIForImagePath(finalImagePath);
          AppLogger.info('Using UTI for image attachment: $uti');
          
          // Create attachment with proper file extension for type recognition
          final List<DarwinNotificationAttachment> attachments = [
            DarwinNotificationAttachment(
              finalImagePath,
              identifier: 'image-${DateTime.now().millisecondsSinceEpoch}',
            ),
          ];
          AppLogger.info('Created attachment with identifier for: $finalImagePath');
          
          iosDetails = DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
            interruptionLevel: InterruptionLevel.active,
            attachments: attachments,
          );
          
          AppLogger.info('Successfully added image attachment to notification: $finalImagePath');
          } // Close extension validation
          } // Close file size validation
        } catch (e, stackTrace) {
          AppLogger.error('Failed to add image attachment', e, stackTrace);
          // Continue with notification without image
        }
      }

      // Android notification details (for future use)
      const AndroidNotificationDetails androidDetails =
          AndroidNotificationDetails(
        'geofence_notifications',
        'Geofence Notifications',
        channelDescription: 'Notifications triggered by geofence events',
        importance: Importance.high,
        priority: Priority.high,
      );

      final NotificationDetails notificationDetails = NotificationDetails(
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
      return Left(
          NotificationFailure(message: 'Error showing notification: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> cancelNotification(int id) async {
    try {
      if (!_isInitialized) {
        return Left(
            NotificationFailure(message: 'Notifications not initialized'));
      }

      await _notificationsPlugin.cancel(id);
      AppLogger.info('Notification cancelled: $id');
      return const Right(null);
    } catch (e, stackTrace) {
      AppLogger.error('Error cancelling notification', e, stackTrace);
      return Left(
          NotificationFailure(message: 'Error cancelling notification: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> cancelAllNotifications() async {
    try {
      if (!_isInitialized) {
        return Left(
            NotificationFailure(message: 'Notifications not initialized'));
      }

      await _notificationsPlugin.cancelAll();
      AppLogger.info('All notifications cancelled');
      return const Right(null);
    } catch (e, stackTrace) {
      AppLogger.error('Error cancelling all notifications', e, stackTrace);
      return Left(NotificationFailure(
          message: 'Error cancelling all notifications: $e'));
    }
  }

  @override
  Future<Either<Failure, bool>> areNotificationsEnabled() async {
    try {
      if (!_isInitialized) {
        final initResult = await initialize();
        if (initResult.isLeft()) {
          return Left(NotificationFailure(
              message: 'Failed to initialize notifications'));
        }
      }

      // For iOS, check if notifications are enabled
      final bool? enabled = await _notificationsPlugin
          .resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin>()
          ?.requestPermissions(
            alert: true,
            badge: true,
            sound: true,
          );

      return Right(enabled ?? false);
    } catch (e, stackTrace) {
      AppLogger.error('Error checking notification permissions', e, stackTrace);
      return Left(
          NotificationFailure(message: 'Error checking permissions: $e'));
    }
  }

  @override
  Future<Either<Failure, bool>> requestPermissions() async {
    try {
      if (!_isInitialized) {
        final initResult = await initialize();
        if (initResult.isLeft()) {
          return Left(NotificationFailure(
              message: 'Failed to initialize notifications'));
        }
      }

      // Request permissions on iOS
      final bool? granted = await _notificationsPlugin
          .resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin>()
          ?.requestPermissions(
            alert: true,
            badge: true,
            sound: true,
          );

      AppLogger.info('Notification permissions requested, granted: $granted');
      return Right(granted ?? false);
    } catch (e, stackTrace) {
      AppLogger.error(
          'Error requesting notification permissions', e, stackTrace);
      return Left(
          NotificationFailure(message: 'Error requesting permissions: $e'));
    }
  }

  void _onNotificationTap(NotificationResponse response) {
    AppLogger.info('Notification tapped: ${response.payload}');
    
    // Navigate to notification display screen if payload is valid
    if (response.payload != null && response.payload!.isNotEmpty) {
      try {
        AppLogger.info('Attempting to navigate to notification display with payload: ${response.payload}');
        
        // Use the router directly instead of context
        AppRouter.router.push('/notification-display?payload=${Uri.encodeComponent(response.payload!)}');
        
        AppLogger.info('Navigation command sent successfully');
      } catch (e) {
        AppLogger.error('Failed to navigate to notification display: $e');
        
        // Fallback: try to navigate to main and log the payload for manual handling
        try {
          AppRouter.router.go('/main');
          AppLogger.info('Fallback navigation to main successful. Payload was: ${response.payload}');
        } catch (fallbackError) {
          AppLogger.error('Fallback navigation also failed: $fallbackError');
        }
      }
    } else {
      AppLogger.warning('Notification tapped but no payload provided');
    }
  }

  /// Check if the app was launched from a notification and handle accordingly
  Future<void> _checkForLaunchFromNotification() async {
    try {
      final NotificationAppLaunchDetails? launchDetails =
          await _notificationsPlugin.getNotificationAppLaunchDetails();
      
      if (launchDetails?.didNotificationLaunchApp == true) {
        AppLogger.info('App was launched from a notification');
        
        final NotificationResponse? response = launchDetails!.notificationResponse;
        if (response?.payload != null && response!.payload!.isNotEmpty) {
          AppLogger.info('Launch notification payload: ${response.payload}');
          
          // Delay navigation slightly to ensure the app is fully initialized
          Future.delayed(const Duration(milliseconds: 500), () {
            try {
              AppRouter.router.push('/notification-display?payload=${Uri.encodeComponent(response.payload!)}');
              AppLogger.info('Navigation from launch successful');
            } catch (e) {
              AppLogger.error('Failed to navigate from launch: $e');
            }
          });
        } else {
          AppLogger.warning('App launched from notification but no payload available');
        }
      } else {
        AppLogger.info('App was not launched from a notification');
      }
    } catch (e) {
      AppLogger.error('Error checking notification launch details: $e');
    }
  }

  /// Helper method to verify image file exists and find alternative paths if needed
  Future<String?> _findValidImagePath(String originalPath) async {
    try {
      // First, check the original path
      final File originalFile = File(originalPath);
      if (await originalFile.exists()) {
        AppLogger.info('Image found at original path: $originalPath');
        return originalPath;
      }

      AppLogger.warning('Image not found at original path: $originalPath');

      // If not found, try to find it in app group directory
      // This handles migration from old storage location
      final Directory? appGroupDir = await FlutterAppGroupDirectory.getAppGroupDirectory('group.livespotalert.liveactivities');
      if (appGroupDir != null) {
        final String fileName = path.basename(originalPath);
        final String appGroupImagePath = path.join(appGroupDir.path, 'notification_images', fileName);
        
        final File appGroupFile = File(appGroupImagePath);
        if (await appGroupFile.exists()) {
          AppLogger.info('Image found in app group directory: $appGroupImagePath');
          return appGroupImagePath;
        }
        
        // Try backup copies if primary is missing (with proper extensions)
        final String fileNameWithoutExt = path.basenameWithoutExtension(appGroupImagePath);
        final String directory = path.dirname(appGroupImagePath);
        final String extension = path.extension(appGroupImagePath);
        final String backupPath1 = path.join(directory, '${fileNameWithoutExt}_backup1$extension');
        final String backupPath2 = path.join(directory, '${fileNameWithoutExt}_backup2$extension');
        
        if (await File(backupPath1).exists()) {
          AppLogger.info('Image found at backup1: $backupPath1');
          return backupPath1;
        }
        
        if (await File(backupPath2).exists()) {
          AppLogger.info('Image found at backup2: $backupPath2');
          return backupPath2;
        }
      }

      // Last resort: check if it's just a filename and try to construct full path
      if (!originalPath.contains('/')) {
        if (appGroupDir != null) {
          final String constructedPath = path.join(appGroupDir.path, 'notification_images', originalPath);
          final File constructedFile = File(constructedPath);
          if (await constructedFile.exists()) {
            AppLogger.info('Image found with constructed path: $constructedPath');
            return constructedPath;
          }
          
          // Try backup files for constructed path too
          final String constructedFileNameWithoutExt = path.basenameWithoutExtension(constructedPath);
          final String constructedDirectory = path.dirname(constructedPath);
          final String constructedExtension = path.extension(constructedPath);
          
          final String constructedBackup1 = path.join(constructedDirectory, '${constructedFileNameWithoutExt}_backup1$constructedExtension');
          final String constructedBackup2 = path.join(constructedDirectory, '${constructedFileNameWithoutExt}_backup2$constructedExtension');
          
          if (await File(constructedBackup1).exists()) {
            AppLogger.info('Image found at constructed backup1: $constructedBackup1');
            return constructedBackup1;
          }
          
          if (await File(constructedBackup2).exists()) {
            AppLogger.info('Image found at constructed backup2: $constructedBackup2');
            return constructedBackup2;
          }
        }
      }

      AppLogger.error('Image file not found in any location for: $originalPath');
      return null;
    } catch (e) {
      AppLogger.error('Error searching for image file: $e');
      return null;
    }
  }

  /// Check if the file extension is valid for iOS notifications
  bool _isValidImageExtension(String extension) {
    const validExtensions = ['.jpg', '.jpeg', '.png', '.gif', '.heic', '.heif'];
    return validExtensions.contains(extension.toLowerCase());
  }

  /// Get the appropriate UTI (Uniform Type Identifier) for image files
  String _getUTIForImagePath(String imagePath) {
    final String extension = path.extension(imagePath).toLowerCase();
    
    switch (extension) {
      case '.jpg':
      case '.jpeg':
        return 'public.jpeg';
      case '.png':
        return 'public.png';
      case '.gif':
        return 'com.compuserve.gif';
      case '.heic':
        return 'public.heic';
      case '.heif':
        return 'public.heif';
      default:
        AppLogger.warning('Unknown image extension: $extension, defaulting to JPEG UTI');
        return 'public.jpeg'; // Default fallback
    }
  }
}
