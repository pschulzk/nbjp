#!/bin/sh

# Fail immediately if any command fails
set -e

# 1. Move to the project root (where pubspec.yaml is)
cd "$CI_PRIMARY_REPOSITORY_PATH"

# 2. Install Flutter
git clone https://github.com/flutter/flutter.git --depth 1 -b stable $HOME/flutter
export PATH="$PATH:$HOME/flutter/bin"

# 3. Prepare Flutter
flutter precache --ios
flutter pub get

# 4. Install CocoaPods and Pods
brew install cocoapods
cd ios && pod install

exit 0
