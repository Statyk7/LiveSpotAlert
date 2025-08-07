import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../shared/ui_kit/colors.dart';
import '../../../../shared/ui_kit/text_styles.dart';
import '../../../../shared/ui_kit/widgets/app_buttons.dart';
import '../../../../shared/utils/constants.dart';
import '../../../geofencing/presentation/controllers/geofencing_bloc.dart';
import '../../../geofencing/presentation/controllers/geofencing_state.dart';
import '../../../geofencing/domain/models/geofence.dart';
import '../controllers/local_notifications_bloc.dart';
import '../controllers/local_notifications_state.dart';
import '../../domain/models/notification_payload.dart';
import '../../../../i18n/translations.g.dart';

/// Full-screen widget displayed when notification is tapped
class NotificationDisplayScreen extends StatelessWidget {
  const NotificationDisplayScreen({
    super.key,
    required this.payload,
  });

  /// The parsed notification payload containing geofence and event data
  final NotificationPayload payload;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          AppConstants.appName,
          style: AppTextStyles.h3.copyWith(color: Colors.white),
        ),
        backgroundColor: AppColors.primary,
        leading: IconButton(
          onPressed: () => _dismissScreen(context),
          icon: const Icon(Icons.close, color: Colors.white),
        ),
      ),
      body: BlocBuilder<GeofencingBloc, GeofencingState>(
        builder: (context, geofencingState) {
          return BlocBuilder<LocalNotificationsBloc, LocalNotificationsState>(
            builder: (context, notificationState) {
              // Find the geofence by ID
              final geofence = _findGeofenceById(geofencingState, payload.geofenceId);
              
              return SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    children: [
                      // Geofence name at top
                      _buildGeofenceHeader(geofence),
                      
                      const SizedBox(height: 24),
                      
                      // Notification image (center, expandable)
                      Expanded(
                        child: _buildNotificationImage(context, notificationState),
                      ),
                      
                      const SizedBox(height: 24),
                      
                      // Notification title
                      _buildNotificationTitle(notificationState, geofence),
                      
                      const SizedBox(height: 32),
                      
                      // Dismiss button at bottom
                      _buildDismissButton(context),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  /// Build the geofence name header
  Widget _buildGeofenceHeader(Geofence? geofence) {
    final geofenceName = geofence?.name ?? t.defaults.location.unknown;
    final eventDescription = payload.eventType == GeofenceEventType.entry 
        ? t.geofenceEvents.entry.actionDescription
        : t.geofenceEvents.exit.actionDescription;
    
    return Column(
      children: [
        Text(
          eventDescription,
          style: AppTextStyles.bodyLarge.copyWith(
            color: AppColors.textSecondary,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          geofenceName,
          style: AppTextStyles.h2.copyWith(
            fontWeight: FontWeight.bold,
            color: AppColors.primary,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  /// Build the notification image section
  Widget _buildNotificationImage(BuildContext context, LocalNotificationsState state) {
    final config = state.effectiveConfig;
    
    debugPrint('NotificationDisplayScreen: Config has image data: ${config.hasImageData}');
    debugPrint('NotificationDisplayScreen: Base64 data: ${config.imageBase64Data != null ? "present (${config.imageBase64Data!.length} chars)" : "null"}');
    debugPrint('NotificationDisplayScreen: Legacy image path: ${config.imagePath}');
    
    if (!config.hasImageData) {
      debugPrint('NotificationDisplayScreen: No image configured, showing placeholder');
      return _buildPlaceholderImage();
    }
    
    // Prefer Base64 data over legacy file path
    if (config.imageBase64Data != null) {
      debugPrint('NotificationDisplayScreen: Using Base64 image data');
      return _buildBase64Image(context, config.imageBase64Data!);
    } else if (config.imagePath != null) {
      debugPrint('NotificationDisplayScreen: Using legacy image path: ${config.imagePath}');
      return _buildLegacyFileImage(context, config.imagePath!);
    }
    
    return _buildPlaceholderImage();
  }

  /// Build placeholder image when no image is available
  Widget _buildPlaceholderImage() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.image_outlined,
            size: 64,
            color: AppColors.textSecondary,
          ),
          const SizedBox(height: 16),
          Text(
            t.notifications.display.placeholderTitle,
            style: AppTextStyles.h4.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            t.notifications.display.placeholderMessage,
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  /// Build the notification title section
  Widget _buildNotificationTitle(LocalNotificationsState state, Geofence? geofence) {
    final title = state.effectiveConfig.title;
    
    return Text(
      title,
      style: AppTextStyles.h3.copyWith(
        fontWeight: FontWeight.bold,
      ),
      textAlign: TextAlign.center,
    );
  }

  /// Build the dismiss button
  Widget _buildDismissButton(BuildContext context) {
    return PrimaryButton(
      text: t.common.dismiss,
      onPressed: () => _dismissScreen(context),
      isFullWidth: true,
      size: AppButtonSize.large,
    );
  }

  /// Build image from Base64 data
  Widget _buildBase64Image(BuildContext context, String base64Data) {
    try {
      final bloc = context.read<LocalNotificationsBloc>();
      final imageService = bloc.imageService;
      
      final decodeResult = imageService.decodeBase64Image(base64Data);
      return decodeResult.fold(
        (failure) {
          debugPrint('NotificationDisplayScreen: Failed to decode Base64 image: ${failure.message}');
          return _buildPlaceholderImage();
        },
        (bytes) {
          debugPrint('NotificationDisplayScreen: Successfully decoded Base64 image (${bytes.length} bytes)');
          return Image.memory(
            Uint8List.fromList(bytes),
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) {
              debugPrint('NotificationDisplayScreen: Error displaying Base64 image: $error');
              return _buildPlaceholderImage();
            },
          );
        },
      );
    } catch (e) {
      debugPrint('NotificationDisplayScreen: Exception with Base64 image: $e');
      return _buildPlaceholderImage();
    }
  }

  /// Build image from legacy file path
  Widget _buildLegacyFileImage(BuildContext context, String imageFileName) {
    return FutureBuilder<String?>(
      future: _getImagePath(context, imageFileName),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }
        
        if (snapshot.hasData && snapshot.data != null) {
          debugPrint('NotificationDisplayScreen: Attempting to load legacy image from: ${snapshot.data}');
          final imageFile = File(snapshot.data!);
          return FutureBuilder<bool>(
            future: imageFile.exists(),
            builder: (context, existsSnapshot) {
              if (existsSnapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }
              
              if (existsSnapshot.hasData && existsSnapshot.data == true) {
                debugPrint('NotificationDisplayScreen: Legacy image file exists, displaying');
                return Image.file(
                  imageFile,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) {
                    debugPrint('NotificationDisplayScreen: Error loading legacy image: $error');
                    return _buildPlaceholderImage();
                  },
                );
              } else {
                debugPrint('NotificationDisplayScreen: Legacy image file does not exist at path: ${snapshot.data}');
                return _buildPlaceholderImage();
              }
            },
          );
        }
        
        return _buildPlaceholderImage();
      },
    );
  }

  /// Helper method to get image path from filename (legacy support)
  Future<String?> _getImagePath(BuildContext context, String fileName) async {
    try {
      final bloc = context.read<LocalNotificationsBloc>();
      final imageService = bloc.imageService;
      
      final result = await imageService.getImagePath(fileName);
      return result.fold(
        (failure) {
          debugPrint('NotificationDisplayScreen: Failed to get image path for $fileName: ${failure.message}');
          return null;
        },
        (path) {
          debugPrint('NotificationDisplayScreen: Successfully got image path: $path');
          return path;
        },
      );
    } catch (e) {
      debugPrint('NotificationDisplayScreen: Exception getting image path: $e');
      return null;
    }
  }

  /// Helper method to find geofence by ID
  Geofence? _findGeofenceById(GeofencingState state, String geofenceId) {
    if (state.geofences.isEmpty) {
      return null;
    }
    
    try {
      return state.geofences.firstWhere((geofence) => geofence.id == geofenceId);
    } catch (e) {
      return null;
    }
  }

  /// Handle dismissing the screen safely
  void _dismissScreen(BuildContext context) {
    // Check if we can pop the current route
    if (context.canPop()) {
      context.pop();
    } else {
      // If no previous route (e.g., opened from notification), go to main screen
      context.go('/main');
    }
  }
}