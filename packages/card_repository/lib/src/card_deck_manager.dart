import 'models/single_card.dart';
import 'firebase_api.dart';

class CardDeckManager {
  FirebaseApi firebaseapi = FirebaseApi();
  final Map<String, List<SingleCard>> decks = {};
  String userID = '';
  String currentDeckName = '';

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
    this.userID = userID.toLowerCase();
    if (this.userID.isNotEmpty) {
      initDeckNames();
      getCurrentDeck();
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
    if (deckNames.contains(deckName)) {
      print('Deck with name $deckName already exists.');
      return false;
    } else {
      decks[deckName] = [];
      firebaseapi.createDeckInFirestore(userID, deckName);
      print('Added deck with name $deckName.');
    }
    currentDeckName = deckName;
    return true;
  }

  void removeDeck(String deckName) {
    if (deckNames.contains(deckName)) {
      decks.remove(deckName);
      firebaseapi.removeDeckFromFirestore(userID, deckName);
    } else {
      print('Error: deck $deckName did not exist');
    }
  }

  void addCard(SingleCard card) {
    decks[currentDeckName]!.add(card);
    firebaseapi.addCardToFirestore(userID, currentDeckName, card);
  }

  void addCardWithQA(String question, String answer) {
    SingleCard sc = SingleCard(
        deckName: currentDeckName, questionText: question, answerText: answer);
    decks[currentDeckName]!.add(sc);
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
      print('Warning: Deck with name $deckName does not exist in CardDeckManager.');
    }
  }
}
