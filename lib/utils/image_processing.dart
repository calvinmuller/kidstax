import 'package:image/image.dart' as img;
import 'dart:isolate';
import 'dart:typed_data';
import 'dart:io';

class ImageProcessingData {
  final String imagePath;
  final int targetWidth;
  
  ImageProcessingData({required this.imagePath, required this.targetWidth});
}

class ProcessedImageResult {
  final Uint8List processedBytes;
  final int width;
  final int height;
  final String? error;
  
  ProcessedImageResult({
    required this.processedBytes,
    required this.width,
    required this.height,
    this.error,
  });
}

class ImageProcessor {
  
  // Main entry point for background image processing
  static Future<ProcessedImageResult> processImageInBackground(
    String imagePath, 
    {int targetWidth = 384}
  ) async {
    final receivePort = ReceivePort();
    
    try {
      await Isolate.spawn(
        _processImageIsolate,
        [receivePort.sendPort, ImageProcessingData(imagePath: imagePath, targetWidth: targetWidth)]
      );
      
      final result = await receivePort.first as ProcessedImageResult;
      return result;
    } catch (e) {
      return ProcessedImageResult(
        processedBytes: Uint8List(0),
        width: 0,
        height: 0,
        error: 'Failed to process image: $e',
      );
    }
  }
  
  // Isolate entry point - runs image processing on separate thread
  static void _processImageIsolate(List<dynamic> args) async {
    final SendPort sendPort = args[0];
    final ImageProcessingData data = args[1];
    
    try {
      // Read and process the image for thermal printing
      final File imageFile = File(data.imagePath);
      final Uint8List imageBytes = await imageFile.readAsBytes();
      
      // Decode and resize image for thermal printer
      img.Image? originalImage = img.decodeImage(imageBytes);
      if (originalImage == null) {
        sendPort.send(ProcessedImageResult(
          processedBytes: Uint8List(0),
          width: 0,
          height: 0,
          error: 'Could not decode image',
        ));
        return;
      }
      
      // Resize to thermal printer width
      img.Image resizedImage = img.copyResize(originalImage, width: data.targetWidth);
      
      // Convert to grayscale first
      img.Image grayscaleImage = img.grayscale(resizedImage);
      
      // Optimize for portraits/faces
      img.Image optimizedImage = optimizeForPortraits(grayscaleImage);
      
      // Apply dithering for thermal printer optimization
      img.Image ditheredImage = applyFloydSteinbergDithering(optimizedImage);
      
      // Convert processed image back to bytes
      final Uint8List processedImageBytes = Uint8List.fromList(img.encodePng(ditheredImage));
      
      sendPort.send(ProcessedImageResult(
        processedBytes: processedImageBytes,
        width: ditheredImage.width,
        height: ditheredImage.height,
      ));
      
    } catch (e) {
      sendPort.send(ProcessedImageResult(
        processedBytes: Uint8List(0),
        width: 0,
        height: 0,
        error: 'Processing failed: $e',
      ));
    }
  }
  // Optimize image specifically for portrait/face printing on thermal printers
  static img.Image optimizeForPortraits(img.Image grayImage) {
    final img.Image result = img.Image.from(grayImage);
    
    for (int y = 0; y < result.height; y++) {
      for (int x = 0; x < result.width; x++) {
        final pixel = result.getPixel(x, y);
        final gray = img.getLuminanceRgb(pixel.r.toInt(), pixel.g.toInt(), pixel.b.toInt());
        
        // Brighten the image (especially shadows and midtones)
        double brightened = gray * 1.4; // Increase brightness by 40%
        
        // Apply S-curve for better contrast (enhance midtones)
        brightened = brightened / 255.0; // Normalize to 0-1
        brightened = brightened < 0.5 
            ? 2 * brightened * brightened 
            : 1 - 2 * (1 - brightened) * (1 - brightened);
        brightened = brightened * 255.0; // Back to 0-255
        
        // Clamp to valid range
        final newGray = brightened.clamp(0.0, 255.0).toInt();
        
        final newColor = img.ColorRgb8(newGray, newGray, newGray);
        result.setPixel(x, y, newColor);
      }
    }
    
    return result;
  }

  // Floyd-Steinberg dithering algorithm for thermal printer optimization
  static img.Image applyFloydSteinbergDithering(img.Image grayImage) {
    final img.Image result = img.Image.from(grayImage);
    
    for (int y = 0; y < result.height - 1; y++) {
      for (int x = 1; x < result.width - 1; x++) {
        final pixel = result.getPixel(x, y);
        final oldGray = img.getLuminanceRgb(pixel.r.toInt(), pixel.g.toInt(), pixel.b.toInt());
        
        // Apply threshold (black or white) - adjusted for better portraits
        final newGray = oldGray < 160 ? 0 : 255;
        final quantError = oldGray - newGray;
        
        // Set new pixel value
        final newColor = img.ColorRgb8(newGray, newGray, newGray);
        result.setPixel(x, y, newColor);
        
        // Distribute error to neighboring pixels (Floyd-Steinberg pattern)
        if (x + 1 < result.width) {
          _addError(result, x + 1, y, quantError * 7 / 16);
        }
        if (y + 1 < result.height) {
          if (x - 1 >= 0) {
            _addError(result, x - 1, y + 1, quantError * 3 / 16);
          }
          _addError(result, x, y + 1, quantError * 5 / 16);
          if (x + 1 < result.width) {
            _addError(result, x + 1, y + 1, quantError * 1 / 16);
          }
        }
      }
    }
    
    return result;
  }

  static void _addError(img.Image image, int x, int y, double error) {
    final pixel = image.getPixel(x, y);
    final currentGray = img.getLuminanceRgb(pixel.r.toInt(), pixel.g.toInt(), pixel.b.toInt());
    final newGray = (currentGray + error).clamp(0.0, 255.0).toInt();
    final newColor = img.ColorRgb8(newGray, newGray, newGray);
    image.setPixel(x, y, newColor);
  }
}