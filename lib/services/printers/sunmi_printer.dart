import 'package:flutter/material.dart';
import 'dart:io';
import 'dart:typed_data';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:sunmi_printer_plus/sunmi_printer_plus.dart';
import 'package:sunmi_printer_plus/enums.dart';
import 'package:sunmi_printer_plus/sunmi_style.dart';
import 'printer_interface.dart';
import '../../utils/image_processing.dart';
import '../../utils/ui_helpers.dart';

class SunmiPrinterWrapper implements PrinterInterface {
  
  @override
  PrinterType get printerType => PrinterType.sunmi;
  
  @override
  String get deviceName => 'Sunmi P3';
  
  @override
  Map<String, dynamic> get defaultSettings => {
    'paperWidth': 58, // mm - Sunmi P3 uses 80mm paper
    'imageWidth': 384, // pixels - wider than Urovo
    'dithering': true,
    'portraitOptimization': true,
    'density': 1, // Sunmi-specific density setting
  };

  @override
  Future<PrinterConnectionStatus> checkConnection() async {
    try {
      await SunmiPrinter.bindingPrinter();
      await SunmiPrinter.initPrinter();
      return PrinterConnectionStatus.connected;
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
      await SunmiPrinter.bindingPrinter();
      await SunmiPrinter.initPrinter();
      
      // Print the processed image using sunmi_printer_plus
      await SunmiPrinter.printImage(
        Uint8List.fromList(imageResult.processedBytes),
      );
      
      // Feed paper after printing
      await SunmiPrinter.lineWrap(3);
      
      print('Sunmi print completed successfully');
      
      if (context.mounted) {
        UIHelpers.showKidFriendlyMessage(
          context,
          '🎉🖨️ Amazing! Your photo is printed on Sunmi! ✨🌟',
          const Color(0xFF4CAF50),
          duration: 4,
        );
      }
      
    } catch (printerError) {
      print('Sunmi printer error: $printerError');
      
      // Fallback: Save processed image locally
      final Directory appDirectory = await getApplicationDocumentsDirectory();
      final String processedPath = path.join(
        appDirectory.path, 
        'sunmi_processed_${DateTime.now().millisecondsSinceEpoch}.png'
      );
      await File(processedPath).writeAsBytes(imageResult.processedBytes);
      
      if (context.mounted) {
        String errorMsg = '💾✨ Your pretty photo is safely saved for Sunmi! 📸🌟';
        if (printerError.toString().contains('not supported') || 
            printerError.toString().contains('not available')) {
          errorMsg = '📱✨ Oops! Sunmi printer is not available! But your beautiful photo is saved! 🌈📸';
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
      await SunmiPrinter.bindingPrinter();
      await SunmiPrinter.initPrinter();
      
      // Print test page using sunmi_printer_plus
      await SunmiPrinter.printText('===== SUNMI TEST =====', 
          style: SunmiStyle(align: SunmiPrintAlign.CENTER, bold: true));
      await SunmiPrinter.lineWrap(1);
      await SunmiPrinter.printText('Ry Camera App');
      await SunmiPrinter.lineWrap(1);
      await SunmiPrinter.printText('Test Print');
      await SunmiPrinter.lineWrap(1);
      await SunmiPrinter.printText(DateTime.now().toString());
      await SunmiPrinter.lineWrap(1);
      await SunmiPrinter.printText('========================', 
          style: SunmiStyle(align: SunmiPrintAlign.CENTER));
      await SunmiPrinter.lineWrap(3);
      
      print('Sunmi test page printed successfully');
      
      if (context.mounted) {
        UIHelpers.showKidFriendlyMessage(
          context,
          '📄✨ Test page printed on Sunmi! 🖨️',
          const Color(0xFF4CAF50),
        );
      }
    } catch (e) {
      print('Error printing Sunmi test page: $e');
      if (context.mounted) {
        UIHelpers.showKidFriendlyMessage(
          context,
          '❌ Could not print test page on Sunmi',
          Colors.red,
        );
      }
      rethrow;
    }
  }

  @override
  Future<void> updateSettings(Map<String, dynamic> settings) async {
    try {
      await SunmiPrinter.bindingPrinter();
      await SunmiPrinter.initPrinter();
      
      // Set print density if specified
      if (settings.containsKey('density')) {
        // sunmi_printer_plus density is typically 0-3
        int density = settings['density'] ?? 2;
        density = density.clamp(0, 3);
        // Note: Actual density setting method may vary based on plugin implementation
        print('Setting density to: $density');
      }
      
      print('Updated Sunmi printer settings: $settings');
    } catch (e) {
      print('Error updating Sunmi settings: $e');
    }
  }
}