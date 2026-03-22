# Organic Food Directory

A Flutter web application for discovering and managing organic foods, favorites, and personalized shopping lists.

## Features

- **User Authentication**
  - Email/password registration and login
  - Google Sign-In integration
  - Email verification
  - Password management

- **Food Discovery**
  - Browse organic foods by category
  - Search functionality
  - Detailed product information

- **Favorites Management**
  - Add/remove favorite items
  - Quick access to favorite foods

- **Shopping Lists**
  - Create and manage multiple lists
  - Add/remove items from lists
  - Share lists with others

- **User Profile**
  - Manage profile information
  - Upload profile pictures via Cloudinary
  - View account settings

## Tech Stack

- **Framework**: Flutter (Web)
- **Backend**: Firebase (Auth, Firestore, Storage)
- **Image Hosting**: Cloudinary
- **State Management**: BLoC (flutter_bloc)
- **Database**: Firestore

## Prerequisites

- Flutter SDK (latest)
- Dart SDK
- Firebase account
- Cloudinary account
- Chrome browser (for web development)

## Installation

### 1. Clone the Repository

```bash
git clone https://github.com/yourusername/organic-food-directory.git
cd organic-food-directory
```

### 2. Install Dependencies

```bash
flutter pub get
```

### 3. Configure Firebase

#### For Web:
1. Create a Firebase project at [Firebase Console](https://console.firebase.google.com)
2. Add a Web app to your project
3. Download the configuration file
4. Update `lib/firebase_options.dart` with your configuration

#### For Android:
1. Download the `google-services.json` from Firebase Console
2. Place it in `android/app/`

#### For iOS:
1. Download the `GoogleService-Info.plist` from Firebase Console
2. Place it in `ios/Runner/`

### 4. Configure Cloudinary

1. Create a Cloudinary account at [cloudinary.com](https://cloudinary.com)
2. Create an unsigned upload preset in your Cloudinary dashboard
3. Update the Cloudinary configuration in `lib/services/cloudinary_service.dart`:

```dart
static const String _cloudName = 'YOUR_CLOUD_NAME';
static const String _uploadPreset = 'YOUR_UPLOAD_PRESET';
```

### 5. Configure Google Sign-In

1. Enable Google Sign-In in Firebase Console
2. Update the Web OAuth 2.0 Client ID in `lib/repositories/user_repository.dart`:

```dart
clientId: 'YOUR_WEB_CLIENT_ID.googleusercontent.com'
```

## Running the App

### Web (Chrome)
```bash
flutter run -d chrome
```

### Android
```bash
flutter run -d android
```

### iOS
```bash
flutter run -d ios
```

## Project Structure

```
lib/
├── bloc/                 # State management (BLoC pattern)
│   ├── auth/            # Authentication logic
│   ├── favorites/       # Favorites management
│   ├── lists/          # Shopping lists
│   ├── product/        # Product data
│   └── profile/        # User profile
├── models/             # Data models
├── repositories/       # Data layer (Firebase, APIs)
├── screens/            # UI screens
├── services/           # Business logic services
│   └── cloudinary_service.dart  # Image upload
├── utils/              # Utility functions
├── widgets/            # Reusable widgets
├── main.dart          # App entry point
└── firebase_options.dart # Firebase configuration
```

## Development

### Code Style
- Follow Dart style guide (in `analysis_options.yaml`)
- Use meaningful variable and function names
- Add comments for complex logic

### Running Tests
```bash
flutter test
```

### Building for Production

#### Web
```bash
flutter build web --release
```

#### Android
```bash
flutter build apk --release
```

#### iOS
```bash
flutter build ios --release
```

## Troubleshooting

### Google Sign-In Issues
- Ensure OAuth2 Client ID is correctly configured
- Check that your domain is authorized in Firebase Console
- For web, ensure localhost:5000 is whitelisted during development

### Firebase Connection Issues
- Verify firebase_options.dart contains correct project ID
- Check Firestore security rules allow read/write for authenticated users
- Ensure Internet connection is available

### Cloudinary Upload Failures
- Verify upload preset exists and is configured as unsigned
- Check Cloudinary credentials are correct
- Ensure image file size is within limits

## Contributing

1. Fork the repository
2. Create a feature branch: `git checkout -b feature/your-feature`
3. Commit changes: `git commit -m 'Add your feature'`
4. Push to branch: `git push origin feature/your-feature`
5. Submit a Pull Request

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Support

For issues, questions, or suggestions, please open an issue on GitHub.

## Authors

- Tapiwanashe (👨‍💻)

## Acknowledgments

- Flutter community for excellent documentation
- Firebase for backend services
- Cloudinary for image hosting
