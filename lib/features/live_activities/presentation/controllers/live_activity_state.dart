import 'package:equatable/equatable.dart';
import '../../../../shared/base_domain/failures/failure.dart';

enum LiveActivityStatus {
  idle,
  loading,
  active,
  configured,
  error,
}

class LiveActivityState extends Equatable {
  const LiveActivityState({
    this.status = LiveActivityStatus.idle,
    this.currentActivityId,
    this.title = '',
    this.imagePath,
    this.failure,
  });

  final LiveActivityStatus status;
  final String? currentActivityId;
  final String title;
  final String? imagePath;
  final Failure? failure;

  // Convenience getters
  bool get isIdle => status == LiveActivityStatus.idle;
  bool get isLoading => status == LiveActivityStatus.loading;
  bool get isActive => status == LiveActivityStatus.active;
  bool get isConfigured => status == LiveActivityStatus.configured;
  bool get hasError => status == LiveActivityStatus.error;
  bool get hasActiveActivity => currentActivityId != null;

  LiveActivityState copyWith({
    LiveActivityStatus? status,
    String? currentActivityId,
    String? title,
    String? imagePath,
    Failure? failure,
    bool clearActivityId = false,
    bool clearImagePath = false,
    bool clearFailure = false,
  }) {
    return LiveActivityState(
      status: status ?? this.status,
      currentActivityId: clearActivityId
          ? null
          : (currentActivityId ?? this.currentActivityId),
      title: title ?? this.title,
      imagePath: clearImagePath ? null : (imagePath ?? this.imagePath),
      failure: clearFailure ? null : (failure ?? this.failure),
    );
  }

  @override
  List<Object?> get props => [
        status,
        currentActivityId,
        title,
        imagePath,
        failure,
      ];
}
