import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'printer_interface.dart';
import '../../utils/image_processing.dart';
import '../../utils/ui_helpers.dart';

class UrovoPrinter implements PrinterInterface {
  // Platform channel for Urovo printer communication
  static const platform = MethodChannel('za.co.istreet.rycamera/printer');
  
  @override
  PrinterType get printerType => PrinterType.urovo;
  
  @override
  String get deviceName => 'Urovo i9100';
  
  @override
  Map<String, dynamic> get defaultSettings => {
    'paperWidth': 58, // mm
    'imageWidth': 384, // pixels
    'dithering': true,
    'portraitOptimization': true,
  };

  @override
  Future<PrinterConnectionStatus> checkConnection() async {
    try {
      final result = await platform.invokeMethod('checkPrinterStatus');
      if (result == 'connected' || result == 'ready') {
        return PrinterConnectionStatus.connected;
      } else if (result == 'error') {
        return PrinterConnectionStatus.error;
      } else {
        return PrinterConnectionStatus.disconnected;
      }
    } catch (e) {
      print('Error checking Urovo printer connection: $e');
      return PrinterConnectionStatus.unknown;
    }
  }

  @override
  Future<void> printProcessedImage(ProcessedImageResult imageResult, BuildContext context) async {
    if (imageResult.error != null) {
      throw Exception(imageResult.error);
    }
    
    try {
      // Use platform channel to communicate with native Urovo SDK
      final printResult = await platform.invokeMethod('printImage', {
        'imageData': imageResult.processedBytes,
        'width': imageResult.width,
        'height': imageResult.height,
      });
      
      print('Urovo print result: $printResult');
      
      if (context.mounted) {
        UIHelpers.showKidFriendlyMessage(
          context,
          '🎉🖨️ Hooray! Your awesome photo is printed on Urovo! 🌟',
          const Color(0xFF32CD32),
          duration: 4,
        );
      }
      
    } catch (platformError) {
      print('Urovo platform channel error: $platformError');
      
      // Fallback: Save processed image locally
      final Directory appDirectory = await getApplicationDocumentsDirectory();
      final String processedPath = path.join(
        appDirectory.path, 
        'urovo_processed_${DateTime.now().millisecondsSinceEpoch}.png'
      );
      await File(processedPath).writeAsBytes(imageResult.processedBytes);
      
      if (context.mounted) {
        String errorMsg = 'Urovo printing failed: ${platformError.toString()}';
        if (errorMsg.contains('stub')) {
          errorMsg = '📱✨ Oops! Urovo printer is taking a nap! But don\'t worry, your beautiful photo is saved! 🌈📸';
        } else {
          errorMsg = '💾✨ Your pretty photo is safely saved for Urovo! 📸🌟';
        }
        
        UIHelpers.showKidFriendlyMessage(
          context,
          errorMsg,
          Colors.orange,
          duration: 5,
        );
      }
      
      rethrow;
    }
  }

  @override
  Future<void> printTestPage(BuildContext context) async {
    try {
      final result = await platform.invokeMethod('printTestPage');
      print('Urovo test page result: $result');
      
      if (context.mounted) {
        UIHelpers.showKidFriendlyMessage(
          context,
          '📄✨ Test page printed on Urovo i9100! 🖨️',
          const Color(0xFF32CD32),
        );
      }
    } catch (e) {
      print('Error printing Urovo test page: $e');
      if (context.mounted) {
        UIHelpers.showKidFriendlyMessage(
          context,
          '❌ Could not print test page on Urovo',
          Colors.red,
        );
      }
      rethrow;
    }
  }

  @override
  Future<void> updateSettings(Map<String, dynamic> settings) async {
    try {
      // Update Urovo-specific settings if any
      // Urovo i9100 has limited configurable settings compared to Sunmi
      print('Updated Urovo printer settings: $settings');
    } catch (e) {
      print('Error updating Urovo settings: $e');
    }
  }
}