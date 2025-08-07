import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../shared/di/get_it_extensions.dart';
import '../../../../shared/services/analytics_service.dart';
import '../../../../shared/ui_kit/colors.dart';
import '../../../../shared/ui_kit/text_styles.dart';
import '../../../../shared/ui_kit/spacing.dart';
import '../../../../shared/ui_kit/widgets/app_buttons.dart';
import '../controllers/geofencing_bloc.dart';
import '../controllers/geofencing_event.dart';
import '../controllers/geofencing_state.dart';
import '../../domain/models/geofence.dart';
import '../../../../i18n/translations.g.dart';

/// Card widget displaying geofence configuration and controls
class GeofenceConfigCard extends StatelessWidget {
  const GeofenceConfigCard({
    super.key,
    this.title,
    this.onConfigurePressed,
  });

  final String? title;
  final VoidCallback? onConfigurePressed;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<GeofencingBloc, GeofencingState>(
      builder: (context, state) {
        final geofence =
            state.geofences.isNotEmpty ? state.geofences.first : null;

        return Card(
          elevation: 2,
          color: AppColors.surface,
          shadowColor: Colors.black12,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: AppSpacing.cardPadding,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header with title and configure button
                Row(
                  children: [
                    Icon(
                      _getStatusIcon(state, geofence),
                      color: _getStatusColor(state, geofence),
                      size: 28,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            geofence?.name ?? (title ?? t.geofencing.config.title),
                            style: AppTextStyles.h4,
                          ),
                          Text(
                            _getStatusText(state, geofence),
                            style: AppTextStyles.caption.copyWith(
                              color: _getStatusColor(state, geofence),
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: onConfigurePressed ??
                          () => _showConfiguration(context),
                      icon: const Icon(Icons.edit),
                      tooltip: t.geofencing.config.configure,
                      style: IconButton.styleFrom(
                        foregroundColor: AppColors.primary,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Configuration details
                if (geofence != null)
                  _buildConfigDetails(context, state, geofence),

                // Error message if present
                if (state.status == GeofencingStatus.error &&
                    state.errorMessage != null) ...[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.error.withValues(alpha: 26),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                          color: AppColors.error.withValues(alpha: 77)),
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
                if (!state.hasLocationPermissions) ...[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.warning.withValues(alpha: 26),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                          color: AppColors.warning.withValues(alpha: 77)),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.warning, color: AppColors.warning, size: 20),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            t.monitoring.permissions.required,
                            style: AppTextStyles.bodySmall.copyWith(
                              color: AppColors.warning,
                            ),
                          ),
                        ),
                        AppTextButton(
                          text: t.common.grant,
                          onPressed: () => _requestPermissions(context),
                          size: AppButtonSize.small,
                        ),
                      ],
                    ),
                  ),
                ],

                // Action buttons removed - using only edit button in header
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildConfigDetails(
      BuildContext context, GeofencingState state, Geofence geofence) {
    final status = state.getGeofenceStatus(geofence.id);
    final isUserInside = status?.isUserInside ?? false;
    final distanceToCenter = status?.distanceToCenter;

    return Column(
      children: [
        // Location coordinates
        Row(
          children: [
            Icon(Icons.place, color: AppColors.info, size: 18),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                t.geofencing.map.locationInfo(
                  lat: geofence.latitude.toStringAsFixed(4), 
                  lng: geofence.longitude.toStringAsFixed(4)
                ),
                style: AppTextStyles.bodyMedium,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),

        // Radius
        Row(
          children: [
            Icon(Icons.radio_button_checked, color: AppColors.info, size: 18),
            const SizedBox(width: 8),
            Text(
              t.geofencing.config.radiusLabel(radius: geofence.radius.toInt()),
              style: AppTextStyles.bodyMedium,
            ),
          ],
        ),

        // Distance to center if available
        if (distanceToCenter != null) ...[
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(Icons.near_me, color: AppColors.info, size: 18),
              const SizedBox(width: 8),
              Text(
                t.geofencing.status.distance(distance: distanceToCenter.toInt()),
                style: AppTextStyles.bodyMedium,
              ),
            ],
          ),
        ],

        // User status
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isUserInside ? AppColors.success : AppColors.info,
              width: 1,
            ),
          ),
          child: Row(
            children: [
              Icon(
                isUserInside ? Icons.location_on : Icons.location_off,
                size: 18,
                color: isUserInside ? AppColors.success : AppColors.info,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  isUserInside
                      ? t.geofencing.status.youAreInside
                      : t.geofencing.status.youAreOutside,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: isUserInside ? AppColors.success : AppColors.info,
                    fontWeight: FontWeight.w500,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 2,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // Action buttons removed - using only edit button in header for simpler UI

  IconData _getStatusIcon(GeofencingState state, Geofence? geofence) {
    if (geofence == null) return Icons.location_disabled;
    if (!geofence.isActive) return Icons.location_off;

    final status = state.getGeofenceStatus(geofence.id);
    if (status?.isUserInside == true) {
      return Icons.location_on;
    }

    return Icons.location_searching;
  }

  Color _getStatusColor(GeofencingState state, Geofence? geofence) {
    if (state.status == GeofencingStatus.loading) {
      return AppColors.textSecondary;
    }
    if (state.status == GeofencingStatus.error) return AppColors.error;
    if (geofence == null) return AppColors.textSecondary;
    if (!geofence.isActive) return AppColors.textSecondary;

    final status = state.getGeofenceStatus(geofence.id);
    if (status?.isUserInside == true) {
      return AppColors.success;
    }

    return AppColors.geofenceActive;
  }

  String _getStatusText(GeofencingState state, Geofence? geofence) {
    if (state.status == GeofencingStatus.loading) return t.geofencing.status.loading;
    if (state.status == GeofencingStatus.error) return t.geofencing.status.error;
    if (geofence == null) return t.geofencing.config.noConfigured;
    if (!geofence.isActive) return t.geofencing.status.inactive;

    final status = state.getGeofenceStatus(geofence.id);
    if (status?.isUserInside == true) {
      return t.geofencing.status.inside;
    }

    return t.geofencing.status.outside;
  }

  void _showConfiguration(BuildContext context) {
    getIt<AnalyticsService>().screen(screenName: "geofence-configuration");

    final geofence = context.read<GeofencingBloc>().state.geofences.isNotEmpty
        ? context.read<GeofencingBloc>().state.geofences.first
        : null;

    context.push('/geofence-config', extra: {'geofence': geofence});
  }

  void _requestPermissions(BuildContext context) {
    context.read<GeofencingBloc>().add(const RequestLocationPermissions());
  }

  // Toggle geofence active method removed - functionality moved to configuration widget
}
