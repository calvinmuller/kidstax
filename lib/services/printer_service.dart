import 'package:flutter/services.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:flutter/material.dart';
import '../utils/image_processing.dart';
import '../utils/ui_helpers.dart';

class PrinterService {
  // Platform channel for Urovo printer communication
  static const platform = MethodChannel('za.co.istreet.rycamera/printer');

  static Future<void> printPhoto(String imagePath, BuildContext context) async {
    try {
      // Show processing progress
      if (context.mounted) {
        UIHelpers.showKidFriendlyMessage(
          context, 
          '📸✨ Smile! Making your photo super pretty for printing! 🌈',
          const Color(0xFFFF69B4),
        );
      }
      
      // Process image in background isolate to prevent UI blocking
      final ProcessedImageResult result = await ImageProcessor.processImageInBackground(imagePath);
      
      if (result.error != null) {
        throw Exception(result.error);
      }
      
      try {
        // Use platform channel to communicate with native Urovo SDK
        final printResult = await platform.invokeMethod('printImage', {
          'imageData': result.processedBytes,
          'width': result.width,
          'height': result.height,
        });
        
        print('Print result: $printResult');
        
        if (context.mounted) {
          UIHelpers.showKidFriendlyMessage(
            context,
            '🎉🖨️ Hooray! Your awesome photo is printed! 🌟',
            const Color(0xFF32CD32),
            duration: 4,
          );
        }
        
      } catch (platformError) {
        print('Platform channel error: $platformError');
        
        // Fallback: Save processed image locally
        final Directory appDirectory = await getApplicationDocumentsDirectory();
        final String processedPath = path.join(appDirectory.path, 'processed_for_urovo_${DateTime.now().millisecondsSinceEpoch}.png');
        await File(processedPath).writeAsBytes(result.processedBytes);
        
        if (context.mounted) {
          String errorMsg = 'Printing failed: ${platformError.toString()}';
          if (errorMsg.contains('stub')) {
            errorMsg = '📱✨ Oops! Printer is taking a nap! But don\'t worry, your beautiful photo is saved! 🌈📸';
          } else {
            errorMsg = '💾✨ Your pretty photo is safely saved! 📸🌟';
          }
          
          UIHelpers.showKidFriendlyMessage(
            context,
            errorMsg,
            Colors.orange,
            duration: 5,
          );
        }
      }
      
    } catch (e) {
      print('Error processing photo: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('🌈💫 Oopsie! Something silly happened, but let\'s try again! 😊'),
            backgroundColor: const Color(0xFFFF6B6B),
            duration: const Duration(seconds: 4),
          ),
        );
      }
    }
  }
}