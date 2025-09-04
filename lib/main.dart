import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'screens/camera_screen.dart';
import 'services/printer_service.dart';

late List<CameraDescription> cameras;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize cameras
  cameras = await availableCameras();
  
  // Initialize printer service early
  try {
    await PrinterService.initialize();
    print('✅ Printer service initialized successfully');
  } catch (e) {
    print('⚠️ Warning: Printer initialization failed - $e');
    // Continue app launch even if printer fails - it will retry when needed
  }
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Ry Camera',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.pink),
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFF0F8FF), // Light blue background
      ),
      home: CameraScreen(cameras: cameras),
    );
  }
}

