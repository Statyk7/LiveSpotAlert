import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:path/path.dart' as path;
import '../../../../shared/base_domain/use_case.dart';
import '../../../../shared/utils/logger.dart';
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

          emit(state.copyWith(
            status: NotificationStatus.loaded,
            config: config,
            hasPermissions: hasPermissions,
          ));

          AppLogger.info(
              'Notification configuration loaded: ${config.toString()}');
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
        (imagePath) async {
          AppLogger.info('Image picked: $imagePath');

          // Save to persistent storage
          final saveResult = await imageService.saveImageToPersistentStorage(imagePath);

          await saveResult.fold(
            (failure) async {
              AppLogger.error('Failed to save image: ${failure.message}');
              emit(state.copyWith(
                status: NotificationStatus.error,
                errorMessage: failure.message,
              ));
            },
            (savedPath) async {
              AppLogger.info('Image saved to: $savedPath');

              // Delete old image if it exists
              final currentImageFileName = state.effectiveConfig.imagePath;
              if (currentImageFileName != null) {
                final currentImagePathResult = await imageService.getImagePath(currentImageFileName);
                await currentImagePathResult.fold(
                  (failure) async {
                    AppLogger.warning('Could not find old image to delete: ${failure.message}');
                  },
                  (currentImagePath) async {
                    await imageService.deleteImage(currentImagePath);
                  },
                );
              }

              // Extract filename from saved path to store in config
              final fileName = path.basename(savedPath);
              AppLogger.info('Extracted filename from saved path: $fileName');
              AppLogger.info('Full saved path was: $savedPath');
              
              // Update configuration with filename only (not full path)
              final updatedConfig = state.effectiveConfig.copyWith(
                imagePath: fileName,
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
      final currentImageFileName = state.effectiveConfig.imagePath;
      
      if (currentImageFileName != null) {
        // Get full path from filename and delete the image file
        final currentImagePathResult = await imageService.getImagePath(currentImageFileName);
        await currentImagePathResult.fold(
          (failure) async {
            AppLogger.warning('Could not find image to delete: ${failure.message}');
          },
          (currentImagePath) async {
            final deleteResult = await imageService.deleteImage(currentImagePath);
            deleteResult.fold(
              (failure) => AppLogger.warning('Failed to delete image file: ${failure.message}'),
              (_) => AppLogger.info('Image file deleted successfully'),
            );
          },
        );
      }

      // Update configuration to remove image path
      final updatedConfig = state.effectiveConfig.copyWith(
        clearImagePath: true,
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
}
