# Firebase Setup Guide for My Teacher App

## Prerequisites
- Flutter SDK installed
- Android Studio / VS Code
- Google account
- Firebase CLI installed

## 1. Firebase Console Setup

### Create Firebase Project
1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Click "Create a project"
3. Enter project name: `my-teacher-app`
4. Enable Google Analytics (optional)
5. Click "Create project"

### Enable Authentication
1. In Firebase Console, go to **Authentication** > **Sign-in method**
2. Enable **Google** provider
3. Add your app's SHA-1 fingerprint (for Android)
4. Download `google-services.json` (Android) and `GoogleService-Info.plist` (iOS)

### Enable Firestore Database
1. Go to **Firestore Database**
2. Click "Create database"
3. Choose "Start in test mode" (configure security rules later)
4. Select your preferred location

## 2. Flutter Project Configuration

### Add Dependencies
Add to `pubspec.yaml`:
```yaml
dependencies:
  firebase_core: ^2.24.2
  firebase_auth: ^4.15.3
  cloud_firestore: ^4.13.6
  google_sign_in: ^6.1.6
  get: ^4.6.6
```

### Android Configuration

#### 1. Add google-services.json
- Place `google-services.json` in `android/app/`

#### 2. Update android/build.gradle
```gradle
buildscript {
    dependencies {
        classpath 'com.google.gms:google-services:4.4.0'
    }
}
```

#### 3. Update android/app/build.gradle
```gradle
apply plugin: 'com.google.gms.google-services'

android {
    compileSdkVersion 34
    
    defaultConfig {
        minSdkVersion 21
        targetSdkVersion 34
    }
}
```

#### 4. Get SHA-1 Fingerprint
```bash
cd android
./gradlew signingReport
```

### iOS Configuration

#### 1. Add GoogleService-Info.plist
- Place `GoogleService-Info.plist` in `ios/Runner/`
- Add to Xcode project

#### 2. Update ios/Runner/Info.plist
```xml
<key>CFBundleURLTypes</key>
<array>
    <dict>
        <key>CFBundleURLName</key>
        <string>REVERSED_CLIENT_ID</string>
        <key>CFBundleURLSchemes</key>
        <array>
            <string>YOUR_REVERSED_CLIENT_ID</string>
        </array>
    </dict>
</array>
```

## 3. Initialize Firebase

### Create firebase_options.dart
Run Firebase CLI:
```bash
firebase login
dart pub global activate flutterfire_cli
flutterfire configure
```

### Update main.dart
```dart
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(MyApp());
}
```

## 4. Security Rules

### Firestore Rules
```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Users can only access their own data
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
    
    // Chat messages - authenticated users only
    match /chats/{chatId} {
      allow read, write: if request.auth != null;
    }
  }
}
```

## 5. Environment Configuration

### Create .env file
```env
FIREBASE_PROJECT_ID=my-teacher-app
FIREBASE_API_KEY=your-api-key
GOOGLE_CLIENT_ID=your-google-client-id
```

### Add to .gitignore
```
# Firebase
firebase_options.dart
google-services.json
GoogleService-Info.plist
.env
```

## 6. Testing Setup

### Test Authentication
```dart
// Test in your app
final user = FirebaseAuth.instance.currentUser;
print('User: ${user?.email}');
```

### Test Firestore
```dart
// Test write
await FirebaseFirestore.instance
    .collection('test')
    .add({'message': 'Hello Firebase!'});
```

## 7. Production Checklist

- [ ] Update Firestore security rules
- [ ] Enable App Check
- [ ] Configure authentication domains
- [ ] Set up Firebase Analytics
- [ ] Configure crash reporting
- [ ] Test on physical devices
- [ ] Update SHA-1 for release keystore

## 8. Common Issues

### Android Build Errors
- Ensure `minSdkVersion 21` or higher
- Check `google-services.json` placement
- Verify SHA-1 fingerprint in Firebase Console

### iOS Build Errors
- Verify `GoogleService-Info.plist` in Xcode
- Check URL schemes in Info.plist
- Ensure iOS deployment target 11.0+

### Authentication Issues
- Verify SHA-1 fingerprint
- Check Google Sign-In configuration
- Ensure proper URL schemes

## 9. Useful Commands

```bash
# Clean and rebuild
flutter clean && flutter pub get

# Check Firebase connection
flutterfire configure

# Generate SHA-1
keytool -list -v -keystore ~/.android/debug.keystore -alias androiddebugkey

# Firebase deploy rules
firebase deploy --only firestore:rules
```

## Support
- [Firebase Documentation](https://firebase.google.com/docs)
- [FlutterFire Documentation](https://firebase.flutter.dev/)
- [Firebase Console](https://console.firebase.google.com/)