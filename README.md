# Sumanth Net Admin

A cross-platform Flutter admin panel for Internet Service Providers (ISPs). Manage users, plans, payments, and cable billing from a single interface.

[![Flutter](https://img.shields.io/badge/Flutter-3.x-02569B?logo=flutter)](https://flutter.dev)
[![Flutter](https://img.shields.io/badge/Platform-Android%20%7C%20iOS%20%7C%20Web-lightgrey)](https://flutter.dev)
[![Firebase](https://img.shields.io/badge/Firebase-Auth%20%7C%20Firestore%20%7C%20Messaging-FFCA28?logo=firebase)](https://firebase.google.com)

---

## Features

- **Multi-admin support** — Multiple admin accounts with role-based access
- **User management** — Add, edit, view users; manage sessions and logs
- **Net plans & payments** — Configure plans, view active users, process payments
- **Cable payments** — Track and manage cable billing
- **Coupons** — Generate and manage promotional codes
- **OTP capture** — SMS receiver for OTP/code messages (Android)
- **PDF generation** — Generate bills and reports
- **Biometric login** — Fingerprint authentication on mobile
- **Push notifications** — Firebase Cloud Messaging

---

## Tech Stack

| Layer | Technology |
|-------|------------|
| Framework | Flutter |
| Backend | Firebase (Auth, Firestore, Messaging) |
| HTTP | Dio, HTTP |
| PDF | `printing`, `pdf` |
| State / DI | GetIt |

---

## Prerequisites

- [Flutter SDK](https://flutter.dev/docs/get-started/install) (>=2.7.0)
- [Firebase](https://firebase.google.com) project
- Android Studio / Xcode (for mobile builds)

---

## Getting Started

### 1. Clone the repository

```bash
git clone https://github.com/sumanthnani10/sumanthnetadmin.git
cd sumanthnetadmin
```

### 2. Install dependencies

```bash
flutter pub get
```

### 3. Configure Firebase

- Create a Firebase project at [Firebase Console](https://console.firebase.google.com)
- For **Android**: Add `google-services.json` to `android/app/`
- For **iOS**: Add `GoogleService-Info.plist` to `ios/Runner/`
- For **Web**: Copy `lib/firebase_options.example.dart` to `lib/firebase_options.dart` and fill in your Firebase web config (this file is gitignored)

### 4. Run the app

```bash
# Android
flutter run

# iOS
flutter run

# Web
flutter run -d chrome
```

---

## Project Structure

```
lib/
├── main.dart           # Entry point, login
├── home.dart           # Home screen, navigation
├── utils.dart          # Shared utilities, ISP switching
├── authentication.dart # Local auth (biometric)
├── firestoreCollection.dart
├── pdf_generation.dart
├── net_user/           # User management
│   ├── users.dart
│   ├── add_user.dart
│   ├── edit_user.dart
│   ├── bills.dart
│   ├── net_plans.dart
│   ├── net_payments.dart
│   ├── sessions.dart
│   ├── logs.dart
│   ├── renew.dart
│   └── otp_verification.dart
├── isp/                # ISP integrations
│   ├── jaze_isp.dart   # Base ISP interface
│   ├── ssc.dart
│   └── rvr.dart
└── cable/
    └── cable_payments.dart
```

---

## Configuration

- **Firebase**: Configure via `google-services.json` (Android) / `GoogleService-Info.plist` (iOS)
- **ISP backends**: Configure ISP endpoints and credentials in environment-specific config (do not commit secrets)

---

## Contributing

Contributions are welcome. Please:

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

---

## License

This project is published under the MIT License. See the [LICENSE](LICENSE) file for details.

---

## Acknowledgments

- [Flutter](https://flutter.dev)
- [Firebase](https://firebase.google.com)
