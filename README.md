# Weena

<!-- Badges -->
[![Dart](https://img.shields.io/badge/Dart-2.19-blue.svg?style=flat-square)]()
[![Flutter](https://img.shields.io/badge/Flutter-3.0-blueviolet.svg?style=flat-square)]()

<!-- Description -->
Weena is a Flutter-based mobile application designed to provide a vast collection of global movies, series, and animations all in one place. This project aims to deliver a seamless entertainment experience directly to your mobile device. 📱

<!-- Table of Contents -->
## Table of Contents
- [Description](#description)
- [Features](#features)
- [Tech Stack](#tech-stack)
- [Installation](#installation)
- [Usage](#usage)
- [Project Structure](#project-structure)
- [Contributing](#contributing)
- [License](#license)
- [Important Links](#important-links)
- [Footer](#footer)

<!-- Features -->
## Features
- **Extensive Content Library**: Access a wide range of movies, TV series, and animations from around the world. 🎬
- **User Authentication**: Utilizes Firebase Auth for user sign-up and sign-in functionality. 🔑
- **Profile Management**: Allows users to edit their profile information, including name, about, and profile picture. 👤
- **Social Features**: Includes activities, chats, and following/followers features. 💬
- **Content Discovery**: Features an explorer page, recommended posts, and following posts to help users find content they love. 🔍
- **Video Playback**: Integrated video player with functionalities like play, pause, and full-screen mode. ▶️
- **Personalization**: Users can create feeds, upload content, and manage their history. ➕
- **Settings**: Offers settings screen for managing blocked users, editing links, and more. ⚙️

<!-- Tech Stack -->
## Tech Stack
- **Dart**: Primary programming language.
- **Flutter**: UI framework for building cross-platform applications.
- **Firebase**: Backend services for authentication, database, and storage.
  - Firebase Auth
  - Cloud Firestore
  - Firebase Storage
- **Swift & Kotlin**: Native code for iOS and Android implementations respectively.
- **HTML**: For web implementation.
- **JSON**: Used for animations and configurations.
- **YAML**: Used for analysis options and dependency management (pubspec.yaml).

<!-- Installation -->
## Installation

To get started with Weena, follow these steps:

1. **Clone the Repository**: 
   ```bash
   git clone https://github.com/shram0077/Weena.git
   cd Weena
   ```

2. **Install Flutter**: 
   Ensure you have Flutter installed on your machine. If not, follow the official Flutter installation guide: [https://docs.flutter.dev/get-started/install](https://docs.flutter.dev/get-started/install)

3. **Set up Firebase**: 
   - Create a Firebase project on the Firebase Console ([https://console.firebase.google.com/](https://console.firebase.google.com/)).
   - Download the `google-services.json` (for Android) and `GoogleService-Info.plist` (for iOS) and place them in the appropriate directories:
     - Android: `weena_latest/android/app/google-services.json`
     - iOS: Use Xcode to add `GoogleService-Info.plist` to `weena_latest/ios/Runner`
   - Configure Firebase in your Flutter project by initializing it in your `main.dart` file.

4. **Install Dependencies**: 
   Run the following command to install the required Dart packages:
   ```bash
   flutter pub get
   ```

5. **Run the Application**: 
   Connect a device or start an emulator and run the app:
   ```bash
   flutter run
   ```

<!-- Usage -->
## Usage

1. **Sign Up/Sign In**: 🔑
   - New users can sign up using their email, username, and password on the `SignUp.dart` screen.
   - Existing users can sign in using their credentials on the `SignIn.dart` screen.

2. **Explore Content**: 🔍
   - Use the bottom navigation bar (`bottomNAV.dart`) to navigate between different sections of the app.
   - Browse movies, series, and animations on the home screen (`Dashbord.dart`).
   - Use the explorer page (`explorer.dart`) to discover new content.

3. **Watch Videos**: ▶️
   - Select a movie or series to view its details on the `movie_page.dart` screen.
   - Play trailers and episodes using the integrated video player (`Video_Player/VideoPlayer.dart`).

4. **Engage with Community**: 💬
   - Use the activities screen (`activites.dart`) to see recent activities and interactions.
   - Chat with other users using the chats screen (`ChatsScreen.dart`).
   - Follow and interact with other users on their profiles (`profile.dart`).

5. **Customize Your Profile**: 👤
   - Edit your profile information, including name, about, and profile picture, on the `EditeProfile.dart` screen.
   - Manage your settings, including blocked users and linked accounts, on the `Settings.dart` screen.

## How to use 

- To use Weena, first clone the repository and set up Firebase as mentioned above.
- You can navigate the app using the bottom navigation bar and explore the features as described in the Usage section. 
- You can customize your profile, upload content, and engage with the community features.

<!-- Project Structure -->
## Project Structure

The project structure is organized as follows:

```
weena_latest/
├── android/          # Android-specific files
├── ios/              # iOS-specific files
├── lib/              # Dart source code
│   ├── APi/            # API related files
│   ├── Constant/       # Constant values
│   ├── Models/         # Data models
│   ├── Screens/        # UI screens
│   ├── Services/       # Backend services
│   ├── Widgets/        # Reusable widgets
│   ├── encryption_decryption/ # Encryption functionalities
│   ├── firebase_options.dart # Firebase configuration
│   ├── main.dart       # Entry point of the application
├── linux/            # Linux-specific files
├── macos/            # MacOS-specific files
├── web/              # Web-specific files
├── windows/          # Windows-specific files
├── .gitignore        # Specifies intentionally untracked files that Git should ignore
├── analysis_options.yaml # Configures the analyzer for the Dart language
├── firebase.json     # Firebase configuration file
├── pubspec.lock      # Auto-generated file listing the exact versions of all packages in your application
└── pubspec.yaml      # Contains metadata about the project and declares dependencies
```

<!-- Contributing -->
## Contributing

Contributions are welcome! Please follow these steps:

1. Fork the repository.
2. Create a new branch.
3. Make your changes.
4. Submit a pull request.

<!-- License -->
## License

No license provided.

<!-- Important Links -->
## Important Links
- **Repository**: [https://github.com/shram0077/Weena](https://github.com/shram0077/Weena)

<!-- Footer -->
## Footer

- **Project**: Weena
- **Repository URL**: [https://github.com/shram0077/Weena](https://github.com/shram0077/Weena)
- **Author**: shram0077

👍 If you find this project helpful, please give it a star! ⭐ Feel free to fork it and submit issues or pull requests. Your contributions are highly appreciated! 🚀


---
**<p align="center">Generated by [ReadmeCodeGen](https://www.readmecodegen.com/)</p>**
