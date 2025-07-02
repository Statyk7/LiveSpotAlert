import 'package:equatable/equatable.dart';

abstract class LiveActivityEvent extends Equatable {
  const LiveActivityEvent();

  @override
  List<Object?> get props => [];
}

class StartLiveActivity extends LiveActivityEvent {
  const StartLiveActivity({
    required this.title,
    this.imagePath,
    this.activityId = 'livespotalert-test-activity',
  });

  final String title;
  final String? imagePath;
  final String activityId;

  @override
  List<Object?> get props => [title, imagePath, activityId];
}

class StopLiveActivity extends LiveActivityEvent {
  const StopLiveActivity({
    required this.activityId,
  });

  final String activityId;

  @override
  List<Object?> get props => [activityId];
}

class UpdateLiveActivity extends LiveActivityEvent {
  const UpdateLiveActivity({
    required this.activityId,
    required this.title,
    this.imagePath,
    this.customData,
  });

  final String activityId;
  final String title;
  final String? imagePath;
  final Map<String, String>? customData;

  @override
  List<Object?> get props => [activityId, title, imagePath, customData];
}

class ConfigureLiveActivity extends LiveActivityEvent {
  const ConfigureLiveActivity({
    required this.title,
    this.imagePath,
  });

  final String title;
  final String? imagePath;

  @override
  List<Object?> get props => [title, imagePath];
}

class ResetLiveActivity extends LiveActivityEvent {
  const ResetLiveActivity();
}

class SaveConfigurationImmediately extends LiveActivityEvent {
  const SaveConfigurationImmediately({
    required this.title,
    this.imagePath,
  });

  final String title;
  final String? imagePath;

  @override
  List<Object?> get props => [title, imagePath];
}

class LoadSavedConfiguration extends LiveActivityEvent {
  const LoadSavedConfiguration();
}