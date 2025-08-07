import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../shared/ui_kit/colors.dart';
import '../../../../shared/ui_kit/text_styles.dart';
import '../../../../shared/ui_kit/widgets/app_buttons.dart';
import '../../../geofencing/presentation/controllers/geofencing_bloc.dart';
import '../../../geofencing/presentation/controllers/geofencing_state.dart';
import '../../domain/models/notification_payload.dart';
import '../../../../i18n/translations.g.dart';

/// Card widget for previewing the notification display screen
class NotificationPreviewCard extends StatelessWidget {
  const NotificationPreviewCard({
    super.key,
    this.title,
  });

  final String? title;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<GeofencingBloc, GeofencingState>(
      builder: (context, state) {
        return Card(
          elevation: 2,
          color: AppColors.surface,
          shadowColor: Colors.black12,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header with icon and title
                Row(
                  children: [
                    Icon(
                      Icons.preview,
                      color: AppColors.primary,
                      size: 24,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        title ?? t.notifications.preview.title,
                        style: AppTextStyles.h4,
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 12),
                
                // Description text
                Text(
                  t.notifications.preview.description,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                
                const SizedBox(height: 16),
                
                // Preview buttons
                _buildPreviewButtons(context, state),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildPreviewButtons(BuildContext context, GeofencingState state) {
    final hasGeofences = state.geofences.isNotEmpty;
    
    if (!hasGeofences) {
      return _buildNoGeofenceMessage();
    }
    
    final currentGeofence = state.geofences.first;
    
    return Column(
      children: [
        // Entry preview button
        AppOutlinedButton(
          text: t.notifications.preview.entryButton,
          onPressed: () => _showPreview(
            context, 
            currentGeofence.id, 
            GeofenceEventType.entry,
          ),
          icon: Icons.login,
          isFullWidth: true,
        ),
        
        const SizedBox(height: 8),
        
        // Exit preview button
        AppOutlinedButton(
          text: t.notifications.preview.exitButton,
          onPressed: () => _showPreview(
            context, 
            currentGeofence.id, 
            GeofenceEventType.exit,
          ),
          icon: Icons.logout,
          isFullWidth: true,
        ),
        
        const SizedBox(height: 12),
        
        // Info about current geofence
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            //color: AppColors.info.withValues(alpha: 26),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Icon(
                Icons.info_outline,
                color: AppColors.info,
                size: 16,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  t.notifications.preview.info(name: currentGeofence.name),
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.info,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildNoGeofenceMessage() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        // color: AppColors.warning.withValues(alpha: 26),
        borderRadius: BorderRadius.circular(8),
        // border: Border.all(color: AppColors.warning.withValues(alpha: 77)),
      ),
      child: Row(
        children: [
          Icon(
            Icons.warning,
            color: AppColors.warning,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  t.notifications.preview.noGeofence,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.warning,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  t.notifications.preview.noGeofenceMessage,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.warning,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showPreview(BuildContext context, String geofenceId, GeofenceEventType eventType) {
    final payload = NotificationPayload(
      eventType: eventType,
      geofenceId: geofenceId,
    );
    
    final payloadString = payload.toPayloadString();
    context.push('/notification-display?payload=${Uri.encodeComponent(payloadString)}');
  }
}