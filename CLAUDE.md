# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a Flutter project named "nbjp" that is currently uninitialized.

## Common Development Commands

### Flutter Project Initialization
```bash
flutter create . --project-name nbjp
```

### Once initialized, common Flutter commands:
```bash
# Run the app
flutter run

# Run on specific device/platform
flutter run -d chrome  # Web
flutter run -d ios     # iOS simulator
flutter run -d android # Android emulator

# Build commands
flutter build apk      # Android APK
flutter build ios      # iOS build
flutter build web      # Web build

# Testing
flutter test           # Run all tests
flutter test test/widget_test.dart  # Run specific test file

# Code analysis and formatting
flutter analyze        # Analyze code for issues
dart format .         # Format all Dart files

# Dependencies
flutter pub get       # Install dependencies
flutter pub upgrade   # Upgrade dependencies
```

## Project Structure (once initialized)

Standard Flutter project structure will include:
- `lib/` - Main application code
  - `main.dart` - Entry point
- `test/` - Unit and widget tests
- `android/` - Android-specific code
- `ios/` - iOS-specific code
- `web/` - Web-specific code
- `pubspec.yaml` - Project configuration and dependencies