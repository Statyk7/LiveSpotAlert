import 'package:dartz/dartz.dart';
import '../../../../shared/base_domain/failures/failure.dart';
import '../models/live_activity.dart';
import '../../../geofencing/domain/models/location_event.dart';
import '../../../geofencing/domain/models/geofence.dart';

abstract class LiveActivityService {
  // Live Activity Lifecycle
  Future<Either<Failure, LiveActivity>> startLiveActivity(LiveActivity activity);
  Future<Either<Failure, LiveActivity>> updateLiveActivity(LiveActivity activity);
  Future<Either<Failure, void>> endLiveActivity(String activityId);
  Future<Either<Failure, void>> endAllLiveActivities();
  
  // Activity Management
  Future<Either<Failure, List<LiveActivity>>> getActiveLiveActivities();
  Future<Either<Failure, LiveActivity?>> getLiveActivityById(String id);
  Future<Either<Failure, List<LiveActivity>>> getLiveActivityHistory({
    DateTime? startDate,
    DateTime? endDate,
    int? limit,
  });
  
  // Geofence Integration
  Future<Either<Failure, LiveActivity>> createActivityForLocationEvent(
    LocationEvent event,
    Geofence geofence,
    {
    String? mediaItemId,
    Map<String, dynamic>? customData,
  });
  
  Future<Either<Failure, void>> handleGeofenceEntry(
    LocationEvent event,
    Geofence geofence,
    {String? mediaItemId}
  );
  
  Future<Either<Failure, void>> handleGeofenceExit(
    LocationEvent event,
    Geofence geofence,
  );
  
  // Media Integration
  Future<Either<Failure, LiveActivity>> attachMediaToActivity(
    String activityId,
    String mediaItemId,
  );
  
  // Configuration
  Future<Either<Failure, bool>> isLiveActivitiesSupported();
  Future<Either<Failure, bool>> isLiveActivitiesEnabled();
  Future<Either<Failure, void>> requestLiveActivitiesPermission();
  
  // Live Activity Configuration Management
  Future<Either<Failure, LiveActivity?>> getActiveConfiguration();
  Future<Either<Failure, void>> saveConfiguration({
    required String title,
    String? subtitle,
    String? imageUrl,
    String? imageData,
    String? activityType,
    Map<String, dynamic>? customData,
  });
  Future<Either<Failure, void>> clearConfiguration();
  
  // Streams
  Stream<Either<Failure, LiveActivity>> get liveActivityUpdates;
  
  // Cleanup
  Future<Either<Failure, void>> cleanupOldActivities({
    Duration? maxAge,
    int? maxCount,
  });
}