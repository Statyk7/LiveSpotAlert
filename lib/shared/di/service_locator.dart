import 'package:dartz/dartz.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:live_activities/live_activities.dart';
import '../../shared/base_domain/failures/failure.dart';
// import 'get_it_extensions.dart'; // For future use
import '../../features/geofencing/data/data_sources/local/geofence_local_data_source.dart';
import '../../features/geofencing/data/data_sources/remote/background_geolocation_data_source.dart';
import '../../features/geofencing/data/services/geofencing_service_impl.dart';
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
import '../../features/live_activities/data/data_sources/remote/live_activities_data_source.dart';
import '../../features/live_activities/data/services/live_activity_service_impl.dart';
import '../../features/live_activities/domain/services/live_activity_service.dart';
import '../../features/live_activities/domain/use_cases/process_image_for_live_activity_use_case.dart';
import '../../features/live_activities/domain/use_cases/start_live_activity_use_case.dart';
import '../../features/live_activities/domain/use_cases/stop_live_activity_use_case.dart';
import '../../features/live_activities/domain/use_cases/update_live_activity_use_case.dart';
import '../../features/live_activities/presentation/controllers/live_activity_bloc.dart';

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

    // Register mock media service
    getIt.registerLazySingleton<MediaService>(
      () => _MockMediaService(),
    );

    // Register Live Activities services
    getIt.registerLazySingleton<LiveActivityService>(
      () => LiveActivityServiceImpl(
        liveActivitiesPlugin: getIt<LiveActivities>(),
      ),
    );


    // Register main services
    getIt.registerLazySingleton<GeofencingService>(
      () => GeofencingServiceImpl(
        localDataSource: getIt<GeofenceLocalDataSource>(),
        backgroundGeolocationDataSource: getIt<BackgroundGeolocationDataSource>(),
        // liveActivityIntegration: null, // Will be added when Live Activities are complete
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
    );
  }

  /// Create a new LiveActivityBloc instance with all dependencies
  static LiveActivityBloc createLiveActivityBloc() {
    return LiveActivityBloc(
      startLiveActivityUseCase: getIt<StartLiveActivityUseCase>(),
      stopLiveActivityUseCase: getIt<StopLiveActivityUseCase>(),
      updateLiveActivityUseCase: getIt<UpdateLiveActivityUseCase>(),
    );
  }

  /// Clean up resources and reset GetIt
  static Future<void> reset() async {
    // Dispose of services that need cleanup
    if (getIt.isRegistered<GeofencingService>()) {
      final service = getIt<GeofencingService>() as GeofencingServiceImpl;
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