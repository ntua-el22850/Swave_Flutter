# Swave - Your Ultimate Nightlife Companion 🌊

Swave is a modern nightlife and events management application. It allows you to discover clubs, view upcoming events, make reservations, and manage your social nightlife profile!

## 📱 How to Get Started (Simple Guide)

If you want to use Swave on your Android phone, just follow these easy steps:

### 1. Download the App
*   Get the **APK file** (the app installer) from our [Releases page](https://github.com/ntua-el22850/Swave_Flutter/releases) or from the person who shared it with you.
*   The file is called `Swave-v1.0.apk`.

### 2. Install on Your Phone
*   Open the file on your Android phone.
*   Your phone might ask if you want to "Install from Unknown Sources"—just say **Yes** or **Allow**. This is normal for apps not downloaded from the Play Store.
*   Tap **Install** and wait a few seconds.

### 3. Open and Enjoy!
*   Look for the **Swave logo** (purple waves) on your home screen.
*   Tap it to start discovering clubs and events!

---

## 🛠 For Developers & Advanced Users

If you want to run the code itself or change the app, here is what you need:

### Quick Setup
1.  **Install Flutter**: Follow the guide at [flutter.dev](https://docs.flutter.dev/get-started/install).
2.  **Get the Code**: `git clone https://github.com/ntua-el22850/Swave_Flutter.git`
3.  **Install Dependencies**: Run `flutter pub get` to install all required libraries (GetX, MongoDB driver, etc.).
4.  **Setup Database**: 
    *   Create a `.env` file in the main folder.
    *   Add your database link like this: `MONGO_URI=your_mongodb_link_here`
5.  **Run it**: Type `flutter run` in your command line.

---

## 📋 Technical Specs
*   **Works on**: Android phones (Android 5.0 and newer).
*   **Requires**: Internet connection and Google Play Services (for maps).
*   **Made with**: Flutter, MongoDB, and GetX.

*   **Flutter SDK**: [Download and Install Flutter](https://docs.flutter.dev/get-started/install) (Version 3.10.4 or higher recommended)
*   **Dart SDK**: Included with Flutter.
*   **Minimum Android SDK**: 21 (Android 5.0 Lollipop)
*   **Target Android SDK**: 34 (Android 14)
*   **Google Play Services**: Required for Map features.
---

### External Services & Dependencies
*   **Backend**: MongoDB (via `mongo_dart`)
*   **State Management & Navigation**: [GetX](https://pub.dev/packages/get)
*   **Maps**: [Flutter Map](https://pub.dev/packages/flutter_map) & [OSM Plugin](https://pub.dev/packages/flutter_osm_plugin)
*   **Fonts**: [Google Fonts](https://pub.dev/packages/google_fonts)
*   **Environment**: [Flutter Dotenv](https://pub.dev/packages/flutter_dotenv)


## ❓ Having Trouble?
*   **App won't install?** Check if you have enough space on your phone or if "Unknown Sources" is enabled in settings.
*   **Maps not loading?** Make sure your internet is on and your phone is updated.
*   **App crashes at start?** This usually means the database link is missing or incorrect in the `.env` file (for developers).

---
**Enjoy the music! 🎶**
