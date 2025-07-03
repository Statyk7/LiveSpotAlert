import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../shared/ui_kit/colors.dart';
import '../../../../shared/ui_kit/text_styles.dart';
import '../controllers/geofencing_bloc.dart';
import '../controllers/geofencing_event.dart';
import '../controllers/geofencing_state.dart';
import '../../domain/models/geofence.dart';
import '../../domain/use_cases/create_geofence_use_case.dart';
import '../../domain/use_cases/update_geofence_use_case.dart';
import 'location_picker.dart';

/// Widget for configuring geofence settings
class GeofenceConfigurationWidget extends StatefulWidget {
  const GeofenceConfigurationWidget({
    super.key,
    this.geofence,
    required this.onSave,
    required this.onCancel,
  });

  final Geofence? geofence;
  final VoidCallback onSave;
  final VoidCallback onCancel;

  @override
  State<GeofenceConfigurationWidget> createState() =>
      _GeofenceConfigurationWidgetState();
}

class _GeofenceConfigurationWidgetState
    extends State<GeofenceConfigurationWidget> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _radiusController = TextEditingController();
  final _descriptionController = TextEditingController();

  double? _selectedLatitude;
  double? _selectedLongitude;
  bool _isActive = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _initializeForm();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _radiusController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _initializeForm() {
    if (widget.geofence != null) {
      final geofence = widget.geofence!;
      _nameController.text = geofence.name;
      _radiusController.text = geofence.radius.toInt().toString();
      _descriptionController.text = geofence.description ?? '';
      _selectedLatitude = geofence.latitude;
      _selectedLongitude = geofence.longitude;
      _isActive = geofence.isActive;
    } else {
      // Default values for new geofence
      _nameController.text = 'My Location';
      _radiusController.text = '100';
      _isActive = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<GeofencingBloc, GeofencingState>(
      listener: (context, state) {
        if (state.status == GeofencingStatus.loaded && _isLoading) {
          setState(() => _isLoading = false);
          widget.onSave();
        } else if (state.status == GeofencingStatus.error) {
          setState(() => _isLoading = false);
          if (state.errorMessage != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.errorMessage!),
                backgroundColor: AppColors.error,
              ),
            );
          }
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: Text(
            widget.geofence != null ? 'Edit Geofence' : 'Create Geofence',
            style: AppTextStyles.h3.copyWith(color: Colors.white),
          ),
          backgroundColor: AppColors.primary,
          leading: IconButton(
            onPressed: widget.onCancel,
            icon: const Icon(Icons.close),
          ),
          actions: [
            TextButton(
              onPressed: _isLoading ? null : _saveGeofence,
              child: _isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : Text(
                      'Save',
                      style: TextStyle(
                        color: _canSave() ? Colors.white : Colors.white54,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ),
          ],
        ),
        body: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Name field
              Card(
                elevation: 2,
                color: AppColors.surface,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Geofence Name',
                        style: AppTextStyles.bodyLarge
                            .copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _nameController,
                        decoration: const InputDecoration(
                          hintText: 'e.g., Home, Office, Gym',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter a name';
                          }
                          return null;
                        },
                        onChanged: (_) => setState(() {}),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Location section
              Card(
                elevation: 2,
                color: AppColors.surface,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Location',
                        style: AppTextStyles.bodyLarge
                            .copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      SizedBox(
                        height: 400,
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
                      if (_selectedLatitude != null &&
                          _selectedLongitude != null) ...[
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

              const SizedBox(height: 16),

              // Radius section
              Card(
                elevation: 2,
                color: AppColors.surface,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Detection Radius',
                        style: AppTextStyles.bodyLarge
                            .copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _radiusController,
                        decoration: const InputDecoration(
                          hintText: '100',
                          suffixText: 'meters',
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter a radius';
                          }
                          final radius = double.tryParse(value);
                          if (radius == null || radius <= 0) {
                            return 'Please enter a valid radius';
                          }
                          if (radius < 10) {
                            return 'Radius must be at least 10 meters';
                          }
                          if (radius > 10000) {
                            return 'Radius cannot exceed 10,000 meters';
                          }
                          return null;
                        },
                        onChanged: (_) => setState(() {}),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Recommended: 50-200 meters for reliable detection',
                        style: AppTextStyles.caption
                            .copyWith(color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Description section
              Card(
                elevation: 2,
                color: AppColors.surface,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Description (Optional)',
                        style: AppTextStyles.bodyLarge
                            .copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _descriptionController,
                        decoration: const InputDecoration(
                          hintText: 'Additional notes about this location',
                          border: OutlineInputBorder(),
                        ),
                        maxLines: 3,
                        validator: (value) {
                          if (value != null && value.length > 500) {
                            return 'Description cannot exceed 500 characters';
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Active toggle
              Card(
                elevation: 2,
                color: AppColors.surface,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Active',
                              style: AppTextStyles.bodyLarge
                                  .copyWith(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _isActive
                                  ? 'Geofence will trigger notifications'
                                  : 'Geofence is configured but inactive',
                              style: AppTextStyles.caption.copyWith(
                                color: _isActive
                                    ? AppColors.success
                                    : AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Switch(
                        value: _isActive,
                        onChanged: (value) {
                          setState(() => _isActive = value);
                        },
                        activeColor: AppColors.success,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  bool _canSave() {
    return _nameController.text.isNotEmpty &&
        _selectedLatitude != null &&
        _selectedLongitude != null &&
        _radiusController.text.isNotEmpty &&
        !_isLoading;
  }

  void _saveGeofence() {
    if (!_formKey.currentState!.validate() || !_canSave()) return;

    setState(() => _isLoading = true);

    final radius = double.parse(_radiusController.text);
    final description = _descriptionController.text.trim();

    if (widget.geofence != null) {
      // Update existing geofence
      final updatedGeofence = widget.geofence!.copyWith(
        name: _nameController.text.trim(),
        latitude: _selectedLatitude!,
        longitude: _selectedLongitude!,
        radius: radius,
        description: description.isEmpty ? null : description,
        isActive: _isActive,
      );

      context.read<GeofencingBloc>().add(
            UpdateGeofence(UpdateGeofenceParams(geofence: updatedGeofence)),
          );
    } else {
      // Create new geofence
      context.read<GeofencingBloc>().add(
            CreateGeofence(CreateGeofenceParams(
              name: _nameController.text.trim(),
              latitude: _selectedLatitude!,
              longitude: _selectedLongitude!,
              radius: radius,
              description: description.isEmpty ? null : description,
            )),
          );
    }
  }
}
