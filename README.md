# Flutter Face ID Auth App

A secure Flutter application with email/password and facial recognition authentication, built using **Supabase** for backend services (authentication, database, and storage). This project demonstrates how to build a modern and secure mobile login system with an intuitive UI and advanced features like login history, password update, profile editing, and account deletion.

---

## 📱 Features

- Email and Password Sign-Up & Login
- Face ID Login using Face++ API
- Secure Photo Upload to Supabase Storage
- User Profile Editing (Name, Password, Profile Picture)
- Login History Viewer (Date, IP, Method)
- Account Deletion with Password Confirmation
- Shared Preferences for Remember Me
- Auth-based Redirection & Toast Notifications

---

## 📂 Project Structure

```
lib/
├── screens/
│   ├── login_screen.dart        # Login page with password & face recognition
│   ├── signup_screen.dart       # Registration page with image upload
│   ├── home_screen.dart         # Main screen with user info & history
│   ├── edit_profile_screen.dart # Profile editor (name, password, picture, delete)
│
├── services/
│   ├── auth_service.dart              # Sign in, sign up, reset, sign out
│   ├── face_recognition_service.dart  # Face++ API comparison logic
│
├── theme/
│   └── app_theme.dart          # Color schemes and text styles
│
├── widgets/
│   ├── custom_text_field.dart  # Styled reusable text input
│   └── gradient_button.dart    # UI gradient button
│
assets/
├── sounds/                     # Login success/failure sound effects
│
.env                          # Face++ API keys (secure your credentials!)
pubspec.yaml                  # Dependencies
```

---

## 🔐 Tech Stack

- **Flutter**: Frontend SDK
- **Supabase**:
  - Auth: Email/password login, session management
  - Database: User info & login logs
  - Storage: Profile pictures
- **Face++ API**: Facial recognition
- **Shared Preferences**: Save login credentials locally
- **Just Audio**: Feedback sound effects
- **Fluttertoast**: User feedback messages

---

## 🚀 Getting Started

### 1. Clone this Repository
```bash
git clone https://github.com/your-username/flutter-face-id-auth.git
cd flutter-face-id-auth
```

### 2. Configure Supabase
- Create a Supabase project.
- Add tables: `users`, `login_logs`.
- Enable email authentication.
- Create a `faces` bucket in Supabase Storage (public access).
- Copy your Supabase `url` and `anonKey`.

### 3. Setup Face++
- Sign up at [https://www.faceplusplus.com/](https://www.faceplusplus.com/).
- Create a project and get your `api_key` and `api_secret`.
- Add these to your `.env` file:

```env
FACEPP_API_KEY=your_api_key
FACEPP_API_SECRET=your_api_secret
```

### 4. Install Dependencies
```bash
flutter pub get
```

### 5. Run the App
```bash
flutter run
```

---

## 🛡 Security Notes

- Password changes and photo uploads require re-authentication.
- Session expiry is handled with a fallback to login screen.
- Never commit your `.env` or `supabase` credentials publicly.

---









