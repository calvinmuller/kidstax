import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'printer_interface.dart';
import '../../utils/image_processing.dart';
import '../../utils/ui_helpers.dart';

class SunmiPrinter implements PrinterInterface {
  // Platform channel for Sunmi printer communication
  static const platform = MethodChannel('za.co.istreet.rycamera/sunmi_printer');
  
  @override
  PrinterType get printerType => PrinterType.sunmi;
  
  @override
  String get deviceName => 'Sunmi P3';
  
  @override
  Map<String, dynamic> get defaultSettings => {
    'paperWidth': 80, // mm - Sunmi P3 uses 80mm paper
    'imageWidth': 576, // pixels - wider than Urovo
    'dithering': true,
    'portraitOptimization': true,
    'density': 2, // Sunmi-specific density setting
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
      print('Error checking Sunmi printer connection: $e');
      return PrinterConnectionStatus.unknown;
    }
  }

  @override
  Future<void> printProcessedImage(ProcessedImageResult imageResult, BuildContext context) async {
    if (imageResult.error != null) {
      throw Exception(imageResult.error);
    }
    
    try {
      // Use platform channel to communicate with Sunmi SDK
      final printResult = await platform.invokeMethod('printBitmap', {
        'imageData': imageResult.processedBytes,
        'width': imageResult.width,
        'height': imageResult.height,
        'alignment': 1, // Center alignment
      });
      
      print('Sunmi print result: $printResult');
      
      if (context.mounted) {
        UIHelpers.showKidFriendlyMessage(
          context,
          '🎉🖨️ Amazing! Your photo is printed on Sunmi P3! ✨🌟',
          const Color(0xFF4CAF50),
          duration: 4,
        );
      }
      
    } catch (platformError) {
      print('Sunmi platform channel error: $platformError');
      
      // Fallback: Save processed image locally
      final Directory appDirectory = await getApplicationDocumentsDirectory();
      final String processedPath = path.join(
        appDirectory.path, 
        'sunmi_processed_${DateTime.now().millisecondsSinceEpoch}.png'
      );
      await File(processedPath).writeAsBytes(imageResult.processedBytes);
      
      if (context.mounted) {
        String errorMsg = 'Sunmi printing failed: ${platformError.toString()}';
        if (errorMsg.contains('stub') || errorMsg.contains('not implemented')) {
          errorMsg = '📱✨ Oops! Sunmi P3 printer is sleeping! But your beautiful photo is saved! 🌈📸';
        } else {
          errorMsg = '💾✨ Your pretty photo is safely saved for Sunmi P3! 📸🌟';
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
      // Print a simple test pattern
      final result = await platform.invokeMethod('printText', {
        'text': '===== SUNMI P3 TEST =====\n\nRy Camera App\nTest Print\n${DateTime.now().toString()}\n\n========================\n\n',
        'size': 24,
        'align': 1, // Center
      });
      
      print('Sunmi test page result: $result');
      
      if (context.mounted) {
        UIHelpers.showKidFriendlyMessage(
          context,
          '📄✨ Test page printed on Sunmi P3! 🖨️',
          const Color(0xFF4CAF50),
        );
      }
    } catch (e) {
      print('Error printing Sunmi test page: $e');
      if (context.mounted) {
        UIHelpers.showKidFriendlyMessage(
          context,
          '❌ Could not print test page on Sunmi P3',
          Colors.red,
        );
      }
      rethrow;
    }
  }

  @override
  Future<void> updateSettings(Map<String, dynamic> settings) async {
    try {
      // Update Sunmi-specific settings like density, speed, etc.
      if (settings.containsKey('density')) {
        await platform.invokeMethod('setPrintDensity', {
          'density': settings['density'],
        });
      }
      
      print('Updated Sunmi printer settings: $settings');
    } catch (e) {
      print('Error updating Sunmi settings: $e');
    }
  }
}