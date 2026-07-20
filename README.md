# SmartStock Mobile App

## Overview
SmartStock Mobile is a mobile application for Android (can also be built for iOS), helping users/staff perform inventory management tasks (inventory checking, import/export, barcode scanning, tracking goods) conveniently. The application is built cross-platform using the Flutter framework.

## Technologies
- **Framework:** Flutter (Dart) - SDK version `^3.11.5`
- **State Management:** Provider
- **Local Storage:** SQLite (`sqflite`), Shared Preferences
- **Server Communication:** `http` (calling RESTful APIs to SmartStockWebAPI)
- **Prominent Libraries:**
  - `mobile_scanner`: Quick QR/Barcode scanning.
  - `google_sign_in`: Supports quick login with a Google account.
  - `image_picker`: Capture and select images (documents, products).
  - `connectivity_plus`: Check network status (online/offline).
  - `intl`: Date and currency formatting.

## Architecture and Folder Structure
The project is organized following the **Feature-First** standard, dividing code by business features, making it easy to manage and scale as the project grows.

- `android/`, `ios/`, `web/`, `windows/`: Configuration folders and Native source code for each compilation platform.
- `lib/`: The folder containing the entire Dart source code of the application:
  - `core/`: Contains core components, utils, general configurations, routing, or base API handling services.
  - `shared/`: Reusable UI components (Global Widgets, Custom Buttons, Dialogs, Themes, Constants).
  - `features/`: Contains the main modules/features of the application. Each feature may include screens, logic (providers), and models. Features in the system:
    - `auth`: User authentication (Login, Register, Forgot Password).
    - `dashboard`: Overall inventory metrics dashboard screen.
    - `home`: Main navigation home screen.
    - `inventory`: Tasks related to inventory and stock taking.
    - `products`: Product catalog and details management.
    - `picking` / `scanner`: Barcode scanning for picking and packing goods.
    - `profile`: User account information management.
    - `ai_assistant`: Integrated internal AI Q&A feature.
    - `notifications`: Display notifications.
    - `sync`: Logic supporting Offline - Online data synchronization.
  - `main.dart`: The entry point of the entire application.
  - `main_tab_screen.dart` / `navigation_menu_screen.dart`: Components managing the Bottom Navigation Bar.

## Setup Instructions
1. Ensure you have installed **Flutter SDK** and set up the Android Studio or VS Code environment.
2. Clone the repository to your local machine.
3. Open a terminal at the project root directory and install dependencies:
   ```bash
   flutter pub get
   ```
4. Ensure SmartStockWebAPI is running (locally) and update the IP endpoint in the app if running on an emulator or real device (Use LAN IP instead of `localhost`).
5. Launch an Emulator or connect a real mobile device (enable USB Debugging).
6. Run the application:
   ```bash
   flutter run
   ```
