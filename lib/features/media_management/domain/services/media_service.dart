import 'package:dartz/dartz.dart';
import '../../../../shared/base_domain/failures/failure.dart';

// Placeholder MediaService - to be implemented later
abstract class MediaService {
  Future<Either<Failure, MediaItem>> getMediaItemById(String id);
}

class MediaItem {
  const MediaItem({
    required this.id,
    this.filePath,
    this.base64Data,
  });
  
  final String id;
  final String? filePath;
  final String? base64Data;
}