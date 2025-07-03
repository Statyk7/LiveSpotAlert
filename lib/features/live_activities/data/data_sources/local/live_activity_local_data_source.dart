import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../../shared/utils/constants.dart';
import '../../../../../shared/utils/logger.dart';
import '../../dto/activity_dto.dart';

abstract class LiveActivityLocalDataSource {
  Future<List<ActivityDto>> getLiveActivities();
  Future<ActivityDto?> getLiveActivityById(String id);
  Future<void> saveLiveActivity(ActivityDto activity);
  Future<void> saveLiveActivities(List<ActivityDto> activities);
  Future<void> deleteLiveActivity(String id);
  Future<void> clearAllLiveActivities();

  Future<List<ActivityDto>> getLiveActivityHistory({
    String? geofenceId,
    DateTime? startDate,
    DateTime? endDate,
    int? limit,
  });

  Future<ActivityDto?> getActiveConfiguration();
  Future<void> saveActiveConfiguration(ActivityDto configuration);
  Future<void> clearActiveConfiguration();
}

class LiveActivityLocalDataSourceImpl implements LiveActivityLocalDataSource {
  LiveActivityLocalDataSourceImpl(this._prefs);

  final SharedPreferences _prefs;

  static const String _activitiesKey = '${AppConstants.liveActivitiesKey}_list';
  static const String _historyKey = '${AppConstants.liveActivitiesKey}_history';
  static const String _activeConfigKey =
      '${AppConstants.liveActivitiesKey}_active_config';

  @override
  Future<List<ActivityDto>> getLiveActivities() async {
    try {
      final jsonString = _prefs.getString(_activitiesKey);
      if (jsonString == null) {
        AppLogger.debug('No live activities found in local storage');
        return [];
      }

      final jsonList = json.decode(jsonString) as List<dynamic>;
      final activities = jsonList
          .map((json) => ActivityDto.fromJson(json as Map<String, dynamic>))
          .toList();

      AppLogger.debug(
          'Retrieved ${activities.length} live activities from local storage');
      return activities;
    } catch (e, stackTrace) {
      AppLogger.error(
          'Error retrieving live activities from local storage', e, stackTrace);
      return [];
    }
  }

  @override
  Future<ActivityDto?> getLiveActivityById(String id) async {
    try {
      final activities = await getLiveActivities();
      return activities.where((a) => a.id == id).firstOrNull;
    } catch (e, stackTrace) {
      AppLogger.error(
          'Error retrieving live activity by id: $id', e, stackTrace);
      return null;
    }
  }

  @override
  Future<void> saveLiveActivity(ActivityDto activity) async {
    try {
      final activities = await getLiveActivities();
      final index = activities.indexWhere((a) => a.id == activity.id);

      if (index >= 0) {
        activities[index] = activity;
      } else {
        activities.add(activity);
      }

      await saveLiveActivities(activities);
      AppLogger.debug('Saved live activity: ${activity.title}');
    } catch (e, stackTrace) {
      AppLogger.error(
          'Error saving live activity: ${activity.title}', e, stackTrace);
      rethrow;
    }
  }

  @override
  Future<void> saveLiveActivities(List<ActivityDto> activities) async {
    try {
      final jsonList = activities.map((a) => a.toJson()).toList();
      final jsonString = json.encode(jsonList);

      await _prefs.setString(_activitiesKey, jsonString);
      AppLogger.debug(
          'Saved ${activities.length} live activities to local storage');
    } catch (e, stackTrace) {
      AppLogger.error(
          'Error saving live activities to local storage', e, stackTrace);
      rethrow;
    }
  }

  @override
  Future<void> deleteLiveActivity(String id) async {
    try {
      final activities = await getLiveActivities();
      activities.removeWhere((a) => a.id == id);
      await saveLiveActivities(activities);
      AppLogger.debug('Deleted live activity: $id');
    } catch (e, stackTrace) {
      AppLogger.error('Error deleting live activity: $id', e, stackTrace);
      rethrow;
    }
  }

  @override
  Future<void> clearAllLiveActivities() async {
    try {
      await _prefs.remove(_activitiesKey);
      AppLogger.debug('Cleared all live activities from local storage');
    } catch (e, stackTrace) {
      AppLogger.error('Error clearing live activities', e, stackTrace);
      rethrow;
    }
  }

  @override
  Future<List<ActivityDto>> getLiveActivityHistory({
    String? geofenceId,
    DateTime? startDate,
    DateTime? endDate,
    int? limit,
  }) async {
    try {
      final jsonString = _prefs.getString(_historyKey);
      if (jsonString == null) return [];

      final jsonList = json.decode(jsonString) as List<dynamic>;
      var activities = jsonList
          .map((json) => ActivityDto.fromJson(json as Map<String, dynamic>))
          .toList();

      // Apply filters
      if (geofenceId != null) {
        activities =
            activities.where((a) => a.geofenceId == geofenceId).toList();
      }

      if (startDate != null) {
        activities = activities
            .where((a) => DateTime.parse(a.createdAt).isAfter(startDate))
            .toList();
      }

      if (endDate != null) {
        activities = activities
            .where((a) => DateTime.parse(a.createdAt).isBefore(endDate))
            .toList();
      }

      // Sort by createdAt (newest first)
      activities.sort((a, b) =>
          DateTime.parse(b.createdAt).compareTo(DateTime.parse(a.createdAt)));

      // Apply limit
      if (limit != null && activities.length > limit) {
        activities = activities.take(limit).toList();
      }

      AppLogger.debug(
          'Retrieved ${activities.length} live activity history items');
      return activities;
    } catch (e, stackTrace) {
      AppLogger.error('Error retrieving live activity history', e, stackTrace);
      return [];
    }
  }

  Future<void> _saveLiveActivityToHistory(ActivityDto activity) async {
    try {
      final history = await getLiveActivityHistory();
      history.insert(0, activity); // Add to beginning (newest first)

      // Keep only last 500 activities to prevent unlimited growth
      if (history.length > 500) {
        history.removeRange(500, history.length);
      }

      final jsonList = history.map((a) => a.toJson()).toList();
      final jsonString = json.encode(jsonList);

      await _prefs.setString(_historyKey, jsonString);
      AppLogger.debug('Saved live activity to history: ${activity.title}');
    } catch (e, stackTrace) {
      AppLogger.error('Error saving live activity to history', e, stackTrace);
      // Don't rethrow - history is nice-to-have but not critical
    }
  }

  @override
  Future<ActivityDto?> getActiveConfiguration() async {
    try {
      final jsonString = _prefs.getString(_activeConfigKey);
      if (jsonString == null) {
        AppLogger.debug('No active live activity configuration found');
        return null;
      }

      final json = jsonDecode(jsonString) as Map<String, dynamic>;
      final config = ActivityDto.fromJson(json);

      AppLogger.debug(
          'Retrieved active live activity configuration: ${config.title}');
      return config;
    } catch (e, stackTrace) {
      AppLogger.error(
          'Error retrieving active live activity configuration', e, stackTrace);
      return null;
    }
  }

  @override
  Future<void> saveActiveConfiguration(ActivityDto configuration) async {
    try {
      final jsonString = json.encode(configuration.toJson());
      await _prefs.setString(_activeConfigKey, jsonString);

      // Also save to history for tracking
      await _saveLiveActivityToHistory(configuration);

      AppLogger.debug(
          'Saved active live activity configuration: ${configuration.title}');
    } catch (e, stackTrace) {
      AppLogger.error(
          'Error saving active live activity configuration', e, stackTrace);
      rethrow;
    }
  }

  @override
  Future<void> clearActiveConfiguration() async {
    try {
      await _prefs.remove(_activeConfigKey);
      AppLogger.debug('Cleared active live activity configuration');
    } catch (e, stackTrace) {
      AppLogger.error(
          'Error clearing active live activity configuration', e, stackTrace);
      rethrow;
    }
  }
}
