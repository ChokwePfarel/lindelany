# Lindelani

**Lindelani** is a multi-purpose mobile application built with **Flutter** and **Firebase**, designed to solve essential student needs—finding university accommodation, buying/selling pre-owned campus items, and coordinating transport for goods.

> **Developer Note**: This was my **very first mobile application**. While it served as a functional and complete platform, it was built during my early learning journey before I fully mastered clean architecture, design patterns, and state management best practices. It served as a critical stepping stone that laid the foundation for my later projects where I applied industry-standard best practices.

---

## App Overview & Key Features

### 1. Student Accommodation Marketplace
- **Landlords**: Create, edit, and manage property listings with detailed descriptions, location specs, and room attributes.
- **Students**: Browse, filter, and inspect accommodation details, image galleries, and landlord contacts.

### 2. Campus Marketplace (Buy & Sell)
- Category-based marketplace for students (Books, Appliances, Electronics, Sports gear, etc.).
- Create, update, and manage product listings.
- Direct seller contact and listing management.

### 3. Transport & Rideshare Broadcast
- Post vehicle profiles and broadcast transport routes or ride availability.
- Search active transport broadcasts for student commutes and long-distance travel.

### 4. Real-Time In-App Chat & Notifications
- Instant messaging between students, landlords, sellers, and drivers powered by Firebase Firestore.
- Push notifications handled via **Firebase Cloud Messaging (FCM)** and `flutter_local_notifications`.

### 5. Auth, Security & Payments
- Google Sign-In & Email/Password Authentication.
- Account verification workflows and password reset functionality.
- Landlord verification with **Yoco Payment Gateway** integration.
- Protected app integrity using **Firebase App Check**.

---

## Current Status & Known Limitations

* **Image Upload Functionality**: Features involving uploading new images (e.g., uploading accommodation photos, product listings, or profile avatars) are currently restricted/inactive because the Firebase project was downgraded from a paid plan (Blaze) to a free tier plan.
* **Architecture & State Management**: State management is handled using `Provider` (`ChangeNotifier`). As my first app, the codebase prioritizes working functionality over strict architectural patterns, serving as a stepping stone to my later projects built with modern best practices.

---

## Tech Stack & Dependencies

- **Frontend Framework**: [Flutter](https://flutter.dev/) (Dart SDK)
- **State Management**: [Provider](https://pub.dev/packages/provider)
- **Backend Services**: 
  - Firebase Authentication
  - Cloud Firestore
  - Firebase Storage
  - Cloud Functions
  - Firebase Messaging & Analytics
  - Firebase App Check
- **Local Persistence**: [Hive](https://pub.dev/packages/hive) & `hive_flutter`
- **Payments**: Yoco Payment Gateway (`flutter_yoco` & webview)
- **Navigation & Routing**: `go_router` & Deep Linking (`app_links`)
- **Media Handling**: `image_picker`, `image_cropper`, `flutter_image_compress`, `cached_network_image`

---

## Project Structure

```text
lib/
├── Market/              # Marketplace UI, product listings & Firestore services
├── Transport_Broadcast/ # Transport vehicles, route broadcasts & providers
├── create_edit/         # Forms for creating/editing accommodation & user profiles
├── custom_made/         # Reusable custom UI components, widgets & inputs
├── firebase_Set/        # Firebase Firestore helper methods & user state handling
├── methods_functions/   # Chat service, image upload utilities & navigation
├── models/              # Data models (User, Listing, Chat, Product, Student)
├── payments/            # Yoco payment integration & webview payment flows
├── providers/           # App-wide ChangeNotifier providers
├── signIn&out/          # Authentication screens (Login, Signup, Gate, Password Reset)
├── user_interface/      # Main application screens (Accommodations, Chat, Settings)
└── main.dart            # App entry point, provider setup & initialization
```

---

## How to Run Locally

### Prerequisites
1. Install the [Flutter SDK](https://docs.flutter.dev/get-started/install).
2. Set up an Android Emulator or connect a physical test device.
3. Configure a Firebase project with Firestore, Auth, and Storage enabled.

### Setup Instructions
1. **Clone the repository**:
   ```bash
   git clone https://github.com/your-username/lindelany.git
   cd lindelany
   ```

2. **Install dependencies**:
   ```bash
   flutter pub get
   ```

3. **Configure Firebase**:
   Ensure `lib/firebase_options.dart` and `android/app/google-services.json` are present and configured for your Firebase environment.

4. **Run the application**:
   ```bash
   flutter run
   ```

---

## Reflection & Learning Outcomes

This project was an invaluable practical experience in full-stack mobile application development. Key takeaways included:
- Integrating multi-service Firebase backends (Auth, Firestore, Storage, FCM, App Check).
- Implementing real-time chat, push notifications, and payment gateways in Flutter.
- Understanding state management with Provider and local storage caching with Hive.
- Gaining firsthand experience with technical debt and architectural evolution, which directly shaped the adoption of best practices in subsequent projects.
