import 'package:flutter/material.dart';
import '../../../../shared/ui_kit/colors.dart';
import '../../../../shared/ui_kit/text_styles.dart';
import '../../domain/models/geofence.dart';
import '../../domain/models/geofence_status.dart';
import '../../domain/models/location_event.dart';

class GeofenceCard extends StatelessWidget {
  const GeofenceCard({
    super.key,
    required this.geofence,
    this.status,
    this.recentEvents = const [],
    this.isSelected = false,
    this.onTap,
    this.onToggleActive,
    // onDelete removed - single geofence MVP doesn't need delete
  });

  final Geofence geofence;
  final GeofenceStatus? status;
  final List<LocationEvent> recentEvents;
  final bool isSelected;
  final VoidCallback? onTap;
  final VoidCallback? onToggleActive;
  // onDelete removed - single geofence MVP doesn't need delete

  @override
  Widget build(BuildContext context) {
    final bool isUserInside = status?.isUserInside ?? false;
    final double? distanceToCenter = status?.distanceToCenter;

    return Card(
      elevation: isSelected ? 8 : 4,
      color: AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isSelected ? AppColors.primary : Colors.transparent,
          width: 2,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Row
              Row(
                children: [
                  // Status Indicator
                  Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _getStatusColor(),
                    ),
                  ),
                  const SizedBox(width: 12),

                  // Geofence Name
                  Expanded(
                    child: Text(
                      geofence.name,
                      style: AppTextStyles.h4,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),

                  // Actions
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Active Toggle
                      InkWell(
                        onTap: onToggleActive,
                        borderRadius: BorderRadius.circular(20),
                        child: Padding(
                          padding: const EdgeInsets.all(4),
                          child: Icon(
                            geofence.isActive
                                ? Icons.notifications_active
                                : Icons.notifications_off,
                            size: 20,
                            color: geofence.isActive
                                ? AppColors.geofenceActive
                                : AppColors.geofenceInactive,
                          ),
                        ),
                      ),
                      // Delete button removed - single geofence MVP doesn't need delete
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // Geofence Details
              Row(
                children: [
                  Icon(
                    Icons.radio_button_unchecked,
                    size: 16,
                    color: AppColors.textSecondary,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '${geofence.radius.toInt()}m radius',
                    style: AppTextStyles.bodySmall
                        .copyWith(color: AppColors.textSecondary),
                  ),
                  const SizedBox(width: 16),
                  if (distanceToCenter != null) ...[
                    Icon(
                      Icons.near_me,
                      size: 16,
                      color: AppColors.textSecondary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${distanceToCenter.toInt()}m away',
                      style: AppTextStyles.bodySmall
                          .copyWith(color: AppColors.textSecondary),
                    ),
                  ],
                ],
              ),

              // User Status
              if (isUserInside || distanceToCenter != null) ...[
                const SizedBox(height: 8),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: isUserInside
                        ? AppColors.success.withValues(alpha: 26)
                        : AppColors.info.withValues(alpha: 26),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isUserInside ? AppColors.success : AppColors.info,
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        isUserInside
                            ? Icons.location_on
                            : Icons.location_searching,
                        size: 12,
                        color:
                            isUserInside ? AppColors.success : AppColors.info,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        isUserInside ? 'Inside' : 'Outside',
                        style: AppTextStyles.caption.copyWith(
                          color:
                              isUserInside ? AppColors.success : AppColors.info,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              // Description
              if (geofence.description != null &&
                  geofence.description!.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  geofence.description!,
                  style: AppTextStyles.bodySmall
                      .copyWith(color: AppColors.textSecondary),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],

              // Recent Activity
              if (recentEvents.isNotEmpty) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Recent Activity',
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      ...recentEvents.take(2).map((event) => Padding(
                            padding: const EdgeInsets.only(bottom: 2),
                            child: Row(
                              children: [
                                Icon(
                                  _getEventIcon(event.eventType),
                                  size: 12,
                                  color: _getEventColor(event.eventType),
                                ),
                                const SizedBox(width: 6),
                                Expanded(
                                  child: Text(
                                    '${_getEventText(event.eventType)} ${_formatTime(event.timestamp)}',
                                    style: AppTextStyles.caption,
                                  ),
                                ),
                              ],
                            ),
                          )),
                    ],
                  ),
                ),
              ],

              // Media Indicator
              if (geofence.mediaItemId != null) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(
                      Icons.image,
                      size: 16,
                      color: AppColors.secondary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Has attached media',
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.secondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Color _getStatusColor() {
    if (!geofence.isActive) {
      return AppColors.geofenceInactive;
    }

    if (status?.isUserInside == true) {
      return AppColors.success;
    }

    return AppColors.geofenceActive;
  }

  IconData _getEventIcon(LocationEventType eventType) {
    switch (eventType) {
      case LocationEventType.enter:
        return Icons.login;
      case LocationEventType.exit:
        return Icons.logout;
      case LocationEventType.dwell:
        return Icons.access_time;
    }
  }

  Color _getEventColor(LocationEventType eventType) {
    switch (eventType) {
      case LocationEventType.enter:
        return AppColors.success;
      case LocationEventType.exit:
        return AppColors.warning;
      case LocationEventType.dwell:
        return AppColors.info;
    }
  }

  String _getEventText(LocationEventType eventType) {
    switch (eventType) {
      case LocationEventType.enter:
        return 'Entered';
      case LocationEventType.exit:
        return 'Exited';
      case LocationEventType.dwell:
        return 'Dwelling';
    }
  }

  String _formatTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 1) {
      return 'just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else {
      return '${difference.inDays}d ago';
    }
  }
}
