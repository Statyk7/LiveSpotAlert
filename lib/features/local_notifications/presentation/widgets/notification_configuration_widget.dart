import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../shared/di/get_it_extensions.dart';
import '../../../../shared/services/analytics_service.dart';
import '../../../../shared/ui_kit/colors.dart';
import '../../../../shared/ui_kit/spacing.dart';
import '../../../../shared/ui_kit/text_styles.dart';
import '../../../../shared/ui_kit/widgets/app_buttons.dart';
import '../../../../shared/utils/constants.dart';
import '../controllers/local_notifications_bloc.dart';
import '../controllers/local_notifications_event.dart';
import '../controllers/local_notifications_state.dart';
import '../../../../i18n/translations.g.dart';

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
            t.notifications.config.title,
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
                return AppTextButton(
                  text: state.isLoading ? t.notifications.config.saving : t.common.save,
                  onPressed: _hasUnsavedChanges && !state.isLoading ? _onSave : null,
                  isLoading: state.isLoading,
                  size: AppButtonSize.small,
                );
              },
            ),
          ],
        ),
        body: BlocBuilder<LocalNotificationsBloc, LocalNotificationsState>(
          builder: (context, state) {
            return SingleChildScrollView(
              padding: AppSpacing.cardPadding,
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

                  AppSpacing.verticalSpaceLarge,

                  // Notification Title Section
                  _buildSectionCard(
                    title: t.notifications.config.content,
                    icon: Icons.title,
                    children: [
                      Padding(
                        padding: AppSpacing.screenPaddingHorizontal,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              t.notifications.config.titleLabel,
                              style: AppTextStyles.bodyLarge
                                  .copyWith(fontWeight: FontWeight.bold),
                            ),
                            AppSpacing.verticalSpaceSmall,
                            TextField(
                              controller: _titleController,
                              decoration: InputDecoration(
                                hintText: t.notifications.config.titleHint,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(AppSpacing.radiusSmall),
                                ),
                                filled: true,
                                fillColor: AppColors.surface,
                              ),
                              maxLength: 50,
                            ),
                            AppSpacing.verticalSpaceSmall,
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                //color: AppColors.info.withValues(alpha: 26),
                                borderRadius: BorderRadius.circular(AppSpacing.radiusSmall),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    t.notifications.config.preview,
                                    style: AppTextStyles.bodySmall.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.info,
                                    ),
                                  ),
                                  SizedBox(height: AppSpacing.micro),
                                  Text(
                                    AppConstants.appName,
                                    style: AppTextStyles.bodyMedium.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    '${_titleController.text.isEmpty ? t.notifications.config.defaultTitle : _titleController.text}${t.notifications.config.locationSuffix}',
                                    style: AppTextStyles.bodyMedium,
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(height: AppSpacing.xxlarge),
                            
                            // Image Selection Section
                            Text(
                              t.notifications.config.image,
                              style: AppTextStyles.bodyLarge
                                  .copyWith(fontWeight: FontWeight.bold),
                            ),
                            AppSpacing.verticalSpaceSmall,
                            _buildImageSection(state),
                            AppSpacing.verticalSpaceLarge,
                          ],
                        ),
                      ),
                    ],
                  ),

                  AppSpacing.verticalSpaceLarge,

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

                  AppSpacing.verticalSpaceLarge,

                  // Permissions Section
                  _buildPermissionsSection(state),

                  SizedBox(height: AppSpacing.xxlarge + AppSpacing.small),

                  // Test Notification Button
                  if (state.hasPermissions)
                    AppOutlinedButton(
                      text: t.notifications.config.testNotification,
                      onPressed: () => _showTestNotification(context),
                      icon: Icons.notifications,
                      isFullWidth: true,
                      size: AppButtonSize.large,
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
        borderRadius: BorderRadius.circular(AppSpacing.radiusMedium),
      ),
      child: Column(
        children: [
          Padding(
            padding: AppSpacing.cardPadding,
            child: Row(
              children: [
                Icon(icon, color: AppColors.primary, size: 24),
                AppSpacing.horizontalSpaceMedium,
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
      title: t.notifications.config.permissions,
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
                      ? t.notifications.permissions.granted
                      : t.notifications.permissions.required,
                  style: AppTextStyles.bodyMedium,
                ),
              ),
              if (!state.hasPermissions)
                AppTextButton(
                  text: t.common.grant,
                  onPressed: () => _requestPermissions(context),
                  size: AppButtonSize.small,
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildImageSection(LocalNotificationsState state) {
    final config = state.effectiveConfig;
    final hasImage = config.hasImageData;

    return Container(
      padding: AppSpacing.cardPadding,
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.textHint),
        borderRadius: BorderRadius.circular(AppSpacing.radiusMedium),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (hasImage) ...[
            // Display current image (prefer Base64 over legacy file path)
            Container(
              height: 120,
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.textHint),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(7),
                child: _buildImagePreview(config),
              ),
            ),
            AppSpacing.verticalSpaceMedium,
            
            // Image action buttons
            Row(
              children: [
                Expanded(
                  child: AppOutlinedButton(
                    text: t.notifications.config.changeImage,
                    onPressed: state.isLoading ? null : () {
                      context.read<LocalNotificationsBloc>()
                          .add(const SelectNotificationImage());
                      _onSettingChanged();
                    },
                    icon: Icons.photo_library,
                    isFullWidth: true,
                  ),
                ),
                AppSpacing.horizontalSpaceMedium,
                Expanded(
                  child: AppOutlinedButton(
                    text: t.common.remove,
                    onPressed: state.isLoading ? null : () {
                      context.read<LocalNotificationsBloc>()
                          .add(const RemoveNotificationImage());
                      _onSettingChanged();
                    },
                    icon: Icons.delete_outline,
                    isFullWidth: true,
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
                //color: AppColors.surface.withValues(alpha: 128),
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
                  AppSpacing.verticalSpaceSmall,
                  Text(
                    t.notifications.config.noImageSelected,
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            AppSpacing.verticalSpaceMedium,
            
            // Select image button
            PrimaryButton(
              text: state.isLoading ? t.notifications.config.selecting : t.notifications.config.selectFromGallery,
              onPressed: state.isLoading ? null : () {
                context.read<LocalNotificationsBloc>()
                    .add(const SelectNotificationImage());
                _onSettingChanged();
              },
              icon: Icons.photo_library,
              isLoading: state.isLoading,
              isFullWidth: true,
            ),
          ],
          
          const SizedBox(height: 12),
          
          // Image info text
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              //color: AppColors.info.withValues(alpha: 26),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.info_outline,
                  color: AppColors.info,
                  size: 16,
                ),
                AppSpacing.horizontalSpaceSmall,
                Expanded(
                  child: Text(
                    t.notifications.config.imageInfo,
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
          ? t.notifications.config.defaultTitle
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
          title: Text(t.notifications.dialogs.unsavedChanges),
          content: Text(t.notifications.dialogs.unsavedMessage),
          actions: [
            AppTextButton(
              text: t.common.stay,
              onPressed: () => Navigator.of(context).pop(),
              size: AppButtonSize.small,
            ),
            AppTextButton(
              text: t.common.cancel,
              onPressed: () {
                Navigator.of(context).pop();
                widget.onCancel();
              },
              size: AppButtonSize.small,
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

  Widget _buildImagePreview(config) {
    // Prefer Base64 data over legacy file path
    if (config.imageBase64Data != null) {
      return _buildBase64ImagePreview(config.imageBase64Data!);
    } else if (config.imagePath != null) {
      return _buildFileImagePreview(config.imagePath!);
    } else {
      return _buildErrorImagePreview();
    }
  }

  Widget _buildBase64ImagePreview(String base64Data) {
    try {
      final bloc = context.read<LocalNotificationsBloc>();
      final imageService = bloc.imageService;
      
      final decodeResult = imageService.decodeBase64Image(base64Data);
      return decodeResult.fold(
        (failure) {
          return _buildErrorImagePreview();
        },
        (bytes) {
          return Image.memory(
            Uint8List.fromList(bytes),
            fit: BoxFit.scaleDown,
            errorBuilder: (context, error, stackTrace) {
              return _buildErrorImagePreview();
            },
          );
        },
      );
    } catch (e) {
      return _buildErrorImagePreview();
    }
  }

  Widget _buildFileImagePreview(String fileName) {
    return FutureBuilder<String?>(
      future: _getImagePath(fileName),
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
              return _buildErrorImagePreview();
            },
          );
        }
        
        return _buildErrorImagePreview();
      },
    );
  }

  Widget _buildErrorImagePreview() {
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
            t.common.errors.imageNotFound,
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
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
