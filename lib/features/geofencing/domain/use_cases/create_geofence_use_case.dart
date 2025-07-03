import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../shared/base_domain/failures/failure.dart';
import '../../../../shared/base_domain/use_case.dart';
import '../../../../shared/utils/constants.dart';
import '../models/geofence.dart';
import '../services/geofencing_service.dart';

class CreateGeofenceUseCase implements UseCase<Geofence, CreateGeofenceParams> {
  const CreateGeofenceUseCase(this._geofencingService);

  final GeofencingService _geofencingService;

  @override
  Future<Either<Failure, Geofence>> call(CreateGeofenceParams params) async {
    // Validate input parameters
    final validationResult = _validateParams(params);
    if (validationResult != null) {
      return Left(validationResult);
    }

    // Check if we've reached the maximum number of geofences
    final existingGeofences = await _geofencingService.getGeofences();
    return await existingGeofences.fold(
      (failure) async => Left(failure),
      (geofences) async {
        if (geofences.length >= AppConstants.maxGeofences) {
          return Left(LocationFailure(
            message:
                'Maximum number of geofences (${AppConstants.maxGeofences}) reached',
          ));
        }
        return await _createGeofenceInternal(params);
      },
    );
  }

  Future<Either<Failure, Geofence>> _createGeofenceInternal(
      CreateGeofenceParams params) async {
    // Create the geofence
    final geofence = Geofence(
      id: params.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
      name: params.name,
      latitude: params.latitude,
      longitude: params.longitude,
      radius: params.radius,
      isActive: params.isActive,
      description: params.description,
      mediaItemId: params.mediaItemId,
      createdAt: DateTime.now(),
    );

    return await _geofencingService.createGeofence(geofence);
  }

  Failure? _validateParams(CreateGeofenceParams params) {
    // Validate name
    if (params.name.trim().isEmpty) {
      return const LocationFailure(message: 'Geofence name cannot be empty');
    }

    if (params.name.length > 100) {
      return const LocationFailure(
          message: 'Geofence name cannot exceed 100 characters');
    }

    // Validate coordinates
    if (params.latitude < -90 || params.latitude > 90) {
      return const LocationFailure(
          message: 'Invalid latitude. Must be between -90 and 90');
    }

    if (params.longitude < -180 || params.longitude > 180) {
      return const LocationFailure(
          message: 'Invalid longitude. Must be between -180 and 180');
    }

    // Validate radius
    if (params.radius <= 0) {
      return const LocationFailure(message: 'Radius must be greater than 0');
    }

    if (params.radius > 10000) {
      // 10km max
      return const LocationFailure(
          message: 'Radius cannot exceed 10,000 meters');
    }

    if (params.radius < 10) {
      // 10m minimum for reliability
      return const LocationFailure(
          message: 'Radius must be at least 10 meters for reliable detection');
    }

    // Validate description length
    if (params.description != null && params.description!.length > 500) {
      return const LocationFailure(
          message: 'Description cannot exceed 500 characters');
    }

    return null;
  }
}

class CreateGeofenceParams extends Equatable {
  const CreateGeofenceParams({
    required this.name,
    required this.latitude,
    required this.longitude,
    required this.radius,
    this.id,
    this.isActive = true,
    this.description,
    this.mediaItemId,
  });

  final String? id;
  final String name;
  final double latitude;
  final double longitude;
  final double radius;
  final bool isActive;
  final String? description;
  final String? mediaItemId;

  @override
  List<Object?> get props => [
        id,
        name,
        latitude,
        longitude,
        radius,
        isActive,
        description,
        mediaItemId,
      ];
}
