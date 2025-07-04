import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../presentation/screens/main_screen.dart';
import '../presentation/screens/splash_screen.dart';
import '../../../features/local_notifications/presentation/screens/notification_display_screen.dart';
import '../../../features/local_notifications/domain/models/notification_payload.dart';

class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: '/splash',
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
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Text('Page not found: ${state.matchedLocation}'),
      ),
    ),
  );
}
