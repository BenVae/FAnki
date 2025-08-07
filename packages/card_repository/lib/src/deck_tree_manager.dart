import 'models/deck.dart';
import 'firebase_api.dart';

/// Manages the hierarchical deck structure
class DeckTreeManager {
  final FirebaseApi _firebaseApi = FirebaseApi();
  final Map<String, Deck> _decksById = {};
  List<Deck> _rootDecks = [];
  String _userId = '';

  /// Get all root decks (decks without parents)
  List<Deck> get rootDecks => _rootDecks;

  /// Get all decks as a flat list
  List<Deck> get allDecks => _decksById.values.toList();

  /// Get a deck by ID
  Deck? getDeckById(String id) => _decksById[id];

  /// Set the user ID and load decks
  Future<void> setUserId(String userId) async {
    _userId = userId.toLowerCase();
    if (_userId.isNotEmpty) {
      await loadDecks();
    }
  }

  /// Load all decks from Firestore and build tree structure
  Future<void> loadDecks() async {
    try {
      final decksData = await _firebaseApi.getAllDecksFromFirestore(_userId);
      _decksById.clear();
      _rootDecks.clear();

      // First pass: create all deck objects
      for (final deckData in decksData) {
        final deck = Deck.fromMap(deckData);
        _decksById[deck.id] = deck;
      }

      // Second pass: build tree structure
      for (final deck in _decksById.values) {
        if (deck.parentId == null) {
          _rootDecks.add(deck);
        } else {
          final parent = _decksById[deck.parentId!];
          if (parent != null) {
            parent.children.add(deck);
          }
        }
      }

      // Sort decks at each level
      _sortDecksRecursively(_rootDecks);
    } catch (e) {
      throw Exception('Failed to load decks: $e');
    }
  }

  /// Sort decks alphabetically at each level
  void _sortDecksRecursively(List<Deck> decks) {
    decks.sort((a, b) => a.name.compareTo(b.name));
    for (final deck in decks) {
      if (deck.children.isNotEmpty) {
        _sortDecksRecursively(deck.children);
      }
    }
  }

  /// Create a new deck
  Future<Deck> createDeck({
    required String name,
    String? parentId,
    DeckSettings? settings,
  }) async {
    // Build the path
    String path = name;
    int level = 0;
    
    if (parentId != null) {
      final parent = _decksById[parentId];
      if (parent != null) {
        path = '${parent.path}::$name';
        level = parent.level + 1;
        // Inherit settings from parent if not provided
        settings ??= parent.settings;
      }
    }

    final deck = Deck(
      name: name,
      parentId: parentId,
      path: path,
      level: level,
      settings: settings,
    );

    // Save to Firestore
    await _firebaseApi.createDeckInFirestoreV2(_userId, deck.toMap());

    // Update local cache
    _decksById[deck.id] = deck;
    
    if (parentId == null) {
      _rootDecks.add(deck);
    } else {
      final parent = _decksById[parentId];
      if (parent != null) {
        parent.children.add(deck);
      }
    }

    _sortDecksRecursively(_rootDecks);
    return deck;
  }

  /// Delete a deck and optionally its subdecks
  Future<void> deleteDeck(String deckId, {bool deleteSubdecks = false}) async {
    final deck = _decksById[deckId];
    if (deck == null) return;

    if (deleteSubdecks) {
      // Delete all subdecks recursively
      await _deleteDecksRecursively(deck);
    } else if (deck.children.isNotEmpty) {
      // Move children to parent or make them root decks
      for (final child in deck.children) {
        child.parentId == deck.parentId;
        if (deck.parentId == null) {
          _rootDecks.add(child);
        } else {
          final parent = _decksById[deck.parentId!];
          parent?.children.add(child);
        }
        
        // Update path and level for child and its descendants
        await _updateDeckPath(child, deck.parentId);
      }
    }

    // Remove from parent's children or root decks
    if (deck.parentId == null) {
      _rootDecks.remove(deck);
    } else {
      final parent = _decksById[deck.parentId!];
      parent?.children.remove(deck);
    }

    // Delete from Firestore and local cache
    await _firebaseApi.deleteDeckFromFirestore(_userId, deckId);
    _decksById.remove(deckId);
  }

  /// Delete deck and all its subdecks recursively
  Future<void> _deleteDecksRecursively(Deck deck) async {
    // Delete all children first
    for (final child in List.from(deck.children)) {
      await _deleteDecksRecursively(child);
    }
    
    // Delete the deck itself
    await _firebaseApi.deleteDeckFromFirestore(_userId, deck.id);
    _decksById.remove(deck.id);
  }

  /// Update deck path and level after moving
  Future<void> _updateDeckPath(Deck deck, String? newParentId) async {
    String newPath = deck.name;
    int newLevel = 0;
    
    if (newParentId != null) {
      final parent = _decksById[newParentId];
      if (parent != null) {
        newPath = '${parent.path}::${deck.name}';
        newLevel = parent.level + 1;
      }
    }

    // Update the deck
    final updatedDeck = deck.copyWith(
      parentId: newParentId,
      path: newPath,
      level: newLevel,
      updatedAt: DateTime.now(),
    );
    
    _decksById[deck.id] = updatedDeck;
    await _firebaseApi.updateDeckInFirestore(_userId, deck.id, updatedDeck.toMap());

    // Update all children recursively
    for (final child in deck.children) {
      await _updateDeckPath(child, deck.id);
    }
  }

  /// Move a deck to a new parent
  Future<void> moveDeck(String deckId, String? newParentId) async {
    final deck = _decksById[deckId];
    if (deck == null) return;

    // Prevent moving a deck to its own subdeck
    if (newParentId != null && _isDescendantOf(newParentId, deckId)) {
      throw Exception('Cannot move a deck to its own subdeck');
    }

    // Remove from current parent
    if (deck.parentId == null) {
      _rootDecks.remove(deck);
    } else {
      final oldParent = _decksById[deck.parentId!];
      oldParent?.children.remove(deck);
    }

    // Add to new parent
    if (newParentId == null) {
      _rootDecks.add(deck);
    } else {
      final newParent = _decksById[newParentId];
      newParent?.children.add(deck);
    }

    // Update path and level
    await _updateDeckPath(deck, newParentId);
    _sortDecksRecursively(_rootDecks);
  }

  /// Check if a deck is a descendant of another deck
  bool _isDescendantOf(String potentialDescendantId, String ancestorId) {
    final deck = _decksById[potentialDescendantId];
    if (deck == null) return false;
    
    if (deck.parentId == null) return false;
    if (deck.parentId == ancestorId) return true;
    
    return _isDescendantOf(deck.parentId!, ancestorId);
  }

  /// Rename a deck
  Future<void> renameDeck(String deckId, String newName) async {
    final deck = _decksById[deckId];
    if (deck == null) return;

    // Update path
    String newPath = newName;
    if (deck.parentId != null) {
      final parent = _decksById[deck.parentId!];
      if (parent != null) {
        newPath = '${parent.path}::$newName';
      }
    }

    // Update the deck
    final updatedDeck = deck.copyWith(
      name: newName,
      path: newPath,
      updatedAt: DateTime.now(),
    );
    
    _decksById[deckId] = updatedDeck;
    await _firebaseApi.updateDeckInFirestore(_userId, deckId, updatedDeck.toMap());

    // Update paths of all children
    for (final child in deck.children) {
      await _updateDeckPath(child, deck.id);
    }
  }

  /// Get the full path of a deck as a list
  List<String> getDeckPath(String deckId) {
    final deck = _decksById[deckId];
    if (deck == null) return [];
    
    return deck.path.split('::');
  }

  /// Get all ancestor decks of a given deck
  List<Deck> getAncestors(String deckId) {
    final ancestors = <Deck>[];
    Deck? current = _decksById[deckId];
    
    while (current?.parentId != null) {
      final parent = _decksById[current!.parentId!];
      if (parent != null) {
        ancestors.add(parent);
        current = parent;
      } else {
        break;
      }
    }
    
    return ancestors.reversed.toList();
  }

  /// Get total card count for a deck including all subdecks
  int getTotalCardCount(String deckId) {
    final deck = _decksById[deckId];
    return deck?.totalCards ?? 0;
  }

  /// Update card counts for a deck
  Future<void> updateDeckCardCounts(
    String deckId, {
    int? cardCount,
    int? newCards,
    int? learningCards,
    int? reviewCards,
  }) async {
    final deck = _decksById[deckId];
    if (deck == null) return;

    final updatedDeck = deck.copyWith(
      cardCount: cardCount ?? deck.cardCount,
      newCards: newCards ?? deck.newCards,
      learningCards: learningCards ?? deck.learningCards,
      reviewCards: reviewCards ?? deck.reviewCards,
      updatedAt: DateTime.now(),
    );

    _decksById[deckId] = updatedDeck;
    await _firebaseApi.updateDeckInFirestore(_userId, deckId, updatedDeck.toMap());
  }
}