import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../shared/base_domain/failures/failure.dart';
import '../../../../shared/base_domain/use_case.dart';
import '../services/geofencing_service.dart';

class DeleteGeofenceUseCase implements UseCase<void, DeleteGeofenceParams> {
  const DeleteGeofenceUseCase(this._geofencingService);
  
  final GeofencingService _geofencingService;
  
  @override
  Future<Either<Failure, void>> call(DeleteGeofenceParams params) async {
    // Validate input
    if (params.geofenceId.trim().isEmpty) {
      return Left(LocationFailure(message: 'Geofence ID cannot be empty'));
    }
    
    // Check if geofence exists
    final geofenceResult = await _geofencingService.getGeofenceById(params.geofenceId);
    if (geofenceResult.isLeft()) {
      return geofenceResult.fold(
        (failure) => Left(failure),
        (_) => throw Exception('Unexpected right value'),
      );
    }
    
    // Delete the geofence
    return await _geofencingService.deleteGeofence(params.geofenceId);
  }
}

class DeleteGeofenceParams extends Equatable {
  const DeleteGeofenceParams({
    required this.geofenceId,
  });
  
  final String geofenceId;
  
  @override
  List<Object?> get props => [geofenceId];
}