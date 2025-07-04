import 'dart:io';
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
      
      AppLogger.info('Image selected successfully: ${pickedFile.path}');
      return Right(pickedFile.path);
      
    } catch (e, stackTrace) {
      AppLogger.error('Failed to pick image from gallery', e, stackTrace);
      return Left(MediaFailure(message: 'Failed to select image: $e'));
    }
  }

  @override
  Future<Either<Failure, String>> saveImageToPersistentStorage(String sourcePath) async {
    try {
      AppLogger.info('Saving image to persistent storage: $sourcePath');
      
      // Try app group directory first (for notifications)
      Directory? primaryDir;
      String primaryDirType = 'app_group';
      
      final Directory? appGroupDir = await FlutterAppGroupDirectory.getAppGroupDirectory(_appGroupId);
      if (appGroupDir != null) {
        primaryDir = Directory(path.join(appGroupDir.path, _notificationImagesDir));
        AppLogger.info('Using app group directory: ${primaryDir.path}');
      } else {
        AppLogger.warning('App group directory not available, using documents directory');
        // Fallback to documents directory
        final Directory documentsDir = await getApplicationDocumentsDirectory();
        primaryDir = Directory(path.join(documentsDir.path, _notificationImagesDir));
        primaryDirType = 'documents';
        AppLogger.info('Using documents directory: ${primaryDir.path}');
      }
      
      // Create directory if it doesn't exist
      if (!await primaryDir.exists()) {
        await primaryDir.create(recursive: true);
        AppLogger.info('Created notification images directory in $primaryDirType');
      }
      
      // Generate persistent filename (using hash for consistency)
      final String extension = path.extension(sourcePath);
      final String baseFileName = path.basenameWithoutExtension(sourcePath);
      // Use source file hash to ensure same file gets same name
      final String fileName = 'notification_persistent_${baseFileName.hashCode.abs()}$extension';
      final String destinationPath = path.join(primaryDir.path, fileName);
      
      AppLogger.info('Generated filename: $fileName');
      AppLogger.info('Full destination path: $destinationPath');
      
      // Copy the file (check if it already exists first)
      final File sourceFile = File(sourcePath);
      final File destinationFile = File(destinationPath);
      
      // Only copy if destination doesn't exist or is different
      if (!await destinationFile.exists()) {
        await sourceFile.copy(destinationPath);
        AppLogger.info('Copied new image to: $destinationPath');
      } else {
        AppLogger.info('Image already exists at: $destinationPath');
      }
      
      // Create backup copies for iOS notification persistence with proper extensions
      final String fileNameWithoutExt = path.basenameWithoutExtension(destinationPath);
      final String directory = path.dirname(destinationPath);
      final String backupPath1 = path.join(directory, '${fileNameWithoutExt}_backup1$extension');
      final String backupPath2 = path.join(directory, '${fileNameWithoutExt}_backup2$extension');
      
      if (!await File(backupPath1).exists()) {
        await sourceFile.copy(backupPath1);
        AppLogger.info('Created backup copy 1: $backupPath1');
      }
      
      if (!await File(backupPath2).exists()) {
        await sourceFile.copy(backupPath2);
        AppLogger.info('Created backup copy 2: $backupPath2');
      }
      
      // Also save to documents directory as fallback (if we used app group as primary)
      if (primaryDirType == 'app_group') {
        try {
          final Directory documentsDir = await getApplicationDocumentsDirectory();
          final Directory fallbackDir = Directory(path.join(documentsDir.path, _notificationImagesDir));
          
          if (!await fallbackDir.exists()) {
            await fallbackDir.create(recursive: true);
          }
          
          final String fallbackPath = path.join(fallbackDir.path, fileName);
          if (!await File(fallbackPath).exists()) {
            await sourceFile.copy(fallbackPath);
            AppLogger.info('Created fallback copy in documents: $fallbackPath');
          }
        } catch (e) {
          AppLogger.warning('Failed to create fallback copy: $e');
          // Continue anyway, this is just a backup
        }
      }
      
      // Verify the primary file was saved
      final bool fileExists = await destinationFile.exists();
      final int fileSize = fileExists ? await destinationFile.length() : 0;
      
      AppLogger.info('Image saved successfully to: $destinationPath');
      AppLogger.info('Saved file exists: $fileExists, size: ${fileSize}bytes');
      
      return Right(destinationFile.path);
      
    } catch (e, stackTrace) {
      AppLogger.error('Failed to save image to persistent storage', e, stackTrace);
      return Left(MediaFailure(message: 'Failed to save image: $e'));
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
  Future<Either<Failure, String>> getImagePath(String fileName) async {
    try {
      AppLogger.info('Getting image path for fileName: $fileName');
      
      // Get the app group directory (shared with notification service)
      final Directory? appGroupDir = await FlutterAppGroupDirectory.getAppGroupDirectory(_appGroupId);
      if (appGroupDir == null) {
        AppLogger.error('Failed to get app group directory during retrieval');
        return const Left(MediaFailure(message: 'Failed to access app group directory'));
      }
      
      AppLogger.info('App group directory for retrieval: ${appGroupDir.path}');
      
      // Debug: List all files in the notification images directory
      final Directory notificationImagesDir = Directory(
        path.join(appGroupDir.path, _notificationImagesDir),
      );
      
      if (await notificationImagesDir.exists()) {
        try {
          final List<FileSystemEntity> files = notificationImagesDir.listSync();
          AppLogger.info('Files in notification images directory:');
          for (final file in files) {
            AppLogger.info('  - ${path.basename(file.path)}');
          }
        } catch (e) {
          AppLogger.warning('Failed to list directory contents: $e');
        }
      } else {
        AppLogger.warning('Notification images directory does not exist');
      }
      
      final String imagePath = path.join(appGroupDir.path, _notificationImagesDir, fileName);
      AppLogger.info('Constructed image path: $imagePath');
      
      final bool exists = await imageExists(imagePath);
      AppLogger.info('Image exists check result: $exists');
      
      if (exists) {
        return Right(imagePath);
      } else {
        AppLogger.warning('Image not found in app group directory, checking fallback locations');
        
        // Fallback: Try documents directory
        try {
          final Directory documentsDir = await getApplicationDocumentsDirectory();
          final String fallbackImagePath = path.join(documentsDir.path, _notificationImagesDir, fileName);
          AppLogger.info('Checking fallback path: $fallbackImagePath');
          
          final bool fallbackExists = await imageExists(fallbackImagePath);
          AppLogger.info('Fallback image exists: $fallbackExists');
          
          if (fallbackExists) {
            AppLogger.info('Image found in documents directory fallback');
            return Right(fallbackImagePath);
          }
          
          AppLogger.error('Image not found in any location');
          return const Left(MediaFailure(message: 'Image file not found in app group or documents directory'));
        } catch (e) {
          AppLogger.error('Fallback check failed: $e');
          return const Left(MediaFailure(message: 'Image file not found'));
        }
      }
    } catch (e, stackTrace) {
      AppLogger.error('Failed to get image path', e, stackTrace);
      return Left(MediaFailure(message: 'Failed to get image path: $e'));
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