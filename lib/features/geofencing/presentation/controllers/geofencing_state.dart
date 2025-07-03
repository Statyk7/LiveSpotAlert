import 'package:equatable/equatable.dart';
import '../../domain/models/geofence.dart';
import '../../domain/models/location_event.dart';
import '../../domain/models/geofence_status.dart';

enum GeofencingStatus {
  initial,
  loading,
  loaded,
  monitoring,
  error,
}

class GeofencingState extends Equatable {
  const GeofencingState({
    this.status = GeofencingStatus.initial,
    this.geofences = const [],
    this.geofenceStatuses = const [],
    this.locationEvents = const [],
    this.selectedGeofence,
    this.isMonitoring = false,
    this.hasLocationPermissions = false,
    this.errorMessage,
  });

  final GeofencingStatus status;
  final List<Geofence> geofences;
  final List<GeofenceStatus> geofenceStatuses;
  final List<LocationEvent> locationEvents;
  final Geofence? selectedGeofence;
  final bool isMonitoring;
  final bool hasLocationPermissions;
  final String? errorMessage;

  GeofencingState copyWith({
    GeofencingStatus? status,
    List<Geofence>? geofences,
    List<GeofenceStatus>? geofenceStatuses,
    List<LocationEvent>? locationEvents,
    Geofence? selectedGeofence,
    bool? clearSelectedGeofence,
    bool? isMonitoring,
    bool? hasLocationPermissions,
    String? errorMessage,
    bool? clearError,
  }) {
    return GeofencingState(
      status: status ?? this.status,
      geofences: geofences ?? this.geofences,
      geofenceStatuses: geofenceStatuses ?? this.geofenceStatuses,
      locationEvents: locationEvents ?? this.locationEvents,
      selectedGeofence: clearSelectedGeofence == true
          ? null
          : selectedGeofence ?? this.selectedGeofence,
      isMonitoring: isMonitoring ?? this.isMonitoring,
      hasLocationPermissions:
          hasLocationPermissions ?? this.hasLocationPermissions,
      errorMessage:
          clearError == true ? null : errorMessage ?? this.errorMessage,
    );
  }

  // Convenience getters
  bool get hasError => errorMessage != null;
  bool get isLoading => status == GeofencingStatus.loading;
  bool get isLoaded =>
      status == GeofencingStatus.loaded ||
      status == GeofencingStatus.monitoring;
  bool get isEmpty => geofences.isEmpty;
  int get activeGeofenceCount => geofences.where((g) => g.isActive).length;
  int get totalGeofenceCount => geofences.length;

  // MVP Single Geofence getters
  bool get hasSingleGeofence => geofences.length == 1;
  Geofence? get singleGeofence => geofences.isNotEmpty ? geofences.first : null;
  GeofenceStatus? get singleGeofenceStatus =>
      singleGeofence != null ? getGeofenceStatus(singleGeofence!.id) : null;
  bool get isSingleGeofenceActive => singleGeofence?.isActive ?? false;
  bool get isUserInsideSingleGeofence =>
      singleGeofenceStatus?.isUserInside ?? false;

  // Get recent location events (last 10)
  List<LocationEvent> get recentLocationEvents {
    final sortedEvents = List<LocationEvent>.from(locationEvents)
      ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
    return sortedEvents.take(10).toList();
  }

  // Get geofence by ID
  Geofence? getGeofenceById(String id) {
    try {
      return geofences.firstWhere((g) => g.id == id);
    } catch (e) {
      return null;
    }
  }

  // Get status for a specific geofence
  GeofenceStatus? getGeofenceStatus(String geofenceId) {
    try {
      return geofenceStatuses.firstWhere((s) => s.geofence.id == geofenceId);
    } catch (e) {
      return null;
    }
  }

  // Get events for a specific geofence
  List<LocationEvent> getEventsForGeofence(String geofenceId) {
    return locationEvents.where((e) => e.geofence.id == geofenceId).toList()
      ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
  }

  // Check if user is currently inside any geofence
  bool get isUserInsideAnyGeofence {
    return geofenceStatuses.any((status) => status.isUserInside);
  }

  // Get currently triggered geofences
  List<GeofenceStatus> get triggeredGeofences {
    return geofenceStatuses
        .where((status) => status.isUserInside && status.geofence.isActive)
        .toList();
  }

  @override
  List<Object?> get props => [
        status,
        geofences,
        geofenceStatuses,
        locationEvents,
        selectedGeofence,
        isMonitoring,
        hasLocationPermissions,
        errorMessage,
      ];

  @override
  String toString() {
    return 'GeofencingState{status: $status, geofences: ${geofences.length}, monitoring: $isMonitoring, permissions: $hasLocationPermissions, error: $errorMessage}';
  }
}
