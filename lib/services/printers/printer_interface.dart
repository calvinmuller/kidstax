import 'package:flutter/material.dart';
import '../../utils/image_processing.dart';

enum PrinterType {
  urovo,
  sunmi,
}

enum PrinterConnectionStatus {
  connected,
  disconnected,
  error,
  unknown,
}

abstract class PrinterInterface {
  PrinterType get printerType;
  String get deviceName;
  
  Future<PrinterConnectionStatus> checkConnection();
  Future<void> printProcessedImage(ProcessedImageResult imageResult, BuildContext context);
  Future<void> printTestPage(BuildContext context);
  
  // Optional: Device-specific settings
  Map<String, dynamic> get defaultSettings => {};
  Future<void> updateSettings(Map<String, dynamic> settings) async {}
}