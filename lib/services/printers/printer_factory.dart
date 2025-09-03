import 'dart:io';
import 'package:flutter/services.dart';
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
        final deviceLower = deviceModel.toLowerCase();
        print('Device detection - checking: $deviceModel');
        
        if (deviceLower.contains('urovo') || 
            deviceLower.contains('i9100') ||
            deviceLower.contains('honeywell') ||
            deviceLower.contains('rt40')) {
          print('Detected Urovo/compatible device');
          _currentPrinter = UrovoPrinter();
          return _currentPrinter;
        } else if (deviceLower.contains('sunmi') || 
                   deviceLower.contains('p3') ||
                   deviceLower.contains('p2') ||
                   deviceLower.contains('v2') ||
                   deviceLower.contains('t2') ||
                   deviceLower.contains('m2')) {
          print('Detected Sunmi device');
          _currentPrinter = SunmiPrinterWrapper();
          return _currentPrinter;
        }
      }
      
      // Fallback: Try to connect to each printer type
      // Try Sunmi first since it's more common and has better plugin support
      final sunmi = SunmiPrinterWrapper();
      final sunmiStatus = await sunmi.checkConnection();
      
      if (sunmiStatus == PrinterConnectionStatus.connected) {
        _currentPrinter = sunmi;
        return _currentPrinter;
      }
      
      final urovo = UrovoPrinter();
      final urovoStatus = await urovo.checkConnection();
      
      if (urovoStatus == PrinterConnectionStatus.connected) {
        _currentPrinter = urovo;
        return _currentPrinter;
      }
      
      // Default to Sunmi if no printer is detected (more common)
      _currentPrinter = SunmiPrinterWrapper();
      return _currentPrinter;
      
    } catch (e) {
      print('Error detecting printer: $e');
      // Default fallback - prefer Sunmi
      _currentPrinter = SunmiPrinterWrapper();
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
        _currentPrinter = SunmiPrinterWrapper();
        break;
    }
    return _currentPrinter!;
  }
  
  /// Get list of all available printer types
  static List<PrinterInterface> getAllPrinters() {
    return [
      UrovoPrinter(),
      SunmiPrinterWrapper(),
    ];
  }
  
  /// Create specific printer instance
  static PrinterInterface createPrinter(PrinterType type) {
    switch (type) {
      case PrinterType.urovo:
        return UrovoPrinter();
      case PrinterType.sunmi:
        return SunmiPrinterWrapper();
    }
  }
  
  static Future<String?> _getDeviceModel() async {
    try {
      if (Platform.isAndroid) {
        // Try to get device information through platform channel
        const platform = MethodChannel('za.co.istreet.rycamera/device_info');
        try {
          final String? deviceModel = await platform.invokeMethod('getDeviceModel');
          print('Detected device model: $deviceModel');
          return deviceModel;
        } catch (platformError) {
          print('Platform channel error getting device model: $platformError');
          // Fallback to checking Android system properties if available
          return null;
        }
      }
      return null;
    } catch (e) {
      print('Error getting device model: $e');
      return null;
    }
  }
}