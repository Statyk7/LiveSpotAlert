import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:live_activities/live_activities.dart';
import '../../../../shared/base_domain/failures/failure.dart';
import '../../../../shared/base_domain/use_case.dart';
import 'process_image_for_live_activity_use_case.dart';

class StartLiveActivityParams {
  const StartLiveActivityParams({
    required this.activityId,
    required this.title,
    this.imagePath,
    this.removeWhenAppIsKilled = false,
  });

  final String activityId;
  final String title;
  final String? imagePath;
  final bool removeWhenAppIsKilled;
}

class StartLiveActivityUseCase
    implements UseCase<String?, StartLiveActivityParams> {
  const StartLiveActivityUseCase({
    required this.liveActivitiesPlugin,
    required this.processImageUseCase,
  });

  final LiveActivities liveActivitiesPlugin;
  final ProcessImageForLiveActivityUseCase processImageUseCase;

  @override
  Future<Either<Failure, String?>> call(StartLiveActivityParams params) async {
    try {
      // Check if Live Activities are enabled
      final activityStatus = await liveActivitiesPlugin.areActivitiesEnabled();
      debugPrint("Live Activity Enabled: $activityStatus");

      if (!activityStatus) {
        return Left(LiveActivityNotEnabledFailure());
      }

      // First, end any existing Live Activity to prevent duplicates
      try {
        await liveActivitiesPlugin.endActivity(params.activityId);
        debugPrint("Ended any existing Live Activity: ${params.activityId}");
      } catch (e) {
        debugPrint("No existing Live Activity to end: $e");
      }

      // Create the Live Activity with consistent ID
      final activityId = await liveActivitiesPlugin.createActivity(
        params.activityId,
        {}, // Empty attributes, data will be set via UserDefaults
        removeWhenAppIsKilled: params.removeWhenAppIsKilled,
      );

      debugPrint("ActivityID: $activityId");

      if (activityId != null) {
        // Prepare activity data for Swift
        final activityData = <String, String>{
          'title': params.title.isEmpty ? 'Live Activity' : params.title,
        };

        // Add optimized image data if available
        if (params.imagePath != null) {
          final imageResult = await processImageUseCase(
            ProcessImageForLiveActivityParams(imagePath: params.imagePath!),
          );

          imageResult.fold(
            (failure) =>
                debugPrint("Error processing image: ${failure.message}"),
            (optimizedImageData) {
              if (optimizedImageData != null) {
                activityData['image'] = optimizedImageData;
                debugPrint("Optimized image data prepared for Live Activity");
              }
            },
          );
        }

        // Update the activity with the actual data
        await liveActivitiesPlugin.updateActivity(activityId, activityData);
        debugPrint("Live Activity updated with title: ${params.title}");

        return Right(activityId);
      } else {
        return Left(LiveActivityCreationFailure(
            message: 'Failed to create Live Activity'));
      }
    } catch (e) {
      debugPrint("Error starting Live Activity: $e");
      return Left(LiveActivityCreationFailure(
          message: 'Error starting Live Activity: $e'));
    }
  }
}

class LiveActivityNotEnabledFailure extends Failure {
  const LiveActivityNotEnabledFailure()
      : super(message: 'Live Activities are not enabled on this device');
}

class LiveActivityCreationFailure extends Failure {
  const LiveActivityCreationFailure({required super.message});
}
