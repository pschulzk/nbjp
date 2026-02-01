#!/bin/sh

set -e # Exit immediately if a command fails

# 1. Install Flutter (using the stable branch)
git clone https://github.com/flutter/flutter.git --depth 1 -b stable $HOME/flutter
export PATH="$PATH:$HOME/flutter/bin"

# 2. Pre-cache artifacts for iOS only (saves time/compute hours)
flutter precache --ios

# 3. Install your project dependencies
cd .. # Move from 'ios/ci_scripts' to project root
flutter pub get

# 4. Initialize the iOS build files (This creates the missing Generated.xcconfig)
flutter build ios --config-only --release

# 5. Install CocoaPods (Required for device_info_plus and others)
cd ios
HOMEBREW_NO_AUTO_UPDATE=1 brew install cocoapods
pod install

exit 0
