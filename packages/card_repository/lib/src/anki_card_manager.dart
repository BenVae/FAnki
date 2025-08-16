import 'models/anki_card.dart';
import 'models/single_card.dart';
import 'firebase_api.dart';
import 'services/sm2_service.dart';
import 'services/card_scheduler.dart';
import 'package:logging/logging.dart';

final _logger = Logger('AnkiCardManager');

/// Manager for AnkiCards and decks with full SM-2 spaced repetition support
class AnkiCardManager {
  final FirebaseApi firebaseApi = FirebaseApi();
  final SM2Service sm2Service = SM2Service();
  late final CardScheduler cardScheduler;
  
  final Map<String, List<AnkiCard>> decks = {};
  String userID = '';
  String currentDeckId = '';

  AnkiCardManager() {
    cardScheduler = CardScheduler(firebaseApi);
    _logger.config('AnkiCardManager initialized - userID: "$userID", deck: "$currentDeckId"');
  }

  List<String> get deckIds => decks.keys.toList();

  /// Get the number of cards in a specific deck
  int getCardCount(String deckId) {
    if (decks.containsKey(deckId) && decks[deckId] != null) {
      return decks[deckId]!.length;
    }
    return 0;
  }

  /// Get card counts for all decks as a map
  Map<String, int> get deckCardCounts {
    Map<String, int> counts = {};
    for (String deckId in deckIds) {
      counts[deckId] = getCardCount(deckId);
    }
    return counts;
  }

  /// Get statistics for a deck
  Future<Map<String, dynamic>> getDeckStatistics(String deckId) async {
    if (userID.isEmpty || deckId.isEmpty) {
      return {};
    }
    return await cardScheduler.getDeckStatistics(userID, deckId);
  }

  void setUserID(String userID) {
    _logger.fine('Setting userID from "${this.userID}" to "$userID"');
    this.userID = userID.toLowerCase();
    _logger.fine('UserID normalized to: "${this.userID}"');
    if (this.userID.isNotEmpty) {
      _logger.info('Initializing card manager for user');
      initDeckNames();
      getCurrentDeck();
    } else {
      _logger.warning('UserID is empty after setting - this may cause issues');
    }
  }

  Future<void> initDeckNames() async {
    List<String> deckIds = await firebaseApi.getAllDecknamesFromFirestore(userID);
    for (String deckId in deckIds) {
      if (!decks.containsKey(deckId)) {
        decks[deckId] = [];
      }
    }
  }

  Future<List<AnkiCard>> getCurrentDeckCards() async {
    List<AnkiCard> deck = [];
    if (decks.containsKey(currentDeckId) &&
        decks[currentDeckId] != null &&
        decks[currentDeckId]!.isNotEmpty) {
      deck = decks[currentDeckId]!;
    } else {
      decks[currentDeckId] = await loadDeck();
      deck = decks[currentDeckId]!;
    }
    return deck;
  }

  Future<List<AnkiCard>> loadDeck() async {
    if (currentDeckIsEmpty()) {
      List<AnkiCard> cards = await firebaseApi.getAllAnkiCardsFromDeck(userID, currentDeckId);
      return cards;
    } else {
      return [];
    }
  }

  Future<bool> createDeck(String deckId, {String? deckName}) async {
    _logger.info('Creating deck "$deckId" for user "$userID"');
    if (deckIds.contains(deckId)) {
      _logger.warning('Deck "$deckId" already exists');
      return false;
    } else {
      decks[deckId] = [];
      _logger.fine('Calling Firebase API to create deck');
      await firebaseApi.createDeckInFirestore(userID, deckId, deckName: deckName);
      _logger.info('Successfully created deck "$deckId"');
    }
    currentDeckId = deckId;
    _logger.fine('Set current deck to "$currentDeckId"');
    return true;
  }

  Future<void> removeDeck(String deckId) async {
    if (deckIds.contains(deckId)) {
      decks.remove(deckId);
      await firebaseApi.removeDeckFromFirestore(userID, deckId);
    } else {
      _logger.warning('Cannot delete deck "$deckId" - does not exist');
    }
  }

  Future<void> addCard(AnkiCard card) async {
    decks[currentDeckId]!.add(card);
    await firebaseApi.addAnkiCardToFirestore(userID, currentDeckId, card);
  }

  Future<void> addCardWithQA(String question, String answer) async {
    _logger.info('Adding card to deck "$currentDeckId" for user "$userID"');
    _logger.fine('Card content - Q: "$question", A: "$answer"');
    
    AnkiCard card = AnkiCard(
      deckId: currentDeckId,
      questionText: question,
      answerText: answer,
    );
    
    decks[currentDeckId]!.add(card);
    _logger.fine('Saving card to Firebase');
    await firebaseApi.addAnkiCardToFirestore(userID, currentDeckId, card);
  }

  Future<void> removeCard(AnkiCard card) async {
    decks[currentDeckId]!.remove(card);
    await firebaseApi.removeAnkiCardFromFirestore(userID, currentDeckId, card.id);
  }

  Future<void> removeCardByID(String cardID) async {
    for (AnkiCard card in decks[currentDeckId]!) {
      if (card.id == cardID) {
        await removeCard(card);
        break;
      }
    }
  }

  /// Process a card review with SM-2 algorithm
  Future<void> reviewCard(AnkiCard card, ReviewGrade grade) async {
    _logger.info('Processing review for card ${card.id} with grade ${grade.name}');
    
    // Process the review using SM-2 algorithm
    final updatedCard = sm2Service.processReview(card, grade);
    
    // Update the card in Firebase
    await firebaseApi.updateAnkiCard(userID, currentDeckId, updatedCard);
    
    // Update local cache
    final index = decks[currentDeckId]!.indexWhere((c) => c.id == card.id);
    if (index != -1) {
      decks[currentDeckId]![index] = updatedCard;
    }
    
    _logger.info('Card ${card.id} updated: next due ${updatedCard.dueDate}');
  }

  /// Get cards due for review
  Future<List<AnkiCard>> getDueCards({int? limit}) async {
    if (userID.isEmpty || currentDeckId.isEmpty) {
      return [];
    }
    
    final allCards = await getCurrentDeckCards();
    return sm2Service.getDueCards(allCards, limit: limit);
  }

  /// Create a study session with proper Anki queue management
  Future<StudySession> createStudySession(StudySettings settings) async {
    if (userID.isEmpty || currentDeckId.isEmpty) {
      throw ArgumentError('UserID and currentDeckId must be set');
    }
    
    return await cardScheduler.createStudySession(userID, currentDeckId, settings);
  }

  bool currentDeckIsEmpty() {
    if (decks.containsKey(currentDeckId)) {
      var currentDeck = decks[currentDeckId];
      if (currentDeck != null && currentDeck.isNotEmpty) {
        return false;
      }
    }
    return true;
  }

  Future<String> getCurrentDeck() async {
    if (currentDeckId == '' && userID.isNotEmpty) {
      currentDeckId = await firebaseApi.getLastDeckFromFireStore(userID);
    }
    return currentDeckId;
  }

  void setCurrentDeck(String deckId) {
    if (deckIds.contains(deckId)) {
      currentDeckId = deckId;
      firebaseApi.setLastDeckInFireStore(userID, deckId);
    } else {
      _logger.warning('Deck "$deckId" does not exist in AnkiCardManager');
    }
  }

  /// Migrate SingleCards to AnkiCards
  Future<void> migrateFromSingleCards(List<SingleCard> singleCards) async {
    _logger.info('Migrating ${singleCards.length} SingleCards to AnkiCards');
    
    for (final singleCard in singleCards) {
      final ankiCard = AnkiCard.fromSingleCard(singleCard, currentDeckId);
      await addCard(ankiCard);
    }
    
    _logger.info('Migration complete');
  }

  /// Get card statistics for display
  Map<String, int> getCardStatistics() {
    int newCount = 0;
    int learningCount = 0;
    int reviewCount = 0;
    int dueCount = 0;
    
    for (final deck in decks.values) {
      for (final card in deck) {
        if (card.suspended) continue;
        
        switch (card.state) {
          case CardState.newCard:
            newCount++;
            break;
          case CardState.learning:
          case CardState.relearning:
            learningCount++;
            if (card.isDue) dueCount++;
            break;
          case CardState.review:
            reviewCount++;
            if (card.isDue) dueCount++;
            break;
        }
      }
    }
    
    return {
      'new': newCount,
      'learning': learningCount,
      'review': reviewCount,
      'due': dueCount,
      'total': decks.values.fold(0, (sum, deck) => sum + deck.length),
    };
  }
}