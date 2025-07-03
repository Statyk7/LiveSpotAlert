import 'dart:io';
import 'dart:typed_data';
import 'dart:convert';
import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;
import '../../../../shared/base_domain/failures/failure.dart';
import '../../../../shared/base_domain/use_case.dart';

class ProcessImageForLiveActivityParams {
  const ProcessImageForLiveActivityParams({
    required this.imagePath,
    this.maxDimension = 300,
    this.maxEncodedSizeKB = 500,
    this.initialQuality = 85,
    this.minQuality = 30,
  });

  final String imagePath;
  final int maxDimension;
  final int maxEncodedSizeKB;
  final int initialQuality;
  final int minQuality;
}

class ProcessImageForLiveActivityUseCase
    implements UseCase<String?, ProcessImageForLiveActivityParams> {
  @override
  Future<Either<Failure, String?>> call(
      ProcessImageForLiveActivityParams params) async {
    try {
      final imageFile = File(params.imagePath);
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
      if (image.width > params.maxDimension ||
          image.height > params.maxDimension) {
        // Calculate new dimensions maintaining aspect ratio
        double scale = params.maxDimension /
            (image.width > image.height ? image.width : image.height);
        int newWidth = (image.width * scale).round();
        int newHeight = (image.height * scale).round();

        image = img.copyResize(image, width: newWidth, height: newHeight);
        debugPrint("Resized image to: ${image.width}x${image.height}");
      }

      // Convert to JPEG with compression for better size control
      Uint8List processedImageBytes = Uint8List.fromList(
          img.encodeJpg(image, quality: params.initialQuality));

      // Check if still too large, reduce quality further if needed
      int quality = params.initialQuality;
      while (processedImageBytes.length >
              (params.maxEncodedSizeKB * 1024 * 0.75) &&
          quality > params.minQuality) {
        quality -= 15;
        processedImageBytes =
            Uint8List.fromList(img.encodeJpg(image, quality: quality));
        debugPrint(
            "Reduced quality to $quality%, size: ${(processedImageBytes.length / 1024).toStringAsFixed(1)} KB");
      }

      // Encode to base64
      final base64Image = base64Encode(processedImageBytes);
      final finalSizeKB = base64Image.length / 1024;

      debugPrint(
          "Final optimized image: ${finalSizeKB.toStringAsFixed(1)} KB base64 (${(processedImageBytes.length / 1024).toStringAsFixed(1)} KB raw)");

      // Final size check
      if (finalSizeKB > params.maxEncodedSizeKB) {
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
}

class ImageProcessingFailure extends Failure {
  const ImageProcessingFailure({required super.message});
}
