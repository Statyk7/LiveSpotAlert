import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../shared/ui_kit/widgets/app_buttons.dart';
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
            // Control Button
            AppOutlinedButton(
              text: _getButtonText(state),
              onPressed: state.isLoading
                  ? null
                  : () => _onTogglePressed(context, state),
              isLoading: state.isLoading,
              isFullWidth: true,
              icon: state.isActive ? Icons.stop : Icons.play_arrow,
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

}
