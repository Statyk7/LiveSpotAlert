import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../shared/ui_kit/colors.dart';
import '../../../../shared/ui_kit/text_styles.dart';
import '../../../../shared/utils/constants.dart';
import '../../../geofencing/presentation/controllers/geofencing_bloc.dart';
import '../../../geofencing/presentation/controllers/geofencing_state.dart';
import '../../../geofencing/domain/models/geofence.dart';
import '../controllers/local_notifications_bloc.dart';
import '../controllers/local_notifications_state.dart';
import '../../domain/models/notification_payload.dart';

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
    final geofenceName = geofence?.name ?? 'Unknown Location';
    final eventDescription = payload.eventType.actionDescription;
    
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
    final imageFileName = state.effectiveConfig.imagePath;
    
    debugPrint('NotificationDisplayScreen: Image filename from config: $imageFileName');
    
    if (imageFileName == null) {
      debugPrint('NotificationDisplayScreen: No image configured, showing placeholder');
      return _buildPlaceholderImage();
    }
    
    return FutureBuilder<String?>(
      future: _getImagePath(context, imageFileName),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }
        
        if (snapshot.hasData && snapshot.data != null) {
          debugPrint('NotificationDisplayScreen: Attempting to load image from: ${snapshot.data}');
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
                debugPrint('NotificationDisplayScreen: Image file exists, displaying');
                return Image.file(
                  imageFile,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) {
                    debugPrint('NotificationDisplayScreen: Error loading image: $error');
                    return _buildPlaceholderImage();
                  },
                );
              } else {
                debugPrint('NotificationDisplayScreen: Image file does not exist at path: ${snapshot.data}');
                return _buildPlaceholderImage();
              }
            },
          );
        }
        
        return _buildPlaceholderImage();
      },
    );
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
            'No image configured',
            style: AppTextStyles.h4.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Configure an image in notification settings',
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
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: () => _dismissScreen(context),
        label: const Text('Dismiss', style: AppTextStyles.h4),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  /// Helper method to get image path from filename
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