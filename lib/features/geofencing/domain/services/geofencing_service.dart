import 'package:dartz/dartz.dart';
import '../../../../shared/base_domain/failures/failure.dart';
import '../models/geofence.dart';
import '../models/location_event.dart';
import '../models/geofence_status.dart';

abstract class GeofencingService {
  // Geofence Management
  Future<Either<Failure, List<Geofence>>> getGeofences();
  Future<Either<Failure, Geofence>> getGeofenceById(String id);
  Future<Either<Failure, Geofence>> createGeofence(Geofence geofence);
  Future<Either<Failure, Geofence>> updateGeofence(Geofence geofence);
  Future<Either<Failure, void>> deleteGeofence(String id);
  
  // Location Monitoring
  Future<Either<Failure, void>> startMonitoring();
  Future<Either<Failure, void>> stopMonitoring();
  Future<Either<Failure, bool>> isMonitoring();
  
  // Real-time Streams
  Stream<Either<Failure, LocationEvent>> get locationEventStream;
  Stream<Either<Failure, List<GeofenceStatus>>> get geofenceStatusStream;
  
  // Permission and Setup
  Future<Either<Failure, bool>> requestLocationPermissions();
  Future<Either<Failure, bool>> hasRequiredPermissions();
  Future<Either<Failure, void>> configureBackgroundGeolocation();
  
  // Utility Methods
  Future<Either<Failure, double>> calculateDistanceToGeofence(String geofenceId);
  Future<Either<Failure, bool>> isUserInsideGeofence(String geofenceId);
  
  // Event History
  Future<Either<Failure, List<LocationEvent>>> getLocationEvents({
    String? geofenceId,
    DateTime? startDate,
    DateTime? endDate,
    int? limit,
  });
}