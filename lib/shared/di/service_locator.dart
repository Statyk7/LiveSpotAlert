import 'package:dartz/dartz.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:live_activities/live_activities.dart';
import '../../shared/base_domain/failures/failure.dart';
// import 'get_it_extensions.dart'; // For future use
import '../../features/geofencing/data/data_sources/local/geofence_local_data_source.dart';
import '../../features/geofencing/data/data_sources/remote/background_geolocation_data_source.dart';
import '../../features/geofencing/data/services/geofencing_service_impl.dart';
import '../../features/geofencing/data/services/geofencing_live_activity_integration.dart';
import '../../features/geofencing/domain/services/geofencing_service.dart';
import '../../features/geofencing/domain/use_cases/create_geofence_use_case.dart';
import '../../features/geofencing/domain/use_cases/delete_geofence_use_case.dart';
import '../../features/geofencing/domain/use_cases/get_geofences_use_case.dart';
import '../../features/geofencing/domain/use_cases/get_location_events_use_case.dart';
import '../../features/geofencing/domain/use_cases/monitor_location_use_case.dart';
import '../../features/geofencing/domain/use_cases/stop_monitoring_use_case.dart';
import '../../features/geofencing/domain/use_cases/update_geofence_use_case.dart';
import '../../features/geofencing/presentation/controllers/geofencing_bloc.dart';
import '../../features/media_management/domain/services/media_service.dart';
import '../services/analytics_service.dart';
import '../services/user_preferences_service.dart';
import '../../features/live_activities/data/data_sources/remote/live_activities_data_source.dart';
import '../../features/live_activities/data/data_sources/local/live_activity_local_data_source.dart';
import '../../features/live_activities/data/services/live_activity_service_impl.dart';
import '../../features/live_activities/domain/services/live_activity_service.dart';
import '../../features/live_activities/domain/use_cases/process_image_for_live_activity_use_case.dart';
import '../../features/live_activities/domain/use_cases/start_live_activity_use_case.dart';
import '../../features/live_activities/domain/use_cases/stop_live_activity_use_case.dart';
import '../../features/live_activities/domain/use_cases/update_live_activity_use_case.dart';
import '../../features/live_activities/presentation/controllers/live_activity_bloc.dart';
import '../../features/local_notifications/data/data_sources/local/notification_config_local_data_source.dart';
import '../../features/local_notifications/data/data_sources/remote/local_notifications_data_source.dart';
import '../../features/local_notifications/data/services/local_notifications_service_impl.dart';
import '../../features/local_notifications/domain/services/local_notifications_service.dart';
import '../../features/local_notifications/domain/use_cases/load_notification_config_use_case.dart';
import '../../features/local_notifications/domain/use_cases/save_notification_config_use_case.dart';
import '../../features/local_notifications/domain/use_cases/request_notification_permissions_use_case.dart';
import '../../features/local_notifications/presentation/controllers/local_notifications_bloc.dart';
import '../../features/local_notifications/domain/services/notification_image_service.dart';
import '../../features/local_notifications/data/services/notification_image_service_impl.dart';
import '../../features/geofencing/data/services/geofencing_notification_integration.dart';
import 'package:image_picker/image_picker.dart';
import '../../features/donations/data/data_sources/local/donation_local_data_source.dart';
import '../../features/donations/data/data_sources/remote/in_app_purchase_data_source.dart';
import '../../features/donations/data/services/donation_service_impl.dart';
import '../../features/donations/domain/services/donation_service.dart';
import '../../features/donations/domain/use_cases/get_donation_products_use_case.dart';
import '../../features/donations/domain/use_cases/make_donation_use_case.dart';
import '../../features/donations/domain/use_cases/check_purchase_history_use_case.dart';
import '../../features/donations/presentation/controllers/donation_bloc.dart';

// Global GetIt instance
final GetIt getIt = GetIt.instance;

/// Service locator setup using GetIt
class ServiceLocator {
  static bool _isInitialized = false;

  /// Initialize all dependencies
  static Future<void> init() async {
    if (_isInitialized) return;

    // Register SharedPreferences as a singleton
    final sharedPreferences = await SharedPreferences.getInstance();
    getIt.registerSingleton<SharedPreferences>(sharedPreferences);

    // Register data sources
    getIt.registerLazySingleton<GeofenceLocalDataSource>(
      () => GeofenceLocalDataSourceImpl(getIt<SharedPreferences>()),
    );

    getIt.registerLazySingleton<BackgroundGeolocationDataSource>(
      () => BackgroundGeolocationDataSourceImpl(),
    );

    // Register Live Activities plugin with proper initialization
    getIt.registerLazySingleton<LiveActivities>(
      () {
        final liveActivities = LiveActivities();
        // Initialize with the group ID
        liveActivities.init(appGroupId: "group.livespotalert.liveactivities");
        return liveActivities;
      },
    );

    // Register Live Activities data sources
    getIt.registerLazySingleton<LiveActivitiesDataSource>(
      () => LiveActivitiesDataSourceImpl(),
    );

    getIt.registerLazySingleton<LiveActivityLocalDataSource>(
      () => LiveActivityLocalDataSourceImpl(getIt<SharedPreferences>()),
    );

    // Register mock media service
    getIt.registerLazySingleton<MediaService>(
      () => _MockMediaService(),
    );

    // Register user preferences service
    getIt.registerLazySingleton<UserPreferencesService>(
      () => UserPreferencesServiceImpl(getIt<SharedPreferences>()),
    );

    // Register analytics service
    getIt.registerLazySingleton<AnalyticsService>(
      () => AnalyticsServicePosthog(),
    );

    // Register Live Activities services
    getIt.registerLazySingleton<LiveActivityService>(
      () => LiveActivityServiceImpl(
        liveActivitiesPlugin: getIt<LiveActivities>(),
        localDataSource: getIt<LiveActivityLocalDataSource>(),
        mediaService: getIt<MediaService>(),
      ),
    );

    // Register Live Activity integration for geofencing
    getIt.registerLazySingleton<GeofencingLiveActivityIntegration>(
      () => GeofencingLiveActivityIntegration(
        liveActivityService: getIt<LiveActivityService>(),
        mediaService: getIt<MediaService>(),
      ),
    );

    // Register Local Notifications data sources
    getIt.registerLazySingleton<NotificationConfigLocalDataSource>(
      () => NotificationConfigLocalDataSourceImpl(getIt<SharedPreferences>()),
    );

    getIt.registerLazySingleton<LocalNotificationsDataSource>(
      () => LocalNotificationsDataSourceImpl(
        imageService: getIt<NotificationImageService>() as NotificationImageServiceImpl,
      ),
    );

    // Register ImagePicker
    getIt.registerLazySingleton<ImagePicker>(() => ImagePicker());

    // Register Donation data sources
    getIt.registerLazySingleton<DonationLocalDataSource>(
      () => DonationLocalDataSourceImpl(getIt<SharedPreferences>()),
    );

    getIt.registerLazySingleton<InAppPurchaseDataSource>(
      () => InAppPurchaseDataSourceImpl(),
    );

    // Register Notification Image service
    getIt.registerLazySingleton<NotificationImageService>(
      () => NotificationImageServiceImpl(getIt<ImagePicker>()),
    );

    // Register Local Notifications service
    getIt.registerLazySingleton<LocalNotificationsService>(
      () => LocalNotificationsServiceImpl(
        localDataSource: getIt<NotificationConfigLocalDataSource>(),
        notificationsDataSource: getIt<LocalNotificationsDataSource>(),
      ),
    );

    // Register Notification integration for geofencing
    getIt.registerLazySingleton<GeofencingNotificationIntegration>(
      () => GeofencingNotificationIntegration(
        notificationsService: getIt<LocalNotificationsService>(),
      ),
    );

    // Register main services
    getIt.registerLazySingleton<GeofencingService>(
      () => GeofencingServiceImpl(
        localDataSource: getIt<GeofenceLocalDataSource>(),
        backgroundGeolocationDataSource:
            getIt<BackgroundGeolocationDataSource>(),
        liveActivityIntegration: getIt<GeofencingLiveActivityIntegration>(),
        notificationIntegration: getIt<GeofencingNotificationIntegration>(),
      ),
    );

    // Register Donation service
    getIt.registerLazySingleton<DonationService>(
      () => DonationServiceImpl(
        inAppPurchaseDataSource: getIt<InAppPurchaseDataSource>(),
        localDataSource: getIt<DonationLocalDataSource>(),
      ),
    );

    // Register use cases
    getIt.registerLazySingleton<GetGeofencesUseCase>(
      () => GetGeofencesUseCase(getIt<GeofencingService>()),
    );

    getIt.registerLazySingleton<CreateGeofenceUseCase>(
      () => CreateGeofenceUseCase(getIt<GeofencingService>()),
    );

    getIt.registerLazySingleton<UpdateGeofenceUseCase>(
      () => UpdateGeofenceUseCase(getIt<GeofencingService>()),
    );

    getIt.registerLazySingleton<DeleteGeofenceUseCase>(
      () => DeleteGeofenceUseCase(getIt<GeofencingService>()),
    );

    getIt.registerLazySingleton<MonitorLocationUseCase>(
      () => MonitorLocationUseCase(getIt<GeofencingService>()),
    );

    getIt.registerLazySingleton<StopMonitoringUseCase>(
      () => StopMonitoringUseCase(getIt<GeofencingService>()),
    );

    getIt.registerLazySingleton<GetLocationEventsUseCase>(
      () => GetLocationEventsUseCase(getIt<GeofencingService>()),
    );

    // Register Live Activities use cases
    getIt.registerLazySingleton<ProcessImageForLiveActivityUseCase>(
      () => ProcessImageForLiveActivityUseCase(),
    );

    getIt.registerLazySingleton<StartLiveActivityUseCase>(
      () => StartLiveActivityUseCase(
        liveActivitiesPlugin: getIt<LiveActivities>(),
        processImageUseCase: getIt<ProcessImageForLiveActivityUseCase>(),
      ),
    );

    getIt.registerLazySingleton<StopLiveActivityUseCase>(
      () => StopLiveActivityUseCase(
        liveActivitiesPlugin: getIt<LiveActivities>(),
      ),
    );

    getIt.registerLazySingleton<UpdateLiveActivityUseCase>(
      () => UpdateLiveActivityUseCase(
        liveActivitiesPlugin: getIt<LiveActivities>(),
        processImageUseCase: getIt<ProcessImageForLiveActivityUseCase>(),
      ),
    );

    // Register Local Notifications use cases
    getIt.registerLazySingleton<LoadNotificationConfigUseCase>(
      () => LoadNotificationConfigUseCase(getIt<LocalNotificationsService>()),
    );

    getIt.registerLazySingleton<SaveNotificationConfigUseCase>(
      () => SaveNotificationConfigUseCase(getIt<LocalNotificationsService>()),
    );

    getIt.registerLazySingleton<RequestNotificationPermissionsUseCase>(
      () => RequestNotificationPermissionsUseCase(
          getIt<LocalNotificationsService>()),
    );

    // Register Donation use cases
    getIt.registerLazySingleton<GetDonationProductsUseCase>(
      () => GetDonationProductsUseCase(getIt<DonationService>()),
    );

    getIt.registerLazySingleton<MakeDonationUseCase>(
      () => MakeDonationUseCase(getIt<DonationService>()),
    );

    getIt.registerLazySingleton<CheckPurchaseHistoryUseCase>(
      () => CheckPurchaseHistoryUseCase(getIt<DonationService>()),
    );

    _isInitialized = true;
  }

  /// Create a new GeofencingBloc instance with all dependencies
  static GeofencingBloc createGeofencingBloc() {
    return GeofencingBloc(
      getGeofencesUseCase: getIt<GetGeofencesUseCase>(),
      createGeofenceUseCase: getIt<CreateGeofenceUseCase>(),
      updateGeofenceUseCase: getIt<UpdateGeofenceUseCase>(),
      deleteGeofenceUseCase: getIt<DeleteGeofenceUseCase>(),
      monitorLocationUseCase: getIt<MonitorLocationUseCase>(),
      stopMonitoringUseCase: getIt<StopMonitoringUseCase>(),
      getLocationEventsUseCase: getIt<GetLocationEventsUseCase>(),
      geofencingService: getIt<GeofencingService>(),
      userPreferencesService: getIt<UserPreferencesService>(),
    );
  }

  /// Create a new LiveActivityBloc instance with all dependencies
  static LiveActivityBloc createLiveActivityBloc() {
    return LiveActivityBloc(
      startLiveActivityUseCase: getIt<StartLiveActivityUseCase>(),
      stopLiveActivityUseCase: getIt<StopLiveActivityUseCase>(),
      updateLiveActivityUseCase: getIt<UpdateLiveActivityUseCase>(),
      liveActivityService: getIt<LiveActivityService>(),
    );
  }

  /// Create a new LocalNotificationsBloc instance with all dependencies
  static LocalNotificationsBloc createLocalNotificationsBloc() {
    return LocalNotificationsBloc(
      loadNotificationConfigUseCase: getIt<LoadNotificationConfigUseCase>(),
      saveNotificationConfigUseCase: getIt<SaveNotificationConfigUseCase>(),
      requestNotificationPermissionsUseCase:
          getIt<RequestNotificationPermissionsUseCase>(),
      notificationsService: getIt<LocalNotificationsService>(),
      imageService: getIt<NotificationImageService>(),
      userPreferencesService: getIt<UserPreferencesService>(),
    );
  }

  /// Create a new DonationBloc instance with all dependencies
  static DonationBloc createDonationBloc() {
    return DonationBloc(
      getDonationProductsUseCase: getIt<GetDonationProductsUseCase>(),
      makeDonationUseCase: getIt<MakeDonationUseCase>(),
      checkPurchaseHistoryUseCase: getIt<CheckPurchaseHistoryUseCase>(),
    );
  }

  /// Clean up resources and reset GetIt
  static Future<void> reset() async {
    // Dispose of services that need cleanup
    if (getIt.isRegistered<GeofencingService>()) {
      final service = getIt<GeofencingService>() as GeofencingServiceImpl;
      service.dispose();
    }

    if (getIt.isRegistered<DonationService>()) {
      final service = getIt<DonationService>() as DonationServiceImpl;
      service.dispose();
    }

    await getIt.reset();
    _isInitialized = false;
  }

  /// Check if dependencies are initialized
  static bool get isInitialized => _isInitialized;
}

/// Mock MediaService implementation
class _MockMediaService implements MediaService {
  @override
  Future<Either<Failure, MediaItem>> getMediaItemById(String id) async {
    // Return a mock media item for now
    return Right(MediaItem(
      id: id,
      filePath: null,
      base64Data: null,
    ));
  }
}
