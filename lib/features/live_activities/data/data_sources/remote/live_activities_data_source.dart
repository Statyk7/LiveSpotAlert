import 'dart:async';
import 'package:live_activities/live_activities.dart';
import '../../../../../shared/utils/logger.dart';
import '../../dto/activity_dto.dart';

abstract class LiveActivitiesDataSource {
  Future<bool> isSupported();
  Future<bool> isEnabled();
  Future<void> requestPermission();

  Future<String> createActivity(ActivityDto activity);
  Future<void> updateActivity(String activityId, ActivityDto activity);
  Future<void> endActivity(String activityId);
  Future<void> endAllActivities();

  Future<List<String>> getActiveActivityIds();
  Stream<ActivityUpdateDto> get activityUpdates;
}

class LiveActivitiesDataSourceImpl implements LiveActivitiesDataSource {
  LiveActivitiesDataSourceImpl() {
    _initializeLiveActivities();
    _initializeStreams();
  }

  final StreamController<ActivityUpdateDto> _activityUpdateController =
      StreamController<ActivityUpdateDto>.broadcast();

  final LiveActivities _liveActivities = LiveActivities();

  void _initializeLiveActivities() {
    // Initialize the LiveActivities plugin with the group ID
    _liveActivities.init(appGroupId: "group.livespotalert.liveactivities");
  }

  void _initializeStreams() {
    // Listen to activity state changes
    _liveActivities.activityUpdateStream.listen(
      (update) {
        try {
          final activityUpdate = ActivityUpdateDto(
            activityId: update.activityId,
            status: _mapActivityStatus('active'), // Default status for now
            timestamp: DateTime.now(),
            data: {'activityId': update.activityId},
          );

          _activityUpdateController.add(activityUpdate);
          AppLogger.info(
              'Live Activity update: ${activityUpdate.activityId} -> ${activityUpdate.status}');
        } catch (e, stackTrace) {
          AppLogger.error(
              'Error processing Live Activity update', e, stackTrace);
        }
      },
      onError: (error) {
        AppLogger.error('Live Activities stream error', error);
      },
    );
  }

  String _mapActivityStatus(String status) {
    switch (status.toLowerCase()) {
      case 'active':
        return 'active';
      case 'dismissed':
        return 'dismissed';
      case 'ended':
        return 'ended';
      case 'stale':
        return 'stale';
      default:
        return 'unknown';
    }
  }

  @override
  Future<bool> isSupported() async {
    try {
      // Live Activities are supported on iOS 16.1+
      final isSupported = await _liveActivities.areActivitiesEnabled();
      AppLogger.debug('Live Activities supported: $isSupported');
      return isSupported;
    } catch (e, stackTrace) {
      AppLogger.error('Error checking Live Activities support', e, stackTrace);
      return false;
    }
  }

  @override
  Future<bool> isEnabled() async {
    try {
      final isEnabled = await _liveActivities.areActivitiesEnabled();
      AppLogger.debug('Live Activities enabled: $isEnabled');
      return isEnabled;
    } catch (e, stackTrace) {
      AppLogger.error(
          'Error checking Live Activities enabled status', e, stackTrace);
      return false;
    }
  }

  @override
  Future<void> requestPermission() async {
    try {
      // Note: Live Activities don't require explicit permission request
      // They are automatically available if the device supports them
      AppLogger.info(
          'Live Activities permission requested (automatic on supported devices)');
    } catch (e, stackTrace) {
      AppLogger.error(
          'Error requesting Live Activities permission', e, stackTrace);
      rethrow;
    }
  }

  @override
  Future<String> createActivity(ActivityDto activity) async {
    try {
      final activityData = activity.toLiveActivitiesData();

      final activityId = await _liveActivities.createActivity(
        activity.id, // First parameter: activity ID
        activityData, // Second parameter: complete data map
      );

      AppLogger.info(
          'Created Live Activity: $activityId for ${activity.title}');
      return activityId ?? '';
    } catch (e, stackTrace) {
      AppLogger.error(
          'Error creating Live Activity: ${activity.title}', e, stackTrace);
      rethrow;
    }
  }

  @override
  Future<void> updateActivity(String activityId, ActivityDto activity) async {
    try {
      final activityData = activity.toLiveActivitiesData();

      await _liveActivities.updateActivity(
        activityId,
        activityData['contentState'] as Map<String, dynamic>,
      );

      AppLogger.info('Updated Live Activity: $activityId');
    } catch (e, stackTrace) {
      AppLogger.error(
          'Error updating Live Activity: $activityId', e, stackTrace);
      rethrow;
    }
  }

  @override
  Future<void> endActivity(String activityId) async {
    try {
      await _liveActivities.endActivity(activityId);
      AppLogger.info('Ended Live Activity: $activityId');
    } catch (e, stackTrace) {
      AppLogger.error('Error ending Live Activity: $activityId', e, stackTrace);
      rethrow;
    }
  }

  @override
  Future<void> endAllActivities() async {
    try {
      await _liveActivities.endAllActivities();
      AppLogger.info('Ended all Live Activities');
    } catch (e, stackTrace) {
      AppLogger.error('Error ending all Live Activities', e, stackTrace);
      rethrow;
    }
  }

  @override
  Future<List<String>> getActiveActivityIds() async {
    try {
      final activeIds = await _liveActivities.getAllActivitiesIds();
      AppLogger.debug('Active Live Activities: ${activeIds.length}');
      return activeIds;
    } catch (e, stackTrace) {
      AppLogger.error('Error getting active Live Activities', e, stackTrace);
      return [];
    }
  }

  @override
  Stream<ActivityUpdateDto> get activityUpdates =>
      _activityUpdateController.stream;

  void dispose() {
    _activityUpdateController.close();
  }
}

class ActivityUpdateDto {
  const ActivityUpdateDto({
    required this.activityId,
    required this.status,
    required this.timestamp,
    this.data,
  });

  final String activityId;
  final String status;
  final DateTime timestamp;
  final Map<String, dynamic>? data;
}
