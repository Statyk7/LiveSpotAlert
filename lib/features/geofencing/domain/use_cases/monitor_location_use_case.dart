import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../shared/base_domain/failures/failure.dart';
import '../../../../shared/base_domain/use_case.dart';
import '../models/location_event.dart';
import '../models/geofence_status.dart';
import '../services/geofencing_service.dart';

class MonitorLocationUseCase implements StreamUseCase<MonitorLocationResult, MonitorLocationParams> {
  const MonitorLocationUseCase(this._geofencingService);
  
  final GeofencingService _geofencingService;
  
  @override
  Stream<Either<Failure, MonitorLocationResult>> call(MonitorLocationParams params) async* {
    // First, ensure we have the required permissions
    final permissionResult = await _geofencingService.hasRequiredPermissions();
    final hasPermissions = permissionResult.fold(
      (failure) => false,
      (hasPermissions) => hasPermissions,
    );
    
    if (!hasPermissions) {
      // Try to request permissions
      final requestResult = await _geofencingService.requestLocationPermissions();
      final granted = requestResult.fold(
        (failure) {
          return false;
        },
        (granted) => granted,
      );
      
      if (!granted) {
        yield Left(PermissionFailure(message: 'Location permissions are required for geofence monitoring'));
        return;
      }
    }
    
    // Configure background geolocation if needed
    final configResult = await _geofencingService.configureBackgroundGeolocation();
    if (configResult.isLeft()) {
      yield configResult.fold(
        (failure) => Left(failure),
        (_) => throw Exception('Unexpected right value'),
      );
      return;
    }
    
    // Start monitoring if requested
    if (params.startMonitoring) {
      final startResult = await _geofencingService.startMonitoring();
      if (startResult.isLeft()) {
        yield startResult.fold(
          (failure) => Left(failure),
          (_) => throw Exception('Unexpected right value'),
        );
        return;
      }
    }
    
    // Listen to location events if requested
    if (params.includeLocationEvents) {
      yield* _geofencingService.locationEventStream.map((eventResult) {
        return eventResult.fold(
          (failure) => Left(failure),
          (event) => Right(MonitorLocationResult(
            locationEvent: event,
            geofenceStatuses: null,
          )),
        );
      });
    }
    
    // Listen to geofence status updates if requested
    if (params.includeGeofenceStatuses) {
      yield* _geofencingService.geofenceStatusStream.map((statusResult) {
        return statusResult.fold(
          (failure) => Left(failure),
          (statuses) => Right(MonitorLocationResult(
            locationEvent: null,
            geofenceStatuses: statuses,
          )),
        );
      });
    }
  }
}

class MonitorLocationParams extends Equatable {
  const MonitorLocationParams({
    this.startMonitoring = true,
    this.includeLocationEvents = true,
    this.includeGeofenceStatuses = true,
  });
  
  final bool startMonitoring;
  final bool includeLocationEvents;
  final bool includeGeofenceStatuses;
  
  @override
  List<Object?> get props => [
        startMonitoring,
        includeLocationEvents,
        includeGeofenceStatuses,
      ];
}

class MonitorLocationResult extends Equatable {
  const MonitorLocationResult({
    this.locationEvent,
    this.geofenceStatuses,
  });
  
  final LocationEvent? locationEvent;
  final List<GeofenceStatus>? geofenceStatuses;
  
  @override
  List<Object?> get props => [locationEvent, geofenceStatuses];
}