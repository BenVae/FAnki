import 'package:bloc/bloc.dart';
import 'package:card_repository/card_deck_manager.dart';

import '../../../main.dart';

class ManageDecksCubitV2 extends Cubit<DeckStateV2> {
  final DeckTreeManager _deckTreeManager;
  final CardDeckManager _cdm; // Keep for backwards compatibility
  String? _selectedDeckId;

  ManageDecksCubitV2({
    required DeckTreeManager deckTreeManager,
    required CardDeckManager cardDeckManager,
  })  : _deckTreeManager = deckTreeManager,
        _cdm = cardDeckManager,
        super(DeckStateV2Loading()) {
    _initialize();
  }

  void _initialize() async {
    // Get user ID from CardDeckManager (already set by LoginCubit)
    if (_cdm.userID.isNotEmpty) {
      await _deckTreeManager.setUserId(_cdm.userID);
      await loadDecks();
    } else {
      emit(DeckStateV2Error('User not logged in'));
    }
  }

  Future<void> loadDecks() async {
    emit(DeckStateV2Loading());
    try {
      await _deckTreeManager.loadDecks();
      
      // Try to select the previously selected deck or the first available
      if (_selectedDeckId != null) {
        final deck = _deckTreeManager.getDeckById(_selectedDeckId!);
        if (deck != null) {
          _cdm.setCurrentDeck(deck.name);
        }
      } else if (_deckTreeManager.allDecks.isNotEmpty) {
        final firstDeck = _deckTreeManager.allDecks.first;
        _selectedDeckId = firstDeck.id;
        _cdm.setCurrentDeck(firstDeck.name);
      }
      
      emit(DeckStateV2Loaded(
        rootDecks: _deckTreeManager.rootDecks,
        allDecks: _deckTreeManager.allDecks,
        selectedDeckId: _selectedDeckId,
        currentDeck: _selectedDeckId != null 
            ? _deckTreeManager.getDeckById(_selectedDeckId!)
            : null,
      ));
    } catch (e) {
      emit(DeckStateV2Error(e.toString()));
    }
  }

  void selectDeck(Deck deck) {
    _selectedDeckId = deck.id;
    _cdm.setCurrentDeck(deck.name);
    
    if (state is DeckStateV2Loaded) {
      final currentState = state as DeckStateV2Loaded;
      emit(currentState.copyWith(
        selectedDeckId: deck.id,
        currentDeck: deck,
      ));
    }
  }

  Future<void> createDeck({
    required String name,
    String? parentId,
    DeckSettings? settings,
  }) async {
    try {
      await _deckTreeManager.createDeck(
        name: name,
        parentId: parentId,
        settings: settings,
      );
      
      // Also create in old system for compatibility
      if (parentId != null) {
        final parent = _deckTreeManager.getDeckById(parentId);
        if (parent != null) {
          _cdm.createDeck('${parent.path}::$name');
        }
      } else {
        _cdm.createDeck(name);
      }
      
      await loadDecks();
    } catch (e) {
      log.severe('Error creating deck: $e');
    }
  }

  Future<void> deleteDeck(String deckId, {bool deleteSubdecks = false}) async {
    try {
      final deck = _deckTreeManager.getDeckById(deckId);
      if (deck == null) return;
      
      // If deleting selected deck, select another one
      if (deckId == _selectedDeckId) {
        final allDecks = _deckTreeManager.allDecks;
        final currentIndex = allDecks.indexWhere((d) => d.id == deckId);
        
        if (allDecks.length > 1) {
          // Select next deck or previous if it's the last one
          final newIndex = currentIndex < allDecks.length - 1 
              ? currentIndex + 1 
              : currentIndex - 1;
          if (newIndex >= 0 && newIndex < allDecks.length) {
            selectDeck(allDecks[newIndex]);
          }
        } else {
          _selectedDeckId = null;
          _cdm.setCurrentDeck('');
        }
      }
      
      await _deckTreeManager.deleteDeck(deckId, deleteSubdecks: deleteSubdecks);
      
      // Also delete from old system
      _cdm.removeDeck(deck.name);
      
      await loadDecks();
    } catch (e) {
      log.severe('Error deleting deck: $e');
    }
  }

  Future<void> renameDeck(String deckId, String newName) async {
    try {
      await _deckTreeManager.renameDeck(deckId, newName);
      await loadDecks();
    } catch (e) {
      log.severe('Error renaming deck: $e');
    }
  }

  Future<void> moveDeck(String deckId, String? newParentId) async {
    try {
      await _deckTreeManager.moveDeck(deckId, newParentId);
      await loadDecks();
    } catch (e) {
      log.severe('Error moving deck: $e');
    }
  }

  List<Deck> getAncestors(String deckId) {
    return _deckTreeManager.getAncestors(deckId);
  }

  int getTotalCardCount(String deckId) {
    return _deckTreeManager.getTotalCardCount(deckId);
  }
}

// New state classes for tree deck structure
abstract class DeckStateV2 {}

class DeckStateV2Loading extends DeckStateV2 {}

class DeckStateV2Loaded extends DeckStateV2 {
  final List<Deck> rootDecks;
  final List<Deck> allDecks;
  final String? selectedDeckId;
  final Deck? currentDeck;

  DeckStateV2Loaded({
    required this.rootDecks,
    required this.allDecks,
    this.selectedDeckId,
    this.currentDeck,
  });

  DeckStateV2Loaded copyWith({
    List<Deck>? rootDecks,
    List<Deck>? allDecks,
    String? selectedDeckId,
    Deck? currentDeck,
  }) {
    return DeckStateV2Loaded(
      rootDecks: rootDecks ?? this.rootDecks,
      allDecks: allDecks ?? this.allDecks,
      selectedDeckId: selectedDeckId ?? this.selectedDeckId,
      currentDeck: currentDeck ?? this.currentDeck,
    );
  }
}

class DeckStateV2Error extends DeckStateV2 {
  final String message;

  DeckStateV2Error(this.message);
}