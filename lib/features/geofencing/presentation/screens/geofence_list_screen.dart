import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../shared/ui_kit/colors.dart';
import '../../../../shared/ui_kit/text_styles.dart';
import '../../domain/models/geofence.dart';
import '../../domain/use_cases/delete_geofence_use_case.dart';
import '../controllers/geofencing_bloc.dart';
import '../controllers/geofencing_event.dart';
import '../controllers/geofencing_state.dart';
import '../widgets/geofence_card.dart';

class GeofenceListScreen extends StatelessWidget {
  const GeofenceListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'Geofences',
          style: AppTextStyles.h3.copyWith(color: Colors.white),
        ),
        backgroundColor: AppColors.primary,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => context.go('/home'),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: () {
              context.read<GeofencingBloc>().add(const RefreshGeofences());
            },
          ),
        ],
      ),
      body: BlocConsumer<GeofencingBloc, GeofencingState>(
        listener: (context, state) {
          if (state.hasError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.errorMessage!),
                backgroundColor: AppColors.error,
                action: SnackBarAction(
                  label: 'Dismiss',
                  textColor: Colors.white,
                  onPressed: () {
                    context.read<GeofencingBloc>().add(const ClearError());
                  },
                ),
              ),
            );
          }
        },
        builder: (context, state) {
          return Column(
            children: [
              // Status Header
              _buildStatusHeader(context, state),
              
              // Geofences List
              Expanded(
                child: _buildGeofencesList(context, state),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          context.go('/geofences/create');
        },
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildStatusHeader(BuildContext context, GeofencingState state) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: state.isMonitoring ? AppColors.success : AppColors.warning,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 26),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                state.isMonitoring ? Icons.radar : Icons.pause_circle,
                color: Colors.white,
                size: 24,
              ),
              const SizedBox(width: 8),
              Text(
                state.isMonitoring ? 'Monitoring Active' : 'Monitoring Paused',
                style: AppTextStyles.h4.copyWith(color: Colors.white),
              ),
              const Spacer(),
              if (state.hasLocationPermissions)
                const Icon(Icons.check_circle, color: Colors.white, size: 20)
              else
                const Icon(Icons.warning, color: Colors.white, size: 20),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '${state.activeGeofenceCount} of ${state.totalGeofenceCount} geofences active',
            style: AppTextStyles.bodyMedium.copyWith(
              color: Colors.white.withValues(alpha: 230),
            ),
          ),
          if (!state.hasLocationPermissions)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: GestureDetector(
                onTap: () {
                  context.read<GeofencingBloc>().add(const RequestLocationPermissions());
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 51),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    'Grant Location Permission',
                    style: AppTextStyles.bodySmall.copyWith(color: Colors.white),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildGeofencesList(BuildContext context, GeofencingState state) {
    if (state.isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (state.isEmpty) {
      return _buildEmptyState(context);
    }

    return RefreshIndicator(
      onRefresh: () async {
        context.read<GeofencingBloc>().add(const RefreshGeofences());
      },
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: state.geofences.length,
        itemBuilder: (context, index) {
          final geofence = state.geofences[index];
          final status = state.getGeofenceStatus(geofence.id);
          final recentEvents = state.getEventsForGeofence(geofence.id).take(3).toList();
          
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: GeofenceCard(
              geofence: geofence,
              status: status,
              recentEvents: recentEvents,
              isSelected: state.selectedGeofence?.id == geofence.id,
              onTap: () {
                context.read<GeofencingBloc>().add(SelectGeofence(geofence));
                _showGeofenceDetails(context, geofence, status, recentEvents);
              },
              onToggleActive: () {
                context.read<GeofencingBloc>().add(ToggleGeofenceActive(geofence.id));
              },
              onDelete: () {
                _showDeleteConfirmation(context, geofence);
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.location_on_outlined,
              size: 80,
              color: AppColors.textSecondary,
            ),
            const SizedBox(height: 24),
            Text(
              'No Geofences Yet',
              style: AppTextStyles.h2.copyWith(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 12),
            Text(
              'Create your first geofence to start receiving location-based alerts',
              style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () {
                context.go('/geofences/create');
              },
              icon: const Icon(Icons.add),
              label: const Text('Create Geofence'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showGeofenceDetails(BuildContext context, Geofence geofence, dynamic status, List<dynamic> events) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        maxChildSize: 0.9,
        minChildSize: 0.3,
        builder: (context, scrollController) {
          return Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Column(
              children: [
                Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: AppColors.textHint,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    controller: scrollController,
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              geofence.isActive ? Icons.location_on : Icons.location_off,
                              color: geofence.isActive ? AppColors.geofenceActive : AppColors.geofenceInactive,
                              size: 32,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    geofence.name,
                                    style: AppTextStyles.h2,
                                  ),
                                  Text(
                                    '${geofence.radius.toInt()}m radius',
                                    style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        if (geofence.description != null) ...[
                          const SizedBox(height: 16),
                          Text(
                            'Description',
                            style: AppTextStyles.label,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            geofence.description!,
                            style: AppTextStyles.bodyMedium,
                          ),
                        ],
                        const SizedBox(height: 24),
                        Text(
                          'Location',
                          style: AppTextStyles.label,
                        ),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppColors.background,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  const Icon(Icons.my_location, size: 16),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Lat: ${geofence.latitude.toStringAsFixed(6)}',
                                    style: AppTextStyles.bodySmall,
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  const Icon(Icons.my_location, size: 16),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Lng: ${geofence.longitude.toStringAsFixed(6)}',
                                    style: AppTextStyles.bodySmall,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        if (events.isNotEmpty) ...[
                          const SizedBox(height: 24),
                          Text(
                            'Recent Activity',
                            style: AppTextStyles.label,
                          ),
                          const SizedBox(height: 8),
                          ...events.map((event) => Container(
                            margin: const EdgeInsets.only(bottom: 8),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: AppColors.background,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  event.eventType == 'enter' ? Icons.login : Icons.logout,
                                  size: 16,
                                  color: event.eventType == 'enter' ? AppColors.success : AppColors.warning,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    '${event.eventType.toString().toUpperCase()} at ${event.timestamp.toString().substring(0, 16)}',
                                    style: AppTextStyles.bodySmall,
                                  ),
                                ),
                              ],
                            ),
                          )),
                        ],
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context, Geofence geofence) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete Geofence', style: AppTextStyles.h3),
        content: Text(
          'Are you sure you want to delete "${geofence.name}"? This action cannot be undone.',
          style: AppTextStyles.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: TextStyle(color: AppColors.textSecondary)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              context.read<GeofencingBloc>().add(
                DeleteGeofence(DeleteGeofenceParams(geofenceId: geofence.id)),
              );
            },
            child: Text('Delete', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
  }
}