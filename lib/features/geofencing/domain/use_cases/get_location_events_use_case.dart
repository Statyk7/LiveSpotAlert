import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../shared/base_domain/failures/failure.dart';
import '../../../../shared/base_domain/use_case.dart';
import '../models/location_event.dart';
import '../services/geofencing_service.dart';

class GetLocationEventsUseCase implements UseCase<List<LocationEvent>, GetLocationEventsParams> {
  const GetLocationEventsUseCase(this._geofencingService);
  
  final GeofencingService _geofencingService;
  
  @override
  Future<Either<Failure, List<LocationEvent>>> call(GetLocationEventsParams params) async {
    // Validate date range if provided
    if (params.startDate != null && params.endDate != null) {
      if (params.startDate!.isAfter(params.endDate!)) {
        return Left(LocationFailure(message: 'Start date cannot be after end date'));
      }
    }
    
    // Validate limit
    if (params.limit != null && params.limit! <= 0) {
      return Left(LocationFailure(message: 'Limit must be greater than 0'));
    }
    
    if (params.limit != null && params.limit! > 1000) {
      return Left(LocationFailure(message: 'Limit cannot exceed 1000 events'));
    }
    
    return await _geofencingService.getLocationEvents(
      geofenceId: params.geofenceId,
      startDate: params.startDate,
      endDate: params.endDate,
      limit: params.limit,
    );
  }
}

class GetLocationEventsParams extends Equatable {
  const GetLocationEventsParams({
    this.geofenceId,
    this.startDate,
    this.endDate,
    this.limit = 50, // Default limit
  });
  
  final String? geofenceId;
  final DateTime? startDate;
  final DateTime? endDate;
  final int? limit;
  
  // Convenience constructors
  const GetLocationEventsParams.forGeofence(String geofenceId, {int? limit})
      : this(geofenceId: geofenceId, limit: limit);
  
  const GetLocationEventsParams.forDateRange(DateTime startDate, DateTime endDate, {int? limit})
      : this(startDate: startDate, endDate: endDate, limit: limit);
  
  const GetLocationEventsParams.recent({int limit = 20})
      : this(limit: limit);
  
  @override
  List<Object?> get props => [geofenceId, startDate, endDate, limit];
}