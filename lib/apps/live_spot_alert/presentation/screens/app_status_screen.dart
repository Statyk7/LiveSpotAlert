import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../features/geofencing/presentation/controllers/geofencing_bloc.dart';
import '../../../../features/geofencing/presentation/controllers/geofencing_state.dart';
import '../../../../shared/di/service_locator.dart';
import '../../../../shared/ui_kit/colors.dart';
import '../../../../shared/ui_kit/text_styles.dart';

/// Debug screen to show app integration status
class AppStatusScreen extends StatelessWidget {
  const AppStatusScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('App Status'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/home'),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'LiveSpotAlert Integration Status',
              style: AppTextStyles.h2,
            ),
            const SizedBox(height: 24),
            
            // Geofencing Status
            BlocBuilder<GeofencingBloc, GeofencingState>(
              builder: (context, state) {
                return _StatusCard(
                  title: 'Geofencing Service',
                  status: _getGeofencingStatus(state),
                  details: [
                    'Geofences: ${state.geofences.length}',
                    'Is Monitoring: ${state.isMonitoring}',
                    'Has Permissions: ${state.hasLocationPermissions}',
                  ],
                );
              },
            ),
            
            const SizedBox(height: 16),
            
            _StatusCard(
              title: 'Dependency Injection (GetIt)',
              status: ServiceLocator.isInitialized ? 'Active' : 'Not Initialized',
              details: [
                'GetIt initialized: ${ServiceLocator.isInitialized}',
                'Lazy singletons registered: 7',
                'Direct singletons: 1 (SharedPreferences)',
              ],
            ),
            
            const SizedBox(height: 16),
            
            _StatusCard(
              title: 'Live Activities',
              status: 'Not Implemented',
              details: const [
                'Domain models: Pending',
                'Service integration: Pending',
                'iOS permissions: Configured',
              ],
              isWarning: true,
            ),
            
            const SizedBox(height: 16),
            
            _StatusCard(
              title: 'Media Management',
              status: 'Mock Implementation',
              details: const [
                'Service: Mock active',
                'Image handling: Placeholder',
                'QR code generation: Pending',
              ],
              isWarning: true,
            ),
            
            const SizedBox(height: 32),
            
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => context.go('/geofences'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text('Test Geofencing Features'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getGeofencingStatus(GeofencingState state) {
    if (state.errorMessage != null) return 'Error';
    if (state.isLoading) return 'Loading';
    return 'Active';
  }
}

class _StatusCard extends StatelessWidget {
  const _StatusCard({
    required this.title,
    required this.status,
    required this.details,
    this.isWarning = false,
  });

  final String title;
  final String status;
  final List<String> details;
  final bool isWarning;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  isWarning ? Icons.warning : Icons.check_circle,
                  color: isWarning ? AppColors.warning : AppColors.success,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: AppTextStyles.h4,
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: isWarning ? AppColors.warning.withValues(alpha: 26) : AppColors.success.withValues(alpha: 26),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isWarning ? AppColors.warning : AppColors.success,
                    ),
                  ),
                  child: Text(
                    status,
                    style: AppTextStyles.caption.copyWith(
                      color: isWarning ? AppColors.warning : AppColors.success,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ...details.map((detail) => Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Row(
                children: [
                  const Text('• ', style: TextStyle(color: AppColors.textSecondary)),
                  Text(
                    detail,
                    style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary),
                  ),
                ],
              ),
            )),
          ],
        ),
      ),
    );
  }
}