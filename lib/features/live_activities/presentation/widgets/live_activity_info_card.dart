import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../shared/ui_kit/colors.dart';
import '../../../../shared/ui_kit/text_styles.dart';
import '../controllers/live_activity_bloc.dart';
import '../controllers/live_activity_state.dart';
import 'live_activity_controller_widget.dart';

class LiveActivityInfoCard extends StatelessWidget {
  const LiveActivityInfoCard({
    super.key,
    required this.title,
    this.onConfigurePressed,
  });

  final String title;
  final VoidCallback? onConfigurePressed;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LiveActivityBloc, LiveActivityState>(
      builder: (context, state) {
        return Card(
          elevation: 4,
          color: AppColors.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Row
                Row(
                  children: [
                    Icon(
                      Icons.notifications_active,
                      color: state.isActive
                          ? AppColors.geofenceActive
                          : AppColors.primary,
                      size: 28,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Live Activity',
                            style: AppTextStyles.h4,
                          ),
                          Text(
                            _getStatusDescription(state),
                            style: AppTextStyles.caption.copyWith(
                              color: state.isActive
                                  ? AppColors.geofenceActive
                                  : AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    if (onConfigurePressed != null)
                      IconButton(
                        onPressed: state.isLoading ? null : onConfigurePressed,
                        icon: const Icon(Icons.edit),
                        tooltip: 'Configure Live Activity',
                        style: IconButton.styleFrom(
                          foregroundColor: AppColors.primary,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 16),
                // Content Row
                if (state.imagePath != null || state.title.isNotEmpty) ...[
                  Row(
                    children: [
                      if (state.imagePath != null) ...[
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: _buildImage(state.imagePath!),
                        ),
                        const SizedBox(width: 12),
                      ],
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.title,
                                    color: AppColors.info, size: 18),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    state.title.isEmpty ? title : state.title,
                                    style: AppTextStyles.bodyMedium,
                                  ),
                                ),
                              ],
                            ),
                            if (state.imagePath != null) ...[
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  Icon(Icons.image,
                                      color: AppColors.info, size: 18),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Custom image configured',
                                    style: AppTextStyles.bodyMedium,
                                  ),
                                ],
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Live Activity Preview/Controls
                  LiveActivityControllerWidget(
                    title: 'Test Live Activity',
                    onConfigurePressed: () => onConfigurePressed!(),
                  ),
                ] else ...[
                  Row(
                    children: [
                      Icon(Icons.info_outline, color: AppColors.info, size: 18),
                      const SizedBox(width: 8),
                      Text(
                        'Configure your Live Activity notification',
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildImage(String imagePath) {
    debugPrint(
        'LiveActivityInfoCard: Building image for path: ${imagePath.substring(0, imagePath.length > 100 ? 100 : imagePath.length)}...');
    debugPrint(
        'LiveActivityInfoCard: Is base64? ${_isBase64String(imagePath)}');

    // Check if it's base64 data or file path
    if (_isBase64String(imagePath)) {
      debugPrint('LiveActivityInfoCard: Rendering as base64 image');
      return _buildBase64Image(imagePath);
    } else {
      debugPrint('LiveActivityInfoCard: Rendering as file image');
      return _buildFileImage(imagePath);
    }
  }

  bool _isBase64String(String str) {
    // Check common base64 indicators
    if (str.startsWith('data:')) return true;
    if (str.startsWith('/9j/') || str.startsWith('iVBORw0KGgo')) return true;

    // Check if it's likely a file path
    if (str.contains('/') ||
        str.contains('\\') ||
        str.startsWith('/') ||
        str.contains('.')) {
      return false;
    }

    // For base64, check length and valid characters
    if (str.length > 100) {
      final base64Regex = RegExp(r'^[A-Za-z0-9+/]*={0,2}$');
      if (base64Regex.hasMatch(str)) {
        try {
          if (str.length > 50) {
            base64Decode(str.substring(0, 48));
            return true;
          }
        } catch (e) {
          return false;
        }
      }
    }

    return false;
  }

  Widget _buildBase64Image(String base64Data) {
    try {
      debugPrint(
          'LiveActivityInfoCard: Attempting to decode base64 image (length: ${base64Data.length})');

      String cleanBase64 = base64Data;
      if (base64Data.contains(',')) {
        cleanBase64 = base64Data.split(',').last;
        debugPrint(
            'LiveActivityInfoCard: Cleaned base64 from data URL (new length: ${cleanBase64.length})');
      }

      if (cleanBase64.isEmpty) {
        debugPrint('LiveActivityInfoCard: Base64 is empty after cleaning');
        return _buildImagePlaceholder();
      }

      final bytes = base64Decode(cleanBase64);
      debugPrint(
          'LiveActivityInfoCard: Successfully decoded base64 to ${bytes.length} bytes');

      return Image.memory(
        bytes,
        width: 48,
        height: 48,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          debugPrint('LiveActivityInfoCard: Error rendering image: $error');
          return _buildImagePlaceholder();
        },
      );
    } catch (e) {
      debugPrint('LiveActivityInfoCard: Exception decoding base64: $e');
      return _buildImagePlaceholder();
    }
  }

  Widget _buildFileImage(String filePath) {
    return Image.file(
      File(filePath),
      width: 48,
      height: 48,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) {
        return _buildImagePlaceholder();
      },
    );
  }

  Widget _buildImagePlaceholder() {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 26),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(
        Icons.image,
        color: AppColors.primary,
        size: 24,
      ),
    );
  }

  String _getStatusDescription(LiveActivityState state) {
    if (state.isLoading) {
      return 'Processing...';
    } else if (state.isActive) {
      return 'Will appear when you enter the geofence';
    } else if (state.hasError) {
      return 'Error occurred';
    } else {
      return 'Ready to test';
    }
  }
}
