import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../shared/di/service_locator.dart';
import '../../../../shared/services/analytics_service.dart';
import '../../../../shared/ui_kit/colors.dart';
import '../../../../shared/ui_kit/text_styles.dart';
import '../../../../shared/utils/constants.dart';
import '../../../../features/geofencing/presentation/controllers/geofencing_bloc.dart';
import '../../../../features/geofencing/presentation/controllers/geofencing_state.dart';
import '../../../../features/geofencing/presentation/controllers/geofencing_event.dart';
import '../../../../features/geofencing/presentation/widgets/geofence_config_card.dart';
import '../../../../features/local_notifications/presentation/widgets/notification_config_card.dart';
import '../../../../features/local_notifications/presentation/widgets/notification_preview_card.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  final AnalyticsService _analyticsService = getIt<AnalyticsService>();

  @override
  void initState() {
    super.initState();
    // Load saved Live Activity configuration
    // context.read<LiveActivityBloc>().add(const LoadSavedConfiguration());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: _buildMainContent(),
    );
  }

  Widget _buildMainContent() {
    return CustomScrollView(
      slivers: [
        SliverAppBar(
          title: Text(
            AppConstants.appName,
            style: AppTextStyles.h3.copyWith(color: Colors.white),
          ),
          backgroundColor: AppColors.primary,
          elevation: 0,
          floating: true,
        ),
        SliverPadding(
          padding: const EdgeInsets.all(16.0),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              // Location Monitoring Section
              _buildMonitoringControlCard(),

              const SizedBox(height: 24),

              // Geofence Configuration Card
              const GeofenceConfigCard(),

              const SizedBox(height: 24),

              // Local Notifications Section
              const NotificationConfigCard(
                title: 'Notification',
              ),

              const SizedBox(height: 24),

              // Notification Preview Section
              const NotificationPreviewCard(),
            ]),
          ),
        ),
      ],
    );
  }

  // Monitoring control methods
  Widget _buildMonitoringControlCard() {
    return BlocBuilder<GeofencingBloc, GeofencingState>(
      builder: (context, state) {
        return Card(
          elevation: 2,
          color: AppColors.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.location_searching,
                      color: state.isMonitoring
                          ? AppColors.success
                          : AppColors.textSecondary,
                      size: 24,
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Location Monitoring',
                          style: AppTextStyles.h4,
                        ),
                        Text(
                          state.isMonitoring
                              ? 'Actively monitoring your location'
                              : 'Monitoring is disabled',
                          style: AppTextStyles.caption.copyWith(
                            color: state.isMonitoring
                                ? AppColors.success
                                : AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    Switch(
                      value: state.isMonitoring,
                      onChanged: state.hasLocationPermissions
                          ? (value) {
                              if (value) {
                                _startMonitoring();
                              } else {
                                _stopMonitoring();
                              }
                            }
                          : null,
                      activeColor: AppColors.success,
                    ),
                  ],
                ),
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
                            'Location permissions required',
                            style: AppTextStyles.bodySmall.copyWith(
                              color: AppColors.warning,
                            ),
                          ),
                        ),
                        TextButton(
                          onPressed: () => _requestLocationPermissions(),
                          child: Text(
                            'Grant',
                            style: TextStyle(color: AppColors.warning),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                if (state.isMonitoring && state.locationEvents.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.info.withValues(alpha: 26),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.history, color: AppColors.info, size: 16),
                        const SizedBox(width: 8),
                        Text(
                          'Last event: ${_formatLastLocationEvent(state.locationEvents.first)}',
                          style: AppTextStyles.caption.copyWith(
                            color: AppColors.info,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  void _startMonitoring() {
    _analyticsService.event(eventName: "start_monitoring");
    context.read<GeofencingBloc>().add(const StartMonitoring());
  }

  void _stopMonitoring() {
    _analyticsService.event(eventName: "stop_monitoring");
    context.read<GeofencingBloc>().add(const StopMonitoring());
  }

  void _requestLocationPermissions() {
    context.read<GeofencingBloc>().add(const RequestLocationPermissions());
  }

  String _formatLastLocationEvent(locationEvent) {
    final eventType = locationEvent.eventType.toString();
    final timeAgo = DateTime.now().difference(locationEvent.timestamp);

    String eventDescription;
    switch (eventType) {
      case 'geofence_enter':
      case 'enter':
        eventDescription = 'Entered ${locationEvent.geofence.name}';
        break;
      case 'geofence_exit':
      case 'exit':
        eventDescription = 'Exited ${locationEvent.geofence.name}';
        break;
      default:
        eventDescription = 'Location update';
    }

    String timeDescription;
    if (timeAgo.inMinutes < 1) {
      timeDescription = 'just now';
    } else if (timeAgo.inHours < 1) {
      timeDescription = '${timeAgo.inMinutes}m ago';
    } else if (timeAgo.inDays < 1) {
      timeDescription = '${timeAgo.inHours}h ago';
    } else {
      timeDescription = '${timeAgo.inDays}d ago';
    }

    return '$eventDescription $timeDescription';
  }
}
