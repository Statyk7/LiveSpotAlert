import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../shared/di/get_it_extensions.dart';
import '../../../../shared/services/analytics_service.dart';
import '../../../../shared/ui_kit/colors.dart';
import '../../../../shared/ui_kit/text_styles.dart';
import '../controllers/local_notifications_bloc.dart';
import '../controllers/local_notifications_event.dart';
import '../controllers/local_notifications_state.dart';

/// Card widget displaying notification configuration and controls
class NotificationConfigCard extends StatelessWidget {
  const NotificationConfigCard({
    super.key,
    this.title = 'Local Notifications',
    this.onConfigurePressed,
  });

  final String title;
  final VoidCallback? onConfigurePressed;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LocalNotificationsBloc, LocalNotificationsState>(
      builder: (context, state) {
        final config = state.effectiveConfig;

        return Card(
          elevation: 2,
          color: AppColors.surface,
          shadowColor: Colors.black12,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header with title and configure button
                Row(
                  children: [
                    Icon(
                      state.areNotificationsAvailable
                          ? Icons.notifications_active
                          : Icons.notifications_off,
                      color: state.areNotificationsAvailable
                          ? AppColors.success
                          : AppColors.textSecondary,
                      size: 28,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: AppTextStyles.h4,
                          ),
                          Text(
                            _getStatusText(state),
                            style: AppTextStyles.caption.copyWith(
                              color: _getStatusColor(state),
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: onConfigurePressed ??
                          () => _showConfiguration(context),
                      icon: const Icon(Icons.edit),
                      tooltip: 'Configure Notification',
                      style: IconButton.styleFrom(
                        foregroundColor: AppColors.primary,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Configuration details
                _buildConfigDetails(context, state, config),

                // Error message if present
                if (state.hasError && state.errorMessage != null) ...[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      //color: AppColors.error.withValues(alpha: 26),
                      borderRadius: BorderRadius.circular(8),
                      // border: Border.all(
                      //     color: AppColors.error.withValues(alpha: 77)),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.error, color: AppColors.error, size: 20),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            state.errorMessage!,
                            style: AppTextStyles.bodySmall.copyWith(
                              color: AppColors.error,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                // Permission request if needed
                if (!state.hasPermissions && config.isEnabled) ...[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      //color: AppColors.warning.withValues(alpha: 26),
                      borderRadius: BorderRadius.circular(8),
                      // border: Border.all(
                      //     color: AppColors.warning.withValues(alpha: 77)),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.warning, color: AppColors.warning, size: 20),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Notification permissions required',
                            style: AppTextStyles.bodySmall.copyWith(
                              color: AppColors.warning,
                            ),
                          ),
                        ),
                        TextButton(
                          onPressed: () => _requestPermissions(context),
                          child: Text(
                            'Grant',
                            style: TextStyle(color: AppColors.warning),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                // Action buttons
                const SizedBox(height: 16),
                _buildActionButtons(context, state),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildConfigDetails(
      BuildContext context, LocalNotificationsState state, config) {
    return Column(
      children: [
        // Title configuration
        Row(
          children: [
            Icon(Icons.title, color: AppColors.info, size: 18),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Title: "${config.title}"',
                style: AppTextStyles.bodyMedium,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),

        // Image configuration
        Row(
          children: [
            Icon(Icons.image, color: AppColors.info, size: 18),
            const SizedBox(width: 8),
            Expanded(
              child: config.hasImageData
                  ? Row(
                      children: [
                        Text(
                          'Custom image: ',
                          style: AppTextStyles.bodyMedium,
                        ),
                        Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(color: AppColors.textHint),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(3),
                            child: _buildImagePreview(context, config),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Selected',
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: AppColors.success,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    )
                  : Text(
                      'Image: Not selected',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
            ),
          ],
        ),

        // Enabled status (commented out)
        // Row(
        //   children: [
        //     Icon(Icons.toggle_on, color: AppColors.info, size: 18),
        //     const SizedBox(width: 8),
        //     Text(
        //       'Enabled: ${config.isEnabled ? "Yes" : "No"}',
        //       style: AppTextStyles.bodyMedium,
        //     ),
        //   ],
        // ),
      ],
    );
  }

  Widget _buildActionButtons(
      BuildContext context, LocalNotificationsState state) {
    return Row(
      children: [
        // Test notification button
        if (state.areNotificationsAvailable)
          Expanded(
            child: OutlinedButton.icon(
              onPressed: () => _showTestNotification(context),
              icon: const Icon(Icons.notifications),
              label: const Text('Test Notification'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.primary,
                side: BorderSide(color: AppColors.primary),
              ),
            ),
          ),

        if (state.areNotificationsAvailable) const SizedBox(width: 12),
      ],
    );
  }

  String _getStatusText(LocalNotificationsState state) {
    if (state.isLoading) return 'Loading...';
    if (state.hasError) return 'Error occurred';
    if (!state.effectiveConfig.isEnabled) return 'Notifications disabled';
    if (!state.hasPermissions) return 'Permissions required';
    return 'Notifications enabled';
  }

  Color _getStatusColor(LocalNotificationsState state) {
    if (state.isLoading) return AppColors.textSecondary;
    if (state.hasError) return AppColors.error;
    if (!state.effectiveConfig.isEnabled) return AppColors.textSecondary;
    if (!state.hasPermissions) return AppColors.warning;
    return AppColors.success;
  }

  void _showConfiguration(BuildContext context) {
    getIt<AnalyticsService>().screen(screenName: "notification-configuration");

    context.push('/notification-config');
  }

  void _requestPermissions(BuildContext context) {
    context
        .read<LocalNotificationsBloc>()
        .add(const RequestNotificationPermissions());
  }

  void _showTestNotification(BuildContext context) {
    getIt<AnalyticsService>().event(eventName: "test_notification_1");
    context.read<LocalNotificationsBloc>().add(const ShowTestNotification());
  }

  Widget _buildImagePreview(BuildContext context, config) {
    // Prefer Base64 data over legacy file path
    if (config.imageBase64Data != null) {
      return _buildBase64ImagePreview(context, config.imageBase64Data!);
    } else if (config.imagePath != null) {
      return _buildFileImagePreview(context, config.imagePath!);
    } else {
      return _buildErrorImagePreview();
    }
  }

  Widget _buildBase64ImagePreview(BuildContext context, String base64Data) {
    try {
      final bloc = context.read<LocalNotificationsBloc>();
      final imageService = bloc.imageService;
      
      final decodeResult = imageService.decodeBase64Image(base64Data);
      return decodeResult.fold(
        (failure) {
          return _buildErrorImagePreview();
        },
        (bytes) {
          return Image.memory(
            Uint8List.fromList(bytes),
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return _buildErrorImagePreview();
            },
          );
        },
      );
    } catch (e) {
      return _buildErrorImagePreview();
    }
  }

  Widget _buildFileImagePreview(BuildContext context, String fileName) {
    return FutureBuilder<String?>(
      future: _getImagePath(context, fileName),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Container(
            color: AppColors.surface,
            child: const Center(
              child: SizedBox(
                width: 12,
                height: 12,
                child: CircularProgressIndicator(strokeWidth: 1),
              ),
            ),
          );
        }
        
        if (snapshot.hasData && snapshot.data != null) {
          return Image.file(
            File(snapshot.data!),
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return _buildErrorImagePreview();
            },
          );
        }
        
        return _buildErrorImagePreview();
      },
    );
  }

  Widget _buildErrorImagePreview() {
    return Container(
      color: AppColors.surface,
      child: Icon(
        Icons.broken_image,
        color: AppColors.textSecondary,
        size: 16,
      ),
    );
  }

  Future<String?> _getImagePath(BuildContext context, String fileName) async {
    final bloc = context.read<LocalNotificationsBloc>();
    final imageService = bloc.imageService;
    
    final result = await imageService.getImagePath(fileName);
    return result.fold(
      (failure) => null,
      (path) => path,
    );
  }
}
