// import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../../../../shared/di/service_locator.dart';
import '../../../../shared/services/analytics_service.dart';
import '../../../../shared/ui_kit/colors.dart';
import '../../../../shared/ui_kit/text_styles.dart';
import '../../../../features/geofencing/presentation/controllers/geofencing_bloc.dart';
import '../../../../features/geofencing/presentation/controllers/geofencing_state.dart';
import '../../../../features/geofencing/presentation/controllers/geofencing_event.dart';
import '../../../../features/geofencing/presentation/widgets/geofence_config_card.dart';
import '../../../../features/local_notifications/presentation/widgets/notification_config_card.dart';
import '../../../../features/local_notifications/presentation/widgets/notification_preview_card.dart';
import '../../../../features/donations/presentation/widgets/donation_button.dart';
import '../../../../i18n/translations.g.dart';


class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  final AnalyticsService _analyticsService = getIt<AnalyticsService>();
  String _appVersion = '';


  @override
  void initState() {
    super.initState();

    _loadAppVersion();

    // _loadPurchases();

    // Load saved Live Activity configuration
    // context.read<LiveActivityBloc>().add(const LoadSavedConfiguration());
  }

  Future<void> _loadAppVersion() async {
    final packageInfo = await PackageInfo.fromPlatform();
    setState(() {
      _appVersion = '${packageInfo.appName} v${packageInfo.version}+${packageInfo.buildNumber}';
    });
  }

  /// Works only on real device
  // Future<void> _loadPurchases() async {
  //   if(!(await _iap.isAvailable())) return;
  //
  //   if (Platform.isIOS) {
  //     final iosPlatformAddition = _iap
  //         .getPlatformAddition<InAppPurchaseStoreKitPlatformAddition>();
  //
  //     // await iosPlatformAddition.setDelegate(PaymentQueueDelegate());
  //   }
  //
  //   const Set<String> ids = {"small_tip", "medium_tip", "large_tip", "giant_tip"};
  //   ProductDetailsResponse response = await _iap.queryProductDetails(ids);
  //
  //   if (response.notFoundIDs.isNotEmpty) {
  //     // Handle not found product IDs
  //   }
  //   AppLogger.debug("IAP Products: ${response.productDetails.length}");
  // }


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
            t.app.name,
            style: AppTextStyles.h2.copyWith(color: Colors.white),
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
              NotificationConfigCard(
                title: t.notifications.title,
              ),

              const SizedBox(height: 24),

              // Notification Preview Section
              const NotificationPreviewCard(),

              const SizedBox(height: 32),

              // Donation button
              DonationButton(
                onPressed: () {
                  _analyticsService.event(eventName: "donation_button_tapped");
                  context.push('/donation');
                },
              ),

              const SizedBox(height: 16),

              // App version label
              Center(
                child: Text(
                  _appVersion.isEmpty ? t.common.loading : _appVersion,
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ),

              const SizedBox(height: 16),
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
          shadowColor: Colors.black12,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
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
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            t.monitoring.title,
                            style: AppTextStyles.h4,
                            maxLines: 2,
                            overflow: TextOverflow.visible,
                          ),
                          Text(
                            state.isMonitoring
                                ? t.monitoring.status.active
                                : t.monitoring.status.disabled,
                            style: AppTextStyles.caption.copyWith(
                              color: state.isMonitoring
                                  ? AppColors.success
                                  : AppColors.textSecondary,
                            ),
                            maxLines: 3,
                            overflow: TextOverflow.visible,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
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
                      //color: AppColors.warning.withValues(alpha: 26),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                          color: AppColors.warning),
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
                        TextButton(
                          onPressed: () => _requestLocationPermissions(),
                          child: Text(
                            t.common.grant,
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
                      // color: AppColors.info.withValues(alpha: 26),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.history, color: AppColors.info, size: 16),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            t.monitoring.lastEvent(event: _formatLastLocationEvent(state.locationEvents.first)),
                            style: AppTextStyles.caption.copyWith(
                              color: AppColors.info,
                            ),
                            maxLines: 3,
                            overflow: TextOverflow.visible,
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
        eventDescription = t.monitoring.events.entered(name: locationEvent.geofence.name);
        break;
      case 'geofence_exit':
      case 'exit':
        eventDescription = t.monitoring.events.exited(name: locationEvent.geofence.name);
        break;
      default:
        eventDescription = t.monitoring.events.locationUpdate;
    }

    String timeDescription;
    if (timeAgo.inMinutes < 1) {
      timeDescription = t.common.time.justNow;
    } else if (timeAgo.inHours < 1) {
      timeDescription = t.common.time.minutesAgo(minutes: timeAgo.inMinutes);
    } else if (timeAgo.inDays < 1) {
      timeDescription = t.common.time.hoursAgo(hours: timeAgo.inHours);
    } else {
      timeDescription = t.common.time.daysAgo(days: timeAgo.inDays);
    }

    return '$eventDescription $timeDescription';
  }
}
