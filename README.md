# kartei

**Kartei** (pronounced "kar-TIE") is derived from the German word "Karteikarten," which literally translates to "index cards" or "file cards." In German, "Kartei" refers to a card index system - a traditional method of organizing information on individual cards that can be sorted, searched, and reviewed. "Karten" means "cards," making "Karteikarten" the perfect linguistic foundation for a flashcard application.

This Flutter-based app brings the timeless concept of Karteikarten into the digital age, offering a modern Anki-like flashcard experience for effective learning and memorization.

## Features

- **Create Flashcards:** Users can create flashcards, adding both a question and an answer.
- **Manage Decks:** Users can create and organize flashcards into specific decks.
- **Firebase Integration:** Utilizes Firebase for backend data storage, ensuring that flashcards and decks are saved and can be retrieved across sessions.

## Getting Started

To get a local copy up and running follow these simple steps.

### Prerequisites

- Flutter installed on your machine
- Firebase cli installed

### Installation

1. **Install dependencies:**

```bash
flutter pub get
```

2. **Setup env**

```bash
cp .env.example .env
```

then add your openAi api key.

1. **Setup Firebase:**

Create a Firebase project at Firebase Console
Add your Android/iOS app to your Firebase project
Download the google-services.json or GoogleService-Info.plist and place it in the appropriate directory (android/app or ios/Runner)

```bash
flutterfire configure
```

3. **Run the app:**

```bash
flutter run
```




