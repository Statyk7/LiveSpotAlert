import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../shared/ui_kit/colors.dart';
import '../../../../shared/ui_kit/text_styles.dart';
import '../controllers/local_notifications_bloc.dart';
import '../controllers/local_notifications_event.dart';
import '../controllers/local_notifications_state.dart';
import 'notification_configuration_widget.dart';

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
          elevation: 4,
          color: AppColors.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
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
                      onPressed: onConfigurePressed ?? () => _showConfiguration(context),
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
                      color: AppColors.error.withValues(alpha: 26),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.error.withValues(alpha: 77)),
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
                      color: AppColors.warning.withValues(alpha: 26),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.warning.withValues(alpha: 77)),
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

  Widget _buildConfigDetails(BuildContext context, LocalNotificationsState state, config) {
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

        // Enabled status
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

  Widget _buildActionButtons(BuildContext context, LocalNotificationsState state) {
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
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => NotificationConfigurationWidget(
          onSave: () => Navigator.of(context).pop(),
          onCancel: () => Navigator.of(context).pop(),
        ),
      ),
    );
  }

  void _requestPermissions(BuildContext context) {
    context.read<LocalNotificationsBloc>().add(const RequestNotificationPermissions());
  }

  void _showTestNotification(BuildContext context) {
    context.read<LocalNotificationsBloc>().add(const ShowTestNotification());
  }
}