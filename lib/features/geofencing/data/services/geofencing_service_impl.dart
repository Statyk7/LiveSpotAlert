import 'dart:async';
import 'package:dartz/dartz.dart';
import '../../../../shared/base_domain/failures/failure.dart';
import '../../../../shared/utils/logger.dart';
import '../../domain/models/geofence.dart';
import '../../domain/models/location_event.dart';
import '../../domain/models/geofence_status.dart';
import '../../domain/services/geofencing_service.dart';
import '../data_sources/local/geofence_local_data_source.dart';
import '../data_sources/remote/background_geolocation_data_source.dart';
import '../mappers/geofence_mapper.dart';
import '../dto/location_event_dto.dart';
import 'geofencing_live_activity_integration.dart';
import 'geofencing_notification_integration.dart';

class GeofencingServiceImpl implements GeofencingService {
  GeofencingServiceImpl({
    required this.localDataSource,
    required this.backgroundGeolocationDataSource,
    this.liveActivityIntegration,
    this.notificationIntegration,
  }) {
    _initializeStreams();
  }
  
  final GeofenceLocalDataSource localDataSource;
  final BackgroundGeolocationDataSource backgroundGeolocationDataSource;
  final GeofencingLiveActivityIntegration? liveActivityIntegration;
  final GeofencingNotificationIntegration? notificationIntegration;
  
  final StreamController<Either<Failure, LocationEvent>> _locationEventController = 
      StreamController<Either<Failure, LocationEvent>>.broadcast();
  
  final StreamController<Either<Failure, List<GeofenceStatus>>> _geofenceStatusController = 
      StreamController<Either<Failure, List<GeofenceStatus>>>.broadcast();
  
  StreamSubscription? _backgroundLocationSubscription;
  List<Geofence> _cachedGeofences = [];
  
  void _initializeStreams() {
    // Listen to background geolocation events
    _backgroundLocationSubscription = backgroundGeolocationDataSource.geofenceEventStream.listen(
      (LocationEventDto eventDto) async {
        try {
          // Save event to local storage
          await localDataSource.saveLocationEvent(eventDto);
          
          // Find the geofence for this event
          final geofence = _cachedGeofences.where((g) => g.id == eventDto.geofenceId).firstOrNull;
          if (geofence == null) {
            AppLogger.warning('Geofence not found for event: ${eventDto.geofenceId}');
            return;
          }
          
          // Convert to domain model and emit
          final locationEvent = LocationEventMapper.fromDto(eventDto, geofence);
          _locationEventController.add(Right(locationEvent));
          
          // Trigger Live Activity if integration is available
          await _handleLiveActivityTrigger(locationEvent, geofence);
          
          // Trigger notification if integration is available
          await _handleNotificationTrigger(locationEvent, geofence);
          
          // Update geofence status
          await _updateGeofenceStatuses();
          
          AppLogger.info('Processed location event: ${locationEvent.eventType} for ${geofence.name}');
        } catch (e, stackTrace) {
          AppLogger.error('Error processing location event', e, stackTrace);
          _locationEventController.add(Left(LocationFailure(message: 'Error processing location event: $e')));
        }
      },
      onError: (error) {
        AppLogger.error('Error in geofence event stream', error);
        _locationEventController.add(Left(LocationFailure(message: 'Geofence event stream error: $error')));
      },
    );
  }
  
  Future<void> _updateGeofenceStatuses() async {
    try {
      final geofences = await getGeofences();
      await geofences.fold(
        (failure) async {
          _geofenceStatusController.add(Left(failure));
        },
        (geofenceList) async {
          final statuses = <GeofenceStatus>[];
          
          for (final geofence in geofenceList) {
            final isInside = await isUserInsideGeofence(geofence.id);
            final distance = await calculateDistanceToGeofence(geofence.id);
            
            final status = GeofenceStatus(
              geofence: geofence,
              state: geofence.isActive ? GeofenceState.monitoring : GeofenceState.idle,
              isUserInside: isInside.getOrElse(() => false),
              lastUpdated: DateTime.now(),
              distanceToCenter: distance.fold((l) => null, (r) => r),
            );
            
            statuses.add(status);
          }
          
          _geofenceStatusController.add(Right(statuses));
        },
      );
    } catch (e, stackTrace) {
      AppLogger.error('Error updating geofence statuses', e, stackTrace);
      _geofenceStatusController.add(Left(LocationFailure(message: 'Error updating statuses: $e')));
    }
  }
  
  @override
  Future<Either<Failure, List<Geofence>>> getGeofences() async {
    try {
      final geofenceDtos = await localDataSource.getGeofences();
      final geofences = GeofenceMapper.fromDtoList(geofenceDtos);
      _cachedGeofences = geofences;
      
      AppLogger.debug('Retrieved ${geofences.length} geofences');
      return Right(geofences);
    } catch (e, stackTrace) {
      AppLogger.error('Error retrieving geofences', e, stackTrace);
      return Left(CacheFailure(message: 'Failed to retrieve geofences: $e'));
    }
  }
  
  @override
  Future<Either<Failure, Geofence>> getGeofenceById(String id) async {
    try {
      final geofenceDto = await localDataSource.getGeofenceById(id);
      if (geofenceDto == null) {
        return Left(CacheFailure(message: 'Geofence not found: $id'));
      }
      
      final geofence = GeofenceMapper.fromDto(geofenceDto);
      return Right(geofence);
    } catch (e, stackTrace) {
      AppLogger.error('Error retrieving geofence by id: $id', e, stackTrace);
      return Left(CacheFailure(message: 'Failed to retrieve geofence: $e'));
    }
  }
  
  @override
  Future<Either<Failure, Geofence>> createGeofence(Geofence geofence) async {
    try {
      final geofenceDto = GeofenceMapper.toDto(geofence.copyWith(
        createdAt: DateTime.now(),
      ));
      
      // Save to local storage
      await localDataSource.saveGeofence(geofenceDto);
      
      // Add to background geolocation if active
      if (geofence.isActive) {
        await backgroundGeolocationDataSource.addGeofence(geofenceDto);
      }
      
      // Update cache
      _cachedGeofences.add(geofence);
      
      // Trigger geofence status update
      await _updateGeofenceStatuses();
      
      AppLogger.info('Created geofence: ${geofence.name}');
      return Right(geofence);
    } catch (e, stackTrace) {
      AppLogger.error('Error creating geofence: ${geofence.name}', e, stackTrace);
      return Left(CacheFailure(message: 'Failed to create geofence: $e'));
    }
  }
  
  @override
  Future<Either<Failure, Geofence>> updateGeofence(Geofence geofence) async {
    try {
      final geofenceDto = GeofenceMapper.toDto(geofence);
      
      // Update in local storage
      await localDataSource.saveGeofence(geofenceDto);
      
      // Update in background geolocation
      await backgroundGeolocationDataSource.removeGeofence(geofence.id);
      if (geofence.isActive) {
        await backgroundGeolocationDataSource.addGeofence(geofenceDto);
      }
      
      // Update cache
      final index = _cachedGeofences.indexWhere((g) => g.id == geofence.id);
      if (index >= 0) {
        _cachedGeofences[index] = geofence;
      }
      
      // Trigger geofence status update
      await _updateGeofenceStatuses();
      
      AppLogger.info('Updated geofence: ${geofence.name}');
      return Right(geofence);
    } catch (e, stackTrace) {
      AppLogger.error('Error updating geofence: ${geofence.name}', e, stackTrace);
      return Left(CacheFailure(message: 'Failed to update geofence: $e'));
    }
  }
  
  @override
  Future<Either<Failure, void>> deleteGeofence(String id) async {
    try {
      // Remove from background geolocation
      await backgroundGeolocationDataSource.removeGeofence(id);
      
      // Remove from local storage
      await localDataSource.deleteGeofence(id);
      
      // Update cache
      _cachedGeofences.removeWhere((g) => g.id == id);
      
      // Trigger geofence status update
      await _updateGeofenceStatuses();
      
      AppLogger.info('Deleted geofence: $id');
      return const Right(null);
    } catch (e, stackTrace) {
      AppLogger.error('Error deleting geofence: $id', e, stackTrace);
      return Left(CacheFailure(message: 'Failed to delete geofence: $e'));
    }
  }
  
  @override
  Future<Either<Failure, void>> startMonitoring() async {
    try {
      await backgroundGeolocationDataSource.start();
      
      // Add all active geofences to monitoring
      final geofences = await getGeofences();
      await geofences.fold(
        (failure) => throw Exception(failure.message),
        (geofenceList) async {
          for (final geofence in geofenceList.where((g) => g.isActive)) {
            final geofenceDto = GeofenceMapper.toDto(geofence);
            await backgroundGeolocationDataSource.addGeofence(geofenceDto);
          }
        },
      );
      
      // Trigger geofence status update
      await _updateGeofenceStatuses();
      
      AppLogger.info('Started geofence monitoring');
      return const Right(null);
    } catch (e, stackTrace) {
      AppLogger.error('Error starting monitoring', e, stackTrace);
      return Left(LocationFailure(message: 'Failed to start monitoring: $e'));
    }
  }
  
  @override
  Future<Either<Failure, void>> stopMonitoring() async {
    try {
      await backgroundGeolocationDataSource.stop();
      AppLogger.info('Stopped geofence monitoring');
      return const Right(null);
    } catch (e, stackTrace) {
      AppLogger.error('Error stopping monitoring', e, stackTrace);
      return Left(LocationFailure(message: 'Failed to stop monitoring: $e'));
    }
  }
  
  @override
  Future<Either<Failure, bool>> isMonitoring() async {
    try {
      final isRunning = await backgroundGeolocationDataSource.isRunning();
      return Right(isRunning);
    } catch (e, stackTrace) {
      AppLogger.error('Error checking monitoring status', e, stackTrace);
      return Left(LocationFailure(message: 'Failed to check monitoring status: $e'));
    }
  }
  
  @override
  Stream<Either<Failure, LocationEvent>> get locationEventStream => _locationEventController.stream;
  
  @override
  Stream<Either<Failure, List<GeofenceStatus>>> get geofenceStatusStream => _geofenceStatusController.stream;
  
  @override
  Future<Either<Failure, bool>> requestLocationPermissions() async {
    try {
      final granted = await backgroundGeolocationDataSource.requestPermissions();
      return Right(granted);
    } catch (e, stackTrace) {
      AppLogger.error('Error requesting permissions', e, stackTrace);
      return Left(PermissionFailure(message: 'Failed to request permissions: $e'));
    }
  }
  
  @override
  Future<Either<Failure, bool>> hasRequiredPermissions() async {
    try {
      final hasPermissions = await backgroundGeolocationDataSource.hasRequiredPermissions();
      return Right(hasPermissions);
    } catch (e, stackTrace) {
      AppLogger.error('Error checking permissions', e, stackTrace);
      return Left(PermissionFailure(message: 'Failed to check permissions: $e'));
    }
  }
  
  @override
  Future<Either<Failure, void>> configureBackgroundGeolocation() async {
    try {
      await backgroundGeolocationDataSource.configure();
      return const Right(null);
    } catch (e, stackTrace) {
      AppLogger.error('Error configuring background geolocation', e, stackTrace);
      return Left(LocationFailure(message: 'Failed to configure background geolocation: $e'));
    }
  }
  
  @override
  Future<Either<Failure, double>> calculateDistanceToGeofence(String geofenceId) async {
    try {
      final geofence = await getGeofenceById(geofenceId);
      return await geofence.fold(
        (failure) => Left(failure),
        (geofence) async {
          final currentLocation = await backgroundGeolocationDataSource.getCurrentLocation();
          if (currentLocation == null) {
            return Left(LocationFailure(message: 'Unable to get current location'));
          }
          
          final distance = await backgroundGeolocationDataSource.calculateDistance(
            currentLocation.coords.latitude,
            currentLocation.coords.longitude,
            geofence.latitude,
            geofence.longitude,
          );
          
          return Right(distance);
        },
      );
    } catch (e, stackTrace) {
      AppLogger.error('Error calculating distance to geofence: $geofenceId', e, stackTrace);
      return Left(LocationFailure(message: 'Failed to calculate distance: $e'));
    }
  }
  
  @override
  Future<Either<Failure, bool>> isUserInsideGeofence(String geofenceId) async {
    try {
      final distanceResult = await calculateDistanceToGeofence(geofenceId);
      return await distanceResult.fold(
        (failure) => Left(failure),
        (distance) async {
          final geofence = await getGeofenceById(geofenceId);
          return geofence.fold(
            (failure) => Left(failure),
            (geofence) => Right(distance <= geofence.radius),
          );
        },
      );
    } catch (e, stackTrace) {
      AppLogger.error('Error checking if user is inside geofence: $geofenceId', e, stackTrace);
      return Left(LocationFailure(message: 'Failed to check geofence status: $e'));
    }
  }
  
  @override
  Future<Either<Failure, List<LocationEvent>>> getLocationEvents({
    String? geofenceId,
    DateTime? startDate,
    DateTime? endDate,
    int? limit,
  }) async {
    try {
      final eventDtos = await localDataSource.getLocationEvents(
        geofenceId: geofenceId,
        startDate: startDate,
        endDate: endDate,
        limit: limit,
      );
      
      final geofences = await getGeofences();
      return await geofences.fold(
        (failure) => Left(failure),
        (geofenceList) {
          try {
            final events = LocationEventMapper.fromDtoList(eventDtos, geofenceList);
            return Right(events);
          } catch (e) {
            return Left(CacheFailure(message: 'Failed to map location events: $e'));
          }
        },
      );
    } catch (e, stackTrace) {
      AppLogger.error('Error retrieving location events', e, stackTrace);
      return Left(CacheFailure(message: 'Failed to retrieve location events: $e'));
    }
  }
  
  /// Handle Live Activity triggers for location events
  Future<void> _handleLiveActivityTrigger(
    LocationEvent event,
    Geofence geofence,
  ) async {
    if (liveActivityIntegration == null) {
      AppLogger.debug('Live Activity integration not available');
      return;
    }
    
    try {
      switch (event.eventType) {
        case LocationEventType.enter:
          await liveActivityIntegration!.handleGeofenceEntry(event, geofence);
          break;
        case LocationEventType.exit:
          await liveActivityIntegration!.handleGeofenceExit(event, geofence);
          break;
        case LocationEventType.dwell:
          await liveActivityIntegration!.handleGeofenceDwell(event, geofence);
          break;
      }
    } catch (e, stackTrace) {
      AppLogger.error('Error handling Live Activity trigger', e, stackTrace);
    }
  }
  
  /// Handle notification triggers for location events
  Future<void> _handleNotificationTrigger(
    LocationEvent event,
    Geofence geofence,
  ) async {
    if (notificationIntegration == null) {
      AppLogger.debug('Notification integration not available');
      return;
    }
    
    try {
      switch (event.eventType) {
        case LocationEventType.enter:
          await notificationIntegration!.handleGeofenceEntry(event, geofence);
          break;
        case LocationEventType.exit:
          await notificationIntegration!.handleGeofenceExit(event, geofence);
          break;
        case LocationEventType.dwell:
          await notificationIntegration!.handleGeofenceDwell(event, geofence);
          break;
      }
    } catch (e, stackTrace) {
      AppLogger.error('Error handling notification trigger', e, stackTrace);
    }
  }
  
  void dispose() {
    _backgroundLocationSubscription?.cancel();
    _locationEventController.close();
    _geofenceStatusController.close();
    
    // Clean up Live Activity integration
    liveActivityIntegration?.cleanup();
    
    // Clean up notification integration
    notificationIntegration?.cleanup();
  }
}

