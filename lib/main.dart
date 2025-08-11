import 'package:kartei/src/env.dart';
import 'package:kartei/src/navigation/view/app.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:logging/logging.dart';
import 'package:authentication_repository/authentication_repository.dart';
import 'package:card_repository/card_deck_manager.dart';

// Removed unused _rootLogger

void initializeLogger() {
  Logger.root.level = kDebugMode ? Level.ALL : Level.WARNING;
  Logger.root.onRecord.listen((record) {
    if (kDebugMode) {
      final time = record.time.toString().substring(11, 19);
      final level = record.level.name.padRight(7);
      final name = record.loggerName;
      print('$time [$level] $name: ${record.message}');
      if (record.error != null) print('  Error: ${record.error}');
    }
  });
}

/// Get a logger instance for a specific component
Logger getLogger(String name) => Logger(name);

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize logging
  initializeLogger();

  // Validate environment variables
  Env.validateEnvironment();

  await Firebase.initializeApp();

  final authenticationRepository = AuthenticationRepository();
  await authenticationRepository.user.first;

  final cardDeckManager = CardDeckManager();
  final deckTreeManager = DeckTreeManager();

  runApp(
    KarteiApp(
      authenticationRepository: authenticationRepository,
      cardDeckManager: cardDeckManager,
      deckTreeManager: deckTreeManager,
    ),
  );
}
