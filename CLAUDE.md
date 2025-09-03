# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

**rycamera** is a Flutter camera application that captures photos and prints them using the Urovo i9100's thermal printer. The app has package ID `za.co.istreet.rycamera` and follows standard Flutter project structure with Android platform support.

## Development Commands

### Dependencies and Setup
- `flutter pub get` - Install/update dependencies
- `flutter pub upgrade` - Upgrade dependencies to latest compatible versions

### Development
- `flutter run` - Run the app in development mode with hot reload
- `flutter run --debug` - Run in debug mode
- `flutter run --release` - Run in release mode for performance testing

### Testing and Quality
- `flutter test` - Run all unit and widget tests
- `flutter analyze` - Run static analysis and linting
- `flutter doctor` - Check Flutter installation and dependencies

### Building
- `flutter build apk` - Build Android APK
- `flutter build appbundle` - Build Android App Bundle for Play Store
- `flutter clean` - Clean build artifacts

## Project Structure

- **lib/main.dart** - Main application entry point with default counter app
- **test/** - Widget and unit tests
- **android/** - Android platform-specific code and configuration
- **pubspec.yaml** - Project dependencies and metadata

## Key Configuration

- **SDK Version**: Flutter SDK ^3.10.0-28.0.dev (development channel)
- **Package Name**: za.co.istreet.rycamera
- **Linting**: Uses `package:flutter_lints/flutter.yaml` for code analysis
- **Android Target**: Standard Flutter Android embedding v2

## Development Notes

The project implements a camera application with thermal printing capabilities for the Urovo i9100 terminal. Key features include:

- **Camera Integration**: Live camera preview and photo capture using Flutter's camera plugin
- **Kid-Friendly UI**: Colorful interface with emojis, decorative elements, and a custom flower-shaped camera button
- **Interactive Elements**: Haptic feedback, pressed animations, and floating decorations for engaging user experience
- **Advanced Image Processing**: Automatic resizing, grayscale conversion, portrait optimization, and Floyd-Steinberg dithering for optimal thermal printing
- **Urovo i9100 Printing**: Native integration with `android.device.PrinterManager` SDK for direct printing to the built-in thermal printer
- **Instant Printing**: Photos are automatically processed and printed immediately after capture
- **Thermal Optimization**: Specialized portrait optimization and dithering algorithm creates dotty, newspaper-like appearance perfect for thermal printers

The Android package is configured under the `za.co.istreet` domain, indicating this is for iStreet company development.