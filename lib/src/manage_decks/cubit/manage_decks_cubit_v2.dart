import 'package:bloc/bloc.dart';
import 'package:card_repository/card_deck_manager.dart';

import '../../../main.dart';

class ManageDecksCubitV2 extends Cubit<DeckStateV2> {
  final DeckTreeManager _deckTreeManager;
  final CardDeckManager _cdm; // Keep for backwards compatibility
  String? _selectedDeckId;
  final Set<String> _expandedDeckIds = {};

  // Getter to expose CardDeckManager for other components
  CardDeckManager get cdm => _cdm;

  ManageDecksCubitV2({
    required DeckTreeManager deckTreeManager,
    required CardDeckManager cardDeckManager,
  })  : _deckTreeManager = deckTreeManager,
        _cdm = cardDeckManager,
        super(DeckStateV2Loading());

  void initialize() async {
    // Get user ID from CardDeckManager (already set by LoginCubit)
    String userId = _cdm.userID;
    
    // If userID is empty, try to get it from AuthenticationRepository
    if (userId.isEmpty) {
      // Wait a bit and try again - login might still be in progress
      await Future.delayed(Duration(milliseconds: 100));
      userId = _cdm.userID;
    }
    
    if (userId.isNotEmpty) {
      await _deckTreeManager.setUserId(userId);
      await loadDecks();
    } else {
      emit(DeckStateV2Error('User not logged in. Please retry.'));
    }
  }

  Future<void> loadDecks() async {
    emit(DeckStateV2Loading());
    try {
      await _deckTreeManager.loadDecks();
      
      // Try to select the previously selected deck or the first available
      if (_selectedDeckId != null) {
        final deck = _deckTreeManager.getDeckById(_selectedDeckId!);
        if (deck != null && _cdm.deckNames.contains(deck.name)) {
          _cdm.setCurrentDeck(deck.name);
        }
      } else if (_deckTreeManager.allDecks.isNotEmpty) {
        final firstDeck = _deckTreeManager.allDecks.first;
        _selectedDeckId = firstDeck.id;
        // Only set current deck if it exists in the old system
        if (_cdm.deckNames.contains(firstDeck.name)) {
          _cdm.setCurrentDeck(firstDeck.name);
        }
      }
      
      emit(DeckStateV2Loaded(
        rootDecks: _deckTreeManager.rootDecks,
        allDecks: _deckTreeManager.allDecks,
        selectedDeckId: _selectedDeckId,
        currentDeck: _selectedDeckId != null 
            ? _deckTreeManager.getDeckById(_selectedDeckId!)
            : null,
        expandedDeckIds: _expandedDeckIds,
      ));
    } catch (e) {
      emit(DeckStateV2Error(e.toString()));
    }
  }

  void selectDeck(Deck deck) {
    // Validate deck before selection
    if (deck.id.isEmpty) {
      log.severe('Cannot select deck with empty ID');
      return;
    }
    
    print('ManageDecksCubitV2: Selecting deck "${deck.name}" (id: ${deck.id})');
    print('ManageDecksCubitV2: CDM userID: "${_cdm.userID}"');
    print('ManageDecksCubitV2: CDM deckNames: ${_cdm.deckNames}');
    
    _selectedDeckId = deck.id;
    // Always set current deck in the old system, creating if needed
    if (!_cdm.deckNames.contains(deck.name)) {
      // Create deck in old system to sync with v2
      print('ManageDecksCubitV2: Creating deck "${deck.name}" in old system');
      _cdm.createDeck(deck.name);
    } else {
      print('ManageDecksCubitV2: Setting current deck to "${deck.name}"');
      _cdm.setCurrentDeck(deck.name);
    }
    
    print('ManageDecksCubitV2: CDM currentDeckName after selection: "${_cdm.currentDeckName}"');
    
    if (state is DeckStateV2Loaded) {
      final currentState = state as DeckStateV2Loaded;
      emit(currentState.copyWith(
        selectedDeckId: deck.id,
        currentDeck: deck,
        expandedDeckIds: _expandedDeckIds,
      ));
    }
  }

  void toggleDeckExpansion(String deckId) {
    if (_expandedDeckIds.contains(deckId)) {
      _expandedDeckIds.remove(deckId);
    } else {
      _expandedDeckIds.add(deckId);
    }
    
    if (state is DeckStateV2Loaded) {
      final currentState = state as DeckStateV2Loaded;
      emit(currentState.copyWith(
        expandedDeckIds: Set<String>.from(_expandedDeckIds),
      ));
    }
  }

  Future<void> createDeck({
    required String name,
    String? parentId,
    DeckSettings? settings,
  }) async {
    // Validate inputs
    if (name.isEmpty) {
      log.severe('Cannot create deck with empty name');
      return;
    }
    
    if (parentId != null && parentId.isEmpty) {
      log.severe('Cannot create deck with empty parent ID');
      return;
    }
    
    try {
      // Ensure DeckTreeManager has the userID before creating deck
      if (_cdm.userID.isNotEmpty) {
        await _deckTreeManager.setUserId(_cdm.userID);
      } else {
        log.severe('Cannot create deck: User not logged in');
        return;
      }
      
      await _deckTreeManager.createDeck(
        name: name,
        parentId: parentId,
        settings: settings,
      );
      
      // Auto-expand parent deck when creating subdeck
      if (parentId != null) {
        _expandedDeckIds.add(parentId);
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
    // Validate inputs
    if (deckId.isEmpty) {
      log.severe('Cannot delete deck with empty ID');
      return;
    }
    
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
    // Validate inputs
    if (deckId.isEmpty) {
      log.severe('Cannot rename deck with empty ID');
      return;
    }
    
    if (newName.isEmpty) {
      log.severe('Cannot rename deck to empty name');
      return;
    }
    
    try {
      await _deckTreeManager.renameDeck(deckId, newName);
      await loadDecks();
    } catch (e) {
      log.severe('Error renaming deck: $e');
    }
  }

  Future<void> moveDeck(String deckId, String? newParentId) async {
    // Validate inputs
    if (deckId.isEmpty) {
      log.severe('Cannot move deck with empty ID');
      return;
    }
    
    if (newParentId != null && newParentId.isEmpty) {
      log.severe('Cannot move deck to empty parent ID');
      return;
    }
    
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
  final Set<String> expandedDeckIds;

  DeckStateV2Loaded({
    required this.rootDecks,
    required this.allDecks,
    this.selectedDeckId,
    this.currentDeck,
    Set<String>? expandedDeckIds,
  }) : expandedDeckIds = expandedDeckIds ?? {};

  DeckStateV2Loaded copyWith({
    List<Deck>? rootDecks,
    List<Deck>? allDecks,
    String? selectedDeckId,
    Deck? currentDeck,
    Set<String>? expandedDeckIds,
  }) {
    return DeckStateV2Loaded(
      rootDecks: rootDecks ?? this.rootDecks,
      allDecks: allDecks ?? this.allDecks,
      selectedDeckId: selectedDeckId ?? this.selectedDeckId,
      currentDeck: currentDeck ?? this.currentDeck,
      expandedDeckIds: expandedDeckIds ?? this.expandedDeckIds,
    );
  }
}

class DeckStateV2Error extends DeckStateV2 {
  final String message;

  DeckStateV2Error(this.message);
}