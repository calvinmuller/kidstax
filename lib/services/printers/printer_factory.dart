import 'dart:io';
import 'printer_interface.dart';
import 'urovo_printer.dart';
import 'sunmi_printer.dart';

class PrinterFactory {
  static PrinterInterface? _currentPrinter;
  
  /// Get the current active printer instance
  static PrinterInterface? get currentPrinter => _currentPrinter;
  
  /// Detect and create appropriate printer instance based on device
  static Future<PrinterInterface?> detectPrinter() async {
    try {
      // Try to detect device type based on system properties or available hardware
      final String? deviceModel = await _getDeviceModel();
      
      if (deviceModel != null) {
        if (deviceModel.toLowerCase().contains('urovo') || 
            deviceModel.toLowerCase().contains('i9100')) {
          _currentPrinter = UrovoPrinter();
          return _currentPrinter;
        } else if (deviceModel.toLowerCase().contains('sunmi') || 
                   deviceModel.toLowerCase().contains('p3')) {
          _currentPrinter = SunmiPrinter();
          return _currentPrinter;
        }
      }
      
      // Fallback: Try to connect to each printer type
      final urovo = UrovoPrinter();
      final urovoStatus = await urovo.checkConnection();
      
      if (urovoStatus == PrinterConnectionStatus.connected) {
        _currentPrinter = urovo;
        return _currentPrinter;
      }
      
      final sunmi = SunmiPrinter();
      final sunmiStatus = await sunmi.checkConnection();
      
      if (sunmiStatus == PrinterConnectionStatus.connected) {
        _currentPrinter = sunmi;
        return _currentPrinter;
      }
      
      // Default to Urovo if no printer is detected
      _currentPrinter = UrovoPrinter();
      return _currentPrinter;
      
    } catch (e) {
      print('Error detecting printer: $e');
      // Default fallback
      _currentPrinter = UrovoPrinter();
      return _currentPrinter;
    }
  }
  
  /// Manually set printer type
  static PrinterInterface setPrinterType(PrinterType type) {
    switch (type) {
      case PrinterType.urovo:
        _currentPrinter = UrovoPrinter();
        break;
      case PrinterType.sunmi:
        _currentPrinter = SunmiPrinter();
        break;
    }
    return _currentPrinter!;
  }
  
  /// Get list of all available printer types
  static List<PrinterInterface> getAllPrinters() {
    return [
      UrovoPrinter(),
      SunmiPrinter(),
    ];
  }
  
  /// Create specific printer instance
  static PrinterInterface createPrinter(PrinterType type) {
    switch (type) {
      case PrinterType.urovo:
        return UrovoPrinter();
      case PrinterType.sunmi:
        return SunmiPrinter();
    }
  }
  
  static Future<String?> _getDeviceModel() async {
    try {
      if (Platform.isAndroid) {
        // This would typically use a platform channel to get device info
        // For now, return null to use fallback detection
        return null;
      }
      return null;
    } catch (e) {
      print('Error getting device model: $e');
      return null;
    }
  }
}