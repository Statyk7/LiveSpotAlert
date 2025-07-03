import 'package:equatable/equatable.dart';
import '../../domain/models/notification_config.dart';

/// Base class for all local notification events
abstract class LocalNotificationsEvent extends Equatable {
  const LocalNotificationsEvent();

  @override
  List<Object?> get props => [];
}

/// Event to load saved notification configuration
class LoadNotificationConfiguration extends LocalNotificationsEvent {
  const LoadNotificationConfiguration();
}

/// Event to save notification configuration
class SaveNotificationConfiguration extends LocalNotificationsEvent {
  const SaveNotificationConfiguration(this.config);

  final NotificationConfig config;

  @override
  List<Object?> get props => [config];
}

/// Event to update notification title
class UpdateNotificationTitle extends LocalNotificationsEvent {
  const UpdateNotificationTitle(this.title);

  final String title;

  @override
  List<Object?> get props => [title];
}

/// Event to toggle notification enabled state
class ToggleNotificationsEnabled extends LocalNotificationsEvent {
  const ToggleNotificationsEnabled(this.enabled);

  final bool enabled;

  @override
  List<Object?> get props => [enabled];
}

/// Event to toggle foreground notification display
class ToggleForegroundNotifications extends LocalNotificationsEvent {
  const ToggleForegroundNotifications(this.showInForeground);

  final bool showInForeground;

  @override
  List<Object?> get props => [showInForeground];
}

/// Event to request notification permissions
class RequestNotificationPermissions extends LocalNotificationsEvent {
  const RequestNotificationPermissions();
}

/// Event to show a test notification
class ShowTestNotification extends LocalNotificationsEvent {
  const ShowTestNotification();
}

/// Event to dismiss all notifications
class DismissAllNotifications extends LocalNotificationsEvent {
  const DismissAllNotifications();
}