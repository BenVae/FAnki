// deck_database.dart
import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

// Needed for generated code
part 'deck_database.g.dart';

// ------------------
// Drift Table Schema
// ------------------
class Decks extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get deckName => text().unique()();
}

class Flashcards extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get deckId => integer().references(Decks, #id)();
  TextColumn get question => text()();
  TextColumn get answer => text()();
}

// ------------------
// Drift Database
// ------------------
@DriftDatabase(tables: [Decks, Flashcards])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 1; // Bump when you change tables
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'deck_db.sqlite'));
    return NativeDatabase(file);
  });
}
