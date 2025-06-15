import 'package:equatable/equatable.dart';
import '../../domain/models/geofence.dart';
import '../../domain/use_cases/create_geofence_use_case.dart';
import '../../domain/use_cases/update_geofence_use_case.dart';
import '../../domain/use_cases/delete_geofence_use_case.dart';
import '../../domain/use_cases/get_location_events_use_case.dart';

abstract class GeofencingEvent extends Equatable {
  const GeofencingEvent();

  @override
  List<Object?> get props => [];
}

// Initial loading event
class GeofencingStarted extends GeofencingEvent {
  const GeofencingStarted();
}

// Geofence CRUD events
class LoadGeofences extends GeofencingEvent {
  const LoadGeofences();
}

class CreateGeofence extends GeofencingEvent {
  const CreateGeofence(this.params);
  
  final CreateGeofenceParams params;
  
  @override
  List<Object?> get props => [params];
}

class UpdateGeofence extends GeofencingEvent {
  const UpdateGeofence(this.params);
  
  final UpdateGeofenceParams params;
  
  @override
  List<Object?> get props => [params];
}

class DeleteGeofence extends GeofencingEvent {
  const DeleteGeofence(this.params);
  
  final DeleteGeofenceParams params;
  
  @override
  List<Object?> get props => [params];
}

// Monitoring events
class StartMonitoring extends GeofencingEvent {
  const StartMonitoring({
    this.includeLocationEvents = true,
    this.includeGeofenceStatuses = true,
  });
  
  final bool includeLocationEvents;
  final bool includeGeofenceStatuses;
  
  @override
  List<Object?> get props => [includeLocationEvents, includeGeofenceStatuses];
}

class StopMonitoring extends GeofencingEvent {
  const StopMonitoring();
}

class ToggleGeofenceActive extends GeofencingEvent {
  const ToggleGeofenceActive(this.geofenceId);
  
  final String geofenceId;
  
  @override
  List<Object?> get props => [geofenceId];
}

// Location events
class LoadLocationEvents extends GeofencingEvent {
  const LoadLocationEvents(this.params);
  
  final GetLocationEventsParams params;
  
  @override
  List<Object?> get props => [params];
}

class ClearLocationEvents extends GeofencingEvent {
  const ClearLocationEvents();
}

// Permission events
class RequestLocationPermissions extends GeofencingEvent {
  const RequestLocationPermissions();
}

class CheckLocationPermissions extends GeofencingEvent {
  const CheckLocationPermissions();
}

// Internal events (from streams) - moved to bloc file due to private access

// UI events
class RefreshGeofences extends GeofencingEvent {
  const RefreshGeofences();
}

class SelectGeofence extends GeofencingEvent {
  const SelectGeofence(this.geofence);
  
  final Geofence? geofence;
  
  @override
  List<Object?> get props => [geofence];
}

class ClearError extends GeofencingEvent {
  const ClearError();
}