# Track It - Flutter App

A Flutter application that allows users to log in (via Firebase) and link their Spotify account to track music statistics.

## Features

- **Firebase Authentication**: Email/Password, Google Sign-In, Apple Sign-In (configured)
- **Spotify OAuth PKCE**: Secure authentication flow for linking Spotify accounts
- **Firestore Integration**: Stores Spotify authorization codes linked to user IDs
- **Modern UI**: Dark theme with Spotify-inspired colors

## Project Structure

```
lib/
├── main.dart                 # App entry point
├── app.dart                  # Main app with routing
├── firebase_options.dart     # Firebase configuration
├── screens/
│   ├── login_screen.dart     # Login screen with multiple auth options
│   ├── home_screen.dart      # Home screen with user info and features
│   └── spotify_link_screen.dart # Spotify linking screen
├── services/
│   ├── auth_service.dart     # Firebase authentication service
│   └── spotify_service.dart  # Spotify OAuth PKCE service
└── widgets/
    ├── auth_button.dart       # Custom auth buttons
    ├── email_password_form.dart # Email/password form
    └── feature_card.dart      # Feature cards for home screen
```

## Setup Instructions

### 1. Flutter Setup

Make sure you have Flutter installed:
```bash
flutter doctor
```

### 2. Firebase Setup

#### Create a Firebase Project
1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Create a new project named "Track It"
3. Add Android and iOS apps

#### Android Configuration
1. In Firebase Console, add an Android app
2. Package name: `com.AntoineCFR.trackit`
3. Download `google-services.json` and place it in `android/app/`
4. Enable Email/Password, Google, and Apple authentication in Firebase Console

#### iOS Configuration
1. In Firebase Console, add an iOS app
2. Bundle ID: `com.AntoineCFR.trackit`
3. Download `GoogleService-Info.plist` and place it in `ios/Runner/`
4. Enable Email/Password, Google, and Apple authentication in Firebase Console

#### Update firebase_options.dart
Replace the placeholder values in `lib/firebase_options.dart` with your actual Firebase configuration:
```dart
static const FirebaseOptions android = FirebaseOptions(
  apiKey: 'YOUR_ANDROID_API_KEY',
  appId: 'YOUR_ANDROID_APP_ID',
  messagingSenderId: 'YOUR_MESSAGING_SENDER_ID',
  projectId: 'YOUR_PROJECT_ID',
  storageBucket: 'YOUR_STORAGE_BUCKET',
);

static const FirebaseOptions ios = FirebaseOptions(
  apiKey: 'YOUR_IOS_API_KEY',
  appId: 'YOUR_IOS_APP_ID',
  messagingSenderId: 'YOUR_MESSAGING_SENDER_ID',
  projectId: 'YOUR_PROJECT_ID',
  storageBucket: 'YOUR_STORAGE_BUCKET',
  iosBundleId: 'com.AntoineCFR.trackit',
);
```

Or run `flutterfire configure` to generate this file automatically.

### 3. Spotify Developer Setup

1. Go to [Spotify Developer Dashboard](https://developer.spotify.com/dashboard/)
2. Create a new app
3. App name: "Track It"
4. Redirect URIs: `com.AntoineCFR.trackit:/callback`
5. Copy the Client ID and update it in `lib/services/spotify_service.dart`:
```dart
class SpotifyConfig {
  static const String clientId = 'YOUR_SPOTIFY_CLIENT_ID';
  // ...
}
```

### 4. Firestore Setup

1. In Firebase Console, go to Firestore Database
2. Create a database in "test mode" (for development) or "locked mode" (for production)
3. The app will automatically create a `users` collection with documents containing:
   - `uid`
   - `email`
   - `displayName`
   - `photoURL`
   - `spotifyLinked` (boolean)
   - `spotifyCode` (string)
   - `spotifyCodeUpdatedAt` (timestamp)

### 5. Run the App

#### Android
```bash
flutter run -d android
```

#### iOS
```bash
cd ios
pod install
cd ..
flutter run -d ios
```

## How It Works

### Authentication Flow
1. User logs in via Email/Password, Google, or Apple
2. Firebase Authentication creates/verifies the user
3. A user document is created in Firestore (if it doesn't exist)

### Spotify Linking Flow (PKCE)
1. User clicks "Link Spotify" button
2. App generates a PKCE code verifier and challenge
3. User is redirected to Spotify's authorization page
4. Spotify redirects back to `com.AntoineCFR.trackit:/callback` with an authorization code
5. The authorization code is extracted and saved to Firestore with the user's UID
6. Your backend can then exchange this code for an access token

### Data Stored in Firestore
```json
{
  "users": {
    "USER_UID": {
      "uid": "USER_UID",
      "email": "user@example.com",
      "displayName": "User Name",
      "photoURL": "https://...",
      "createdAt": "2024-01-01T00:00:00Z",
      "spotifyLinked": true,
      "spotifyCode": "AUTHORIZATION_CODE_FROM_SPOTIFY",
      "spotifyCodeUpdatedAt": "2024-01-01T00:00:00Z"
    }
  }
}
```

## Dependencies

- `firebase_core`: Firebase initialization
- `firebase_auth`: Authentication
- `cloud_firestore`: Database
- `google_sign_in`: Google authentication
- `flutter_appauth`: OAuth PKCE flow
- `crypto`: PKCE code generation
- `go_router`: Navigation
- `provider`: State management
- `shared_preferences`: Local storage
- `url_launcher`: Open URLs
- `http`: HTTP requests

## Future Enhancements

- [ ] Add Apple Sign-In implementation
- [ ] Add email verification
- [ ] Add password reset
- [ ] Add user registration
- [ ] Add more Spotify scopes
- [ ] Implement token refresh
- [ ] Add error handling for network issues
- [ ] Add loading states
- [ ] Add animations
- [ ] Add unit tests

## License

MIT License

## Author

AntoineCFR
