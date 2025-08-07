import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:posthog_flutter/posthog_flutter.dart';
import '../presentation/screens/main_screen.dart';
import '../presentation/screens/splash_screen.dart';
import '../../../features/local_notifications/presentation/screens/notification_display_screen.dart';
import '../../../features/local_notifications/domain/models/notification_payload.dart';
import '../../../features/local_notifications/presentation/widgets/notification_configuration_widget.dart';
import '../../../features/geofencing/presentation/widgets/geofence_configuration_widget.dart';
import '../../../features/live_activities/presentation/widgets/live_activity_configuration_widget.dart';
import '../../../features/donations/presentation/screens/donation_screen.dart';


class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: '/splash',
    // Records screen views automatically with Posthog
    observers: [PosthogObserver()],
    routes: [
      GoRoute(
        path: '/splash',
        name: 'splash',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/main',
        name: 'main',
        builder: (context, state) => const MainScreen(),
      ),
      GoRoute(
        path: '/notification-display',
        name: 'notification-display',
        builder: (context, state) {
          final payloadString = state.uri.queryParameters['payload'];
          debugPrint('AppRouter: Building notification-display route with payload: $payloadString');
          
          final payload = NotificationPayload.fromPayloadString(payloadString);
          
          if (payload == null) {
            debugPrint('AppRouter: Invalid payload, redirecting to main screen');
            // If payload is invalid, redirect to main screen
            return const MainScreen();
          }
          
          debugPrint('AppRouter: Valid payload parsed, showing NotificationDisplayScreen');
          return NotificationDisplayScreen(payload: payload);
        },
      ),
      GoRoute(
        path: '/notification-config',
        name: 'notification-config',
        builder: (context, state) {
          return NotificationConfigurationWidget(
            onSave: () => context.pop(),
            onCancel: () => context.pop(),
          );
        },
      ),
      GoRoute(
        path: '/geofence-config',
        name: 'geofence-config',
        builder: (context, state) {
          final geofenceData = state.extra as Map<String, dynamic>?;
          return GeofenceConfigurationWidget(
            geofence: geofenceData?['geofence'],
            onSave: () => context.pop(),
            onCancel: () => context.pop(),
          );
        },
      ),
      GoRoute(
        path: '/live-activity-config',
        name: 'live-activity-config',
        builder: (context, state) {
          return LiveActivityConfigurationWidget(
            onSave: () => context.pop(),
            onCancel: () => context.pop(),
          );
        },
      ),
      GoRoute(
        path: '/donation',
        name: 'donation',
        builder: (context, state) => const DonationScreen(),
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Text('Page not found: ${state.matchedLocation}'),
      ),
    ),
  );
}
