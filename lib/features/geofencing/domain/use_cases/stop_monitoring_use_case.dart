import 'package:dartz/dartz.dart';
import '../../../../shared/base_domain/failures/failure.dart';
import '../../../../shared/base_domain/use_case.dart';
import '../services/geofencing_service.dart';

class StopMonitoringUseCase implements UseCase<void, NoParams> {
  const StopMonitoringUseCase(this._geofencingService);
  
  final GeofencingService _geofencingService;
  
  @override
  Future<Either<Failure, void>> call(NoParams params) async {
    return await _geofencingService.stopMonitoring();
  }
}