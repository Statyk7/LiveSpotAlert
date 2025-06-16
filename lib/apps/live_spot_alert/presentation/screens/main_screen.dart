import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:live_activities/live_activities.dart';
import 'dart:io';

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
import '../../../../features/live_activities/presentation/widgets/live_activity_preview.dart';

enum ViewMode { 
  empty,        // No geofence exists
  viewing,      // Viewing current geofence
  creating,     // Creating new geofence
  configuring   // Configuring live activity
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  ViewMode _currentMode = ViewMode.empty;
  final _liveActivitiesPlugin = LiveActivities();
  
  // Form controllers
  final _nameController = TextEditingController();
  final _liveActivityTitleController = TextEditingController();
  
  // Form data
  double? _selectedLatitude;
  double? _selectedLongitude;
  File? _selectedImage;
  String? _selectedImagePath;
  
  // Live Activity data
  String _liveActivityTitle = '';
  String? _liveActivityImagePath;
  String? _currentActivityId;

  @override
  void initState() {
    super.initState();
    _liveActivitiesPlugin.init(appGroupId: "group.livespotalert.liveactivities");
    
    // Load initial data
    context.read<GeofencingBloc>().add(const GeofencingStarted());
  }

  @override
  void dispose() {
    _nameController.dispose();
    _liveActivityTitleController.dispose();
    _liveActivitiesPlugin.dispose();
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
      case ViewMode.configuring:
        return _buildConfigureState(state);
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
              
              // Live Activity Section
              Row(
                children: [
                  Icon(Icons.notifications_active, color: AppColors.primary),
                  const SizedBox(width: 8),
                  Text(
                    'Live Activity',
                    style: AppTextStyles.h4,
                  ),
                  const Spacer(),
                  TextButton.icon(
                    onPressed: () => _switchToConfigureMode(),
                    icon: const Icon(Icons.settings),
                    label: const Text('Configure'),
                  ),
                ],
              ),
              
              const SizedBox(height: 12),
              
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
                          if (_liveActivityImagePath != null) ...[
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.file(
                                File(_liveActivityImagePath!),
                                width: 48,
                                height: 48,
                                fit: BoxFit.cover,
                              ),
                            ),
                            const SizedBox(width: 12),
                          ],
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _liveActivityTitle.isEmpty 
                                    ? 'Arrived at ${geofence.name}' 
                                    : _liveActivityTitle,
                                  style: AppTextStyles.bodyLarge,
                                ),
                                Text(
                                  'This will appear when you enter the geofence',
                                  style: AppTextStyles.caption.copyWith(
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      if (_currentActivityId != null) ...[
                        const SizedBox(height: 12),
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
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Toggle Live Activity Button
              OutlinedButton.icon(
                onPressed: () => _toggleLiveActivity(),
                icon: Icon(_currentActivityId != null ? Icons.stop : Icons.play_arrow),
                label: Text(_currentActivityId != null ? 'Stop Live Activity' : 'Start Live Activity'),
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: _currentActivityId != null ? Colors.red : AppColors.primary),
                  foregroundColor: _currentActivityId != null ? Colors.red : AppColors.primary,
                ),
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

  Widget _buildConfigureState(GeofencingState state) {
    return CustomScrollView(
      slivers: [
        SliverAppBar(
          title: Text(
            'Configure Live Activity',
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
              onPressed: () => _saveLiveActivityConfig(),
              child: const Text(
                'Save',
                style: TextStyle(
                  color: Colors.white,
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
              // Title Field
              Text(
                'Notification Title',
                style: AppTextStyles.bodyLarge.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _liveActivityTitleController,
                decoration: InputDecoration(
                  hintText: 'e.g., You\'ve arrived!',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  filled: true,
                  fillColor: AppColors.surface,
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Image Section
              Text(
                'Notification Image',
                style: AppTextStyles.bodyLarge.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Card(
                elevation: 2,
                color: AppColors.surface,
                child: InkWell(
                  onTap: () => _pickImage(),
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    height: 120,
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    child: _selectedImage != null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.file(
                              _selectedImage!,
                              fit: BoxFit.cover,
                            ),
                          )
                        : Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.add_photo_alternate,
                                size: 48,
                                color: AppColors.textSecondary,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Tap to add image',
                                style: AppTextStyles.bodyMedium.copyWith(
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                  ),
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Preview Section
              LiveActivityPreview(
                title: _liveActivityTitleController.text,
                imageFile: _selectedImage,
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

  void _switchToConfigureMode() {
    setState(() {
      _currentMode = ViewMode.configuring;
      _liveActivityTitleController.text = _liveActivityTitle;
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
    _selectedImage = null;
    _selectedImagePath = null;
  }

  // Live Activity methods
  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    
    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
        _selectedImagePath = pickedFile.path;
      });
    }
  }

  void _saveLiveActivityConfig() {
    setState(() {
      _liveActivityTitle = _liveActivityTitleController.text;
      if (_selectedImagePath != null) {
        _liveActivityImagePath = _selectedImagePath;
      }
    });
    _switchToViewMode();
  }

  Future<void> _toggleLiveActivity() async {
    if (_currentActivityId != null) {
      // Stop existing Live Activity
      await _stopLiveActivity();
    } else {
      // Start new Live Activity
      await _startLiveActivity();
    }
  }

  Future<void> _startLiveActivity() async {
    try {
      final activityStatus = await _liveActivitiesPlugin.areActivitiesEnabled();
      debugPrint("Live Activity Enabled: $activityStatus");

      if (!activityStatus) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Live Activities are not enabled on this device')),
          );
        }
        return;
      }

      final activityAttributes = {
        'title': _liveActivityTitle.isEmpty ? 'Test Live Activity' : _liveActivityTitle,
        'activityType': 'geofence_alert',
        'createdAt': DateTime.now().toIso8601String(),
      };

      final activityId = await _liveActivitiesPlugin.createActivity(
        'test-activity-${DateTime.now().millisecondsSinceEpoch}',
        activityAttributes,
        removeWhenAppIsKilled: true,
      );

      debugPrint("ActivityID: $activityId");
      
      if (activityId != null && mounted) {
        setState(() => _currentActivityId = activityId);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Live Activity started successfully!')),
        );
      }
    } catch (e) {
      debugPrint("Error starting Live Activity: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error starting Live Activity: $e')),
        );
      }
    }
  }

  Future<void> _stopLiveActivity() async {
    if (_currentActivityId == null) return;

    try {
      await _liveActivitiesPlugin.endActivity(_currentActivityId!);
      debugPrint("Live Activity stopped: $_currentActivityId");
      
      if (mounted) {
        setState(() => _currentActivityId = null);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Live Activity stopped successfully!')),
        );
      }
    } catch (e) {
      debugPrint("Error stopping Live Activity: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error stopping Live Activity: $e')),
        );
      }
    }
  }

  bool get _isEditing => _currentMode == ViewMode.creating && 
                       _nameController.text.isNotEmpty;
}