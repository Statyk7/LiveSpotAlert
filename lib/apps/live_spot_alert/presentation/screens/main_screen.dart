import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../shared/ui_kit/colors.dart';
import '../../../../shared/ui_kit/text_styles.dart';
import '../../../../shared/utils/constants.dart';
import '../../../../features/geofencing/presentation/controllers/geofencing_bloc.dart';
import '../../../../features/geofencing/presentation/controllers/geofencing_state.dart';
import '../../../../features/geofencing/presentation/controllers/geofencing_event.dart';
import '../../../../features/geofencing/presentation/widgets/location_picker.dart';
import '../../../../features/geofencing/domain/models/geofence.dart';
import '../../../../features/geofencing/domain/use_cases/create_geofence_use_case.dart';
import '../../../../features/geofencing/domain/use_cases/delete_geofence_use_case.dart';
import '../../../../features/live_activities/presentation/widgets/live_activity_controller_widget.dart';
import '../../../../features/live_activities/presentation/widgets/live_activity_configuration_widget.dart';

enum ViewMode { 
  empty,        // No geofence exists
  viewing,      // Viewing current geofence
  creating,     // Creating new geofence
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  ViewMode _currentMode = ViewMode.empty;
  
  // Form controllers
  final _nameController = TextEditingController();
  
  // Form data
  double? _selectedLatitude;
  double? _selectedLongitude;

  @override
  void initState() {
    super.initState();
    // Load initial data
    context.read<GeofencingBloc>().add(const GeofencingStarted());
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<GeofencingBloc, GeofencingState>(
      listener: (context, state) {
        // Update view mode based on state
        if (state.isEmpty && _currentMode == ViewMode.empty) {
          // Stay in empty mode
        } else if (state.isLoaded && state.geofences.isNotEmpty && _currentMode == ViewMode.empty) {
          setState(() => _currentMode = ViewMode.viewing);
        }
        
        // Handle geofence creation success
        if (state.status == GeofencingStatus.loaded && _currentMode == ViewMode.creating) {
          setState(() => _currentMode = ViewMode.viewing);
          _clearForm();
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: BlocBuilder<GeofencingBloc, GeofencingState>(
          builder: (context, state) {
            return _buildCurrentView(state);
          },
        ),
      ),
    );
  }

  Widget _buildCurrentView(GeofencingState state) {
    switch (_currentMode) {
      case ViewMode.empty:
        return _buildEmptyState();
      case ViewMode.viewing:
        return _buildViewingState(state);
      case ViewMode.creating:
        return _buildCreatingState();
    }
  }

  Widget _buildEmptyState() {
    return CustomScrollView(
      slivers: [
        SliverAppBar(
          title: Text(
            AppConstants.appName,
            style: AppTextStyles.h3.copyWith(color: Colors.white),
          ),
          backgroundColor: AppColors.primary,
          elevation: 0,
          floating: true,
        ),
        SliverFillRemaining(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.location_on_outlined,
                  size: 120,
                  color: AppColors.primary.withValues(alpha: 77),
                ),
                const SizedBox(height: 32),
                Text(
                  'Create Your First Geofence',
                  style: AppTextStyles.h2,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                Text(
                  'Get live notifications when you arrive at special places. Set up your location and customize your alert.',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 48),
                ElevatedButton.icon(
                  onPressed: () => _switchToCreateMode(),
                  icon: const Icon(Icons.add_location),
                  label: const Text('Create Geofence'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildViewingState(GeofencingState state) {
    final geofence = state.geofences.isNotEmpty ? state.geofences.first : null;
    
    if (geofence == null) {
      return _buildEmptyState();
    }

    final status = state.getGeofenceStatus(geofence.id);
    final isUserInside = status?.isUserInside ?? false;

    return CustomScrollView(
      slivers: [
        SliverAppBar(
          title: Text(
            AppConstants.appName,
            style: AppTextStyles.h3.copyWith(color: Colors.white),
          ),
          backgroundColor: AppColors.primary,
          elevation: 0,
          floating: true,
          actions: [
            IconButton(
              onPressed: () => _switchToCreateMode(editingGeofence: geofence),
              icon: const Icon(Icons.edit),
            ),
            PopupMenuButton(
              itemBuilder: (context) => [
                PopupMenuItem(
                  value: 'delete',
                  child: const Row(
                    children: [
                      Icon(Icons.delete, color: Colors.red),
                      SizedBox(width: 8),
                      Text('Delete Geofence'),
                    ],
                  ),
                ),
              ],
              onSelected: (value) {
                if (value == 'delete') {
                  _deleteGeofence(geofence);
                }
              },
            ),
          ],
        ),
        SliverPadding(
          padding: const EdgeInsets.all(16.0),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              // Current Geofence Card
              Card(
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
                      Row(
                        children: [
                          Icon(
                            isUserInside ? Icons.location_on : Icons.location_off,
                            color: isUserInside ? AppColors.geofenceActive : AppColors.textSecondary,
                            size: 28,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  geofence.name,
                                  style: AppTextStyles.h4,
                                ),
                                Text(
                                  isUserInside ? 'You are inside this area' : 'You are outside this area',
                                  style: AppTextStyles.caption.copyWith(
                                    color: isUserInside ? AppColors.geofenceActive : AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: geofence.isActive ? AppColors.geofenceActive : AppColors.textSecondary,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Text(
                              geofence.isActive ? 'Active' : 'Inactive',
                              style: AppTextStyles.caption.copyWith(color: Colors.white),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      if (status?.distanceToCenter != null) ...[
                        Row(
                          children: [
                            Icon(Icons.near_me, color: AppColors.info, size: 18),
                            const SizedBox(width: 8),
                            Text(
                              'Distance: ${status!.distanceToCenter!.toInt()}m',
                              style: AppTextStyles.bodyMedium,
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                      ],
                      Row(
                        children: [
                          Icon(Icons.radio_button_checked, color: AppColors.info, size: 18),
                          const SizedBox(width: 8),
                          Text(
                            'Radius: ${geofence.radius.toInt()}m',
                            style: AppTextStyles.bodyMedium,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Location Monitoring Section
              _buildMonitoringControlCard(state),
              
              const SizedBox(height: 24),
              
              // Live Activity Section
              LiveActivityControllerWidget(
                title: 'Arrived at ${geofence.name}',
                onConfigurePressed: () => _showLiveActivityConfiguration(context),
              ),
            ]),
          ),
        ),
      ],
    );
  }

  Widget _buildCreatingState() {
    return CustomScrollView(
      slivers: [
        SliverAppBar(
          title: Text(
            _isEditing ? 'Edit Geofence' : 'Create Geofence',
            style: AppTextStyles.h3.copyWith(color: Colors.white),
          ),
          backgroundColor: AppColors.primary,
          elevation: 0,
          leading: IconButton(
            onPressed: () => _switchToViewMode(),
            icon: const Icon(Icons.close),
          ),
          actions: [
            TextButton(
              onPressed: _canSaveGeofence() ? () => _saveGeofence() : null,
              child: Text(
                'Save',
                style: TextStyle(
                  color: _canSaveGeofence() ? Colors.white : Colors.white54,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        SliverPadding(
          padding: const EdgeInsets.all(16.0),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              // Name Field
              Text(
                'Geofence Name',
                style: AppTextStyles.bodyLarge.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _nameController,
                decoration: InputDecoration(
                  hintText: 'e.g., Home, Office, Gym',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  filled: true,
                  fillColor: AppColors.surface,
                ),
                onChanged: (_) => setState(() {}),
              ),
              
              const SizedBox(height: 24),
              
              // Location Section
              Text(
                'Location',
                style: AppTextStyles.bodyLarge.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Card(
                elevation: 2,
                color: AppColors.surface,
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    children: [
                      SizedBox(
                        height: 400, // Fixed height to prevent unbounded constraints
                        child: LocationPicker(
                          initialLatitude: _selectedLatitude,
                          initialLongitude: _selectedLongitude,
                          onLocationSelected: (lat, lng) {
                            setState(() {
                              _selectedLatitude = lat;
                              _selectedLongitude = lng;
                            });
                          },
                          onCancel: () {
                            // Handle cancel if needed
                          },
                        ),
                      ),
                      if (_selectedLatitude != null && _selectedLongitude != null) ...[
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppColors.info.withValues(alpha: 26),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            'Location: ${_selectedLatitude!.toStringAsFixed(4)}, ${_selectedLongitude!.toStringAsFixed(4)}',
                            style: AppTextStyles.caption,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ]),
          ),
        ),
      ],
    );
  }


  // Navigation methods
  void _switchToCreateMode({Geofence? editingGeofence}) {
    setState(() {
      _currentMode = ViewMode.creating;
      if (editingGeofence != null) {
        _nameController.text = editingGeofence.name;
        _selectedLatitude = editingGeofence.latitude;
        _selectedLongitude = editingGeofence.longitude;
      }
    });
  }

  void _switchToViewMode() {
    setState(() {
      _currentMode = ViewMode.viewing;
      _clearForm();
    });
  }


  // Form methods
  bool _canSaveGeofence() {
    return _nameController.text.isNotEmpty &&
           _selectedLatitude != null &&
           _selectedLongitude != null;
  }

  void _saveGeofence() {
    if (!_canSaveGeofence()) return;
    
    final params = CreateGeofenceParams(
      name: _nameController.text,
      latitude: _selectedLatitude!,
      longitude: _selectedLongitude!,
      radius: 100.0, // Default radius
      description: '',
    );

    context.read<GeofencingBloc>().add(CreateGeofence(params));
  }

  void _deleteGeofence(Geofence geofence) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Geofence'),
        content: Text('Are you sure you want to delete "${geofence.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              context.read<GeofencingBloc>().add(
                DeleteGeofence(DeleteGeofenceParams(geofenceId: geofence.id)),
              );
              setState(() => _currentMode = ViewMode.empty);
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _clearForm() {
    _nameController.clear();
    _selectedLatitude = null;
    _selectedLongitude = null;
  }

  // Monitoring control methods
  Widget _buildMonitoringControlCard(GeofencingState state) {
    return Card(
      elevation: 2,
      color: AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.location_searching,
                  color: state.isMonitoring ? AppColors.success : AppColors.textSecondary,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Location Monitoring',
                      style: AppTextStyles.h4,
                    ),
                    Text(
                      state.isMonitoring 
                        ? 'Actively monitoring your location'
                        : 'Monitoring is disabled',
                      style: AppTextStyles.caption.copyWith(
                        color: state.isMonitoring ? AppColors.success : AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                Switch(
                  value: state.isMonitoring,
                  onChanged: state.hasLocationPermissions ? (value) {
                    if (value) {
                      _startMonitoring();
                    } else {
                      _stopMonitoring();
                    }
                  } : null,
                  activeColor: AppColors.success,
                ),
              ],
            ),
            
            if (!state.hasLocationPermissions) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.warning.withValues(alpha: 26),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.warning.withValues(alpha: 77)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.warning, color: AppColors.warning, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Location permissions required',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.warning,
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: () => _requestLocationPermissions(),
                      child: Text(
                        'Grant',
                        style: TextStyle(color: AppColors.warning),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            
            if (state.isMonitoring && state.locationEvents.isNotEmpty) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.info.withValues(alpha: 26),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(Icons.history, color: AppColors.info, size: 16),
                    const SizedBox(width: 8),
                    Text(
                      'Last event: ${_formatLastLocationEvent(state.locationEvents.first)}',
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.info,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _startMonitoring() {
    context.read<GeofencingBloc>().add(const StartMonitoring());
  }

  void _stopMonitoring() {
    context.read<GeofencingBloc>().add(const StopMonitoring());
  }

  void _requestLocationPermissions() {
    context.read<GeofencingBloc>().add(const RequestLocationPermissions());
  }

  String _formatLastLocationEvent(locationEvent) {
    final eventType = locationEvent.eventType.toString();
    final timeAgo = DateTime.now().difference(locationEvent.timestamp);
    
    String eventDescription;
    switch (eventType) {
      case 'geofence_enter':
      case 'enter':
        eventDescription = 'Entered ${locationEvent.geofence.name}';
        break;
      case 'geofence_exit':
      case 'exit':
        eventDescription = 'Exited ${locationEvent.geofence.name}';
        break;
      default:
        eventDescription = 'Location update';
    }
    
    String timeDescription;
    if (timeAgo.inMinutes < 1) {
      timeDescription = 'just now';
    } else if (timeAgo.inHours < 1) {
      timeDescription = '${timeAgo.inMinutes}m ago';
    } else if (timeAgo.inDays < 1) {
      timeDescription = '${timeAgo.inHours}h ago';
    } else {
      timeDescription = '${timeAgo.inDays}d ago';
    }
    
    return '$eventDescription $timeDescription';
  }

  // Live Activity methods
  void _showLiveActivityConfiguration(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => LiveActivityConfigurationWidget(
          onSave: () => Navigator.of(context).pop(),
          onCancel: () => Navigator.of(context).pop(),
        ),
      ),
    );
  }

  bool get _isEditing => _currentMode == ViewMode.creating && 
                       _nameController.text.isNotEmpty;
}