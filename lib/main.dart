import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'apps/live_spot_alert/router/app_router.dart';
import 'shared/ui_kit/colors.dart';
import 'shared/utils/constants.dart';
import 'shared/utils/logger.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  
  AppLogger.info('Starting ${AppConstants.appName} v${AppConstants.appVersion}');
  
  runApp(const LiveSpotAlertApp());
}

class LiveSpotAlertApp extends StatelessWidget {
  const LiveSpotAlertApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      theme: _buildTheme(),
      routerConfig: AppRouter.router,
    );
    // return MultiBlocProvider(
    //   providers: [
    //     // TODO: Add BLoC providers for features
    //   ],
    //   child: MaterialApp.router(
    //     title: AppConstants.appName,
    //     debugShowCheckedModeBanner: false,
    //     theme: _buildTheme(),
    //     routerConfig: AppRouter.router,
    //   ),
    // );
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
      cardTheme: CardTheme(
        color: AppColors.surface,
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
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