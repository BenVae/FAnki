// deck_repository.dart
import 'dart:async';
import 'package:drift/drift.dart';
import 'deck_database.dart'; // The Drift db + tables
import 'data_models/deck_model.dart'; // DeckModel
import 'data_models/flash_card_model.dart'; // FlashCardModel

enum EditCard { init, editing, notEditing }

class DeckRepository {
  final AppDatabase _db;

  DeckModel? _currentDeck;
  FlashCardModel? _currentCard;

  final _deckController = StreamController<DeckModel?>.broadcast();
  Stream<DeckModel?> get currentDeckStream async* {
    // By yielding null first, you match the original behavior
    yield null;
    yield* _deckController.stream;
  }

  DeckRepository._create(this._db);

  // -------------
  //   INIT
  // -------------
  static Future<DeckRepository> init() async {
    final db = AppDatabase();
    return DeckRepository._create(db);
  }

  // -------------
  //   DECKS
  // -------------

  Future<List<String>> getDeckNames() async {
    final allDeckRows = await _db.select(_db.decks).get();
    return allDeckRows.map((row) => row.deckName).toList();
  }

  Future<void> createDeck(String deckName) async {
    await _db.into(_db.decks).insert(
          DecksCompanion.insert(deckName: deckName),
        );
  }

  Future<void> deleteCurrentDeck() async {
    if (_currentDeck == null) {
      throw Exception('Delete current deck error, because no deck is selected.');
    }
    await (_db.delete(_db.decks)..where((tbl) => tbl.id.equals(_currentDeck!.id))).go();

    // Clear our in-memory state
    _currentDeck = null;
    _currentCard = null;
    _deckController.add(null);
  }

  Future<bool> isDeckNameUsed(String deckName) async {
    final existing = await (_db.select(_db.decks)..where((tbl) => tbl.deckName.equals(deckName))).getSingleOrNull();
    return existing != null;
  }

  Future<void> setCurrentDeckByName(String deckName) async {
    final foundDeck = await (_db.select(_db.decks)..where((tbl) => tbl.deckName.equals(deckName))).getSingleOrNull();

    if (foundDeck == null) {
      throw Exception('Deck "$deckName" does not exist.');
    }

    // Fetch all flashcards for that deck
    final flashcardRows = await (_db.select(_db.flashcards)..where((tbl) => tbl.deckId.equals(foundDeck.id))).get();

    _currentDeck = DeckModel(
      id: foundDeck.id,
      deckName: foundDeck.deckName,
      flashCards: flashcardRows
          .map((fc) => FlashCardModel(
                id: fc.id,
                question: fc.question,
                answer: fc.answer,
              ))
          .toList(),
    );

    _deckController.add(_currentDeck);
  }

  String getCurrentDeckName() {
    if (_currentDeck == null) {
      throw Exception('No deck selected.');
    }
    return _currentDeck!.deckName;
  }

  DeckModel getCurrentDeck() {
    if (_currentDeck == null) {
      throw Exception('No deck selected.');
    }
    return _currentDeck!;
  }

  Future<void> renameDeck({
    required String newDeckName,
  }) async {
    if (_currentDeck == null) {
      throw Exception('No current deck to rename.');
    }

    // Check if new name is taken
    final existingDeck =
        await (_db.select(_db.decks)..where((tbl) => tbl.deckName.equals(newDeckName))).getSingleOrNull();
    if (existingDeck != null) {
      throw Exception('Deck name "$newDeckName" is already in use.');
    }

    // Update deck name in DB
    await (_db.update(_db.decks)..where((tbl) => tbl.id.equals(_currentDeck!.id)))
        .write(DecksCompanion(deckName: Value(newDeckName)));

    // Update in-memory model
    _currentDeck!.deckName = newDeckName;
    _deckController.add(_currentDeck);
  }

  // -------------
  //   FLASHCARDS
  // -------------

  void setCurrentFlashCard({required int cardId}) {
    if (_currentDeck == null) {
      throw Exception('No deck selected.');
    }
    final foundCard = _currentDeck!.flashCards.firstWhere(
      (c) => c.id == cardId,
      orElse: () => throw Exception('FlashCard with id=$cardId not found.'),
    );
    _currentCard = foundCard;
  }

  FlashCardModel? getCurrentFlashCard() => _currentCard;

  Future<bool> addFlashCard({
    required String question,
    required String answer,
  }) async {
    if (_currentDeck == null) {
      throw Exception('No deck selected.');
    }

    // Insert new flashcard into DB
    await _db.into(_db.flashcards).insert(
          FlashcardsCompanion.insert(
            deckId: _currentDeck!.id,
            question: question,
            answer: answer,
          ),
        );

    // Refresh current deck from DB
    await _reloadCurrentDeck();
    return true;
  }

  Future<bool> updateFlashCard({
    required int cardId,
    required String question,
    required String answer,
  }) async {
    if (_currentDeck == null) {
      throw Exception('No deck selected.');
    }

    // Check existence in local model (not strictly required, but consistent with old code)
    final index = _currentDeck!.flashCards.indexWhere((fc) => fc.id == cardId);
    if (index == -1) {
      throw Exception('Flashcard with id $cardId not found.');
    }

    // Update in DB
    await (_db.update(_db.flashcards)..where((tbl) => tbl.id.equals(cardId))).write(
      FlashcardsCompanion(
        question: Value(question),
        answer: Value(answer),
      ),
    );

    // Refresh current deck
    await _reloadCurrentDeck();
    return true;
  }

  Future<void> removeFlashCardFromSelectedDeckById(int cardId) async {
    if (_currentDeck == null) {
      throw Exception('No deck selected');
    }

    await (_db.delete(_db.flashcards)..where((tbl) => tbl.id.equals(cardId))).go();

    // Refresh current deck
    await _reloadCurrentDeck();
  }

  List<FlashCardModel> getFlashCardsFromCurrentDeck() {
    if (_currentDeck == null) {
      throw Exception('No deck selected');
    }
    return _currentDeck!.flashCards;
  }

  FlashCardModel getFlashCardsFromSelectedDeckById(int cardId) {
    if (_currentDeck == null) {
      throw Exception('No deck selected');
    }
    return _currentDeck!.flashCards.firstWhere(
      (fc) => fc.id == cardId,
      orElse: () => throw Exception('Flashcard with id $cardId not found.'),
    );
  }

  // ---------------------------
  //   Private Helper Methods
  // ---------------------------
  Future<void> _reloadCurrentDeck() async {
    if (_currentDeck == null) return;

    // Re-query deck
    final deckRow = await (_db.select(_db.decks)..where((tbl) => tbl.id.equals(_currentDeck!.id))).getSingleOrNull();

    if (deckRow == null) {
      // Deck was removed entirely
      _currentDeck = null;
      _currentCard = null;
      _deckController.add(null);
      return;
    }

    final flashcardRows = await (_db.select(_db.flashcards)..where((tbl) => tbl.deckId.equals(deckRow.id))).get();

    _currentDeck = DeckModel(
      id: deckRow.id,
      deckName: deckRow.deckName,
      flashCards: flashcardRows
          .map(
            (fc) => FlashCardModel(
              id: fc.id,
              question: fc.question,
              answer: fc.answer,
            ),
          )
          .toList(),
    );

    _deckController.add(_currentDeck);
  }
}
