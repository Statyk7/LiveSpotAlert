import 'dart:io';
import 'dart:typed_data';
import 'dart:convert';
import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;
import '../../../../shared/base_domain/failures/failure.dart';

class ImageProcessingConfig {
  const ImageProcessingConfig({
    this.maxDimension = 300,
    this.maxEncodedSizeKB = 500,
    this.initialQuality = 85,
    this.minQuality = 30,
    this.qualityReductionStep = 15,
  });

  final int maxDimension;
  final int maxEncodedSizeKB;
  final int initialQuality;
  final int minQuality;
  final int qualityReductionStep;
}

abstract class ImageProcessingService {
  Future<Either<Failure, String?>> processImageForLiveActivity(
    String imagePath, {
    ImageProcessingConfig? config,
  });
}

class ImageProcessingServiceImpl implements ImageProcessingService {
  const ImageProcessingServiceImpl();

  @override
  Future<Either<Failure, String?>> processImageForLiveActivity(
    String imagePath, {
    ImageProcessingConfig? config,
  }) async {
    final processingConfig = config ?? const ImageProcessingConfig();

    try {
      final imageFile = File(imagePath);
      final imageBytes = await imageFile.readAsBytes();

      // Check original file size
      final originalSizeKB = imageBytes.length / 1024;
      debugPrint(
          "Original image size: ${originalSizeKB.toStringAsFixed(1)} KB");

      // Decode image
      img.Image? image = img.decodeImage(imageBytes);
      if (image == null) {
        debugPrint("Failed to decode image");
        return const Right(null);
      }

      debugPrint("Original image dimensions: ${image.width}x${image.height}");

      // Resize image if too large
      image = _resizeImageIfNeeded(image, processingConfig.maxDimension);

      // Convert to JPEG with compression
      Uint8List processedImageBytes = _compressImage(image, processingConfig);

      // Encode to base64
      final base64Image = base64Encode(processedImageBytes);
      final finalSizeKB = base64Image.length / 1024;

      debugPrint(
          "Final optimized image: ${finalSizeKB.toStringAsFixed(1)} KB base64");

      // Final size check
      if (finalSizeKB > processingConfig.maxEncodedSizeKB) {
        debugPrint(
            "Warning: Image still large at ${finalSizeKB.toStringAsFixed(1)} KB");
      }

      return Right(base64Image);
    } catch (e, stackTrace) {
      debugPrint("Error processing image: $e");
      debugPrint("Stack trace: $stackTrace");
      return Left(
          ImageProcessingFailure(message: 'Failed to process image: $e'));
    }
  }

  img.Image _resizeImageIfNeeded(img.Image image, int maxDimension) {
    if (image.width <= maxDimension && image.height <= maxDimension) {
      return image;
    }

    // Calculate new dimensions maintaining aspect ratio
    double scale = maxDimension /
        (image.width > image.height ? image.width : image.height);
    int newWidth = (image.width * scale).round();
    int newHeight = (image.height * scale).round();

    final resizedImage =
        img.copyResize(image, width: newWidth, height: newHeight);
    debugPrint(
        "Resized image to: ${resizedImage.width}x${resizedImage.height}");

    return resizedImage;
  }

  Uint8List _compressImage(img.Image image, ImageProcessingConfig config) {
    Uint8List processedImageBytes = Uint8List.fromList(
      img.encodeJpg(image, quality: config.initialQuality),
    );

    // Check if still too large, reduce quality further if needed
    int quality = config.initialQuality;
    while (
        processedImageBytes.length > (config.maxEncodedSizeKB * 1024 * 0.75) &&
            quality > config.minQuality) {
      quality -= config.qualityReductionStep;
      processedImageBytes =
          Uint8List.fromList(img.encodeJpg(image, quality: quality));
      debugPrint(
          "Reduced quality to $quality%, size: ${(processedImageBytes.length / 1024).toStringAsFixed(1)} KB");
    }

    return processedImageBytes;
  }
}

class ImageProcessingFailure extends Failure {
  const ImageProcessingFailure({required super.message});
}
