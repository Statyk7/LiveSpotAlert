import 'dart:async';
import 'dart:math' as math;
import 'package:flutter_background_geolocation/flutter_background_geolocation.dart' as bg;
import '../../../../../shared/utils/logger.dart';
import '../../dto/geofence_dto.dart';
import '../../dto/location_event_dto.dart';

abstract class BackgroundGeolocationDataSource {
  Future<void> configure();
  Future<bool> requestPermissions();
  Future<bool> hasRequiredPermissions();
  
  Future<void> start();
  Future<void> stop();
  Future<bool> isRunning();
  
  Future<void> addGeofence(GeofenceDto geofence);
  Future<void> removeGeofence(String id);
  Future<void> removeAllGeofences();
  
  Stream<LocationEventDto> get geofenceEventStream;
  Stream<bg.Location> get locationStream;
  
  Future<bg.Location?> getCurrentLocation();
  Future<double> calculateDistance(double lat1, double lng1, double lat2, double lng2);
}

class BackgroundGeolocationDataSourceImpl implements BackgroundGeolocationDataSource {
  BackgroundGeolocationDataSourceImpl() {
    _initializeStreams();
  }
  
  final StreamController<LocationEventDto> _geofenceEventController = StreamController<LocationEventDto>.broadcast();
  final StreamController<bg.Location> _locationController = StreamController<bg.Location>.broadcast();
  
  bool _isConfigured = false;
  
  void _initializeStreams() {
    // Listen to geofence events
    bg.BackgroundGeolocation.onGeofence((bg.GeofenceEvent event) {
      try {
        AppLogger.info('Geofence event received: ${event.action} for ${event.identifier}');
        
        final locationEventDto = LocationEventDto.fromBackgroundGeolocationEvent({
          'identifier': event.identifier,
          'action': event.action,
          'location': {
            'coords': {
              'latitude': event.location.coords.latitude,
              'longitude': event.location.coords.longitude,
              'accuracy': event.location.coords.accuracy,
            }
          }
        });

        _geofenceEventController.add(locationEventDto);
      } catch (e, stackTrace) {
        AppLogger.error('Error processing geofence event', e, stackTrace);
      }
    });
    
    // Listen to location updates
    bg.BackgroundGeolocation.onLocation((bg.Location location) {
      _locationController.add(location);
      AppLogger.debug('Location changed: ${location.toString()}');
    });
    
    // Listen to other events for debugging
    bg.BackgroundGeolocation.onActivityChange((bg.ActivityChangeEvent event) {
      AppLogger.debug('Activity changed: ${event.activity}');
    });
    
    bg.BackgroundGeolocation.onProviderChange((bg.ProviderChangeEvent event) {
      AppLogger.debug('Provider changed: GPS enabled: ${event.gps}, Network enabled: ${event.network}');
    });
  }
  
  @override
  Future<void> configure() async {
    if (_isConfigured) {
      AppLogger.debug('BackgroundGeolocation already configured');
      return;
    }
    
    try {
      await bg.BackgroundGeolocation.ready(bg.Config(
        // Geolocation config
        desiredAccuracy: bg.Config.DESIRED_ACCURACY_HIGH,
        distanceFilter: 10.0,
        stopTimeout: 1,
        
        // Activity Recognition config
        stopDetectionDelay: 1,
        
        // Application config
        debug: false, // Set to true for debugging
        logLevel: bg.Config.LOG_LEVEL_OFF,
        
        // iOS specific
        locationAuthorizationRequest: 'Always',
        backgroundPermissionRationale: bg.PermissionRationale(
          title: "Allow {applicationName} to access this device's location even when closed or not in use.",
          message: "This app collects location data to enable geofence monitoring even when the app is closed or not in use.",
          positiveAction: 'Change to "{backgroundPermissionOptionLabel}"',
          negativeAction: 'Cancel',
        ),
        
        // HTTP / Persistence config (disabled for local-only app)
        autoSync: false,
        maxDaysToPersist: 7,
        
        // Geofencing
        geofenceInitialTriggerEntry: true,
      ));
      
      _isConfigured = true;
      AppLogger.info('BackgroundGeolocation configured successfully');
    } catch (e, stackTrace) {
      AppLogger.error('Error configuring BackgroundGeolocation', e, stackTrace);
      rethrow;
    }
  }
  
  @override
  Future<bool> requestPermissions() async {
    try {
      final status = await bg.BackgroundGeolocation.requestPermission();
      AppLogger.info('Permission request result: $status');
      return status == bg.ProviderChangeEvent.AUTHORIZATION_STATUS_ALWAYS;
    } catch (e, stackTrace) {
      AppLogger.error('Error requesting permissions', e, stackTrace);
      return false;
    }
  }
  
  @override
  Future<bool> hasRequiredPermissions() async {
    return requestPermissions();
  }
  
  @override
  Future<void> start() async {
    try {
      await configure();
      
      if (!await hasRequiredPermissions()) {
        throw Exception('Location permissions not granted');
      }
      
      await bg.BackgroundGeolocation.start();
      AppLogger.info('BackgroundGeolocation started');
    } catch (e, stackTrace) {
      AppLogger.error('Error starting BackgroundGeolocation', e, stackTrace);
      rethrow;
    }
  }
  
  @override
  Future<void> stop() async {
    try {
      await bg.BackgroundGeolocation.stop();
      AppLogger.info('BackgroundGeolocation stopped');
    } catch (e, stackTrace) {
      AppLogger.error('Error stopping BackgroundGeolocation', e, stackTrace);
      rethrow;
    }
  }
  
  @override
  Future<bool> isRunning() async {
    try {
      final state = await bg.BackgroundGeolocation.state;
      return state.enabled;
    } catch (e, stackTrace) {
      AppLogger.error('Error checking if BackgroundGeolocation is running', e, stackTrace);
      return false;
    }
  }
  
  @override
  Future<void> addGeofence(GeofenceDto geofence) async {
    try {
      await bg.BackgroundGeolocation.addGeofence(bg.Geofence(
        identifier: geofence.id,
        radius: geofence.radius,
        latitude: geofence.latitude,
        longitude: geofence.longitude,
        notifyOnEntry: true,
        notifyOnExit: true,
        notifyOnDwell: false,
        loiteringDelay: 30000, // 30 seconds
      ));
      
      AppLogger.info('Added geofence: ${geofence.name} (${geofence.id})');
    } catch (e, stackTrace) {
      AppLogger.error('Error adding geofence: ${geofence.name}', e, stackTrace);
      rethrow;
    }
  }
  
  @override
  Future<void> removeGeofence(String id) async {
    try {
      await bg.BackgroundGeolocation.removeGeofence(id);
      AppLogger.info('Removed geofence: $id');
    } catch (e, stackTrace) {
      AppLogger.error('Error removing geofence: $id', e, stackTrace);
      rethrow;
    }
  }
  
  @override
  Future<void> removeAllGeofences() async {
    try {
      await bg.BackgroundGeolocation.removeGeofences();
      AppLogger.info('Removed all geofences');
    } catch (e, stackTrace) {
      AppLogger.error('Error removing all geofences', e, stackTrace);
      rethrow;
    }
  }
  
  @override
  Stream<LocationEventDto> get geofenceEventStream => _geofenceEventController.stream;
  
  @override
  Stream<bg.Location> get locationStream => _locationController.stream;
  
  @override
  Future<bg.Location?> getCurrentLocation() async {
    try {
      final location = await bg.BackgroundGeolocation.getCurrentPosition(
        timeout: 30,
        maximumAge: 5000,
        desiredAccuracy: 10,
      );
      return location;
    } catch (e, stackTrace) {
      AppLogger.error('Error getting current location', e, stackTrace);
      return null;
    }
  }
  
  @override
  Future<double> calculateDistance(double lat1, double lng1, double lat2, double lng2) async {
    // Using Haversine formula for distance calculation
    const double earthRadius = 6371000; // Earth's radius in meters
    
    final double dLat = _degreesToRadians(lat2 - lat1);
    final double dLng = _degreesToRadians(lng2 - lng1);
    
    final double a = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(_degreesToRadians(lat1)) * math.cos(_degreesToRadians(lat2)) *
        math.sin(dLng / 2) * math.sin(dLng / 2);
    
    final double c = 2 * math.asin(math.sqrt(a));
    
    return earthRadius * c;
  }
  
  double _degreesToRadians(double degrees) {
    return degrees * (math.pi / 180);
  }
  
  void dispose() {
    _geofenceEventController.close();
    _locationController.close();
  }
}