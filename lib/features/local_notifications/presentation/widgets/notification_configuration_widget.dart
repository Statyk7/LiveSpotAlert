import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../shared/di/get_it_extensions.dart';
import '../../../../shared/services/analytics_service.dart';
import '../../../../shared/ui_kit/colors.dart';
import '../../../../shared/ui_kit/text_styles.dart';
import '../../../../shared/utils/constants.dart';
import '../controllers/local_notifications_bloc.dart';
import '../controllers/local_notifications_event.dart';
import '../controllers/local_notifications_state.dart';

/// Widget for configuring notification settings
class NotificationConfigurationWidget extends StatefulWidget {
  const NotificationConfigurationWidget({
    super.key,
    required this.onSave,
    required this.onCancel,
  });

  final VoidCallback onSave;
  final VoidCallback onCancel;

  @override
  State<NotificationConfigurationWidget> createState() =>
      _NotificationConfigurationWidgetState();
}

class _NotificationConfigurationWidgetState
    extends State<NotificationConfigurationWidget> {
  late final TextEditingController _titleController;
  // bool _isEnabled = true;
  // bool _showInForeground = true;
  bool _hasUnsavedChanges = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController();

    // Initialize with current configuration
    final state = context.read<LocalNotificationsBloc>().state;
    final config = state.effectiveConfig;

    _titleController.text = config.title;
    // _isEnabled = config.isEnabled;
    // _showInForeground = config.showInForeground;

    _titleController.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  void _onTextChanged() {
    setState(() {
      _hasUnsavedChanges = true;
    });
  }

  void _onSettingChanged() {
    setState(() {
      _hasUnsavedChanges = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<LocalNotificationsBloc, LocalNotificationsState>(
      listener: (context, state) {
        if (state.isLoaded && !_hasUnsavedChanges) {
          // Configuration was saved successfully
          widget.onSave();
        }

        if (state.hasError && state.errorMessage != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.errorMessage!),
              backgroundColor: AppColors.error,
            ),
          );
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: Text(
            'Notification Settings',
            style: AppTextStyles.h3.copyWith(color: Colors.white),
          ),
          backgroundColor: AppColors.primary,
          leading: IconButton(
            onPressed: _onCancel,
            icon: const Icon(Icons.close),
          ),
          actions: [
            BlocBuilder<LocalNotificationsBloc, LocalNotificationsState>(
              builder: (context, state) {
                return TextButton(
                  onPressed:
                      _hasUnsavedChanges && !state.isLoading ? _onSave : null,
                  child: Text(
                    state.isLoading ? 'Saving...' : 'Save',
                    style: TextStyle(
                      color: _hasUnsavedChanges && !state.isLoading
                          ? Colors.white
                          : Colors.white54,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                );
              },
            ),
          ],
        ),
        body: BlocBuilder<LocalNotificationsBloc, LocalNotificationsState>(
          builder: (context, state) {
            return SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Enable/Disable Section
                  // _buildSectionCard(
                  //   title: 'Notification Control',
                  //   icon: Icons.notifications,
                  //   children: [
                  //     SwitchListTile(
                  //       title: Text('Enable Notifications', style: AppTextStyles.bodyLarge),
                  //       subtitle: Text(
                  //         'Show notifications when entering/exiting geofences',
                  //         style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary),
                  //       ),
                  //       value: _isEnabled,
                  //       onChanged: (value) {
                  //         setState(() {
                  //           _isEnabled = value;
                  //         });
                  //         _onSettingChanged();
                  //       },
                  //       activeColor: AppColors.success,
                  //     ),
                  //   ],
                  // ),

                  const SizedBox(height: 16),

                  // Notification Title Section
                  _buildSectionCard(
                    title: 'Notification Content',
                    icon: Icons.title,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Title',
                              style: AppTextStyles.bodyLarge
                                  .copyWith(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 8),
                            TextField(
                              controller: _titleController,
                              decoration: InputDecoration(
                                hintText:
                                    'e.g., Arrived at location, Location alert',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                filled: true,
                                fillColor: AppColors.surface,
                              ),
                              maxLength: 50,
                            ),
                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: AppColors.info.withValues(alpha: 26),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Preview:',
                                    style: AppTextStyles.bodySmall.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.info,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    AppConstants.appName,
                                    style: AppTextStyles.bodyMedium.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    '${_titleController.text.isEmpty ? "Location Alert" : _titleController.text} @ Location',
                                    style: AppTextStyles.bodyMedium,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 24),
                            
                            // Image Selection Section
                            Text(
                              'Image',
                              style: AppTextStyles.bodyLarge
                                  .copyWith(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 8),
                            _buildImageSection(state),
                            const SizedBox(height: 16),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Display Options Section
                  // _buildSectionCard(
                  //   title: 'Display Options',
                  //   icon: Icons.mobile_friendly,
                  //   children: [
                  //     SwitchListTile(
                  //       title: Text('Show in Foreground', style: AppTextStyles.bodyLarge),
                  //       subtitle: Text(
                  //         'Display notifications even when app is open',
                  //         style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary),
                  //       ),
                  //       value: _showInForeground && _isEnabled,
                  //       onChanged: _isEnabled ? (value) {
                  //         setState(() {
                  //           _showInForeground = value;
                  //         });
                  //         _onSettingChanged();
                  //       } : null,
                  //       activeColor: AppColors.success,
                  //     ),
                  //   ],
                  // ),

                  const SizedBox(height: 16),

                  // Permissions Section
                  _buildPermissionsSection(state),

                  const SizedBox(height: 32),

                  // Test Notification Button
                  if (state.hasPermissions)
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: () => _showTestNotification(context),
                        icon: const Icon(Icons.notifications),
                        label: const Text('Test Notification'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.primary,
                          side: BorderSide(color: AppColors.primary),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                      ),
                    ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildSectionCard({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Card(
      elevation: 2,
      color: AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Icon(icon, color: AppColors.primary, size: 24),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: AppTextStyles.h4,
                ),
              ],
            ),
          ),
          ...children,
        ],
      ),
    );
  }

  Widget _buildPermissionsSection(LocalNotificationsState state) {
    return _buildSectionCard(
      title: 'Permissions',
      icon: Icons.security,
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Icon(
                state.hasPermissions ? Icons.check_circle : Icons.warning,
                color: state.hasPermissions
                    ? AppColors.success
                    : AppColors.warning,
                size: 24,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  state.hasPermissions
                      ? 'Notification permissions granted'
                      : 'Notification permissions required',
                  style: AppTextStyles.bodyMedium,
                ),
              ),
              if (!state.hasPermissions)
                TextButton(
                  onPressed: () => _requestPermissions(context),
                  child: const Text('Grant'),
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildImageSection(LocalNotificationsState state) {
    final imageFileName = state.effectiveConfig.imagePath;
    final hasImage = imageFileName != null;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.textHint),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (hasImage) ...[
            // Display current image using FutureBuilder to get full path
            Container(
              height: 120,
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.textHint),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(7),
                child: FutureBuilder<String?>(
                  future: _getImagePath(imageFileName),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Container(
                        color: AppColors.surface,
                        child: const Center(
                          child: CircularProgressIndicator(),
                        ),
                      );
                    }
                    
                    if (snapshot.hasData && snapshot.data != null) {
                      return Image.file(
                        File(snapshot.data!),
                        fit: BoxFit.scaleDown,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            color: AppColors.surface,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.broken_image,
                                  color: AppColors.textSecondary,
                                  size: 32,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Image not found',
                                  style: AppTextStyles.bodySmall.copyWith(
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      );
                    }
                    
                    return Container(
                      color: AppColors.surface,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.broken_image,
                            color: AppColors.textSecondary,
                            size: 32,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Image not found',
                            style: AppTextStyles.bodySmall.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),
            const SizedBox(height: 12),
            
            // Image action buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: state.isLoading ? null : () {
                      context.read<LocalNotificationsBloc>()
                          .add(const SelectNotificationImage());
                      _onSettingChanged();
                    },
                    icon: const Icon(Icons.photo_library),
                    label: const Text('Change Image'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.primary,
                      side: BorderSide(color: AppColors.primary),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: state.isLoading ? null : () {
                      context.read<LocalNotificationsBloc>()
                          .add(const RemoveNotificationImage());
                      _onSettingChanged();
                    },
                    icon: const Icon(Icons.delete_outline),
                    label: const Text('Remove'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.error,
                      side: BorderSide(color: AppColors.error),
                    ),
                  ),
                ),
              ],
            ),
          ] else ...[
            // No image selected state
            Container(
              height: 120,
              width: double.infinity,
              decoration: BoxDecoration(
                color: AppColors.surface.withValues(alpha: 128),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: AppColors.textHint,
                  style: BorderStyle.solid,
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.image_outlined,
                    color: AppColors.textSecondary,
                    size: 48,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'No image selected',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            
            // Select image button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: state.isLoading ? null : () {
                  context.read<LocalNotificationsBloc>()
                      .add(const SelectNotificationImage());
                  _onSettingChanged();
                },
                icon: state.isLoading 
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.photo_library),
                label: Text(state.isLoading ? 'Selecting...' : 'Select from Gallery'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ],
          
          const SizedBox(height: 12),
          
          // Image info text
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.info.withValues(alpha: 26),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.info_outline,
                  color: AppColors.info,
                  size: 16,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Images will be displayed in notifications. Supported formats: JPG, PNG. Max size: 5MB.',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.info,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _onSave() {
    final bloc = context.read<LocalNotificationsBloc>();
    final currentConfig = bloc.state.effectiveConfig;

    final newConfig = currentConfig.copyWith(
      title: _titleController.text.trim().isEmpty
          ? 'Location Alert'
          : _titleController.text.trim(),
      //isEnabled: _isEnabled,
      // showInForeground: _showInForeground,
    );

    bloc.add(SaveNotificationConfiguration(newConfig));
    _hasUnsavedChanges = false;
  }

  void _onCancel() {
    if (_hasUnsavedChanges) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Unsaved Changes'),
          content: const Text(
              'You have unsaved changes. Are you sure you want to cancel?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Stay'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                widget.onCancel();
              },
              child: const Text('Cancel'),
            ),
          ],
        ),
      );
    } else {
      widget.onCancel();
    }
  }

  void _requestPermissions(BuildContext context) {
    context
        .read<LocalNotificationsBloc>()
        .add(const RequestNotificationPermissions());
  }

  void _showTestNotification(BuildContext context) {
    getIt<AnalyticsService>().event(eventName: "test_notification_2");
    context.read<LocalNotificationsBloc>().add(const ShowTestNotification());
  }

  Future<String?> _getImagePath(String fileName) async {
    final bloc = context.read<LocalNotificationsBloc>();
    final imageService = bloc.imageService;
    
    final result = await imageService.getImagePath(fileName);
    return result.fold(
      (failure) => null,
      (path) => path,
    );
  }
}
