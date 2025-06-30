import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../../shared/utils/constants.dart';
import '../../../../../shared/utils/logger.dart';
import '../../dto/geofence_dto.dart';
import '../../dto/location_event_dto.dart';

abstract class GeofenceLocalDataSource {
  Future<List<GeofenceDto>> getGeofences();
  Future<GeofenceDto?> getGeofenceById(String id);
  Future<void> saveGeofence(GeofenceDto geofence);
  Future<void> saveGeofences(List<GeofenceDto> geofences);
  Future<void> deleteGeofence(String id);
  Future<void> clearAllGeofences();
  
  Future<List<LocationEventDto>> getLocationEvents({
    String? geofenceId,
    DateTime? startDate,
    DateTime? endDate,
    int? limit,
  });
  Future<void> saveLocationEvent(LocationEventDto event);
  Future<void> clearLocationEvents();
}

class GeofenceLocalDataSourceImpl implements GeofenceLocalDataSource {
  GeofenceLocalDataSourceImpl(this._prefs);
  
  final SharedPreferences _prefs;
  
  static const String _geofencesKey = '${AppConstants.geofencesKey}_list';
  static const String _eventsKey = 'location_events_list';
  
  @override
  Future<List<GeofenceDto>> getGeofences() async {
    try {
      final jsonString = _prefs.getString(_geofencesKey);
      if (jsonString == null) {
        AppLogger.debug('No geofences found in local storage');
        return [];
      }
      
      final jsonList = json.decode(jsonString) as List<dynamic>;
      final geofences = jsonList
          .map((json) => GeofenceDto.fromJson(json as Map<String, dynamic>))
          .toList();
      
      AppLogger.debug('Retrieved ${geofences.length} geofences from local storage');
      return geofences;
    } catch (e, stackTrace) {
      AppLogger.error('Error retrieving geofences from local storage', e, stackTrace);
      return [];
    }
  }
  
  @override
  Future<GeofenceDto?> getGeofenceById(String id) async {
    try {
      final geofences = await getGeofences();
      return geofences.where((g) => g.id == id).firstOrNull;
    } catch (e, stackTrace) {
      AppLogger.error('Error retrieving geofence by id: $id', e, stackTrace);
      return null;
    }
  }
  
  @override
  Future<void> saveGeofence(GeofenceDto geofence) async {
    try {
      final geofences = await getGeofences();
      final index = geofences.indexWhere((g) => g.id == geofence.id);
      
      if (index >= 0) {
        geofences[index] = geofence;
      } else {
        geofences.add(geofence);
      }
      
      await saveGeofences(geofences);
      AppLogger.debug('Saved geofence: ${geofence.name}');
    } catch (e, stackTrace) {
      AppLogger.error('Error saving geofence: ${geofence.name}', e, stackTrace);
      rethrow;
    }
  }
  
  @override
  Future<void> saveGeofences(List<GeofenceDto> geofences) async {
    try {
      final jsonList = geofences.map((g) => g.toJson()).toList();
      final jsonString = json.encode(jsonList);
      
      await _prefs.setString(_geofencesKey, jsonString);
      AppLogger.debug('Saved ${geofences.length} geofences to local storage');
    } catch (e, stackTrace) {
      AppLogger.error('Error saving geofences to local storage', e, stackTrace);
      rethrow;
    }
  }
  
  @override
  Future<void> deleteGeofence(String id) async {
    try {
      final geofences = await getGeofences();
      geofences.removeWhere((g) => g.id == id);
      await saveGeofences(geofences);
      AppLogger.debug('Deleted geofence: $id');
    } catch (e, stackTrace) {
      AppLogger.error('Error deleting geofence: $id', e, stackTrace);
      rethrow;
    }
  }
  
  @override
  Future<void> clearAllGeofences() async {
    try {
      await _prefs.remove(_geofencesKey);
      AppLogger.debug('Cleared all geofences from local storage');
    } catch (e, stackTrace) {
      AppLogger.error('Error clearing geofences', e, stackTrace);
      rethrow;
    }
  }
  
  @override
  Future<List<LocationEventDto>> getLocationEvents({
    String? geofenceId,
    DateTime? startDate,
    DateTime? endDate,
    int? limit,
  }) async {
    try {
      final jsonString = _prefs.getString(_eventsKey);
      if (jsonString == null) return [];
      
      final jsonList = json.decode(jsonString) as List<dynamic>;
      var events = jsonList
          .map((json) => LocationEventDto.fromJson(json as Map<String, dynamic>))
          .toList();
      
      // Apply filters
      if (geofenceId != null) {
        events = events.where((e) => e.geofenceId == geofenceId).toList();
      }
      
      if (startDate != null) {
        events = events.where((e) => DateTime.parse(e.timestamp).isAfter(startDate)).toList();
      }
      
      if (endDate != null) {
        events = events.where((e) => DateTime.parse(e.timestamp).isBefore(endDate)).toList();
      }
      
      // Sort by timestamp (newest first)
      events.sort((a, b) => DateTime.parse(b.timestamp).compareTo(DateTime.parse(a.timestamp)));
      
      // Apply limit
      if (limit != null && events.length > limit) {
        events = events.take(limit).toList();
      }
      
      AppLogger.debug('Retrieved ${events.length} location events');
      return events;
    } catch (e, stackTrace) {
      AppLogger.error('Error retrieving location events', e, stackTrace);
      return [];
    }
  }
  
  @override
  Future<void> saveLocationEvent(LocationEventDto event) async {
    try {
      final events = await getLocationEvents();
      events.insert(0, event); // Add to beginning (newest first)
      
      // Keep only last 1000 events to prevent unlimited growth
      if (events.length > 1000) {
        events.removeRange(1000, events.length);
      }
      
      final jsonList = events.map((e) => e.toJson()).toList();
      final jsonString = json.encode(jsonList);
      
      await _prefs.setString(_eventsKey, jsonString);
      AppLogger.debug('Saved location event: ${event.eventType} for geofence ${event.geofenceId}');
    } catch (e, stackTrace) {
      AppLogger.error('Error saving location event', e, stackTrace);
      rethrow;
    }
  }
  
  @override
  Future<void> clearLocationEvents() async {
    try {
      await _prefs.remove(_eventsKey);
      AppLogger.debug('Cleared all location events');
    } catch (e, stackTrace) {
      AppLogger.error('Error clearing location events', e, stackTrace);
      rethrow;
    }
  }
}

