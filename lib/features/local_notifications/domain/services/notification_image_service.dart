import 'package:dartz/dartz.dart';
import '../../../../shared/base_domain/failures/failure.dart';

/// Service for managing notification images
abstract class NotificationImageService {
  /// Pick an image from the photo gallery
  Future<Either<Failure, String>> pickImageFromGallery();
  
  /// Save an image to persistent storage and return the saved path
  Future<Either<Failure, String>> saveImageToPersistentStorage(String sourcePath);
  
  /// Delete an image from storage
  Future<Either<Failure, void>> deleteImage(String imagePath);
  
  /// Check if an image file exists
  Future<bool> imageExists(String imagePath);
  
  /// Get the full path to a saved image
  Future<Either<Failure, String>> getImagePath(String fileName);
}

/// Data class for image selection result
class ImageSelectionResult {
  const ImageSelectionResult({
    required this.imagePath,
    required this.fileSize,
  });
  
  final String imagePath;
  final int fileSize;
}