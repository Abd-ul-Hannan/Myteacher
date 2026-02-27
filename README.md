# 🎓 MyTeacher — AI-Powered Learning Assistant

A smart **Flutter (iOS & Android)** app that acts as your personal AI teacher. Ask any question by typing it or simply snap a photo of it — and get an instant, intelligent answer powered by AI.

---

## 📱 App Overview

MyTeacher makes learning effortless. Whether you're stuck on a math problem, a science question, or anything from your textbook, you can either type your question or point your camera at it — and MyTeacher's AI will explain the answer clearly. All conversations are saved to your account so you can revisit them anytime.

---

## ✨ Features

### 🤖 AI Chat
- Type any question and get an instant AI-generated answer
- Conversational interface — ask follow-up questions naturally
- Full chat history saved and synced to your account
- Clear, easy-to-read responses formatted for learning

### 📷 Camera Question Capture
- Point your camera at any question — from a textbook, worksheet, or whiteboard
- The app captures and processes the image
- AI reads and answers the question from the photo
- No need to retype long questions manually

### 🔐 Authentication
- Sign up and log in with Firebase Auth
- Your chat history and data are tied to your personal account
- Secure and private per user

### 💾 Data & Storage
- All conversations stored in Firestore
- Captured images stored in Firebase Storage
- Access your history anytime, even after reinstalling the app

### 🎨 UI & UX
- Clean, student-friendly interface
- iOS & Android native experience
- Smooth and responsive design

---

## 🛠️ Tech Stack

| Technology | Purpose |
|---|---|
| Flutter | Cross-platform UI (iOS & Android) |
| Dart | Programming language |
| Firebase Auth | User authentication |
| Cloud Firestore | Chat history & data storage |
| Firebase Storage | Storing captured question images |
| AI API | Generating answers to user questions |
| Camera / Image Picker | Capturing question photos |

---

## 📁 Project Structure

```
lib/
├── screens/
│   ├── auth/
│   │   ├── login_screen.dart         # User login
│   │   └── signup_screen.dart        # User registration
│   ├── chat/
│   │   ├── chat_screen.dart          # Main AI chat interface
│   │   └── chat_history_screen.dart  # Past conversations
│   └── camera/
│       └── camera_capture_screen.dart # Capture question from camera
├── services/
│   ├── auth_service.dart             # Firebase Auth logic
│   ├── firestore_service.dart        # Chat history CRUD
│   ├── storage_service.dart          # Image upload to Firebase
│   └── ai_service.dart              # AI API integration
├── models/
│   ├── user_model.dart
│   └── message_model.dart
├── widgets/                          # Reusable UI components
└── main.dart
```

---

## 🚀 Getting Started

### Prerequisites

- [Flutter SDK](https://docs.flutter.dev/get-started/install) ≥ 3.0.0
- Android Studio (for Android) or Xcode (for iOS)
- A [Firebase](https://firebase.google.com) project
- An AI API key (e.g. OpenAI / Gemini)

### 1. Clone the Repository

```bash
git clone https://github.com/Abd-ul-Hannan/Myteacher.git
cd Myteacher
```

### 2. Install Dependencies

```bash
flutter pub get
```

### 3. Set Up Firebase

1. Go to [Firebase Console](https://console.firebase.google.com) and create a new project
2. Enable **Authentication** → Email/Password sign-in
3. Create a **Firestore** database
4. Enable **Firebase Storage**
5. Download and place the config files:
   - `google-services.json` → `android/app/`
   - `GoogleService-Info.plist` → `ios/Runner/`

For detailed Firebase setup, refer to the included [`FIREBASE_COMPLETE_SETUP.md`](FIREBASE_COMPLETE_SETUP.md) in the repo.

### 4. Configure AI API Key

Add your AI API key to your environment or constants file:

```dart
// lib/services/ai_service.dart
const String aiApiKey = 'YOUR_AI_API_KEY';
```

### 5. Run the App

```bash
# Android
flutter run -d android

# iOS
flutter run -d ios
```

---

## 📖 How to Use

### Ask a Question by Typing
1. Open the app and log in or sign up
2. On the chat screen, type your question in the text field
3. Tap **Send** — the AI will reply instantly
4. Continue the conversation with follow-up questions

### Ask a Question from Camera
1. Tap the **Camera** icon in the chat screen
2. Point your camera at the question (textbook, worksheet, etc.)
3. Capture the image
4. The app sends the image to the AI and returns the answer

### View Chat History
1. Navigate to the **History** section
2. Browse and reopen any previous conversation
3. Continue from where you left off

---

## 🔐 Permissions Required

| Permission | Reason |
|---|---|
| Internet | Communicating with AI & Firebase |
| Camera | Capturing question photos |
| Photo Library (iOS) | Selecting images from gallery |

All permissions are requested automatically when needed.

---

## 📋 Requirements

- Flutter SDK: `>=3.0.0 <4.0.0`
- iOS: 12.0 or higher
- Android: API level 21 (Android 5.0) or higher

---

## 🚀 Planned Features

- Voice input for questions
- Multi-language support
- Subject-specific AI modes (Math, Science, English, etc.)
- Offline answer caching
- Share answers as images

---

## 📄 License

This project is open source. See the [LICENSE](LICENSE) file for details.

---

## 👤 Author

**Abd-ul-Hannan**  
GitHub: [@Abd-ul-Hannan](https://github.com/Abd-ul-Hannan)

---

> Built with ❤️ using Flutter & Firebase
