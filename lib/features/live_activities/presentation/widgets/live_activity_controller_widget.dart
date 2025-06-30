import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../shared/ui_kit/colors.dart';
import '../../../../shared/ui_kit/text_styles.dart';
import '../controllers/live_activity_bloc.dart';
import '../controllers/live_activity_event.dart';
import '../controllers/live_activity_state.dart';

class LiveActivityControllerWidget extends StatelessWidget {
  const LiveActivityControllerWidget({
    super.key,
    this.title = 'Test Live Activity',
    this.imagePath,
    this.activityId = 'livespotalert-test-activity',
    this.onConfigurePressed,
  });

  final String title;
  final String? imagePath;
  final String activityId;
  final VoidCallback? onConfigurePressed;

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<LiveActivityBloc, LiveActivityState>(
      listener: (context, state) {
        if (state.hasError && state.failure != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error: ${state.failure!.message}'),
              backgroundColor: Colors.red,
            ),
          );
        } else if (state.isActive) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Live Activity started successfully!'),
              backgroundColor: Colors.green,
            ),
          );
        } else if (state.isIdle && !state.isLoading) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Live Activity stopped successfully!'),
              backgroundColor: Colors.orange,
            ),
          );
        }
      },
      builder: (context, state) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Row
            Row(
              children: [
                Icon(Icons.notifications_active, color: AppColors.primary),
                const SizedBox(width: 8),
                Text(
                  'Live Activity',
                  style: AppTextStyles.h4,
                ),
                const Spacer(),
                if (onConfigurePressed != null)
                  TextButton.icon(
                    onPressed: state.isLoading ? null : onConfigurePressed,
                    icon: const Icon(Icons.settings),
                    label: const Text('Configure'),
                  ),
              ],
            ),
            
            const SizedBox(height: 12),
            
            // Status Card
            Card(
              elevation: 2,
              color: AppColors.surface,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
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
                              Text(
                                state.title.isEmpty ? title : state.title,
                                style: AppTextStyles.bodyLarge,
                              ),
                              Text(
                                _getStatusDescription(state),
                                style: AppTextStyles.caption.copyWith(
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (state.isActive) ...[
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColors.success.withValues(alpha: 26),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              'Live Activity Active',
                              style: AppTextStyles.caption.copyWith(
                                color: AppColors.success,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Control Button
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: state.isLoading ? null : () => _onTogglePressed(context, state),
                icon: state.isLoading 
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Icon(state.isActive ? Icons.stop : Icons.play_arrow),
                label: Text(_getButtonText(state)),
                style: OutlinedButton.styleFrom(
                  side: BorderSide(
                    color: state.isActive ? Colors.red : AppColors.primary,
                  ),
                  foregroundColor: state.isActive ? Colors.red : AppColors.primary,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _onTogglePressed(BuildContext context, LiveActivityState state) {
    if (state.isActive && state.currentActivityId != null) {
      context.read<LiveActivityBloc>().add(
        StopLiveActivity(activityId: state.currentActivityId!),
      );
    } else {
      context.read<LiveActivityBloc>().add(
        StartLiveActivity(
          title: state.title.isEmpty ? title : state.title,
          imagePath: state.imagePath ?? imagePath,
          activityId: activityId,
        ),
      );
    }
  }

  String _getButtonText(LiveActivityState state) {
    if (state.isLoading) {
      return state.isActive ? 'Stopping...' : 'Starting...';
    }
    return state.isActive ? 'Stop Live Activity' : 'Test Live Activity';
  }

  String _getStatusDescription(LiveActivityState state) {
    if (state.isLoading) {
      return 'Processing...';
    } else if (state.isActive) {
      return 'This will appear when you enter the geofence';
    } else if (state.hasError) {
      return 'Error occurred';
    } else {
      return 'Ready to test';
    }
  }
}