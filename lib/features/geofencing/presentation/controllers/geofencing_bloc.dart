import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../shared/base_domain/use_case.dart';
import '../../../../shared/utils/logger.dart';
import '../../domain/models/geofence.dart';
import '../../domain/use_cases/create_geofence_use_case.dart';
import '../../domain/use_cases/delete_geofence_use_case.dart';
import '../../domain/use_cases/get_geofences_use_case.dart';
import '../../domain/use_cases/get_location_events_use_case.dart';
import '../../domain/use_cases/monitor_location_use_case.dart';
import '../../domain/use_cases/stop_monitoring_use_case.dart';
import '../../domain/use_cases/update_geofence_use_case.dart';
import '../../domain/services/geofencing_service.dart';
import '../../../../shared/services/user_preferences_service.dart';
import 'geofencing_event.dart';
import 'geofencing_state.dart';

// Internal events (from streams)
class _LocationEventReceived extends GeofencingEvent {
  const _LocationEventReceived(this.result);

  final MonitorLocationResult result;

  @override
  List<Object?> get props => [result];
}

class _MonitoringError extends GeofencingEvent {
  const _MonitoringError(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}

class GeofencingBloc extends Bloc<GeofencingEvent, GeofencingState> {
  GeofencingBloc({
    required this.getGeofencesUseCase,
    required this.createGeofenceUseCase,
    required this.updateGeofenceUseCase,
    required this.deleteGeofenceUseCase,
    required this.monitorLocationUseCase,
    required this.stopMonitoringUseCase,
    required this.getLocationEventsUseCase,
    required this.geofencingService,
    required this.userPreferencesService,
  }) : super(const GeofencingState()) {
    // Register event handlers
    on<GeofencingStarted>(_onGeofencingStarted);
    on<LoadGeofences>(_onLoadGeofences);
    on<CreateGeofence>(_onCreateGeofence);
    on<UpdateGeofence>(_onUpdateGeofence);
    on<DeleteGeofence>(_onDeleteGeofence);
    on<StartMonitoring>(_onStartMonitoring);
    on<StopMonitoring>(_onStopMonitoring);
    on<ToggleGeofenceActive>(_onToggleGeofenceActive);
    on<LoadLocationEvents>(_onLoadLocationEvents);
    on<RequestLocationPermissions>(_onRequestLocationPermissions);
    on<CheckLocationPermissions>(_onCheckLocationPermissions);
    on<_LocationEventReceived>(_onLocationEventReceived);
    on<_MonitoringError>(_onMonitoringError);
    on<RefreshGeofences>(_onRefreshGeofences);
    on<SelectGeofence>(_onSelectGeofence);
    on<ClearError>(_onClearError);
  }

  final GetGeofencesUseCase getGeofencesUseCase;
  final CreateGeofenceUseCase createGeofenceUseCase;
  final UpdateGeofenceUseCase updateGeofenceUseCase;
  final DeleteGeofenceUseCase deleteGeofenceUseCase;
  final MonitorLocationUseCase monitorLocationUseCase;
  final StopMonitoringUseCase stopMonitoringUseCase;
  final GetLocationEventsUseCase getLocationEventsUseCase;
  final GeofencingService geofencingService;
  final UserPreferencesService userPreferencesService;

  StreamSubscription<dynamic>? _monitoringSubscription;
  bool _hasAttemptedAutoStart = false;

  Future<void> _onGeofencingStarted(
    GeofencingStarted event,
    Emitter<GeofencingState> emit,
  ) async {
    AppLogger.info('Geofencing BLoC started');

    // Check permissions first
    add(const CheckLocationPermissions());

    // Load existing geofences
    add(const LoadGeofences());

    // Load recent location events
    add(const LoadLocationEvents(GetLocationEventsParams.recent()));

    // Load monitoring preference and start monitoring if enabled (only on first startup)
    if (!_hasAttemptedAutoStart) {
      _hasAttemptedAutoStart = true;

      // Add a small delay to prevent race conditions with user actions
      await Future.delayed(const Duration(milliseconds: 100));

      final monitoringResult =
          await userPreferencesService.getMonitoringEnabled();
      monitoringResult.fold(
        (failure) {
          AppLogger.error(
              'Failed to load monitoring preference: ${failure.message}');
        },
        (isEnabled) async {
          AppLogger.info(
              'Initial startup - Loaded monitoring preference: $isEnabled, current isMonitoring: ${state.isMonitoring}');
          if (isEnabled && !state.isMonitoring) {
            // Only auto-start if not already monitoring
            // Check if we have permissions first
            final permissionResult =
                await geofencingService.hasRequiredPermissions();
            permissionResult.fold(
              (failure) {
                AppLogger.warning(
                    'Cannot auto-start monitoring: ${failure.message}');
              },
              (hasPermissions) {
                if (hasPermissions) {
                  AppLogger.info(
                      'Auto-starting monitoring from saved preference');
                  add(const StartMonitoring());
                } else {
                  AppLogger.info(
                      'Monitoring preference saved but permissions not granted');
                }
              },
            );
          } else if (isEnabled && state.isMonitoring) {
            AppLogger.info(
                'Monitoring preference is enabled but already monitoring - skipping auto-start');
          }
        },
      );
    } else {
      AppLogger.info('Skipping auto-start monitoring - already attempted');
    }
  }

  Future<void> _onLoadGeofences(
    LoadGeofences event,
    Emitter<GeofencingState> emit,
  ) async {
    emit(state.copyWith(status: GeofencingStatus.loading));

    try {
      final result = await getGeofencesUseCase(const NoParams());

      result.fold(
        (failure) {
          AppLogger.error('Failed to load geofences: ${failure.message}');
          emit(state.copyWith(
            status: GeofencingStatus.error,
            errorMessage: failure.message,
          ));
        },
        (geofences) async {
          AppLogger.info('Loaded ${geofences.length} geofences');

          // Create empty geofence if none exist for MVP
          if (geofences.isEmpty) {
            AppLogger.info(
                'No geofences found, creating default empty geofence');
            final defaultGeofence = CreateGeofenceParams(
              name: 'My Location',
              latitude: 0.0,
              longitude: 0.0,
              radius: 100.0,
              description: 'Configure this geofence by tapping the edit button',
            );

            final createResult = await createGeofenceUseCase(defaultGeofence);
            createResult.fold(
              (failure) {
                AppLogger.error(
                    'Failed to create default geofence: ${failure.message}');
                emit(state.copyWith(
                  status: GeofencingStatus.loaded,
                  geofences: geofences,
                  clearError: true,
                ));
              },
              (newGeofence) {
                AppLogger.info('Created default geofence: ${newGeofence.name}');
                emit(state.copyWith(
                  status: GeofencingStatus.loaded,
                  geofences: [newGeofence],
                  clearError: true,
                ));
              },
            );
          } else {
            emit(state.copyWith(
              status: GeofencingStatus.loaded,
              geofences: geofences,
              clearError: true,
            ));
          }
        },
      );
    } catch (e, stackTrace) {
      AppLogger.error('Unexpected error loading geofences', e, stackTrace);
      emit(state.copyWith(
        status: GeofencingStatus.error,
        errorMessage: 'Unexpected error loading geofences: $e',
      ));
    }
  }

  Future<void> _onCreateGeofence(
    CreateGeofence event,
    Emitter<GeofencingState> emit,
  ) async {
    emit(state.copyWith(status: GeofencingStatus.loading));

    try {
      final result = await createGeofenceUseCase(event.params);

      result.fold(
        (failure) {
          AppLogger.error('Failed to create geofence: ${failure.message}');
          emit(state.copyWith(
            status: GeofencingStatus.error,
            errorMessage: failure.message,
          ));
        },
        (geofence) {
          AppLogger.info('Created geofence: ${geofence.name}');

          // Add to current list
          final updatedGeofences = List<Geofence>.from(state.geofences)
            ..add(geofence);

          emit(state.copyWith(
            status: GeofencingStatus.loaded,
            geofences: updatedGeofences,
            selectedGeofence: geofence,
            clearError: true,
          ));

          // If monitoring is active and geofence is active, restart monitoring
          if (state.isMonitoring && geofence.isActive) {
            add(const StartMonitoring());
          }
        },
      );
    } catch (e, stackTrace) {
      AppLogger.error('Unexpected error creating geofence', e, stackTrace);
      emit(state.copyWith(
        status: GeofencingStatus.error,
        errorMessage: 'Unexpected error creating geofence: $e',
      ));
    }
  }

  Future<void> _onUpdateGeofence(
    UpdateGeofence event,
    Emitter<GeofencingState> emit,
  ) async {
    emit(state.copyWith(status: GeofencingStatus.loading));

    try {
      final result = await updateGeofenceUseCase(event.params);

      result.fold(
        (failure) {
          AppLogger.error('Failed to update geofence: ${failure.message}');
          emit(state.copyWith(
            status: GeofencingStatus.error,
            errorMessage: failure.message,
          ));
        },
        (updatedGeofence) {
          AppLogger.info('Updated geofence: ${updatedGeofence.name}');

          // Update in current list
          final updatedGeofences = state.geofences.map((g) {
            return g.id == updatedGeofence.id ? updatedGeofence : g;
          }).toList();

          emit(state.copyWith(
            status: GeofencingStatus.loaded,
            geofences: updatedGeofences,
            selectedGeofence: updatedGeofence,
            clearError: true,
          ));

          // Restart monitoring to pick up changes
          if (state.isMonitoring) {
            add(const StartMonitoring());
          }
        },
      );
    } catch (e, stackTrace) {
      AppLogger.error('Unexpected error updating geofence', e, stackTrace);
      emit(state.copyWith(
        status: GeofencingStatus.error,
        errorMessage: 'Unexpected error updating geofence: $e',
      ));
    }
  }

  Future<void> _onDeleteGeofence(
    DeleteGeofence event,
    Emitter<GeofencingState> emit,
  ) async {
    emit(state.copyWith(status: GeofencingStatus.loading));

    try {
      final result = await deleteGeofenceUseCase(event.params);

      result.fold(
        (failure) {
          AppLogger.error('Failed to delete geofence: ${failure.message}');
          emit(state.copyWith(
            status: GeofencingStatus.error,
            errorMessage: failure.message,
          ));
        },
        (_) {
          AppLogger.info('Deleted geofence: ${event.params.geofenceId}');

          // Remove from current list
          final updatedGeofences = state.geofences
              .where((g) => g.id != event.params.geofenceId)
              .toList();

          // Clear selection if deleted geofence was selected
          final clearSelection =
              state.selectedGeofence?.id == event.params.geofenceId;

          emit(state.copyWith(
            status: GeofencingStatus.loaded,
            geofences: updatedGeofences,
            clearSelectedGeofence: clearSelection,
            clearError: true,
          ));
        },
      );
    } catch (e, stackTrace) {
      AppLogger.error('Unexpected error deleting geofence', e, stackTrace);
      emit(state.copyWith(
        status: GeofencingStatus.error,
        errorMessage: 'Unexpected error deleting geofence: $e',
      ));
    }
  }

  Future<void> _onStartMonitoring(
    StartMonitoring event,
    Emitter<GeofencingState> emit,
  ) async {
    try {
      // Cancel existing subscription
      await _monitoringSubscription?.cancel();

      emit(state.copyWith(status: GeofencingStatus.loading));

      final params = MonitorLocationParams(
        startMonitoring: true,
        includeLocationEvents: event.includeLocationEvents,
        includeGeofenceStatuses: event.includeGeofenceStatuses,
      );

      // Start monitoring stream
      _monitoringSubscription = monitorLocationUseCase(params).listen(
        (result) {
          result.fold(
            (failure) {
              add(_MonitoringError(failure.message));
            },
            (monitorResult) {
              add(_LocationEventReceived(monitorResult));
            },
          );
        },
        onError: (error) {
          add(_MonitoringError('Monitoring stream error: $error'));
        },
      );

      AppLogger.info('Started geofence monitoring');
      emit(state.copyWith(
        status: GeofencingStatus.monitoring,
        isMonitoring: true,
        clearError: true,
      ));

      // Save monitoring preference
      await _saveMonitoringPreference(true);
    } catch (e, stackTrace) {
      AppLogger.error('Error starting monitoring', e, stackTrace);
      emit(state.copyWith(
        status: GeofencingStatus.error,
        errorMessage: 'Failed to start monitoring: $e',
        isMonitoring: false,
      ));
    }
  }

  Future<void> _onStopMonitoring(
    StopMonitoring event,
    Emitter<GeofencingState> emit,
  ) async {
    try {
      // Cancel stream subscription first
      await _monitoringSubscription?.cancel();
      _monitoringSubscription = null;

      // Stop monitoring service
      final result = await stopMonitoringUseCase(const NoParams());

      result.fold(
        (failure) {
          AppLogger.error('Failed to stop monitoring: ${failure.message}');
          emit(state.copyWith(
            status: GeofencingStatus.error,
            errorMessage: failure.message,
            isMonitoring: false,
          ));
        },
        (_) {
          AppLogger.info('Stopped geofence monitoring');
          emit(state.copyWith(
            status: GeofencingStatus.loaded,
            isMonitoring: false,
            clearError: true,
          ));
        },
      );

      // Save monitoring preference after state is updated
      await _saveMonitoringPreference(false);
    } catch (e, stackTrace) {
      AppLogger.error('Error stopping monitoring', e, stackTrace);
      emit(state.copyWith(
        status: GeofencingStatus.error,
        errorMessage: 'Failed to stop monitoring: $e',
        isMonitoring: false,
      ));

      // Still save preference even on error
      await _saveMonitoringPreference(false);
    }
  }

  Future<void> _onToggleGeofenceActive(
    ToggleGeofenceActive event,
    Emitter<GeofencingState> emit,
  ) async {
    final geofence = state.getGeofenceById(event.geofenceId);
    if (geofence == null) {
      emit(state.copyWith(
        status: GeofencingStatus.error,
        errorMessage: 'Geofence not found: ${event.geofenceId}',
      ));
      return;
    }

    final updatedGeofence = geofence.copyWith(isActive: !geofence.isActive);
    add(UpdateGeofence(UpdateGeofenceParams(geofence: updatedGeofence)));
  }

  Future<void> _onLoadLocationEvents(
    LoadLocationEvents event,
    Emitter<GeofencingState> emit,
  ) async {
    try {
      final result = await getLocationEventsUseCase(event.params);

      result.fold(
        (failure) {
          AppLogger.error('Failed to load location events: ${failure.message}');
          // Don't emit error state for events, just log it
        },
        (events) {
          AppLogger.debug('Loaded ${events.length} location events');
          emit(state.copyWith(
            locationEvents: events,
          ));
        },
      );
    } catch (e, stackTrace) {
      AppLogger.error(
          'Unexpected error loading location events', e, stackTrace);
    }
  }

  Future<void> _onRequestLocationPermissions(
    RequestLocationPermissions event,
    Emitter<GeofencingState> emit,
  ) async {
    try {
      final result = await geofencingService.requestLocationPermissions();

      result.fold(
        (failure) {
          AppLogger.error('Failed to request permissions: ${failure.message}');
          emit(state.copyWith(
            hasLocationPermissions: false,
            errorMessage: failure.message,
          ));
        },
        (granted) {
          AppLogger.info('Location permissions granted: $granted');
          emit(state.copyWith(
            hasLocationPermissions: granted,
            clearError: granted,
          ));
        },
      );
    } catch (e, stackTrace) {
      AppLogger.error('Error requesting permissions', e, stackTrace);
      emit(state.copyWith(
        hasLocationPermissions: false,
        errorMessage: 'Failed to request permissions: $e',
      ));
    }
  }

  Future<void> _onCheckLocationPermissions(
    CheckLocationPermissions event,
    Emitter<GeofencingState> emit,
  ) async {
    try {
      final result = await geofencingService.hasRequiredPermissions();

      result.fold(
        (failure) {
          AppLogger.error('Failed to check permissions: ${failure.message}');
          emit(state.copyWith(hasLocationPermissions: false));
        },
        (hasPermissions) {
          AppLogger.debug('Has location permissions: $hasPermissions');
          emit(state.copyWith(hasLocationPermissions: hasPermissions));
        },
      );
    } catch (e, stackTrace) {
      AppLogger.error('Error checking permissions', e, stackTrace);
      emit(state.copyWith(hasLocationPermissions: false));
    }
  }

  Future<void> _onLocationEventReceived(
    _LocationEventReceived event,
    Emitter<GeofencingState> emit,
  ) async {
    final result = event.result;

    // Handle location events
    if (result.locationEvent != null) {
      final newEvent = result.locationEvent!;
      AppLogger.info(
          'Received location event: ${newEvent.eventType} for ${newEvent.geofence.name}');

      // Add to events list (keep last 100 events)
      final updatedEvents = [newEvent, ...state.locationEvents];
      if (updatedEvents.length > 100) {
        updatedEvents.removeRange(100, updatedEvents.length);
      }

      emit(state.copyWith(locationEvents: updatedEvents));
    }

    // Handle geofence status updates
    if (result.geofenceStatuses != null) {
      AppLogger.debug(
          'Received geofence status update for ${result.geofenceStatuses!.length} geofences');
      emit(state.copyWith(geofenceStatuses: result.geofenceStatuses));
    }
  }

  Future<void> _onMonitoringError(
    _MonitoringError event,
    Emitter<GeofencingState> emit,
  ) async {
    AppLogger.error('Monitoring error: ${event.message}');
    emit(state.copyWith(
      status: GeofencingStatus.error,
      errorMessage: event.message,
      isMonitoring: false,
    ));

    // Cancel monitoring subscription
    await _monitoringSubscription?.cancel();
    _monitoringSubscription = null;
  }

  Future<void> _onRefreshGeofences(
    RefreshGeofences event,
    Emitter<GeofencingState> emit,
  ) async {
    add(const LoadGeofences());
    add(const LoadLocationEvents(GetLocationEventsParams.recent()));
  }

  Future<void> _onSelectGeofence(
    SelectGeofence event,
    Emitter<GeofencingState> emit,
  ) async {
    emit(state.copyWith(selectedGeofence: event.geofence));
  }

  Future<void> _onClearError(
    ClearError event,
    Emitter<GeofencingState> emit,
  ) async {
    emit(state.copyWith(clearError: true));
  }

  /// Save monitoring preference to persistent storage
  Future<void> _saveMonitoringPreference(bool enabled) async {
    final result = await userPreferencesService.setMonitoringEnabled(enabled);
    result.fold(
      (failure) {
        AppLogger.error(
            'Failed to save monitoring preference: ${failure.message}');
      },
      (_) {
        AppLogger.debug('Monitoring preference saved: $enabled');
      },
    );
  }

  @override
  Future<void> close() async {
    await _monitoringSubscription?.cancel();
    return super.close();
  }
}
