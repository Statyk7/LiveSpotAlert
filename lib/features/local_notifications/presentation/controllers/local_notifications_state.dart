import 'package:equatable/equatable.dart';
import '../../domain/models/notification_config.dart';

/// Status enum for notification operations
enum NotificationStatus {
  initial,
  loading,
  loaded,
  error,
  permissionDenied,
  permissionGranted,
}

/// State for local notifications feature
class LocalNotificationsState extends Equatable {
  const LocalNotificationsState({
    this.status = NotificationStatus.initial,
    this.config,
    this.hasPermissions = false,
    this.errorMessage,
  });

  final NotificationStatus status;
  final NotificationConfig? config;
  final bool hasPermissions;
  final String? errorMessage;

  /// Create a copy with modified properties
  LocalNotificationsState copyWith({
    NotificationStatus? status,
    NotificationConfig? config,
    bool? hasPermissions,
    String? errorMessage,
  }) {
    return LocalNotificationsState(
      status: status ?? this.status,
      config: config ?? this.config,
      hasPermissions: hasPermissions ?? this.hasPermissions,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  /// Clear error message
  LocalNotificationsState clearError() {
    return copyWith(
      status: status == NotificationStatus.error
          ? NotificationStatus.loaded
          : status,
      errorMessage: null,
    );
  }

  /// Convenience getters
  bool get isLoading => status == NotificationStatus.loading;
  bool get isLoaded => status == NotificationStatus.loaded;
  bool get hasError => status == NotificationStatus.error;
  bool get isInitial => status == NotificationStatus.initial;

  /// Get effective configuration (default if null)
  NotificationConfig get effectiveConfig =>
      config ?? NotificationConfig.defaultConfig();

  /// Check if notifications are available (enabled and has permissions)
  bool get areNotificationsAvailable =>
      effectiveConfig.isEnabled && hasPermissions;

  @override
  List<Object?> get props => [status, config, hasPermissions, errorMessage];

  @override
  String toString() {
    return 'LocalNotificationsState(status: $status, config: $config, hasPermissions: $hasPermissions, errorMessage: $errorMessage)';
  }
}
