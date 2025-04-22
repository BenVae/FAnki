import 'dart:async';

import 'data_models/deck_model.dart';
import 'data_models/flash_card_model.dart';

/// Contract for a deck/flash‑card persistence service.
///
/// Implementations may store data locally, remotely, or both, but must honour
/// this API so that the rest of the app can remain platform‑agnostic.
abstract class DeckRepositoryInterface {
  /* -------------------------------------------------------------------------
   * Streams
   * ---------------------------------------------------------------------- */

  /// Emits the currently selected deck whenever it changes (or `null` when
  /// none is selected).
  Stream<DeckModel?> get currentDeckStream;

  /* -------------------------------------------------------------------------
   * Decks
   * ---------------------------------------------------------------------- */

  /// Returns the names of all decks available in the repository.
  Future<List<String>> getDeckNames();

  /// Creates a new deck.
  Future<void> createDeck(String deckName);

  /// Deletes the deck that is currently selected in memory.
  Future<void> deleteCurrentDeck();

  /// Checks whether a deck name is already taken.
  Future<bool> isDeckNameUsed(String deckName);

  /// Selects a deck by its name and loads its flash‑cards into memory.
  Future<void> setCurrentDeckByName(String deckName);

  /// Returns the name of the currently selected deck.
  String getCurrentDeckName();

  /// Returns the fully‑populated model of the currently selected deck.
  DeckModel getCurrentDeck();

  /// Renames the currently selected deck.
  Future<void> renameDeck({required String newDeckName});

  /* -------------------------------------------------------------------------
   * Flash‑cards
   * ---------------------------------------------------------------------- */

  /// Marks the specified flash‑card within the current deck as the active one.
  void setCurrentFlashCard({required int cardId});

  /// Returns the currently active flash‑card (if any).
  FlashCardModel? getCurrentFlashCard();

  /// Adds a new flash‑card to the current deck.
  Future<bool> addFlashCard({required String question, required String answer});

  /// Updates an existing flash‑card.
  Future<bool> updateFlashCard({
    required int cardId,
    required String question,
    required String answer,
  });

  /// Removes a flash‑card from the current deck.
  Future<void> removeFlashCardFromSelectedDeckById(int cardId);

  /// Retrieves all flash‑cards in the current deck.
  List<FlashCardModel> getFlashCardsFromCurrentDeck();

  /// Retrieves a single flash‑card from the current deck by id.
  FlashCardModel getFlashCardsFromSelectedDeckById(int cardId);

  /* -------------------------------------------------------------------------
   * Synchronisation
   * ---------------------------------------------------------------------- */

  /// Performs a two‑way sync between the local store and the remote backend.
  Future<void> syncWithSupabase();
}
