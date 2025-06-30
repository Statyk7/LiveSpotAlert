import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/material.dart';
import '../../domain/use_cases/start_live_activity_use_case.dart';
import '../../domain/use_cases/stop_live_activity_use_case.dart';
import '../../domain/use_cases/update_live_activity_use_case.dart';
import 'live_activity_event.dart';
import 'live_activity_state.dart';

class LiveActivityBloc extends Bloc<LiveActivityEvent, LiveActivityState> {
  LiveActivityBloc({
    required this.startLiveActivityUseCase,
    required this.stopLiveActivityUseCase,
    required this.updateLiveActivityUseCase,
  }) : super(const LiveActivityState()) {
    on<StartLiveActivity>(_onStartLiveActivity);
    on<StopLiveActivity>(_onStopLiveActivity);
    on<UpdateLiveActivity>(_onUpdateLiveActivity);
    on<ConfigureLiveActivity>(_onConfigureLiveActivity);
    on<ResetLiveActivity>(_onResetLiveActivity);
  }

  final StartLiveActivityUseCase startLiveActivityUseCase;
  final StopLiveActivityUseCase stopLiveActivityUseCase;
  final UpdateLiveActivityUseCase updateLiveActivityUseCase;

  Future<void> _onStartLiveActivity(
    StartLiveActivity event,
    Emitter<LiveActivityState> emit,
  ) async {
    emit(state.copyWith(
      status: LiveActivityStatus.loading,
      clearFailure: true,
    ));

    final result = await startLiveActivityUseCase(
      StartLiveActivityParams(
        activityId: event.activityId,
        title: event.title,
        imagePath: event.imagePath,
      ),
    );

    result.fold(
      (failure) => emit(state.copyWith(
        status: LiveActivityStatus.error,
        failure: failure,
      )),
      (activityId) => emit(state.copyWith(
        status: LiveActivityStatus.active,
        currentActivityId: activityId,
        title: event.title,
        imagePath: event.imagePath,
      )),
    );
  }

  Future<void> _onStopLiveActivity(
    StopLiveActivity event,
    Emitter<LiveActivityState> emit,
  ) async {
    emit(state.copyWith(
      status: LiveActivityStatus.loading,
      clearFailure: true,
    ));

    final result = await stopLiveActivityUseCase(
      StopLiveActivityParams(activityId: event.activityId),
    );

    result.fold(
      (failure) => emit(state.copyWith(
        status: LiveActivityStatus.error,
        failure: failure,
      )),
      (_) => emit(state.copyWith(
        status: LiveActivityStatus.idle,
        clearActivityId: true,
      )),
    );
  }

  Future<void> _onUpdateLiveActivity(
    UpdateLiveActivity event,
    Emitter<LiveActivityState> emit,
  ) async {
    emit(state.copyWith(
      status: LiveActivityStatus.loading,
      clearFailure: true,
    ));

    final result = await updateLiveActivityUseCase(
      UpdateLiveActivityParams(
        activityId: event.activityId,
        title: event.title,
        imagePath: event.imagePath,
        customData: event.customData,
      ),
    );

    result.fold(
      (failure) => emit(state.copyWith(
        status: LiveActivityStatus.error,
        failure: failure,
      )),
      (_) => emit(state.copyWith(
        status: LiveActivityStatus.active,
        title: event.title,
        imagePath: event.imagePath,
      )),
    );
  }

  void _onConfigureLiveActivity(
    ConfigureLiveActivity event,
    Emitter<LiveActivityState> emit,
  ) {
    emit(state.copyWith(
      status: LiveActivityStatus.configured,
      title: event.title,
      imagePath: event.imagePath,
      clearFailure: true,
    ));
  }

  void _onResetLiveActivity(
    ResetLiveActivity event,
    Emitter<LiveActivityState> emit,
  ) {
    emit(const LiveActivityState());
  }

  @override
  Future<void> close() async {
    // Clean up any active Live Activity when BLoC is disposed
    if (state.hasActiveActivity) {
      await stopLiveActivityUseCase(
        StopLiveActivityParams(activityId: state.currentActivityId!),
      );
      debugPrint("Live Activity cleaned up during BLoC disposal: ${state.currentActivityId}");
    }
    return super.close();
  }
}