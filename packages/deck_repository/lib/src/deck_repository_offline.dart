import 'dart:async';
import 'package:brick_offline_first_with_supabase/brick_offline_first_with_supabase.dart';
import 'package:brick_sqlite/brick_sqlite.dart';
import 'package:brick_supabase/brick_supabase.dart' hide Supabase;
import 'package:sqflite_common/sqlite_api.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:drift/drift.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'deck_database.dart'; // The Drift db + tables
import 'data_models/deck_model.dart'; // DeckModel
import 'data_models/flash_card_model.dart';
import 'deck_repository_interface.dart'; // FlashCardModel

enum EditCard { init, editing, notEditing }

class DeckRepository extends DeckRepositoryInterface {
  final AppDatabase _db;
  final SupabaseClient _supabaseClient;

  DeckModel? _currentDeck;
  FlashCardModel? _currentCard;

  final _deckController = StreamController<DeckModel?>.broadcast();
  @override
  Stream<DeckModel?> get currentDeckStream async* {
    yield null;
    yield* _deckController.stream;
  }

  static Future<void> configure(DatabaseFactory databaseFactory, SupabaseClient supabaseClient) async {
    final (client, queue) = OfflineFirstWithSupabaseRepository.clientQueue(
      databaseFactory: databaseFactory,
    );

    // await Supabase.initialize(
    //   url: supabaseUrl,
    //   anonKey: supabaseAnonKey,
    //   httpClient: client,
    // );

    // final provider = SupabaseProvider(
    //   supabaseClient,
    //   modelDictionary: supabaseModelDictionary,
    // );

    // _instance = Repository._(
    //   supabaseProvider: provider,
    //   sqliteProvider: SqliteProvider(
    //     'my_repository.sqlite',
    //     databaseFactory: databaseFactory,
    //     modelDictionary: sqliteModelDictionary,
    //   ),
    //   migrations: migrations,
    //   offlineRequestQueue: queue,
    //   // Specify class types that should be cached in memory
    //   memoryCacheProvider: MemoryCacheProvider(),
    // );
  }

  DeckRepository._create(this._db, this._supabaseClient);

  // -------------
  //   INIT
  // -------------
  static Future<DeckRepository> init(SupabaseClient supabaseClient) async {
    final db = AppDatabase();
    return DeckRepository._create(db, supabaseClient);
  }

  // -------------
  //   DECKS
  // -------------

  @override
  Future<List<String>> getDeckNames() async {
    final allDeckRows = await _db.select(_db.decks).get();
    return allDeckRows.map((row) => row.deckName).toList();
  }

  @override
  Future<void> createDeck(String deckName) async {
    // 1) Insert into local DB
    final newDeckId = await _db.into(_db.decks).insert(
          DecksCompanion.insert(deckName: deckName),
        );

    // 2) Push to Supabase
    // (Assumes your 'decks' table has an 'id' column that you can supply yourself.)
    await _supabaseClient.from('decks').insert({
      'id': newDeckId,
      'deck_name': deckName,
      // add other fields as needed (e.g., created_at, etc.)
    });
  }

  @override
  Future<void> deleteCurrentDeck() async {
    if (_currentDeck == null) {
      throw Exception('Delete current deck error, because no deck is selected.');
    }
    final deletingDeckId = _currentDeck!.id;

    // 1) Delete locally
    await (_db.delete(_db.decks)..where((tbl) => tbl.id.equals(deletingDeckId))).go();

    // 2) Delete remotely
    await _supabaseClient.from('decks').delete().match({'id': deletingDeckId});

    // Clear in-memory state
    _currentDeck = null;
    _currentCard = null;
    _deckController.add(null);
  }

  @override
  Future<bool> isDeckNameUsed(String deckName) async {
    final existing = await (_db.select(_db.decks)..where((tbl) => tbl.deckName.equals(deckName))).getSingleOrNull();
    return existing != null;
  }

  @override
  Future<void> setCurrentDeckByName(String deckName) async {
    final foundDeck = await (_db.select(_db.decks)..where((tbl) => tbl.deckName.equals(deckName))).getSingleOrNull();

    if (foundDeck == null) {
      throw Exception('Deck "$deckName" does not exist.');
    }

    // Fetch flashcards for that deck
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

  @override
  String getCurrentDeckName() {
    if (_currentDeck == null) {
      throw Exception('No deck selected.');
    }
    return _currentDeck!.deckName;
  }

  @override
  DeckModel getCurrentDeck() {
    if (_currentDeck == null) {
      throw Exception('No deck selected.');
    }
    return _currentDeck!;
  }

  @override
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

    // 1) Update local DB
    await (_db.update(_db.decks)..where((tbl) => tbl.id.equals(_currentDeck!.id)))
        .write(DecksCompanion(deckName: Value(newDeckName)));

    // 2) Update remote deck name
    await _supabaseClient.from('decks').update({
      'deck_name': newDeckName,
    }).match({'id': _currentDeck!.id});

    // 3) Update in-memory model
    _currentDeck!.deckName = newDeckName;
    _deckController.add(_currentDeck);
  }

  // -------------
  //   FLASHCARDS
  // -------------

  @override
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

  @override
  FlashCardModel? getCurrentFlashCard() => _currentCard;

  @override
  Future<bool> addFlashCard({
    required String question,
    required String answer,
  }) async {
    if (_currentDeck == null) {
      throw Exception('No deck selected.');
    }

    // 1) Insert into local DB
    final newFlashcardId = await _db.into(_db.flashcards).insert(
          FlashcardsCompanion.insert(
            deckId: _currentDeck!.id,
            question: question,
            answer: answer,
          ),
        );

    // 2) Insert into Supabase
    await _supabaseClient.from('flashcards').insert({
      'id': newFlashcardId,
      'deck_id': _currentDeck!.id,
      'question': question,
      'answer': answer,
    });

    // Refresh current deck from DB
    await _reloadCurrentDeck();
    return true;
  }

  @override
  Future<bool> updateFlashCard({
    required int cardId,
    required String question,
    required String answer,
  }) async {
    if (_currentDeck == null) {
      throw Exception('No deck selected.');
    }

    // Check existence in local model (optional)
    final index = _currentDeck!.flashCards.indexWhere((fc) => fc.id == cardId);
    if (index == -1) {
      throw Exception('Flashcard with id $cardId not found.');
    }

    // 1) Update local DB
    await (_db.update(_db.flashcards)..where((tbl) => tbl.id.equals(cardId))).write(
      FlashcardsCompanion(
        question: Value(question),
        answer: Value(answer),
      ),
    );

    // 2) Update Supabase
    await _supabaseClient.from('flashcards').update({'question': question, 'answer': answer}).match({'id': cardId});

    // Refresh current deck
    await _reloadCurrentDeck();
    return true;
  }

  @override
  Future<void> removeFlashCardFromSelectedDeckById(int cardId) async {
    if (_currentDeck == null) {
      throw Exception('No deck selected');
    }

    // 1) Remove locally
    await (_db.delete(_db.flashcards)..where((tbl) => tbl.id.equals(cardId))).go();

    // 2) Remove from Supabase
    await _supabaseClient.from('flashcards').delete().match({'id': cardId});

    // Refresh current deck
    await _reloadCurrentDeck();
  }

  @override
  List<FlashCardModel> getFlashCardsFromCurrentDeck() {
    if (_currentDeck == null) {
      throw Exception('No deck selected');
    }
    return _currentDeck!.flashCards;
  }

  @override
  FlashCardModel getFlashCardsFromSelectedDeckById(int cardId) {
    if (_currentDeck == null) {
      throw Exception('No deck selected');
    }
    return _currentDeck!.flashCards.firstWhere(
      (fc) => fc.id == cardId,
      orElse: () => throw Exception('Flashcard with id $cardId not found.'),
    );
  }

  // -------------
  //   SYNC
  // -------------
  /// A naive two-way sync: fetch from remote, merge to local, then push missing local items
  /// to Supabase. Real-world usage might need conflict resolution, timestamps, etc.
  @override
  Future<void> syncWithSupabase() async {
    // ---------- 1) Pull from Supabase ----------
    //   1a) Fetch remote decks
    final remoteDecksResponse = await _supabaseClient.from('decks').select();
    if (remoteDecksResponse.isEmpty) {
      throw Exception('Error fetching decks from Supabase: ${remoteDecksResponse.toString()}');
    }
    final remoteDecks = remoteDecksResponse.toList();

    //   1b) Fetch remote flashcards
    final remoteFcResponse = await _supabaseClient.from('flashcards').select();
    if (remoteFcResponse.isEmpty) {
      throw Exception('Error fetching flashcards from Supabase: ${remoteFcResponse.toString()}');
    }
    final remoteFlashcards = remoteFcResponse.toList();

    // Group remote flashcards by deck_id
    final Map<int, List<Map<String, dynamic>>> flashcardsByDeckId = {};
    for (final fc in remoteFlashcards) {
      final deckId = fc['deck_id'] as int?;
      if (deckId != null) {
        flashcardsByDeckId.putIfAbsent(deckId, () => []).add(fc);
      }
    }

    // ---------- 2) Merge into local DB ----------
    // For each remote deck, insert/update locally
    for (final rd in remoteDecks) {
      final remoteDeckId = rd['id'] as int;
      final remoteDeckName = rd['deck_name'] as String;

      // Does it exist locally?
      final localDeck = await (_db.select(_db.decks)..where((tbl) => tbl.id.equals(remoteDeckId))).getSingleOrNull();

      if (localDeck == null) {
        // Insert new deck
        await _db.into(_db.decks).insert(
              DecksCompanion.insert(
                id: Value(remoteDeckId),
                deckName: remoteDeckName,
              ),
            );
      } else {
        // Update existing deck (assumes remote is the “source of truth”)
        await (_db.update(_db.decks)..where((tbl) => tbl.id.equals(remoteDeckId))).write(
          DecksCompanion(
            deckName: Value(remoteDeckName),
          ),
        );
      }

      // Now handle flashcards in this deck
      final deckFlashcards = flashcardsByDeckId[remoteDeckId] ?? [];
      for (final remoteFc in deckFlashcards) {
        final fcId = remoteFc['id'] as int;
        final question = remoteFc['question'] as String;
        final answer = remoteFc['answer'] as String;

        // Check if local card with same ID exists
        final localFc = await (_db.select(_db.flashcards)..where((tbl) => tbl.id.equals(fcId))).getSingleOrNull();

        if (localFc == null) {
          // Insert
          await _db.into(_db.flashcards).insert(
                FlashcardsCompanion.insert(
                  id: Value(fcId),
                  deckId: remoteDeckId,
                  question: question,
                  answer: answer,
                ),
              );
        } else {
          // Update
          await (_db.update(_db.flashcards)..where((tbl) => tbl.id.equals(fcId))).write(
            FlashcardsCompanion(
              question: Value(question),
              answer: Value(answer),
            ),
          );
        }
      }
    }

    // ---------- 3) Push local decks/flashcards that aren’t in Supabase ----------
    // Local decks
    final localDecks = await _db.select(_db.decks).get();
    for (final ld in localDecks) {
      final match = remoteDecks.firstWhere(
        (rd) => rd['id'] == ld.id,
        orElse: () => {},
      );

      if (match.isEmpty) {
        // Insert into Supabase
        await _supabaseClient.from('decks').insert({
          'id': ld.id,
          'deck_name': ld.deckName,
        });
      }
    }

    // Local flashcards
    final localFcs = await _db.select(_db.flashcards).get();
    for (final localFc in localFcs) {
      final match = remoteFlashcards.firstWhere(
        (rfc) => rfc['id'] == localFc.id,
        orElse: () => {},
      );
      if (match.isEmpty) {
        // Insert
        await _supabaseClient.from('flashcards').insert({
          'id': localFc.id,
          'deck_id': localFc.deckId,
          'question': localFc.question,
          'answer': localFc.answer,
        });
      }
    }

    // Optionally reload current deck to reflect any changes
    await _reloadCurrentDeck();
  }

  // ---------------------------
  //   Private Helper Methods
  // ---------------------------
  Future<void> _reloadCurrentDeck() async {
    if (_currentDeck == null) return;

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
