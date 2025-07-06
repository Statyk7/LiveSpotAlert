import 'package:equatable/equatable.dart';

/// Configuration model for local notifications
class NotificationConfig extends Equatable {
  const NotificationConfig({
    required this.title,
    required this.isEnabled,
    required this.showInForeground,
    this.imagePath,
    this.imageBase64Data,
  });

  /// Custom title for notifications (e.g., "Arrived at location")
  final String title;

  /// Whether notifications are enabled
  final bool isEnabled;

  /// Whether to show notifications even when app is in foreground
  final bool showInForeground;

  /// Path to custom image for notifications (legacy - for migration)
  final String? imagePath;

  /// Base64 encoded image data for notifications
  final String? imageBase64Data;

  /// Create default configuration
  factory NotificationConfig.defaultConfig() {
    return const NotificationConfig(
      title: 'Location Alert',
      isEnabled: true,
      showInForeground: true,
      imagePath: null,
      imageBase64Data: null,
    );
  }

  /// Create from JSON for SharedPreferences storage
  factory NotificationConfig.fromJson(Map<String, dynamic> json) {
    return NotificationConfig(
      title: json['title'] as String? ?? 'Location Alert',
      isEnabled: json['isEnabled'] as bool? ?? true,
      showInForeground: json['showInForeground'] as bool? ?? true,
      imagePath: json['imagePath'] as String?,
      imageBase64Data: json['imageBase64Data'] as String?,
    );
  }

  /// Convert to JSON for SharedPreferences storage
  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'isEnabled': isEnabled,
      'showInForeground': showInForeground,
      'imagePath': imagePath,
      'imageBase64Data': imageBase64Data,
    };
  }

  /// Create a copy with modified properties
  NotificationConfig copyWith({
    String? title,
    bool? isEnabled,
    bool? showInForeground,
    String? imagePath,
    String? imageBase64Data,
    bool? clearImagePath,
    bool? clearImageBase64Data,
  }) {
    return NotificationConfig(
      title: title ?? this.title,
      isEnabled: isEnabled ?? this.isEnabled,
      showInForeground: showInForeground ?? this.showInForeground,
      imagePath: clearImagePath == true ? null : imagePath ?? this.imagePath,
      imageBase64Data: clearImageBase64Data == true ? null : imageBase64Data ?? this.imageBase64Data,
    );
  }

  @override
  List<Object?> get props => [title, isEnabled, showInForeground, imagePath, imageBase64Data];

  @override
  String toString() {
    return 'NotificationConfig(title: $title, isEnabled: $isEnabled, showInForeground: $showInForeground, imagePath: $imagePath, hasImageBase64Data: ${imageBase64Data != null})';
  }

  /// Check if the configuration has any image data (either file path or Base64)
  bool get hasImageData => imagePath != null || imageBase64Data != null;
}
