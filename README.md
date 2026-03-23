# 🧠 MindCare

MindCare is a Flutter-based mobile application designed to help users track their daily moods, reflect on emotional well-being, and receive gentle reminders for self-care.

---

## ✨ Features

* 📅 Mood Tracking Calendar (Monthly View)
* 📝 Daily Mood Diary
* 🔔 Smart Mood Notifications
* 📊 Mood Statistics (Average & Healthy %)
* 👤 User Profile & Email Verification
* 🔐 Firebase Authentication (Login/Register)
* 🛠️ Admin / User Role Support

---

## 🛠️ Tech Stack

* Flutter (Material 3)
* Firebase Authentication
* Cloud Firestore
* Local Notifications

---

## 🚀 Getting Started

### 🔧 Installation & Setup

#### 1️⃣ Clone Repository

```bash
git clone https://github.com/arnarock/mindcare.git
cd mindcare
```

#### 2️⃣ Install Dependencies

```bash
flutter pub get
```

#### 3️⃣ Generate Assets (Icons & Splash Screen)

```bash
dart run flutter_launcher_icons
dart run flutter_native_splash:create
```

#### ▶️ Run Application

```bash
flutter run
```

---

## 🔄 After Pulling Updates

```bash
flutter pub get
flutter run
```

If build errors occur:

```bash
flutter clean
flutter pub get
flutter run
```

---

## 📄 Documentation (Dart Doc)

### Generate API Docs

```bash
dart doc
```

### View Locally

```bash
dart pub global activate dhttpd
dhttpd --path doc/api
```

Then open in browser:

```
http://localhost:8080
```

---

## 🔐 Firebase Configuration

⚠️ This project is connected to a specific Firebase project.

If you want to use your own:

1. Create a new Firebase project
2. Replace:

   * `google-services.json` (Android)
   * `GoogleService-Info.plist` (iOS)
3. Update Firebase config if needed

---

## 📁 Project Structure

```
lib/
 ┣ core/
 ┃ ┣ layout/
 ┃ ┣ services/
 ┃ ┗ constants/
 ┣ features/
 ┃ ┣ auth/
 ┃ ┣ home/
 ┃ ┣ mood/
 ┃ ┣ profile/
 ┃ ┗ admin/
 ┗ main.dart
```

---

## 📌 Notes

* Make sure notifications permission is granted on Android
* Requires internet connection for Firebase features
* Works best on Android devices

---

## 👨‍💻 Author

**Anajak Chuamuangphan (zoozoo)**
Mobile App Development

---

## ⭐ If you like this project

Give it a star on GitHub ⭐
