import 'dart:async';

import 'package:deck_repository/src/data_models/deck_model.dart';
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';

import 'data_models/flash_card_model.dart';
import 'isar_data_models/isar_deck_model.dart';

class DeckRepository {
  late final Isar isar;

  DeckModel? _currentDeck;
  FlashCardModel? _currentFlashCard;

  DeckRepository._create(this.isar);

  static Future<DeckRepository> init() async {
    final dir = await getApplicationDocumentsDirectory();
    final isar = await Isar.open(
      [IsarDeckModelSchema],
      directory: dir.path,
    );
    return DeckRepository._create(isar);
  }

  Future<List<String>> getDeckNames() async {
    final decks = await isar.isarDeckModels.where().findAll();
    return decks.map((deck) => deck.deckName).toList();
  }

  Future<void> createDeck(String deckName) async {
    final deckModel = IsarDeckModel(deckName: deckName, flashCards: []);
    await isar.writeTxn(() async {
      await isar.isarDeckModels.put(deckModel);
    });
  }

  Future<bool> isDeckNameUsed(String deckName) async {
    final deckModel = await isar.isarDeckModels.filter().deckNameEqualTo(deckName).findFirst();
    return deckModel != null;
  }

  Future<DeckModel> loadDeckByName(String deckName) async {
    final isarDeck = await isar.isarDeckModels.filter().deckNameEqualTo(deckName).findFirst();

    if (isarDeck == null) {
      throw Exception('Deck $deckName is unknown.');
    }

    _currentDeck = isarDeck.toDomain();
    return _currentDeck!;
  }

  String getCurrentDeckName() {
    if (_currentDeck != null) {
      return _currentDeck!.deckName;
    } else {
      throw Exception('No deck selected.');
    }
  }

  FlashCardModel? setCurrentFlashCard({required int? cardId}) {
    if (_currentDeck == null) {
      throw Exception('CurrentDeck was null.');
    }

    if (cardId == null) {
      _currentFlashCard = null;
    } else {
      final foundCard = _currentDeck!.flashCards.firstWhere(
        (flashCard) => flashCard.id == cardId,
        orElse: () => throw Exception('FlashCard with id=$cardId not found.'),
      );
      _currentFlashCard = foundCard;
    }
    return _currentFlashCard;
  }

  FlashCardModel? getCurrentFlashCard() {
    return _currentFlashCard;
  }

  Future<DeckModel> addFlashCard({required String question, required String answer}) async {
    if (_currentDeck == null) {
      throw Exception('No deck selected.');
    }

    final newCard = FlashCardModel(
      id: _getIdForNewFlashCard(),
      question: question,
      answer: answer,
    );

    _currentDeck!.flashCards = [..._currentDeck!.flashCards, newCard];
    final isarDeckModel = _currentDeck!.toIsar();

    await isar.writeTxn(() async {
      await isar.isarDeckModels.put(isarDeckModel);
    });

    final updatedDeck = await isar.isarDeckModels.filter().deckNameEqualTo(_currentDeck!.deckName).findFirst();

    if (updatedDeck != null) {
      _currentDeck = updatedDeck.toDomain();
      return _currentDeck!;
    } else {
      throw Exception('Adding Flashcard did not work.');
    }
  }

  int _getIdForNewFlashCard() {
    if (_currentDeck == null || _currentDeck!.flashCards.isEmpty) {
      return 1;
    }
    final maxId =
        _currentDeck!.flashCards.map((fc) => fc.id).reduce((value, element) => value > element ? value : element);
    return maxId + 1;
  }

  Future<void> editFlashCard({
    required int cardId,
    required String question,
    required String answer,
  }) async {
    if (_currentDeck == null) {
      throw Exception('No deck selected.');
    }

    final index = _currentDeck!.flashCards.indexWhere((fc) => fc.id == cardId);
    if (index == -1) {
      throw Exception('Flashcard with id $cardId not found.');
    }

    final updatedFlashCard = FlashCardModel(id: cardId, question: question, answer: answer);

    _currentDeck!.flashCards = List<FlashCardModel>.from(_currentDeck!.flashCards);
    _currentDeck!.flashCards[index] = updatedFlashCard;

    final isarDeckModel = _currentDeck!.toIsar();
    await isar.writeTxn(() async {
      await isar.isarDeckModels.put(isarDeckModel);
    });

    final updatedDeck = await isar.isarDeckModels.filter().deckNameEqualTo(_currentDeck!.deckName).findFirst();

    if (updatedDeck != null) {
      _currentDeck = updatedDeck.toDomain();
    }
  }

  List<FlashCardModel> getFlashCardsFromSelectedDeck() {
    if (_currentDeck != null) {
      return _currentDeck!.flashCards;
    } else {
      throw Exception('No deck selected');
    }
  }

  FlashCardModel getFlashCardsFromSelectedDeckById(int cardId) {
    if (_currentDeck == null) {
      throw Exception('No deck selected');
    }
    final flashCard = _currentDeck!.flashCards.firstWhere(
      (fc) => fc.id == cardId,
      orElse: () => throw Exception('Flashcard with $cardId not found. Sync mismatch!'),
    );
    return flashCard;
  }

  Future<DeckModel> removeFlashCardFromSelectedDeckById(int cardId) async {
    if (_currentDeck == null) {
      throw Exception('No deck selected');
    }

    final index = _currentDeck!.flashCards.indexWhere((fc) => fc.id == cardId);
    if (index == -1) {
      throw Exception('Flashcard with id $cardId not found in current deck.');
    }

    _currentDeck!.flashCards = List<FlashCardModel>.from(_currentDeck!.flashCards)..removeAt(index);

    final isarDeckModel = _currentDeck!.toIsar();
    await isar.writeTxn(() async {
      await isar.isarDeckModels.put(isarDeckModel);
    });

    final updatedDeck = await isar.isarDeckModels.filter().deckNameEqualTo(_currentDeck!.deckName).findFirst();

    if (updatedDeck != null) {
      _currentDeck = updatedDeck.toDomain();
      return _currentDeck!;
    } else {
      throw Exception('Removing card did not work.');
    }
  }
}
