import 'package:dartz/dartz.dart';
import '../../../../shared/base_domain/failures/failure.dart';

/// Service for managing notification images
abstract class NotificationImageService {
  /// Pick an image from the photo gallery and return Base64 encoded data
  Future<Either<Failure, String>> pickImageFromGallery();
  
  /// Convert Base64 image data to decoded bytes for display
  Either<Failure, List<int>> decodeBase64Image(String base64Data);
  
  /// Convert a file to Base64 encoded data
  Future<Either<Failure, String>> convertFileToBase64(String filePath);
  
  /// Create a temporary file from Base64 data for notifications
  Future<Either<Failure, String>> createTempFileFromBase64(String base64Data);
  
  /// Legacy methods for migration support
  /// Get the full path to a saved image file
  Future<Either<Failure, String>> getImagePath(String fileName);
  
  /// Delete an image file from storage
  Future<Either<Failure, void>> deleteImage(String imagePath);
  
  /// Check if an image file exists
  Future<bool> imageExists(String imagePath);
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