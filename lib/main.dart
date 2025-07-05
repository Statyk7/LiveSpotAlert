import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'apps/live_spot_alert/router/app_router.dart';
import 'shared/di/service_locator.dart';
import 'shared/ui_kit/colors.dart';
import 'shared/utils/constants.dart';
import 'shared/utils/logger.dart';
import 'features/geofencing/presentation/controllers/geofencing_bloc.dart';
import 'features/geofencing/presentation/controllers/geofencing_event.dart';
import 'features/live_activities/presentation/controllers/live_activity_bloc.dart';
import 'features/local_notifications/presentation/controllers/local_notifications_bloc.dart';
import 'features/local_notifications/presentation/controllers/local_notifications_event.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();


void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  AppLogger.info(
      'Starting ${AppConstants.appName} v${AppConstants.appVersion}');

  // Initialize dependency injection
  await ServiceLocator.init();

  // Initialize Sentry and Run App
  await SentryFlutter.init(
        (options) {
      options.dsn = 'https://8d07e530577c338d5bb463baa2477bf3@o4509614113423360.ingest.us.sentry.io/4509614114078720';
      // Adds request headers and IP for users,
      // visit: https://docs.sentry.io/platforms/dart/data-management/data-collected/ for more info
      options.sendDefaultPii = true;
      // Set tracesSampleRate to 1.0 to capture 100% of transactions for tracing.
      // We recommend adjusting this value in production.
      options.tracesSampleRate = 1.0;
      // Enable logs to be sent to Sentry
      options.enableLogs = true;
    },
    appRunner: () => runApp(
      SentryWidget(
        child: const LiveSpotAlertApp(),
      ),
    ),
  );
}

class LiveSpotAlertApp extends StatelessWidget {
  const LiveSpotAlertApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<GeofencingBloc>(
          create: (context) => ServiceLocator.createGeofencingBloc()
            ..add(const GeofencingStarted()),
        ),
        BlocProvider<LiveActivityBloc>(
          create: (context) => ServiceLocator.createLiveActivityBloc(),
        ),
        BlocProvider<LocalNotificationsBloc>(
          create: (context) => ServiceLocator.createLocalNotificationsBloc()
            ..add(const LoadNotificationConfiguration()),
        ),
      ],
      child: MaterialApp.router(
        title: AppConstants.appName,
        debugShowCheckedModeBanner: false,
        theme: _buildTheme(),
        routerConfig: AppRouter.router,
      ),
    );
  }

  ThemeData _buildTheme() {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primary,
        brightness: Brightness.light,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      cardTheme: const CardThemeData(
        color: AppColors.surface,
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(8)),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
    );
  }
}
