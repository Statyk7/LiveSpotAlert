import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../shared/base_domain/failures/failure.dart';
import '../../../../shared/base_domain/use_case.dart';
import '../models/geofence.dart';
import '../services/geofencing_service.dart';

class UpdateGeofenceUseCase implements UseCase<Geofence, UpdateGeofenceParams> {
  const UpdateGeofenceUseCase(this._geofencingService);

  final GeofencingService _geofencingService;

  @override
  Future<Either<Failure, Geofence>> call(UpdateGeofenceParams params) async {
    // Validate input parameters
    final validationResult = _validateParams(params);
    if (validationResult != null) {
      return Left(validationResult);
    }

    // Check if geofence exists
    final existingGeofenceResult =
        await _geofencingService.getGeofenceById(params.geofence.id);
    if (existingGeofenceResult.isLeft()) {
      return existingGeofenceResult.fold(
        (failure) => Left(failure),
        (_) => throw Exception('Unexpected right value'),
      );
    }

    // Update the geofence
    return await _geofencingService.updateGeofence(params.geofence);
  }

  Failure? _validateParams(UpdateGeofenceParams params) {
    final geofence = params.geofence;

    // Validate ID
    if (geofence.id.trim().isEmpty) {
      return const LocationFailure(message: 'Geofence ID cannot be empty');
    }

    // Validate name
    if (geofence.name.trim().isEmpty) {
      return const LocationFailure(message: 'Geofence name cannot be empty');
    }

    if (geofence.name.length > 100) {
      return const LocationFailure(
          message: 'Geofence name cannot exceed 100 characters');
    }

    // Validate coordinates
    if (geofence.latitude < -90 || geofence.latitude > 90) {
      return const LocationFailure(
          message: 'Invalid latitude. Must be between -90 and 90');
    }

    if (geofence.longitude < -180 || geofence.longitude > 180) {
      return const LocationFailure(
          message: 'Invalid longitude. Must be between -180 and 180');
    }

    // Validate radius
    if (geofence.radius <= 0) {
      return const LocationFailure(message: 'Radius must be greater than 0');
    }

    if (geofence.radius > 10000) {
      // 10km max
      return const LocationFailure(
          message: 'Radius cannot exceed 10,000 meters');
    }

    if (geofence.radius < 10) {
      // 10m minimum for reliability
      return const LocationFailure(
          message: 'Radius must be at least 10 meters for reliable detection');
    }

    // Validate description length
    if (geofence.description != null && geofence.description!.length > 500) {
      return const LocationFailure(
          message: 'Description cannot exceed 500 characters');
    }

    return null;
  }
}

class UpdateGeofenceParams extends Equatable {
  const UpdateGeofenceParams({
    required this.geofence,
  });

  final Geofence geofence;

  @override
  List<Object?> get props => [geofence];
}
