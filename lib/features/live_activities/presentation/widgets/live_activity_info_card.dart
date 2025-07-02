import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../shared/ui_kit/colors.dart';
import '../../../../shared/ui_kit/text_styles.dart';
import '../controllers/live_activity_bloc.dart';
import '../controllers/live_activity_state.dart';

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
                      color: state.isActive ? AppColors.geofenceActive : AppColors.primary,
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
                              color: state.isActive ? AppColors.geofenceActive : AppColors.textSecondary,
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
                          child: Image.file(
                            File(state.imagePath!),
                            width: 48,
                            height: 48,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
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
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                      ],
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.title, color: AppColors.info, size: 18),
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
                                  Icon(Icons.image, color: AppColors.info, size: 18),
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