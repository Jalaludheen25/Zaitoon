# Zai Toon

Zai Toon Kids - where stories come alive.

## Overview

Zai Toon is a Flutter-based mobile application designed to provide an engaging storytelling experience for children. The app features multiple languages support, interactive story cards, and a user-friendly reading interface.

## Features

- 📚 Interactive Story Reading
- 🌍 Multiple Language Support
- 🎨 Child-friendly UI/UX
- 📱 Responsive Design
- 🔄 Version Control System
- ✨ Highlighted Story Cards

## Project Structure

lib/
├── constants/
│ ├── app_constants.dart
│ ├── theme.dart
│ ├── ui_styles.dart
│ └── textstyle_class.dart
├── screens/
│ ├── home_screen/
│ │ ├── components/
│ │ │ ├── story_card.dart
│ │ │ └── highlighted_cards.dart
│ │ └── provider/
│ │ └── home_provider.dart
│ ├── language_selection/
│ │ └── language_selection.dart
│ ├── reading_screen/
│ │ └── story_reader_page.dart
│ └── version_check/
│ └── provider/
│ └── version_check_provider.dart
├── main.dart
├── model/
│ └── story_model.dart
├── utils/
│ └── api_urls.dart
├── pubspec.yaml
└── README.md

### Prerequisites

- Flutter SDK
- Dart SDK
- Android Studio / VS Code
- iOS Simulator (for Mac users) / Android Emulator

### Installation

1. Clone the repository
2. Run `flutter pub get` to install dependencies
3. Run `flutter run` to start the application

## Development

The project uses:

- Provider pattern for state management
- Organized folder structure for better code management
- Constants for consistent theming and styling
- Version check system for app updates

## Contributing

1. Fork the repository
2. Create your feature branch
3. Commit your changes
4. Push to the branch
5. Create a Pull Request

## License

This project is proprietary software of Zai Toon Kids.
