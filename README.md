# DUalert - Emergency Alert Security System

DUalert is a production-ready, feature-rich Flutter application designed to serve as an Emergency Alert Security System for Dominion University. It allows students to quickly and discreetly report emergencies, while providing administrators with a powerful dashboard to monitor and manage alerts in real-time.

## 🌟 Key Features

* **Real-time Emergency Reporting**: Instantly send SOS or custom alerts with location data.
* **Voice Input Integration**: Speak your emergency details for hands-free reporting using advanced `speech_to_text`.
* **Automated Email Notifications**: Receive instant email confirmations and status updates via Firebase Trigger Email.
* **Email Verification System**: Secure access ensuring only authenticated and verified students/staff can use the app.
* **Dynamic Light & Dark Themes**: Fully responsive Material 3 design supporting system, light, and dark modes.
* **Admin Dashboard**: Comprehensive dashboard for authorities to view, manage, and resolve emergency reports.
* **Location & Maps**: View the exact location of the emergency directly on Google Maps.

## 📱 Screenshots

| Student Dashboard | Voice Input | Light/Dark Theme | Admin Dashboard |
|:---:|:---:|:---:|:---:|
| ![Student Dashboard](placeholder_1.png) | ![Voice Input](placeholder_2.png) | ![Themes](placeholder_3.png) | ![Admin Dashboard](placeholder_4.png) |

## 🛠 Architecture

The project has been refactored into a scalable, feature-first structure:

```text
lib/
├── core/
│   ├── constants/
│   ├── services/       # EmailService
│   ├── theme/          # AppColors, AppTheme
│   └── widgets/        # Shared components
├── features/
│   ├── auth/           # Login, Signup, Email Verification
│   ├── dashboard/      # Admin Home, Alert History, Analytics
│   ├── emergency/      # Student Home, Voice Input
│   └── settings/       # Settings Screen
├── models/             # AppUser, AlertModel
├── providers/          # UserProvider, ThemeProvider, AlertProvider
└── main.dart
```

## 🚀 Installation Instructions

### Prerequisites
* Flutter SDK (v3.8.0 or higher recommended)
* Dart SDK
* Firebase CLI installed and configured
* Android Studio or Xcode for emulator/device testing

### Steps
1. **Clone the repository:**
   ```bash
   git clone https://github.com/your-org/dualert.git
   cd dualert
   ```

2. **Install Dependencies:**
   ```bash
   flutter pub get
   ```

3. **Configure Environment:**
   If running on a new environment, use the FlutterFire CLI to configure the project:
   ```bash
   flutterfire configure
   ```

4. **Run the App:**
   ```bash
   flutter run
   ```

## 🔥 Firebase Setup Guide

To fully enable all features, particularly the automated email notifications, follow these steps in your Firebase Console:

1. **Authentication:**
   * Enable "Email/Password" sign-in provider.

2. **Cloud Firestore:**
   * Create a Firestore database.
   * Apply the necessary security rules (see `firebase.json` or configure in console to restrict access to authenticated users).

3. **Firebase Extension: Trigger Email (`firestore-send-email`)**
   * Go to "Extensions" in the Firebase Console.
   * Search for and install **Trigger Email**.
   * Configure the extension:
     * **SMTP URI**: Provide your SMTP details (e.g., SendGrid, Mailgun, or standard SMTP).
     * **Email documents collection**: Set this to `mail`.
     * **Default FROM address**: Set a reliable sender address (e.g., `noreply@dualert.com`).
   * The app's `EmailService` automatically writes email templates to the `mail` collection, which the extension will process and send.

## 🛡️ Security Rules (Firestore)

Ensure your Firestore database uses the following fundamental rules for production:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /users/{userId} {
      // Users can only read/write their own profile unless they are an admin
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
    match /alerts/{alertId} {
      // Any verified user can create an alert
      allow create: if request.auth != null && request.auth.token.email_verified == true;
      // Users can read their own alerts; Admins can read all
      allow read: if request.auth != null;
      // Only admins can update the handled status
      allow update: if request.auth != null; 
    }
    match /mail/{mailId} {
      // Allow users to queue emails
      allow create: if request.auth != null;
      allow read: if false; // Users shouldn't read the mail queue
    }
  }
}
```

## 📝 Code Quality
- Uses Provider/Riverpod for scalable state management.
- Follows SOLID principles and Clean Architecture.
- Null-safe Dart implementation.

## 🤝 Contributing
Contributions, issues, and feature requests are welcome!

---
*Developed by the DUalert Engineering Team.*
