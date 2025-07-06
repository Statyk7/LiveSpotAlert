import 'dart:io';
import 'dart:convert';
import 'package:dartz/dartz.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_app_group_directory/flutter_app_group_directory.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import '../../../../shared/base_domain/failures/failure.dart';
import '../../../../shared/utils/logger.dart';
import '../../domain/services/notification_image_service.dart';

class NotificationImageServiceImpl implements NotificationImageService {
  NotificationImageServiceImpl(this._imagePicker);
  
  final ImagePicker _imagePicker;
  
  static const String _appGroupId = 'group.livespotalert.liveactivities';
  static const String _notificationImagesDir = 'notification_images';
  static const int _maxImageSizeBytes = 5 * 1024 * 1024; // 5MB
  static const List<String> _allowedExtensions = ['.jpg', '.jpeg', '.png'];

  /// Debug method to check app group access
  Future<Either<Failure, String>> debugAppGroupAccess() async {
    try {
      final Directory? appGroupDir = await FlutterAppGroupDirectory.getAppGroupDirectory(_appGroupId);
      if (appGroupDir == null) {
        return const Left(MediaFailure(message: 'App group directory is null'));
      }
      
      AppLogger.info('App group directory: ${appGroupDir.path}');
      AppLogger.info('App group directory exists: ${await appGroupDir.exists()}');
      
      return Right(appGroupDir.path);
    } catch (e, stackTrace) {
      AppLogger.error('Error accessing app group directory', e, stackTrace);
      return Left(MediaFailure(message: 'Error accessing app group: $e'));
    }
  }

  @override
  Future<Either<Failure, String>> pickImageFromGallery() async {
    try {
      AppLogger.info('Starting image selection from gallery');
      
      final XFile? pickedFile = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920,
        maxHeight: 1920,
        imageQuality: 85,
      );
      
      if (pickedFile == null) {
        AppLogger.info('User cancelled image selection');
        return const Left(UserCancelledFailure(message: 'Image selection cancelled'));
      }
      
      // Validate file
      final validationResult = await _validateImage(pickedFile.path);
      if (validationResult.isLeft()) {
        return validationResult.fold(
          (failure) => Left(failure),
          (_) => throw Exception('Unexpected right value'),
        );
      }
      
      // Convert picked file to Base64
      final base64Result = await convertFileToBase64(pickedFile.path);
      return base64Result.fold(
        (failure) => Left(failure),
        (base64Data) {
          AppLogger.info('Image selected and converted to Base64 successfully');
          return Right(base64Data);
        },
      );
      
    } catch (e, stackTrace) {
      AppLogger.error('Failed to pick image from gallery', e, stackTrace);
      return Left(MediaFailure(message: 'Failed to select image: $e'));
    }
  }

  @override
  Either<Failure, List<int>> decodeBase64Image(String base64Data) {
    try {
      final List<int> bytes = base64Decode(base64Data);
      AppLogger.info('Successfully decoded Base64 image data (${bytes.length} bytes)');
      return Right(bytes);
    } catch (e, stackTrace) {
      AppLogger.error('Failed to decode Base64 image data', e, stackTrace);
      return Left(MediaFailure(message: 'Failed to decode image data: $e'));
    }
  }

  @override
  Future<Either<Failure, String>> convertFileToBase64(String filePath) async {
    try {
      AppLogger.info('Converting file to Base64: $filePath');
      
      final File imageFile = File(filePath);
      if (!await imageFile.exists()) {
        return const Left(MediaFailure(message: 'Image file not found'));
      }
      
      final List<int> imageBytes = await imageFile.readAsBytes();
      final String base64Data = base64Encode(imageBytes);
      
      AppLogger.info('Image converted to Base64 successfully (${imageBytes.length} bytes -> ${base64Data.length} characters)');
      return Right(base64Data);
      
    } catch (e, stackTrace) {
      AppLogger.error('Failed to convert file to Base64', e, stackTrace);
      return Left(MediaFailure(message: 'Failed to convert image to Base64: $e'));
    }
  }

  @override
  Future<Either<Failure, String>> createTempFileFromBase64(String base64Data) async {
    try {
      AppLogger.info('Creating temporary file from Base64 data for notifications');
      
      // Decode Base64 data
      final decodeResult = decodeBase64Image(base64Data);
      if (decodeResult.isLeft()) {
        return decodeResult.fold(
          (failure) => Left(failure),
          (_) => throw Exception('Unexpected right value'),
        );
      }
      
      final List<int> imageBytes = decodeResult.getOrElse(() => []);
      
      // Get application documents directory for temporary notification images
      final Directory appDocumentsDir = await getApplicationDocumentsDirectory();
      final Directory tempNotificationDir = Directory(path.join(appDocumentsDir.path, 'temp_notifications'));
      
      // Create directory if it doesn't exist
      if (!await tempNotificationDir.exists()) {
        await tempNotificationDir.create(recursive: true);
        AppLogger.info('Created temporary notifications directory: ${tempNotificationDir.path}');
      }
      
      // Generate unique filename with timestamp
      final String timestamp = DateTime.now().millisecondsSinceEpoch.toString();
      final String fileName = 'notification_temp_$timestamp.jpg';
      final String tempFilePath = path.join(tempNotificationDir.path, fileName);
      
      // Write bytes to temporary file
      final File tempFile = File(tempFilePath);
      await tempFile.writeAsBytes(imageBytes);
      
      AppLogger.info('Temporary notification image created: $tempFilePath (${imageBytes.length} bytes)');
      return Right(tempFilePath);
      
    } catch (e, stackTrace) {
      AppLogger.error('Failed to create temporary file from Base64', e, stackTrace);
      return Left(MediaFailure(message: 'Failed to create temporary file: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteImage(String imagePath) async {
    try {
      AppLogger.info('Deleting image: $imagePath');
      
      final File imageFile = File(imagePath);
      if (await imageFile.exists()) {
        await imageFile.delete();
        AppLogger.info('Image deleted successfully');
      } else {
        AppLogger.warning('Image file does not exist: $imagePath');
      }
      
      return const Right(null);
      
    } catch (e, stackTrace) {
      AppLogger.error('Failed to delete image', e, stackTrace);
      return Left(MediaFailure(message: 'Failed to delete image: $e'));
    }
  }

  @override
  Future<bool> imageExists(String imagePath) async {
    try {
      final File imageFile = File(imagePath);
      return await imageFile.exists();
    } catch (e) {
      AppLogger.error('Error checking if image exists: $e');
      return false;
    }
  }

  @override
  Future<Either<Failure, String>> getImagePath(String imagePathOrFileName) async {
    try {
      AppLogger.info('Getting image path for: $imagePathOrFileName');
      
      // If it's already a full path and the file exists, return it
      if (imagePathOrFileName.contains('/')) {
        final File imageFile = File(imagePathOrFileName);
        if (await imageFile.exists()) {
          AppLogger.info('Image found at full path: $imagePathOrFileName');
          return Right(imagePathOrFileName);
        }
        AppLogger.warning('Full path provided but file does not exist: $imagePathOrFileName');
      }
      
      // Get the app group directory (shared with notification service)
      final Directory? appGroupDir = await FlutterAppGroupDirectory.getAppGroupDirectory(_appGroupId);
      if (appGroupDir == null) {
        AppLogger.error('Failed to get app group directory during retrieval');
        return const Left(MediaFailure(message: 'Failed to access app group directory'));
      }
      
      // Extract filename from path if a full path was provided
      final String fileName = imagePathOrFileName.contains('/') 
          ? path.basename(imagePathOrFileName) 
          : imagePathOrFileName;
      
      final Directory notificationImagesDir = Directory(
        path.join(appGroupDir.path, _notificationImagesDir),
      );
      
      if (!await notificationImagesDir.exists()) {
        AppLogger.warning('Notification images directory does not exist');
        return const Left(MediaFailure(message: 'Notification images directory not found'));
      }
      
      final String imagePath = path.join(notificationImagesDir.path, fileName);
      AppLogger.info('Constructed image path: $imagePath');
      
      final bool exists = await imageExists(imagePath);
      AppLogger.info('Image exists check result: $exists');
      
      if (exists) {
        return Right(imagePath);
      } else {
        AppLogger.error('Image not found: $imagePath');
        
        // Debug: List all files in the directory
        try {
          final List<FileSystemEntity> files = notificationImagesDir.listSync();
          AppLogger.info('Available files in notification images directory:');
          for (final file in files) {
            AppLogger.info('  - ${path.basename(file.path)}');
          }
        } catch (e) {
          AppLogger.warning('Failed to list directory contents: $e');
        }
        
        return const Left(MediaFailure(message: 'Image file not found'));
      }
    } catch (e, stackTrace) {
      AppLogger.error('Failed to get image path', e, stackTrace);
      return Left(MediaFailure(message: 'Failed to get image path: $e'));
    }
  }

  /// Clean up temporary notification files
  Future<Either<Failure, int>> cleanupTempNotificationFiles() async {
    try {
      AppLogger.info('Starting cleanup of temporary notification files');
      
      final Directory appDocumentsDir = await getApplicationDocumentsDirectory();
      final Directory tempNotificationDir = Directory(path.join(appDocumentsDir.path, 'temp_notifications'));
      
      if (!await tempNotificationDir.exists()) {
        AppLogger.info('Temporary notifications directory does not exist - nothing to clean up');
        return const Right(0);
      }
      
      final List<FileSystemEntity> files = tempNotificationDir.listSync();
      int deletedCount = 0;
      
      for (final file in files) {
        if (file is File) {
          final String fileName = path.basename(file.path);
          
          // Skip if this file was created recently (within last hour)
          final FileStat fileStat = await file.stat();
          final Duration timeSinceCreation = DateTime.now().difference(fileStat.modified);
          if (timeSinceCreation.inHours < 1) {
            AppLogger.info('Skipping recently created temporary file: $fileName');
            continue;
          }
          
          try {
            await file.delete();
            deletedCount++;
            AppLogger.info('Deleted temporary notification file: $fileName');
          } catch (e) {
            AppLogger.warning('Failed to delete temporary file $fileName: $e');
          }
        }
      }
      
      AppLogger.info('Temporary file cleanup completed - deleted $deletedCount files');
      return Right(deletedCount);
      
    } catch (e, stackTrace) {
      AppLogger.error('Failed to cleanup temporary notification files', e, stackTrace);
      return Left(MediaFailure(message: 'Failed to cleanup temporary files: $e'));
    }
  }

  /// Validate image file
  Future<Either<Failure, void>> _validateImage(String imagePath) async {
    try {
      final File imageFile = File(imagePath);
      
      // Check if file exists
      if (!await imageFile.exists()) {
        return const Left(MediaFailure(message: 'Image file does not exist'));
      }
      
      // Check file size
      final int fileSize = await imageFile.length();
      if (fileSize > _maxImageSizeBytes) {
        return Left(MediaFailure(
          message: 'Image size too large. Maximum size is ${_maxImageSizeBytes ~/ (1024 * 1024)}MB',
        ));
      }
      
      // Check file extension
      final String extension = path.extension(imagePath).toLowerCase();
      if (!_allowedExtensions.contains(extension)) {
        return Left(MediaFailure(
          message: 'Unsupported image format. Allowed formats: ${_allowedExtensions.join(', ')}',
        ));
      }
      
      AppLogger.info('Image validation passed: size=${fileSize}bytes, extension=$extension');
      return const Right(null);
      
    } catch (e, stackTrace) {
      AppLogger.error('Failed to validate image', e, stackTrace);
      return Left(MediaFailure(message: 'Failed to validate image: $e'));
    }
  }
}

/// Failure types for media operations
class MediaFailure extends Failure {
  const MediaFailure({required super.message});
}

class UserCancelledFailure extends Failure {
  const UserCancelledFailure({required super.message});
}