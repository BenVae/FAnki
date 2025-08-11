import 'models/single_card.dart';
import 'firebase_api.dart';
import 'package:logging/logging.dart';

final _logger = Logger('CardDeckManager');

class CardDeckManager {
  FirebaseApi firebaseapi = FirebaseApi();
  final Map<String, List<SingleCard>> decks = {};
  String userID = '';
  String currentDeckName = '';

  CardDeckManager() {
    _logger.config('CardDeckManager initialized - userID: "$userID", deck: "$currentDeckName"');
  }

  List<String> get deckNames => decks.keys.toList();

  /// Get the number of cards in a specific deck
  int getCardCount(String deckName) {
    if (decks.containsKey(deckName) && decks[deckName] != null) {
      return decks[deckName]!.length;
    }
    return 0;
  }

  /// Get card counts for all decks as a map
  Map<String, int> get deckCardCounts {
    Map<String, int> counts = {};
    for (String deckName in deckNames) {
      counts[deckName] = getCardCount(deckName);
    }
    return counts;
  }

  void setUserID(String userID) {
    _logger.fine('Setting userID from "${this.userID}" to "$userID"');
    this.userID = userID.toLowerCase();
    _logger.fine('UserID normalized to: "${this.userID}"');
    if (this.userID.isNotEmpty) {
      _logger.info('Initializing deck manager for user');
      initDeckNames();
      getCurrentDeck();
    } else {
      _logger.warning('UserID is empty after setting - this may cause issues');
    }
  }

  Future<void> initDeckNames() async {
    List<String> deckNames =
        await firebaseapi.getAllDecknamesFromFirestore(userID);
    for (String deckName in deckNames) {
      if (!decks.containsKey(deckName)) {
        decks[deckName] = [];
      }
    }
  }

  Future<List<SingleCard>> getCurrentDeckCards() async {
    List<SingleCard> deck = [];
    if (decks.containsKey(currentDeckName) &&
        decks[currentDeckName] != null &&
        decks[currentDeckName]!.isNotEmpty) {
      deck = decks[currentDeckName]!;
    } else {
      decks[currentDeckName] = await loadDeck();
      deck = decks[currentDeckName]!;
    }
    return deck;
  }

  Future<List<SingleCard>> loadDeck() async {
    if (currentDeckIsEmpty()) {
      List<SingleCard> cards = await firebaseapi.getAllCardsOfDeckFromFirestore(
          userID, currentDeckName);
      return cards;
    } else {
      return [];
    }
  }

  bool createDeck(String deckName) {
    _logger.info('Creating deck "$deckName" for user "$userID"');
    if (deckNames.contains(deckName)) {
      _logger.warning('Deck "$deckName" already exists');
      return false;
    } else {
      decks[deckName] = [];
      _logger.fine('Calling Firebase API to create deck');
      firebaseapi.createDeckInFirestore(userID, deckName);
      _logger.info('Successfully created deck "$deckName"');
    }
    currentDeckName = deckName;
    _logger.fine('Set current deck to "$currentDeckName"');
    return true;
  }

  void removeDeck(String deckName) {
    if (deckNames.contains(deckName)) {
      decks.remove(deckName);
      firebaseapi.removeDeckFromFirestore(userID, deckName);
    } else {
      _logger.warning('Cannot delete deck "$deckName" - does not exist');
    }
  }

  void addCard(SingleCard card) {
    decks[currentDeckName]!.add(card);
    firebaseapi.addCardToFirestore(userID, currentDeckName, card);
  }

  void addCardWithQA(String question, String answer) {
    _logger.info('Adding card to deck "$currentDeckName" for user "$userID"');
    _logger.fine('Card content - Q: "$question", A: "$answer"');
    SingleCard sc = SingleCard(
        deckName: currentDeckName, questionText: question, answerText: answer);
    decks[currentDeckName]!.add(sc);
    _logger.fine('Saving card to Firebase');
    firebaseapi.addCardToFirestore(userID, currentDeckName, sc);
  }

  void removeCard(SingleCard card) {
    decks[currentDeckName]!.remove(card);
    firebaseapi.removeCardFromFirestore(userID, currentDeckName, card);
  }

  void removeCardByID(String cardID) {
    for (SingleCard card in decks[currentDeckName]!) {
      if (card.id == cardID) {
        removeCard(card);
        break;
      }
    }
  }

  bool currentDeckIsEmpty() {
    if (decks.containsKey(currentDeckName)) {
      var currentDeck = decks[currentDeckName];
      if (currentDeck != null && currentDeck.isNotEmpty) {
        return false;
      }
    }
    return true;
  }

  Future<String> getCurrentDeck() async {
    if (currentDeckName == '' && userID.isNotEmpty) {
      currentDeckName = await firebaseapi.getLastDeckFromFireStore(userID);
    }
    return currentDeckName;
  }

  void setCurrentDeck(String deckName) {
    if (deckNames.contains(deckName)) {
      // log.info('Deck $deckName is used now.');
      currentDeckName = deckName;
      // Don't load cards here - let the caller decide when to load
      firebaseapi.setLastDeckInFireStore(userID, deckName);
    } else {
      // log.info('Deck with name $deckName does not exist.');
      // Don't exit the app - just log a warning
      _logger.warning('Deck "$deckName" does not exist in CardDeckManager');
    }
  }
}
