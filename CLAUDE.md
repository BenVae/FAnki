# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

FAnki is a Flutter-based Anki clone application that implements a flashcard learning system with Firebase backend integration. The app follows a BLoC (Business Logic Component) architecture pattern for state management and uses Firebase for authentication and data persistence.

## Future Development: AI-Powered Card Generation

The project is planned to be extended with AI capabilities to automatically generate Anki cards from PDF documents:

### Planned Features
- **PDF Processing**: Upload and transcribe PDF documents (e.g., lecture notes)
- **AI Card Generation**: Automatically split content into bite-sized flashcard information
- **Smart Deck Management**: AI-suggested deck names and automatic card organization
- **AI Service Architecture**: Dedicated service layer for AI operations

### Implementation Guidelines for AI Features
- Create a new AI service layer following existing package structure
- Implement Flutter Hooks to replace StatefulWidget patterns (gradual migration)
- Maintain consistency with existing BLoC architecture
- AI tasks to implement:
  - PDF transcription service
  - Card content generation with appropriate formatting
  - Deck name suggestion system

## Plan development
- focus on ui first, then add add functionality

## Technology Stack

- **Flutter**: 3.29.2 (Dart 3.7.2)
- **State Management**: flutter_bloc (BLoC pattern)
- **Backend**: Firebase (Authentication, Firestore)
- **Package Structure**: Modular with local packages for authentication and card management
- **Future**: Flutter Hooks for state management migration

## Architecture

### Package Structure
- **`lib/src/`**: Main application code organized by feature
  - Each feature has its own directory with `cubit/` and `view/` subdirectories
  - Features: `learning`, `create_cards`, `manage_decks`, `login`, `navigation`
- **`packages/`**: Local packages for core functionality
  - `authentication_repository`: Handles Firebase Auth and user management
  - `card_repository`: Manages flashcard data and deck operations

### State Management Pattern
- Uses BLoC/Cubit pattern consistently across all features
- Each feature has its own Cubit managing local state
- Global providers initialized in `FAnkiApp` widget in `lib/src/navigation/view/app.dart`

### Navigation
- Platform-adaptive navigation (TabBar for mobile, NavigationRail for desktop)
- Managed by `NavigationCubit` with centralized state handling

## Key Commands

### Development
```bash
# Install dependencies
flutter pub get

# Run the application
flutter run

# Run on specific platform
flutter run -d chrome  # Web
flutter run -d macos   # macOS
flutter run -d ios     # iOS simulator

# Analyze code for issues
flutter analyze

# Format code
dart format .
```

### Testing
```bash
# Run all tests
flutter test

# Run tests for specific package
cd packages/authentication_repository && flutter test
cd packages/card_repository && flutter test
```

### Build
```bash
# Build for production
flutter build apk      # Android APK
flutter build ios      # iOS (requires macOS)
flutter build web      # Web
flutter build macos    # macOS desktop
```

## Firebase Configuration

The project uses Firebase with configuration files already in place:
- iOS: `ios/Runner/GoogleService-Info.plist`
- macOS: `macos/Runner/GoogleService-Info.plist`
- General: `lib/firebase_options.dart`

## Development Guidelines

### Adding New Features
1. Create feature directory under `lib/src/` with `cubit/` and `view/` subdirectories
2. Implement Cubit for state management following existing patterns
3. Add BlocProvider in `FAnkiApp` widget
4. Update navigation handling if adding new screens

### Working with Packages
- Authentication logic goes in `packages/authentication_repository`
- Card/deck operations go in `packages/card_repository`
- Each package has its own tests and should be tested independently

### Code Conventions
- Follow existing BLoC/Cubit patterns for state management
- Use StreamBuilder for Firebase real-time data
- Platform-specific UI adaptations in `app.dart`
- Logger instance available via `log` in main.dart
- When adding AI features, maintain the same structural patterns

## Common Tasks

### Adding a new screen
1. Create feature folder with cubit and view subdirectories
2. Implement the Cubit extending `Cubit<StateClass>`
3. Create Page and View widgets following existing patterns
4. Add BlocProvider in `FAnkiApp`
5. Update navigation in `NavigationCubit` and `app.dart`

### Modifying Firebase operations
- Authentication: Update `packages/authentication_repository/lib/src/authentication_repository.dart`
- Card operations: Update `packages/card_repository/lib/src/firebase_api.dart`

### Running with Firebase emulator
The project includes `firebase.json` configuration. To use Firebase emulator:
```bash
firebase emulators:start
```

### Adding AI Service (Future)
When implementing AI features:
1. Create new package `packages/ai_service` following existing package structure
2. Implement services for PDF processing and card generation
3. Consider using Flutter Hooks for new UI components
4. Integrate with existing card_repository for storing generated cards
5. Add appropriate error handling and loading states following existing patterns