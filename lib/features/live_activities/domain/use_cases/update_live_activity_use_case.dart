import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:live_activities/live_activities.dart';
import '../../../../shared/base_domain/failures/failure.dart';
import '../../../../shared/base_domain/use_case.dart';
import 'process_image_for_live_activity_use_case.dart';

class UpdateLiveActivityParams {
  const UpdateLiveActivityParams({
    required this.activityId,
    required this.title,
    this.imagePath,
    this.customData,
  });

  final String activityId;
  final String title;
  final String? imagePath;
  final Map<String, String>? customData;
}

class UpdateLiveActivityUseCase
    implements UseCase<void, UpdateLiveActivityParams> {
  UpdateLiveActivityUseCase({
    required this.liveActivitiesPlugin,
    required this.processImageUseCase,
  });

  final LiveActivities liveActivitiesPlugin;
  final ProcessImageForLiveActivityUseCase processImageUseCase;

  @override
  Future<Either<Failure, void>> call(UpdateLiveActivityParams params) async {
    try {
      // Prepare activity data for Swift
      final activityData = <String, String>{
        'title': params.title.isEmpty ? 'Live Activity' : params.title,
        ...?params.customData,
      };

      // Add optimized image data if available
      if (params.imagePath != null) {
        final imageResult = await processImageUseCase(
          ProcessImageForLiveActivityParams(imagePath: params.imagePath!),
        );

        imageResult.fold(
          (failure) => debugPrint("Error processing image: ${failure.message}"),
          (optimizedImageData) {
            if (optimizedImageData != null) {
              activityData['image'] = optimizedImageData;
              debugPrint(
                  "Optimized image data prepared for Live Activity update");
            }
          },
        );
      }

      // Update the activity with the data
      await liveActivitiesPlugin.updateActivity(
          params.activityId, activityData);
      debugPrint("Live Activity updated: ${params.activityId}");

      return const Right(null);
    } catch (e) {
      debugPrint("Error updating Live Activity: $e");
      return Left(LiveActivityUpdateFailure(
          message: 'Error updating Live Activity: $e'));
    }
  }
}

class LiveActivityUpdateFailure extends Failure {
  const LiveActivityUpdateFailure({required super.message});
}
