# MediFinder - Flutter Android App with Google Maps API and Firebase Integration

MediFinder is a Flutter-based Android application that integrates **Google Maps API** for location-based services and uses **Firebase** for backend services like Firestore, Firebase Storage, and Firebase Cloud Messaging to help customers find their medications easily from nearby pharmacies.

## 1. Prerequisites

### System Requirements

- **Operating System**: Windows, macOS, or Linux
- **Flutter SDK**: Version 3.19.5 or higher
- **Android Studio**: Latest stable version
- **Java Development Kit (JDK)**: Version 17 or higher
- **Google Cloud Console Account**: Required for enabling and managing the Google Maps API

### Tools and Software

- **Git**: Version control system for cloning the repository.
- **Firebase Project**: Set up a Firebase project with Firestore, Firebase Storage, and Firebase Cloud Messaging enabled.

## 2. Setup Instructions

1. **Clone the Repository**
   Clone the project repository using Git:
   ```bash
   git clone https://github.com/ashangunatilake/medifinder.git
   cd medifinder 
2. **Check Flutter Installation**
   ```bash
   flutter doctor
   
3. **Install Dependencies**
   ```bash
   flutter pub get

## 3. Firebase Configuration

1. Create a new project by going to the Firebase console 
(https://console.firebase.google.com/u/0/). 
2. Add android app to the project and continue with the project setup steos. 
3. Download the “google-service,json” file and store it in the /android/app/ directory. 
4. Add Google Services class path to dependencies in android/build.gradle file. 
5. Add “id ‘com.google.gms.google-services’” to plugins in android/app/build,gradle file.

## 4. Google Maps API configuration 

1. Go to Google Cloud Console and create a new project 
(https://console.cloud.google.com) 
2. Generate API key which include Maps SDK for android, Places API, Geocoding API 
and Directions API. 
3. Add the following line inside <application> tag to the /android/app/src/main/AndroidManifest.xml
```bash
<meta-data android:name="com.google.android.geo.API_KEY" android:value=generated API KEY />
```
## 5. Running the Project
1. An android device or an emulator should be connected with the Android studio. 
2. To run the application “flutter run” can be entered in the console or the run button in 
the android studio can be pressed.
```bash
flutter run
```
4. To generate the release APK, “flutter build apk --release” or Android studio Build tab 
can be used.
```bash
flutter build apk --release
```
