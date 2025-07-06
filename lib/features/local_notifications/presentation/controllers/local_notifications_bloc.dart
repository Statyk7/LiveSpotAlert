import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dartz/dartz.dart';
import '../../../../shared/base_domain/use_case.dart';
import '../../../../shared/base_domain/failures/failure.dart';
import '../../../../shared/utils/logger.dart';
import '../../../../shared/services/user_preferences_service.dart';
import '../../domain/models/notification_config.dart';
import '../../domain/use_cases/load_notification_config_use_case.dart';
import '../../domain/use_cases/save_notification_config_use_case.dart';
import '../../domain/use_cases/request_notification_permissions_use_case.dart';
import '../../domain/services/local_notifications_service.dart';
import '../../domain/services/notification_image_service.dart';
import '../../data/services/notification_image_service_impl.dart';
import 'local_notifications_event.dart';
import 'local_notifications_state.dart';

class LocalNotificationsBloc
    extends Bloc<LocalNotificationsEvent, LocalNotificationsState> {
  LocalNotificationsBloc({
    required this.loadNotificationConfigUseCase,
    required this.saveNotificationConfigUseCase,
    required this.requestNotificationPermissionsUseCase,
    required this.notificationsService,
    required this.imageService,
    required this.userPreferencesService,
  }) : super(const LocalNotificationsState()) {
    on<LoadNotificationConfiguration>(_onLoadNotificationConfiguration);
    on<SaveNotificationConfiguration>(_onSaveNotificationConfiguration);
    on<UpdateNotificationTitle>(_onUpdateNotificationTitle);
    on<ToggleNotificationsEnabled>(_onToggleNotificationsEnabled);
    on<ToggleForegroundNotifications>(_onToggleForegroundNotifications);
    on<RequestNotificationPermissions>(_onRequestNotificationPermissions);
    on<ShowTestNotification>(_onShowTestNotification);
    on<DismissAllNotifications>(_onDismissAllNotifications);
    on<SelectNotificationImage>(_onSelectNotificationImage);
    on<RemoveNotificationImage>(_onRemoveNotificationImage);
  }

  final LoadNotificationConfigUseCase loadNotificationConfigUseCase;
  final SaveNotificationConfigUseCase saveNotificationConfigUseCase;
  final RequestNotificationPermissionsUseCase
      requestNotificationPermissionsUseCase;
  final LocalNotificationsService notificationsService;
  final NotificationImageService imageService;
  final UserPreferencesService userPreferencesService;

  Future<void> _onLoadNotificationConfiguration(
    LoadNotificationConfiguration event,
    Emitter<LocalNotificationsState> emit,
  ) async {
    try {
      emit(state.copyWith(status: NotificationStatus.loading));

      // Initialize the notification service
      await notificationsService.initialize();

      // Load saved configuration
      final configResult = await loadNotificationConfigUseCase(NoParams());

      // Check current permissions
      final permissionsResult =
          await notificationsService.areNotificationsAvailable();

      await configResult.fold(
        (failure) async {
          AppLogger.error(
              'Failed to load notification config: ${failure.message}');
          emit(state.copyWith(
            status: NotificationStatus.error,
            errorMessage: failure.message,
          ));
        },
        (config) async {
          final hasPermissions = permissionsResult.getOrElse(() => false);

          // Handle migration from file-based to Base64 storage
          var finalConfig = config;
          if (config.imagePath != null && config.imageBase64Data == null) {
            AppLogger.info('Migrating legacy image configuration to Base64');
            final migrationResult = await _migrateImagePathToBase64(config);
            migrationResult.fold(
              (failure) {
                AppLogger.warning('Failed to migrate image: ${failure.message}');
                // Continue with original config
              },
              (migratedConfig) {
                finalConfig = migratedConfig;
                AppLogger.info('Successfully migrated image to Base64 storage');
                // Save the migrated configuration
                add(SaveNotificationConfiguration(migratedConfig));
              },
            );
          }

          emit(state.copyWith(
            status: NotificationStatus.loaded,
            config: finalConfig,
            hasPermissions: hasPermissions,
          ));

          AppLogger.info(
              'Notification configuration loaded: ${finalConfig.toString()}');

          // Clean up temporary notification files (run in background)
          _cleanupTempNotificationFiles();
        },
      );
    } catch (e, stackTrace) {
      AppLogger.error(
          'Error loading notification configuration', e, stackTrace);
      emit(state.copyWith(
        status: NotificationStatus.error,
        errorMessage: 'Failed to load notification configuration: $e',
      ));
    }
  }

  Future<void> _onSaveNotificationConfiguration(
    SaveNotificationConfiguration event,
    Emitter<LocalNotificationsState> emit,
  ) async {
    try {
      emit(state.copyWith(status: NotificationStatus.loading));

      final result = await saveNotificationConfigUseCase(
        SaveNotificationConfigParams(config: event.config),
      );

      await result.fold(
        (failure) async {
          AppLogger.error(
              'Failed to save notification config: ${failure.message}');
          emit(state.copyWith(
            status: NotificationStatus.error,
            errorMessage: failure.message,
          ));
        },
        (_) async {
          emit(state.copyWith(
            status: NotificationStatus.loaded,
            config: event.config,
          ));

          AppLogger.info(
              'Notification configuration saved: ${event.config.toString()}');
        },
      );
    } catch (e, stackTrace) {
      AppLogger.error('Error saving notification configuration', e, stackTrace);
      emit(state.copyWith(
        status: NotificationStatus.error,
        errorMessage: 'Failed to save notification configuration: $e',
      ));
    }
  }

  Future<void> _onUpdateNotificationTitle(
    UpdateNotificationTitle event,
    Emitter<LocalNotificationsState> emit,
  ) async {
    final updatedConfig = state.effectiveConfig.copyWith(title: event.title);
    add(SaveNotificationConfiguration(updatedConfig));
  }

  Future<void> _onToggleNotificationsEnabled(
    ToggleNotificationsEnabled event,
    Emitter<LocalNotificationsState> emit,
  ) async {
    final updatedConfig =
        state.effectiveConfig.copyWith(isEnabled: event.enabled);
    add(SaveNotificationConfiguration(updatedConfig));
  }

  Future<void> _onToggleForegroundNotifications(
    ToggleForegroundNotifications event,
    Emitter<LocalNotificationsState> emit,
  ) async {
    final updatedConfig = state.effectiveConfig
        .copyWith(showInForeground: event.showInForeground);
    add(SaveNotificationConfiguration(updatedConfig));
  }

  Future<void> _onRequestNotificationPermissions(
    RequestNotificationPermissions event,
    Emitter<LocalNotificationsState> emit,
  ) async {
    try {
      emit(state.copyWith(status: NotificationStatus.loading));

      final result = await requestNotificationPermissionsUseCase(NoParams());

      await result.fold(
        (failure) async {
          AppLogger.error(
              'Failed to request notification permissions: ${failure.message}');
          emit(state.copyWith(
            status: NotificationStatus.permissionDenied,
            errorMessage: failure.message,
          ));
        },
        (granted) async {
          emit(state.copyWith(
            status: granted
                ? NotificationStatus.permissionGranted
                : NotificationStatus.permissionDenied,
            hasPermissions: granted,
          ));

          AppLogger.info(
              'Notification permissions ${granted ? 'granted' : 'denied'}');
        },
      );
    } catch (e, stackTrace) {
      AppLogger.error(
          'Error requesting notification permissions', e, stackTrace);
      emit(state.copyWith(
        status: NotificationStatus.error,
        errorMessage: 'Failed to request notification permissions: $e',
      ));
    }
  }

  Future<void> _onShowTestNotification(
    ShowTestNotification event,
    Emitter<LocalNotificationsState> emit,
  ) async {
    try {
      if (!state.areNotificationsAvailable) {
        emit(state.copyWith(
          status: NotificationStatus.error,
          errorMessage: 'Notifications are not available',
        ));
        return;
      }

      final result = await notificationsService.showGeofenceNotification(
        geofenceId: 'test',
        geofenceName: 'Test Location',
        customTitle: state.effectiveConfig.title,
        isEntry: true,
      );

      await result.fold(
        (failure) async {
          AppLogger.error(
              'Failed to show test notification: ${failure.message}');
          emit(state.copyWith(
            status: NotificationStatus.error,
            errorMessage: failure.message,
          ));
        },
        (_) async {
          AppLogger.info('Test notification shown successfully');
        },
      );
    } catch (e, stackTrace) {
      AppLogger.error('Error showing test notification', e, stackTrace);
      emit(state.copyWith(
        status: NotificationStatus.error,
        errorMessage: 'Failed to show test notification: $e',
      ));
    }
  }

  Future<void> _onDismissAllNotifications(
    DismissAllNotifications event,
    Emitter<LocalNotificationsState> emit,
  ) async {
    try {
      final result = await notificationsService.dismissAllNotifications();

      await result.fold(
        (failure) async {
          AppLogger.error(
              'Failed to dismiss all notifications: ${failure.message}');
          emit(state.copyWith(
            status: NotificationStatus.error,
            errorMessage: failure.message,
          ));
        },
        (_) async {
          AppLogger.info('All notifications dismissed');
        },
      );
    } catch (e, stackTrace) {
      AppLogger.error('Error dismissing all notifications', e, stackTrace);
      emit(state.copyWith(
        status: NotificationStatus.error,
        errorMessage: 'Failed to dismiss all notifications: $e',
      ));
    }
  }

  Future<void> _onSelectNotificationImage(
    SelectNotificationImage event,
    Emitter<LocalNotificationsState> emit,
  ) async {
    try {
      emit(state.copyWith(status: NotificationStatus.loading));

      // Pick image from gallery
      final pickResult = await imageService.pickImageFromGallery();

      await pickResult.fold(
        (failure) async {
          if (failure is UserCancelledFailure) {
            // User cancelled, go back to previous state
            emit(state.copyWith(status: NotificationStatus.loaded));
            AppLogger.info('User cancelled image selection');
          } else {
            AppLogger.error('Failed to pick image: ${failure.message}');
            emit(state.copyWith(
              status: NotificationStatus.error,
              errorMessage: failure.message,
            ));
          }
        },
        (imageBase64Data) async {
          AppLogger.info('Image picked and converted to Base64 (${imageBase64Data.length} characters)');

          // Store in user preferences
          final saveResult = await userPreferencesService.setNotificationImageBase64(imageBase64Data);

          await saveResult.fold(
            (failure) async {
              AppLogger.error('Failed to save Base64 image data: ${failure.message}');
              emit(state.copyWith(
                status: NotificationStatus.error,
                errorMessage: failure.message,
              ));
            },
            (_) async {
              AppLogger.info('Image Base64 data saved to user preferences');

              // Clear any old file-based image data
              final currentImagePath = state.effectiveConfig.imagePath;
              if (currentImagePath != null) {
                // Try to delete old file if it exists
                if (currentImagePath.contains('/')) {
                  await imageService.deleteImage(currentImagePath);
                  AppLogger.info('Deleted old image file: $currentImagePath');
                } else {
                  // Legacy config with filename only - try to resolve it
                  final currentImagePathResult = await imageService.getImagePath(currentImagePath);
                  await currentImagePathResult.fold(
                    (failure) async {
                      AppLogger.warning('Could not find old image to delete: ${failure.message}');
                    },
                    (resolvedPath) async {
                      await imageService.deleteImage(resolvedPath);
                      AppLogger.info('Deleted old image file (resolved): $resolvedPath');
                    },
                  );
                }
              }

              // Update configuration with Base64 data and clear legacy path
              final updatedConfig = state.effectiveConfig.copyWith(
                imageBase64Data: imageBase64Data,
                clearImagePath: true, // Clear legacy file path
              );

              add(SaveNotificationConfiguration(updatedConfig));
            },
          );
        },
      );
    } catch (e, stackTrace) {
      AppLogger.error('Error selecting notification image', e, stackTrace);
      emit(state.copyWith(
        status: NotificationStatus.error,
        errorMessage: 'Failed to select image: $e',
      ));
    }
  }

  Future<void> _onRemoveNotificationImage(
    RemoveNotificationImage event,
    Emitter<LocalNotificationsState> emit,
  ) async {
    try {
      // Clear Base64 data from user preferences
      final clearResult = await userPreferencesService.clearNotificationImageBase64();
      clearResult.fold(
        (failure) {
          AppLogger.warning('Failed to clear Base64 image data: ${failure.message}');
        },
        (_) {
          AppLogger.info('Base64 image data cleared from user preferences');
        },
      );

      // Also clean up any legacy file
      final currentImageFileName = state.effectiveConfig.imagePath;
      if (currentImageFileName != null) {
        // Get full path from filename and delete the image file
        final currentImagePathResult = await imageService.getImagePath(currentImageFileName);
        await currentImagePathResult.fold(
          (failure) async {
            AppLogger.warning('Could not find legacy image to delete: ${failure.message}');
          },
          (currentImagePath) async {
            final deleteResult = await imageService.deleteImage(currentImagePath);
            deleteResult.fold(
              (failure) => AppLogger.warning('Failed to delete legacy image file: ${failure.message}'),
              (_) => AppLogger.info('Legacy image file deleted successfully'),
            );
          },
        );
      }

      // Update configuration to remove both image path and Base64 data
      final updatedConfig = state.effectiveConfig.copyWith(
        clearImagePath: true,
        clearImageBase64Data: true,
      );

      add(SaveNotificationConfiguration(updatedConfig));
    } catch (e, stackTrace) {
      AppLogger.error('Error removing notification image', e, stackTrace);
      emit(state.copyWith(
        status: NotificationStatus.error,
        errorMessage: 'Failed to remove image: $e',
      ));
    }
  }

  /// Migrate legacy image path to Base64 storage
  Future<Either<Failure, NotificationConfig>> _migrateImagePathToBase64(NotificationConfig config) async {
    try {
      if (config.imagePath == null) {
        return Right(config);
      }

      AppLogger.info('Migrating image path to Base64: ${config.imagePath}');

      // Get the full path to the image file
      final imagePathResult = await imageService.getImagePath(config.imagePath!);
      return await imagePathResult.fold(
        (failure) async {
          AppLogger.error('Failed to resolve image path for migration: ${failure.message}');
          return Left(failure);
        },
        (fullImagePath) async {
          // Convert file to Base64
          final base64Result = await imageService.convertFileToBase64(fullImagePath);
          return await base64Result.fold(
            (failure) async {
              AppLogger.error('Failed to convert image to Base64: ${failure.message}');
              return Left(failure);
            },
            (base64Data) async {
              // Store in user preferences
              final saveResult = await userPreferencesService.setNotificationImageBase64(base64Data);
              return saveResult.fold(
                (failure) {
                  AppLogger.error('Failed to save Base64 data during migration: ${failure.message}');
                  return Left(failure);
                },
                (_) {
                  AppLogger.info('Successfully migrated image to Base64 storage');
                  
                  // Create updated config with Base64 data and cleared legacy path
                  final updatedConfig = config.copyWith(
                    imageBase64Data: base64Data,
                    clearImagePath: true,
                  );
                  
                  // Clean up the old file
                  imageService.deleteImage(fullImagePath);
                  
                  return Right(updatedConfig);
                },
              );
            },
          );
        },
      );
    } catch (e, stackTrace) {
      AppLogger.error('Error during image migration', e, stackTrace);
      return Left(CacheFailure(message: 'Migration failed: $e'));
    }
  }

  /// Clean up temporary notification files in the background
  void _cleanupTempNotificationFiles() async {
    try {
      if (imageService is NotificationImageServiceImpl) {
        final serviceImpl = imageService as NotificationImageServiceImpl;
        final result = await serviceImpl.cleanupTempNotificationFiles();
        result.fold(
          (failure) {
            AppLogger.warning('Failed to cleanup temporary notification files: ${failure.message}');
          },
          (deletedCount) {
            if (deletedCount > 0) {
              AppLogger.info('Cleaned up $deletedCount temporary notification files');
            }
          },
        );
      }
    } catch (e) {
      AppLogger.warning('Error during temporary file cleanup: $e');
    }
  }
}
