# NBJP

> No Bullshit, just Pushups – The leanest Pushup Counter.

[![Platform: iOS 17+](https://img.shields.io/badge/Platform-iOS-lightgrey)](https://www.apple.com/ios/)
![Latest Release](https://img.shields.io/github/v/release/pschulzk/nbjp?color=brightgreen&label=latest%20release)
![Last Commit](https://img.shields.io/github/last-commit/pschulzk/nbjp)

**NBJP** is a minimalist pushup tracker designed for everyone who value privacy and simplicity. No accounts, no tracking — only pushups.

---

## ⚡️ Features

- **Simple & Fast:** No login required. Open the app and start moving.
- **Apple Health Integration:** Seamlessly share your workout data with the Apple Health app.
- **Privacy-First:** No account, no analytics, no tracking.

## 🔒 Privacy Policy

_Last updated: January 2026_

NBJP is committed to protecting your privacy. This policy explains how we handle your data.

### 1. Data Collection & Storage

NBJP does not collect, store, or transmit any personal data to external servers. All workout history is stored locally on your device.

### 2. Apple Health (HealthKit) Integration

Our app offers optional integration with Apple Health.

- **Write-Only Access:** NBJP only requests permission to **write** (save) workout data (Pushups) to Apple Health.
- **No Reading:** We do not request permission to read any of your existing health data from Apple Health.
- **Usage:** This data is used solely to keep your personal fitness records centralized in the Apple Health ecosystem.
- **No Third-Parties:** We **do not** share, sell, or disclose your health data to any third-party advertising or marketing services.

### 3. Data Deletion

Since all data is stored on your device or in your personal iCloud/HealthKit, you can delete your data at any time by deleting the app.

- Local Data: All workout history stored within NBJP is permanently deleted when you uninstall the app from your device.
- HealthKit Data: Workouts synced to Apple Health remain in your Health app. You can manage or delete these records at any time directly within the Apple Health app (Browse > Activity > Workouts > Show All Data).
- Account Deletion: Since NBJP does not use accounts or cloud servers, there is no "account" to delete.

## 🆘 Support & Contact

Need help or want to suggest a feature?
Please [Open a GitHub Issue](https://github.com/pschulzk/nbjp/issues/new).

## ⚖️ Legal & Imprint

NBJP is a project by [**Solid Group**](https://www.solidgroup.agency/en/).

- **Imprint:** [Solid Group Imprint](https://www.solidgroup.agency/en#impressum)
- **Contact:** For billing or legal inquiries, please refer to the [contact form on our website](https://www.solidgroup.agency/en#kontakt).
- **EULA:** NBJP app distributed via Apple App Store is governed by the [Apple Standard EULA](https://www.apple.com/legal/internet-services/itunes/dev/stdeula/).

---

## 🛠 Development

Built with **Flutter**.
Apple Device and Signing required to run the iOS app.

### Setup locally:

```bash
git clone https://github.com/pschulzk/nbjp.git
cd nbjp
flutter pub get
cd ios && pod install
flutter run
```
