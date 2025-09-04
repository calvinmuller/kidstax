import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import '../widgets/fun_decorations.dart';
import '../widgets/flower_camera_button.dart';
import '../widgets/camera_controls.dart';
import '../services/printer_service.dart';

class CameraScreen extends StatefulWidget {
  final List<CameraDescription> cameras;
  
  const CameraScreen({required this.cameras, super.key});

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  CameraController? controller;
  bool isCameraInitialized = false;
  String? capturedImagePath;
  bool isProcessing = false;
  int currentCameraIndex = 0;
  FlashMode currentFlashMode = FlashMode.off;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    await _requestCameraPermission();
    
    if (widget.cameras.isNotEmpty) {
      controller = CameraController(
        widget.cameras[currentCameraIndex],
        ResolutionPreset.high,
        enableAudio: false,
      );
      
      try {
        await controller!.initialize();
        await controller!.setFlashMode(currentFlashMode);
        setState(() {
          isCameraInitialized = true;
        });
      } catch (e) {
        print('Error initializing camera: $e');
      }
    }
  }

  Future<void> _requestCameraPermission() async {
    final status = await Permission.camera.request();
    if (status != PermissionStatus.granted) {
      print('Camera permission denied');
    }
  }

  Future<void> _capturePhoto() async {
    if (!controller!.value.isInitialized || isProcessing) {
      return;
    }

    setState(() {
      isProcessing = true;
    });

    try {
      final XFile image = await controller!.takePicture();
      
      final Directory appDirectory = await getApplicationDocumentsDirectory();
      final String fileName = 'photo_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final String filePath = path.join(appDirectory.path, fileName);
      
      await image.saveTo(filePath);
      
      setState(() {
        capturedImagePath = filePath;
      });
      
      // Print directly after capture
      if (mounted) {
        await PrinterService.printPhoto(filePath, context);
      }
    } catch (e) {
      print('Error capturing photo: $e');
    } finally {
      if (mounted) {
        setState(() {
          isProcessing = false;
        });
      }
    }
  }

  Future<void> _switchCamera() async {
    if (widget.cameras.length <= 1 || isProcessing) return;

    setState(() {
      isProcessing = true;
      isCameraInitialized = false; // Hide preview before disposing
    });

    try {
      await controller?.dispose();
      
      currentCameraIndex = (currentCameraIndex + 1) % widget.cameras.length;
      
      controller = CameraController(
        widget.cameras[currentCameraIndex],
        ResolutionPreset.high,
        enableAudio: false,
      );
      
      await controller!.initialize();
      await controller!.setFlashMode(currentFlashMode);
      
      setState(() {
        isCameraInitialized = true;
      });
    } catch (e) {
      print('Error switching camera: $e');
    } finally {
      setState(() {
        isProcessing = false;
      });
    }
  }

  Future<void> _toggleFlash() async {
    if (!isCameraInitialized || isProcessing) return;

    try {
      FlashMode newFlashMode;
      switch (currentFlashMode) {
        case FlashMode.off:
          newFlashMode = FlashMode.auto;
          break;
        case FlashMode.auto:
          newFlashMode = FlashMode.always;
          break;
        case FlashMode.always:
          newFlashMode = FlashMode.torch;
          break;
        case FlashMode.torch:
          newFlashMode = FlashMode.off;
          break;
      }

      await controller!.setFlashMode(newFlashMode);
      setState(() {
        currentFlashMode = newFlashMode;
      });
    } catch (e) {
      print('Error toggling flash: $e');
    }
  }

  String get _getFlashIcon {
    switch (currentFlashMode) {
      case FlashMode.off:
        return '🔆'; // Flash off
      case FlashMode.auto:
        return '⚡'; // Flash auto
      case FlashMode.always:
        return '💡'; // Flash on
      case FlashMode.torch:
        return '🔦'; // Torch/flashlight
    }
  }

  String get _getCameraIcon {
    final camera = widget.cameras[currentCameraIndex];
    return camera.lensDirection == CameraLensDirection.front ? '🤳' : '📷';
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!isCameraInitialized) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('📸 Ry Camera 🌈', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          ],
        ),
        backgroundColor: const Color(0xFF87CEEB), // Sky blue
        foregroundColor: Colors.white,
        elevation: 4,
        shadowColor: Colors.pink.withValues(alpha: 0.5),
      ),
      body: Stack(
        children: [
          SizedBox.expand(
            child: CameraPreview(controller!),
          ),
          const FunDecorations(),
          CameraControls(
            flashIcon: _getFlashIcon,
            cameraIcon: _getCameraIcon,
            onFlashTap: _toggleFlash,
            onCameraTap: _switchCamera,
            isDisabled: isProcessing,
            hasMultipleCameras: widget.cameras.length > 1,
          ),
          FlowerCameraButton(
            onTap: _capturePhoto,
            isLoading: isProcessing,
          ),
        ],
      ),
    );
  }
}