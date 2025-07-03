import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:io';
import '../../domain/use_cases/start_live_activity_use_case.dart';
import '../../domain/use_cases/stop_live_activity_use_case.dart';
import '../../domain/use_cases/update_live_activity_use_case.dart';
import '../../domain/services/live_activity_service.dart';
import 'live_activity_event.dart';
import 'live_activity_state.dart';

class LiveActivityBloc extends Bloc<LiveActivityEvent, LiveActivityState> {
  LiveActivityBloc({
    required this.startLiveActivityUseCase,
    required this.stopLiveActivityUseCase,
    required this.updateLiveActivityUseCase,
    required this.liveActivityService,
  }) : super(const LiveActivityState()) {
    on<StartLiveActivity>(_onStartLiveActivity);
    on<StopLiveActivity>(_onStopLiveActivity);
    on<UpdateLiveActivity>(_onUpdateLiveActivity);
    on<ConfigureLiveActivity>(_onConfigureLiveActivity);
    on<ResetLiveActivity>(_onResetLiveActivity);
    on<SaveConfigurationImmediately>(_onSaveConfigurationImmediately);
    on<LoadSavedConfiguration>(_onLoadSavedConfiguration);
  }

  final StartLiveActivityUseCase startLiveActivityUseCase;
  final StopLiveActivityUseCase stopLiveActivityUseCase;
  final UpdateLiveActivityUseCase updateLiveActivityUseCase;
  final LiveActivityService liveActivityService;

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

  Future<void> _onSaveConfigurationImmediately(
    SaveConfigurationImmediately event,
    Emitter<LiveActivityState> emit,
  ) async {
    try {
      debugPrint(
          'SaveConfigurationImmediately: title="${event.title}", imagePath="${event.imagePath}"');

      // Convert image file to base64 if provided
      String? imageData;
      if (event.imagePath != null) {
        debugPrint(
            'SaveConfigurationImmediately: Processing image file: ${event.imagePath}');
        final imageFile = File(event.imagePath!);
        if (await imageFile.exists()) {
          final bytes = await imageFile.readAsBytes();
          imageData = base64Encode(bytes);
          debugPrint(
              'SaveConfigurationImmediately: Converted ${bytes.length} bytes to base64 (length: ${imageData.length})');
        } else {
          debugPrint(
              'SaveConfigurationImmediately: Image file does not exist: ${event.imagePath}');
        }
      } else {
        debugPrint('SaveConfigurationImmediately: No image path provided');
      }

      // Save configuration using the Live Activity service
      final result = await liveActivityService.saveConfiguration(
        title: event.title,
        imageData: imageData,
      );

      result.fold(
        (failure) {
          debugPrint(
              'Failed to save Live Activity configuration: ${failure.message}');
          // Still update the local state even if persistence fails
          emit(state.copyWith(
            status: LiveActivityStatus.configured,
            title: event.title,
            imagePath: event.imagePath,
          ));
        },
        (_) {
          emit(state.copyWith(
            status: LiveActivityStatus.configured,
            title: event.title,
            imagePath: event.imagePath,
            clearFailure: true,
          ));
        },
      );
    } catch (e) {
      debugPrint('Error saving Live Activity configuration: $e');
      // Still update the local state even if persistence fails
      emit(state.copyWith(
        status: LiveActivityStatus.configured,
        title: event.title,
        imagePath: event.imagePath,
      ));
    }
  }

  Future<void> _onLoadSavedConfiguration(
    LoadSavedConfiguration event,
    Emitter<LiveActivityState> emit,
  ) async {
    try {
      final result = await liveActivityService.getActiveConfiguration();

      result.fold(
        (failure) {
          debugPrint(
              'Failed to load saved Live Activity configuration: ${failure.message}');
          // Don't emit error state, just keep current state
        },
        (config) {
          if (config != null) {
            debugPrint(
                'LoadSavedConfiguration: Found config - title: "${config.title}", hasImageData: ${config.imageData != null}');

            // Convert base64 image data back to file if needed
            String? imagePath;
            if (config.imageData != null && config.imageData!.isNotEmpty) {
              try {
                // Validate the base64 data before using it
                final testData = config.imageData!;
                debugPrint(
                    'LoadSavedConfiguration: Image data length: ${testData.length}');
                debugPrint(
                    'LoadSavedConfiguration: Image data preview: ${testData.substring(0, testData.length > 100 ? 100 : testData.length)}...');

                String cleanBase64 = testData;
                if (testData.contains(',')) {
                  cleanBase64 = testData.split(',').last;
                  debugPrint(
                      'LoadSavedConfiguration: Cleaned base64 length: ${cleanBase64.length}');
                }

                // Try to decode a small portion to validate
                if (cleanBase64.length > 50) {
                  base64Decode(cleanBase64.substring(0, 48));
                  debugPrint(
                      'LoadSavedConfiguration: Base64 validation successful');
                }

                imagePath = config.imageData;
                debugPrint(
                    'LoadSavedConfiguration: Setting imagePath to imageData');
              } catch (e) {
                debugPrint(
                    'Invalid base64 image data in saved configuration: $e');
                imagePath = null;
              }
            } else {
              debugPrint('LoadSavedConfiguration: No image data in config');
            }

            emit(state.copyWith(
              status: LiveActivityStatus.configured,
              title: config.title,
              imagePath: imagePath,
              clearFailure: true,
            ));
          }
        },
      );
    } catch (e) {
      debugPrint('Error loading saved Live Activity configuration: $e');
      // Don't emit error state, just keep current state
    }
  }

  @override
  Future<void> close() async {
    // Clean up any active Live Activity when BLoC is disposed
    if (state.hasActiveActivity) {
      await stopLiveActivityUseCase(
        StopLiveActivityParams(activityId: state.currentActivityId!),
      );
      debugPrint(
          "Live Activity cleaned up during BLoC disposal: ${state.currentActivityId}");
    }
    return super.close();
  }
}
