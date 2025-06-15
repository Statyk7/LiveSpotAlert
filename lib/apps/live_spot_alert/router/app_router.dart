import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../presentation/screens/home_screen.dart';
import '../presentation/screens/splash_screen.dart';
import '../presentation/screens/app_status_screen.dart';
import '../../../features/geofencing/presentation/screens/geofence_list_screen.dart';
import '../../../features/geofencing/presentation/screens/create_geofence_screen.dart';

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
        path: '/home',
        name: 'home',
        builder: (context, state) => HomeScreen(),
      ),
      GoRoute(
        path: '/status',
        name: 'status',
        builder: (context, state) => const AppStatusScreen(),
      ),
      GoRoute(
        path: '/geofences',
        name: 'geofences',
        builder: (context, state) => const GeofenceListScreen(),
        routes: [
          GoRoute(
            path: 'create',
            name: 'create-geofence',
            builder: (context, state) => const CreateGeofenceScreen(),
          ),
          GoRoute(
            path: 'edit/:id',
            name: 'edit-geofence',
            builder: (context, state) {
              final geofenceId = state.pathParameters['id']!;
              return CreateGeofenceScreen(geofenceId: geofenceId);
            },
          ),
        ],
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Text('Page not found: ${state.matchedLocation}'),
      ),
    ),
  );
}