import 'package:flutter/material.dart';
import '../utils/image_processing.dart';
import '../utils/ui_helpers.dart';
import 'printers/printer_factory.dart';
import 'printers/printer_interface.dart';

class PrinterService {
  static PrinterInterface? _printer;
  
  /// Initialize the printer service with automatic detection
  static Future<void> initialize() async {
    _printer = await PrinterFactory.detectPrinter();
    if (_printer != null) {
      print('Initialized printer: ${_printer!.deviceName}');
    }
  }
  
  /// Get current printer instance
  static PrinterInterface? get currentPrinter => _printer;
  
  /// Switch to a specific printer type
  static void switchPrinter(PrinterType type) {
    _printer = PrinterFactory.setPrinterType(type);
    print('Switched to printer: ${_printer!.deviceName}');
  }
  
  /// Main method to print a photo
  static Future<void> printPhoto(String imagePath, BuildContext context) async {
    try {
      // Ensure printer is initialized
      if (_printer == null) {
        await initialize();
      }
      
      if (_printer == null) {
        throw Exception('No printer available');
      }
      
      // Show processing progress
      if (context.mounted) {
        UIHelpers.showKidFriendlyMessage(
          context, 
          '📸✨ Smile! Making your photo super pretty for ${_printer!.deviceName}! 🌈',
          const Color(0xFFFF69B4),
        );
      }
      
      // Get printer-specific settings
      final settings = _printer!.defaultSettings;
      final int targetWidth = settings['imageWidth'] ?? 384;
      
      // Process image in background isolate with printer-specific width
      final ProcessedImageResult result = await ImageProcessor.processImageInBackground(
        imagePath,
        targetWidth: targetWidth,
      );
      
      if (result.error != null) {
        throw Exception(result.error);
      }
      
      // Print using the selected printer
      await _printer!.printProcessedImage(result, context);
      
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
  
  /// Print a test page
  static Future<void> printTestPage(BuildContext context) async {
    try {
      if (_printer == null) {
        await initialize();
      }
      
      if (_printer == null) {
        throw Exception('No printer available');
      }
      
      await _printer!.printTestPage(context);
      
    } catch (e) {
      print('Error printing test page: $e');
      if (context.mounted) {
        UIHelpers.showKidFriendlyMessage(
          context,
          '❌ Could not print test page',
          Colors.red,
        );
      }
    }
  }
  
  /// Check printer connection status
  static Future<PrinterConnectionStatus> checkPrinterStatus() async {
    if (_printer == null) {
      await initialize();
    }
    
    if (_printer == null) {
      return PrinterConnectionStatus.unknown;
    }
    
    return await _printer!.checkConnection();
  }
  
  /// Get list of available printer types
  static List<PrinterInterface> getAvailablePrinters() {
    return PrinterFactory.getAllPrinters();
  }
}