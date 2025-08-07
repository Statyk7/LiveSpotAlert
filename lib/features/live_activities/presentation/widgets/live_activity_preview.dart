import 'package:flutter/material.dart';
import 'dart:io';
import '../../../../shared/ui_kit/colors.dart';
import '../../../../shared/ui_kit/spacing.dart';
import '../../../../shared/ui_kit/text_styles.dart';
import '../../domain/models/live_activity.dart';

class LiveActivityPreview extends StatelessWidget {
  const LiveActivityPreview({
    super.key,
    required this.title,
    this.subtitle,
    this.imageFile,
    this.imageUrl,
    this.imageData,
    this.showHeader = true,
    this.onTap,
  });

  final String title;
  final String? subtitle;
  final File? imageFile;
  final String? imageUrl;
  final String? imageData;
  final bool showHeader;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (showHeader) ...[
          Text(
            'Preview',
            style:
                AppTextStyles.bodyLarge.copyWith(fontWeight: FontWeight.bold),
          ),
          AppSpacing.verticalSpaceSmall,
        ],
        Card(
          elevation: 4,
          color: AppColors.surface,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(AppSpacing.radiusSmall),
            child: Padding(
              padding: AppSpacing.cardPadding,
              child: Row(
                children: [
                  _buildImage(),
                  if (_hasImage()) AppSpacing.horizontalSpaceMedium,
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title.isEmpty ? 'You\'ve arrived!' : title,
                          style: AppTextStyles.bodyLarge,
                        ),
                        Text(
                          subtitle ?? 'Live Activity Preview',
                          style: AppTextStyles.caption.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildImage() {
    if (imageFile != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(AppSpacing.radiusSmall),
        child: Image.file(
          imageFile!,
          width: 48,
          height: 48,
          fit: BoxFit.cover,
        ),
      );
    }

    if (imageUrl != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(AppSpacing.radiusSmall),
        child: Image.network(
          imageUrl!,
          width: 48,
          height: 48,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) =>
              _buildPlaceholderImage(),
        ),
      );
    }

    if (imageData != null) {
      // TODO: Implement base64 image display when needed
      return _buildPlaceholderImage();
    }

    return const SizedBox.shrink();
  }

  Widget _buildPlaceholderImage() {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        //color: AppColors.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppSpacing.radiusSmall),
      ),
      child: Icon(
        Icons.image,
        color: AppColors.primary,
        size: 24,
      ),
    );
  }

  bool _hasImage() {
    return imageFile != null || imageUrl != null || imageData != null;
  }
}

/// Enhanced Live Activity Preview with more detailed information
class LiveActivityDetailedPreview extends StatelessWidget {
  const LiveActivityDetailedPreview({
    super.key,
    required this.liveActivity,
    this.showHeader = true,
    this.onTap,
  });

  final LiveActivity liveActivity;
  final bool showHeader;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (showHeader) ...[
          Text(
            'Live Activity',
            style:
                AppTextStyles.bodyLarge.copyWith(fontWeight: FontWeight.bold),
          ),
          AppSpacing.verticalSpaceSmall,
        ],
        Card(
          elevation: 4,
          color: AppColors.surface,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(AppSpacing.radiusSmall),
            child: Padding(
              padding: AppSpacing.cardPadding,
              child: Column(
                children: [
                  Row(
                    children: [
                      _buildActivityImage(),
                      if (liveActivity.hasImage) AppSpacing.horizontalSpaceMedium,
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              liveActivity.title,
                              style: AppTextStyles.bodyLarge,
                            ),
                            Text(
                              liveActivity.subtitle,
                              style: AppTextStyles.caption.copyWith(
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      _buildStatusChip(),
                    ],
                  ),
                  if (liveActivity.locationName != null) ...[
                    AppSpacing.verticalSpaceMedium,
                    Row(
                      children: [
                        Icon(
                          Icons.location_on,
                          size: 16,
                          color: AppColors.textSecondary,
                        ),
                        SizedBox(width: AppSpacing.micro),
                        Text(
                          liveActivity.locationName!,
                          style: AppTextStyles.caption.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActivityImage() {
    if (liveActivity.imageUrl != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(AppSpacing.radiusSmall),
        child: Image.network(
          liveActivity.imageUrl!,
          width: 48,
          height: 48,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) =>
              _buildPlaceholderImage(),
        ),
      );
    }

    if (liveActivity.imageData != null) {
      // TODO: Implement base64 image display when needed
      return _buildPlaceholderImage();
    }

    return const SizedBox.shrink();
  }

  Widget _buildPlaceholderImage() {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        //color: AppColors.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppSpacing.radiusSmall),
      ),
      child: Icon(
        _getContentTypeIcon(),
        color: AppColors.primary,
        size: 24,
      ),
    );
  }

  Widget _buildStatusChip() {
    Color chipColor;
    String statusText;

    switch (liveActivity.status) {
      case LiveActivityStatus.active:
        chipColor = Colors.green;
        statusText = 'Active';
        break;
      case LiveActivityStatus.dismissed:
        chipColor = Colors.orange;
        statusText = 'Dismissed';
        break;
      case LiveActivityStatus.ended:
        chipColor = Colors.red;
        statusText = 'Ended';
        break;
      case LiveActivityStatus.stale:
        chipColor = Colors.grey;
        statusText = 'Stale';
        break;
      case LiveActivityStatus.configured:
        chipColor = Colors.blue;
        statusText = 'Configured';
        break;
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: AppSpacing.small, vertical: AppSpacing.micro),
      decoration: BoxDecoration(
        //color: chipColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppSpacing.radiusMedium),
        //border: Border.all(color: chipColor.withValues(alpha: 0.3)),
      ),
      child: Text(
        statusText,
        style: AppTextStyles.caption.copyWith(
          color: chipColor,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  IconData _getContentTypeIcon() {
    switch (liveActivity.contentType) {
      case LiveActivityContentType.geofenceEntry:
        return Icons.location_on;
      case LiveActivityContentType.geofenceExit:
        return Icons.location_off;
      case LiveActivityContentType.geofenceDwell:
        return Icons.timer;
      case LiveActivityContentType.locationUpdate:
        return Icons.my_location;
      case LiveActivityContentType.configuration:
        return Icons.settings;
    }
  }
}
