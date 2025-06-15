import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../shared/ui_kit/colors.dart';
import '../../../../shared/ui_kit/text_styles.dart';
import '../../../../shared/utils/constants.dart';
import '../../domain/use_cases/create_geofence_use_case.dart';
import '../controllers/geofencing_bloc.dart';
import '../controllers/geofencing_event.dart';
import '../controllers/geofencing_state.dart';
import '../widgets/location_picker.dart';

class CreateGeofenceScreen extends StatefulWidget {
  const CreateGeofenceScreen({super.key, this.geofenceId});
  
  final String? geofenceId;

  @override
  State<CreateGeofenceScreen> createState() => _CreateGeofenceScreenState();
}

class _CreateGeofenceScreenState extends State<CreateGeofenceScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _radiusController = TextEditingController(text: AppConstants.defaultGeofenceRadius.toString());
  
  double? _selectedLatitude;
  double? _selectedLongitude;
  bool _isActive = true;
  bool _isLocationPickerVisible = false;
  
  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _radiusController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'Create Geofence',
          style: AppTextStyles.h3.copyWith(color: Colors.white),
        ),
        backgroundColor: AppColors.primary,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () => context.go('/geofences'),
        ),
        actions: [
          BlocConsumer<GeofencingBloc, GeofencingState>(
            listener: (context, state) {
              if (state.hasError) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(state.errorMessage!),
                    backgroundColor: AppColors.error,
                  ),
                );
              } else if (state.status == GeofencingStatus.loaded && !state.isLoading) {
                // Geofence created successfully
                context.go('/geofences');
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Geofence created successfully!'),
                    backgroundColor: AppColors.success,
                  ),
                );
              }
            },
            builder: (context, state) {
              return TextButton(
                onPressed: state.isLoading ? null : _saveGeofence,
                child: state.isLoading
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : Text(
                        'Save',
                        style: AppTextStyles.button.copyWith(
                          color: Colors.white,
                          fontSize: 16,
                        ),
                      ),
              );
            },
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Basic Information
                    _buildSectionHeader('Basic Information'),
                    const SizedBox(height: 16),
                    
                    _buildTextField(
                      controller: _nameController,
                      label: 'Geofence Name',
                      hint: 'e.g., Home, Office, Gym',
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter a name';
                        }
                        if (value.length > 100) {
                          return 'Name must be less than 100 characters';
                        }
                        return null;
                      },
                    ),
                    
                    const SizedBox(height: 16),
                    
                    _buildTextField(
                      controller: _descriptionController,
                      label: 'Description (Optional)',
                      hint: 'Add a description for this geofence',
                      maxLines: 3,
                      validator: (value) {
                        if (value != null && value.length > 500) {
                          return 'Description must be less than 500 characters';
                        }
                        return null;
                      },
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // Location
                    _buildSectionHeader('Location'),
                    const SizedBox(height: 16),
                    
                    _buildLocationSection(),
                    
                    const SizedBox(height: 24),
                    
                    // Radius
                    _buildSectionHeader('Radius'),
                    const SizedBox(height: 16),
                    
                    _buildTextField(
                      controller: _radiusController,
                      label: 'Radius (meters)',
                      hint: 'Enter radius in meters',
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter a radius';
                        }
                        final radius = double.tryParse(value);
                        if (radius == null) {
                          return 'Please enter a valid number';
                        }
                        if (radius < 10) {
                          return 'Radius must be at least 10 meters';
                        }
                        if (radius > 10000) {
                          return 'Radius cannot exceed 10,000 meters';
                        }
                        return null;
                      },
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // Settings
                    _buildSectionHeader('Settings'),
                    const SizedBox(height: 16),
                    
                    _buildActiveToggle(),
                    
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
            
            // Location Picker Overlay
            if (_isLocationPickerVisible)
              Expanded(
                child: LocationPicker(
                  initialLatitude: _selectedLatitude,
                  initialLongitude: _selectedLongitude,
                  onLocationSelected: (lat, lng) {
                    setState(() {
                      _selectedLatitude = lat;
                      _selectedLongitude = lng;
                      _isLocationPickerVisible = false;
                    });
                  },
                  onCancel: () {
                    setState(() {
                      _isLocationPickerVisible = false;
                    });
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: AppTextStyles.h4.copyWith(color: AppColors.primary),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    TextInputType? keyboardType,
    int? maxLines,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines ?? 1,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.error, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
    );
  }

  Widget _buildLocationSection() {
    final hasLocation = _selectedLatitude != null && _selectedLongitude != null;
    
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: hasLocation ? AppColors.success : AppColors.textHint,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                hasLocation ? Icons.location_on : Icons.location_off,
                color: hasLocation ? AppColors.success : AppColors.textSecondary,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                hasLocation ? 'Location Selected' : 'No Location Selected',
                style: AppTextStyles.label.copyWith(
                  color: hasLocation ? AppColors.success : AppColors.textSecondary,
                ),
              ),
            ],
          ),
          
          if (hasLocation) ...[
            const SizedBox(height: 8),
            Text(
              'Lat: ${_selectedLatitude!.toStringAsFixed(6)}',
              style: AppTextStyles.bodySmall,
            ),
            Text(
              'Lng: ${_selectedLongitude!.toStringAsFixed(6)}',
              style: AppTextStyles.bodySmall,
            ),
          ] else ...[
            const SizedBox(height: 8),
            Text(
              'Tap the button below to select a location on the map',
              style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary),
            ),
          ],
          
          const SizedBox(height: 16),
          
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    setState(() {
                      _isLocationPickerVisible = true;
                    });
                  },
                  icon: const Icon(Icons.map),
                  label: Text(hasLocation ? 'Change Location' : 'Select Location'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: hasLocation ? AppColors.secondary : AppColors.primary,
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
              
              if (hasLocation) ...[
                const SizedBox(width: 12),
                ElevatedButton.icon(
                  onPressed: _getCurrentLocation,
                  icon: const Icon(Icons.my_location),
                  label: const Text('Current'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.info,
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActiveToggle() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.textHint, width: 1),
      ),
      child: Row(
        children: [
          Icon(
            _isActive ? Icons.notifications_active : Icons.notifications_off,
            color: _isActive ? AppColors.geofenceActive : AppColors.geofenceInactive,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Active Monitoring',
                  style: AppTextStyles.label,
                ),
                Text(
                  _isActive 
                      ? 'This geofence will trigger alerts when you enter or exit'
                      : 'This geofence will be saved but won\'t trigger alerts',
                  style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
          Switch(
            value: _isActive,
            onChanged: (value) {
              setState(() {
                _isActive = value;
              });
            },
            activeColor: AppColors.geofenceActive,
          ),
        ],
      ),
    );
  }

  void _getCurrentLocation() async {
    // TODO: Implement getting current location
    // For now, show a message that this feature will be implemented
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Current location feature coming soon!'),
        backgroundColor: AppColors.info,
      ),
    );
  }

  void _saveGeofence() {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    
    if (_selectedLatitude == null || _selectedLongitude == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a location for the geofence'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }
    
    final params = CreateGeofenceParams(
      name: _nameController.text.trim(),
      latitude: _selectedLatitude!,
      longitude: _selectedLongitude!,
      radius: double.parse(_radiusController.text),
      isActive: _isActive,
      description: _descriptionController.text.trim().isEmpty 
          ? null 
          : _descriptionController.text.trim(),
    );
    
    context.read<GeofencingBloc>().add(CreateGeofence(params));
  }
}