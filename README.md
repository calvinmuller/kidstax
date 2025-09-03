# 📸 Ry Camera 🌈

A delightful Flutter camera application designed for the Urovo i9100 thermal printer terminal. This kid-friendly app captures photos and prints them instantly using advanced thermal printing optimization.

![Flutter](https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white)
![Dart](https://img.shields.io/badge/Dart-0175C2?style=for-the-badge&logo=dart&logoColor=white)
![Android](https://img.shields.io/badge/Android-3DDC84?style=for-the-badge&logo=android&logoColor=white)

## ✨ Features

### 📱 Camera Functionality
- **Multi-camera support** - Switch between front and back cameras
- **Flash controls** - Four modes: Off, Auto, Always, Torch
- **High-quality capture** - Photos optimized for thermal printing
- **Real-time preview** - Live camera feed with smooth performance

### 🖨️ Multi-Device Thermal Printing
- **Multi-printer support** - Supports both Urovo i9100 and Sunmi P3 devices
- **Automatic detection** - Automatically detects and configures the appropriate printer
- **Instant printing** - Photos automatically printed after capture
- **Device-specific optimization** - Different image processing for each printer type
- **Advanced image processing** - Portrait-specific brightness and contrast enhancement
- **Floyd-Steinberg dithering** - Creates optimal dotty appearance for thermal printers
- **Factory pattern architecture** - Easily extensible for additional printer types

### 🎨 Kid-Friendly UI
- **Colorful interface** - Bright, engaging design with emojis
- **Flower-shaped camera button** - Custom-painted interactive button
- **Floating decorations** - Animated emoji elements around the screen
- **Haptic feedback** - Tactile responses for button interactions

### ⚡ Performance
- **Background processing** - Image optimization runs on separate isolate
- **Non-blocking UI** - Smooth animations during processing
- **Loading states** - Visual feedback prevents duplicate captures
- **Memory efficient** - Proper resource management and cleanup

## 🏗️ Project Structure

```
lib/
├── main.dart                      # App entry point
├── screens/
│   └── camera_screen.dart         # Main camera interface
├── widgets/
│   ├── flower_camera_button.dart  # Custom camera button
│   ├── fun_decorations.dart       # Floating emoji decorations
│   └── camera_controls.dart       # Flash and camera switch controls
├── services/
│   ├── printer_service.dart       # Main printing coordinator
│   └── printers/                  # Multi-device printer support
│       ├── printer_interface.dart # Abstract printer interface
│       ├── printer_factory.dart   # Factory for creating printer instances
│       ├── urovo_printer.dart     # Urovo i9100 implementation
│       └── sunmi_printer.dart     # Sunmi P3 implementation
└── utils/
    ├── image_processing.dart       # Background image optimization
    └── ui_helpers.dart            # Reusable UI components
```

## 🚀 Getting Started

### Prerequisites
- Flutter SDK ^3.10.0-28.0.dev (development channel)
- Android development environment
- Supported thermal printer device:
  - **Urovo i9100** terminal, or
  - **Sunmi P3** POS device

### Installation

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd rycamera
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Run the app**
   ```bash
   flutter run
   ```

### Development Commands

```bash
# Install/update dependencies
flutter pub get
flutter pub upgrade

# Development
flutter run --debug          # Debug mode with hot reload
flutter run --release        # Release mode for performance testing

# Testing and Quality
flutter test                 # Run tests
flutter analyze              # Static analysis and linting
flutter doctor               # Check Flutter installation

# Building
flutter build apk            # Build Android APK
flutter build appbundle      # Build for Play Store
flutter clean                # Clean build artifacts
```

## 📦 Dependencies

### Core Dependencies
- `camera` - Camera functionality and preview
- `permission_handler` - Camera permissions management
- `image` - Image processing and optimization
- `path_provider` - File system path management

### Development Dependencies
- `flutter_lints` - Code quality and style enforcement

## 🖨️ Multi-Device Thermal Printing Features

### Supported Devices

#### Urovo i9100
- **Paper Width**: 58mm thermal paper
- **Resolution**: 384 pixels width
- **Platform Channel**: `za.co.istreet.rycamera/printer`
- **Methods**: `printImage`, `checkPrinterStatus`, `printTestPage`

#### Sunmi P3
- **Paper Width**: 80mm thermal paper  
- **Resolution**: 576 pixels width
- **Platform Channel**: `za.co.istreet.rycamera/sunmi_printer`
- **Methods**: `printBitmap`, `printText`, `setPrintDensity`

### Image Processing Pipeline
1. **Capture** - High-resolution photo capture
2. **Device Detection** - Automatically detect Urovo or Sunmi device
3. **Adaptive Resize** - Scale to device-specific width (384px or 576px)
4. **Grayscale** - Convert to monochrome
5. **Portrait Optimization** - Brighten shadows and enhance midtones
6. **Floyd-Steinberg Dithering** - Create optimal dot pattern
7. **Device-Specific Print** - Send to appropriate printer with device settings

### Factory Pattern Architecture
- **Printer Interface** - Abstract base for all printer types
- **Auto-Detection** - Automatically selects appropriate printer
- **Easy Extension** - Add new printer types by implementing interface
- **Device-Specific Settings** - Each printer has optimized configurations

## 🎯 Technical Architecture

### Background Processing
- **Dart Isolates** - Image processing runs on separate thread
- **Non-blocking UI** - Main thread stays responsive
- **Memory Management** - Efficient resource handling

### State Management
- **StatefulWidget** - Local state for camera and UI
- **Loading States** - Prevents duplicate operations
- **Error Handling** - Graceful failure recovery

### Performance Optimizations
- **Isolate Processing** - CPU-intensive tasks off main thread
- **Proper Disposal** - Camera controller cleanup
- **Efficient Rendering** - Custom painters for complex UI elements

## 🎨 UI/UX Design

### Design Philosophy
- **Kid-Friendly** - Large, colorful, emoji-based interface
- **Intuitive** - Simple tap interactions
- **Engaging** - Animations and haptic feedback
- **Accessible** - High contrast and large touch targets

### Custom Components
- **Flower Camera Button** - Multi-petal design with animations
- **Floating Decorations** - Positioned emoji elements
- **Control Buttons** - Circular controls with shadows and animations

## 🔧 Configuration

### Package Configuration
- **Package ID**: `za.co.istreet.rycamera`
- **Min SDK**: Android API level specified in `android/app/build.gradle`
- **Target SDK**: Latest Android version
- **Permissions**: Camera access required

### Platform Channels

#### Urovo i9100
- **Channel**: `za.co.istreet.rycamera/printer`
- **Methods**: 
  - `printImage` - Print processed bitmap
  - `checkPrinterStatus` - Check printer connection
  - `printTestPage` - Print test pattern

#### Sunmi P3  
- **Channel**: `za.co.istreet.rycamera/sunmi_printer`
- **Methods**:
  - `printBitmap` - Print processed bitmap with alignment
  - `printText` - Print text with formatting
  - `setPrintDensity` - Configure print density
  - `checkPrinterStatus` - Check printer connection

## 🧪 Testing

Currently the project includes:
- Widget tests for UI components
- Unit tests for utility functions
- Integration tests for camera functionality

Run tests with:
```bash
flutter test
```

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

### Code Style
- Follow Flutter/Dart conventions
- Use `flutter analyze` to check code quality
- Maintain existing architecture patterns
- Add tests for new functionality

## 📱 Device Compatibility

### Primary Targets
- **Urovo i9100** - Thermal printer terminal (58mm paper)
- **Sunmi P3** - POS thermal printer device (80mm paper)
- **Android** - Primary platform for both devices

### Requirements
- Android 5.0+ (API level 21+)
- Camera permission
- Storage permission for image saving
- Minimum 2GB RAM recommended

## 🔮 Future Enhancements

- [ ] Gallery view for captured photos
- [ ] Photo editing features (crop, filters)
- [ ] Multiple print sizes
- [ ] Cloud storage integration
- [ ] Photo sharing capabilities
- [ ] Custom thermal printer profiles
- [ ] Batch printing functionality

## 📄 License

This project is part of iStreet company development for the Urovo i9100 terminal.

## 🙏 Acknowledgments

- Flutter team for the excellent framework
- Urovo for the i9100 terminal and SDK
- Image processing algorithms from the Dart image package
- Custom UI components inspired by kid-friendly design patterns

## 📞 Support

For support and questions:
- Check existing issues in the repository
- Create new issues for bugs or feature requests
- Follow Flutter best practices for troubleshooting

---

**Built with ❤️ using Flutter for the Urovo i9100 thermal printer terminal**