import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:live_activities/live_activities.dart';
import '../../../../shared/base_domain/failures/failure.dart';
import '../../../../shared/base_domain/use_case.dart';

class StopLiveActivityParams {
  const StopLiveActivityParams({
    required this.activityId,
  });

  final String activityId;
}

class StopLiveActivityUseCase implements UseCase<void, StopLiveActivityParams> {
  StopLiveActivityUseCase({
    required this.liveActivitiesPlugin,
  });

  final LiveActivities liveActivitiesPlugin;

  @override
  Future<Either<Failure, void>> call(StopLiveActivityParams params) async {
    try {
      await liveActivitiesPlugin.endActivity(params.activityId);
      debugPrint("Live Activity stopped: ${params.activityId}");
      
      return const Right(null);
    } catch (e) {
      debugPrint("Error stopping Live Activity: $e");
      return Left(LiveActivityStopFailure(message: 'Error stopping Live Activity: $e'));
    }
  }
}

class LiveActivityStopFailure extends Failure {
  const LiveActivityStopFailure({required super.message});
}