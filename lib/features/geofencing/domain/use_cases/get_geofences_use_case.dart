import 'package:dartz/dartz.dart';
import '../../../../shared/base_domain/failures/failure.dart';
import '../../../../shared/base_domain/use_case.dart';
import '../models/geofence.dart';
import '../services/geofencing_service.dart';

class GetGeofencesUseCase implements UseCase<List<Geofence>, NoParams> {
  const GetGeofencesUseCase(this._geofencingService);

  final GeofencingService _geofencingService;

  @override
  Future<Either<Failure, List<Geofence>>> call(NoParams params) async {
    return await _geofencingService.getGeofences();
  }
}
