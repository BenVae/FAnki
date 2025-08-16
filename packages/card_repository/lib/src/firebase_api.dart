import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:logging/logging.dart';
import 'models/anki_card.dart';
import 'models/single_card.dart';
import 'services/sm2_service.dart';

final _logger = Logger('FirebaseApi');

/// Firebase API for managing AnkiCards and Decks
class FirebaseApi {
  FirebaseFirestore firestore = FirebaseFirestore.instance;

  // ==================== User Settings ====================
  
  /// Get the last used deck from user settings
  Future<String> getLastDeckFromFireStore(String userID) async {
    try {
      if (userID.isEmpty) {
        _logger.warning('UserID is empty');
        return '';
      }

      DocumentSnapshot doc =
          await firestore.collection('users').doc(userID).get();
      if (doc.exists && doc.data() != null) {
        final data = doc.data() as Map<String, dynamic>;
        return data['lastDeck'] as String? ?? '';
      }
      return '';
    } catch (e) {
      _logger.info('Error getting lastDeck: $e');
      return '';
    }
  }

  /// Set the last used deck in user settings
  void setLastDeckInFireStore(String userID, String lastDeck) {
    if (userID.isEmpty) {
      _logger.severe('Error: userID is empty');
      return;
    }
    firestore.collection('users').doc(userID).set(
      {'lastDeck': lastDeck},
      SetOptions(merge: true),
    );
  }

  // ==================== Deck Management ====================
  
  /// Create a new deck
  Future<void> createDeckInFirestore(String userID, String deckId, {String? deckName}) async {
    try {
      if (userID.isEmpty || deckId.isEmpty) {
        throw ArgumentError('UserID and deckId cannot be empty');
      }

      await firestore
          .collection('users')
          .doc(userID)
          .collection('decks')
          .doc(deckId)
          .set({
            'id': deckId,
            'name': deckName ?? deckId,
            'createdAt': FieldValue.serverTimestamp(),
            'updatedAt': FieldValue.serverTimestamp(),
            'cardCount': 0,
            'newCount': 0,
            'reviewCount': 0,
            'learningCount': 0,
          });
      
      _logger.info('Deck $deckId created successfully');
    } catch (e) {
      _logger.severe('Error creating deck: $e');
      rethrow;
    }
  }

  /// Remove a deck and all its cards
  Future<void> removeDeckFromFirestore(String userID, String deckId) async {
    try {
      if (userID.isEmpty || deckId.isEmpty) {
        throw ArgumentError('UserID and deckId cannot be empty');
      }
      
      // Delete all cards in the deck
      final cardsSnapshot = await firestore
          .collection('users')
          .doc(userID)
          .collection('decks')
          .doc(deckId)
          .collection('cards')
          .get();
      
      for (final doc in cardsSnapshot.docs) {
        await doc.reference.delete();
      }
      
      // Delete the deck document
      await firestore
          .collection('users')
          .doc(userID)
          .collection('decks')
          .doc(deckId)
          .delete();
      
      _logger.info('Deck $deckId removed successfully');
    } catch (e) {
      _logger.severe('Error removing deck: $e');
      rethrow;
    }
  }

  /// Get all deck names for a user
  Future<List<String>> getAllDecknamesFromFirestore(String userID) async {
    try {
      if (userID.isEmpty) {
        _logger.warning('UserID is empty');
        return [];
      }

      final snapshot = await firestore
          .collection('users')
          .doc(userID)
          .collection('decks')
          .get();

      return snapshot.docs.map((doc) => doc.id).toList();
    } catch (e) {
      _logger.severe('Error getting deck names: $e');
      return [];
    }
  }

  /// Get deck metadata with card counts
  Future<Map<String, dynamic>?> getDeckMetadata(String userID, String deckId) async {
    try {
      if (userID.isEmpty || deckId.isEmpty) {
        _logger.warning('UserID or deckId is empty');
        return null;
      }

      final doc = await firestore
          .collection('users')
          .doc(userID)
          .collection('decks')
          .doc(deckId)
          .get();

      if (doc.exists) {
        return doc.data();
      }
      return null;
    } catch (e) {
      _logger.severe('Error getting deck metadata: $e');
      return null;
    }
  }

  /// Update deck statistics
  Future<void> updateDeckStatistics(String userID, String deckId) async {
    try {
      if (userID.isEmpty || deckId.isEmpty) {
        throw ArgumentError('UserID and deckId cannot be empty');
      }

      // Get all cards in the deck
      final cards = await getAllAnkiCardsFromDeck(userID, deckId);
      
      // Calculate statistics
      int newCount = 0;
      int learningCount = 0;
      int reviewCount = 0;
      int dueCount = 0;
      
      for (final card in cards) {
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
      
      // Update deck document
      await firestore
          .collection('users')
          .doc(userID)
          .collection('decks')
          .doc(deckId)
          .update({
            'cardCount': cards.length,
            'newCount': newCount,
            'learningCount': learningCount,
            'reviewCount': reviewCount,
            'dueCount': dueCount,
            'updatedAt': FieldValue.serverTimestamp(),
          });
      
      _logger.info('Updated statistics for deck $deckId');
    } catch (e) {
      _logger.severe('Error updating deck statistics: $e');
      rethrow;
    }
  }

  // ==================== AnkiCard CRUD Operations ====================
  
  /// Add a new AnkiCard to a deck
  Future<void> addAnkiCardToFirestore(String userID, String deckId, AnkiCard card) async {
    try {
      if (userID.isEmpty || deckId.isEmpty) {
        throw ArgumentError('UserID and deckId cannot be empty');
      }
      
      await firestore
          .collection('users')
          .doc(userID)
          .collection('decks')
          .doc(deckId)
          .collection('cards')
          .doc(card.id)
          .set(card.toFirestore());
      
      // Update deck statistics
      await updateDeckStatistics(userID, deckId);
      
      _logger.info('AnkiCard ${card.id} added to deck $deckId');
    } catch (e) {
      _logger.severe('Error adding AnkiCard: $e');
      rethrow;
    }
  }

  /// Get a single AnkiCard
  Future<AnkiCard?> getAnkiCard(String userID, String deckId, String cardId) async {
    try {
      if (userID.isEmpty || deckId.isEmpty || cardId.isEmpty) {
        _logger.warning('UserID, deckId, or cardId is empty');
        return null;
      }

      final doc = await firestore
          .collection('users')
          .doc(userID)
          .collection('decks')
          .doc(deckId)
          .collection('cards')
          .doc(cardId)
          .get();

      if (doc.exists && doc.data() != null) {
        return AnkiCard.fromFirestore(doc.data()!);
      }
      return null;
    } catch (e) {
      _logger.severe('Error getting AnkiCard: $e');
      return null;
    }
  }

  /// Update an existing AnkiCard
  Future<void> updateAnkiCard(String userID, String deckId, AnkiCard card) async {
    try {
      if (userID.isEmpty || deckId.isEmpty) {
        throw ArgumentError('UserID and deckId cannot be empty');
      }
      
      await firestore
          .collection('users')
          .doc(userID)
          .collection('decks')
          .doc(deckId)
          .collection('cards')
          .doc(card.id)
          .update(card.toFirestore());
      
      // Update deck statistics
      await updateDeckStatistics(userID, deckId);
      
      _logger.info('AnkiCard ${card.id} updated in deck $deckId');
    } catch (e) {
      _logger.severe('Error updating AnkiCard: $e');
      rethrow;
    }
  }

  /// Delete an AnkiCard
  Future<void> removeAnkiCardFromFirestore(String userID, String deckId, String cardId) async {
    try {
      if (userID.isEmpty || deckId.isEmpty || cardId.isEmpty) {
        throw ArgumentError('UserID, deckId, and cardId cannot be empty');
      }
      
      await firestore
          .collection('users')
          .doc(userID)
          .collection('decks')
          .doc(deckId)
          .collection('cards')
          .doc(cardId)
          .delete();
      
      // Update deck statistics
      await updateDeckStatistics(userID, deckId);
      
      _logger.info('AnkiCard $cardId removed from deck $deckId');
    } catch (e) {
      _logger.severe('Error removing AnkiCard: $e');
      rethrow;
    }
  }

  /// Get all AnkiCards from a deck
  Future<List<AnkiCard>> getAllAnkiCardsFromDeck(String userID, String deckId) async {
    try {
      if (userID.isEmpty || deckId.isEmpty) {
        _logger.warning('UserID or deckId is empty');
        return [];
      }

      final snapshot = await firestore
          .collection('users')
          .doc(userID)
          .collection('decks')
          .doc(deckId)
          .collection('cards')
          .get();

      final cards = <AnkiCard>[];
      for (final doc in snapshot.docs) {
        if (doc.data() != null) {
          try {
            cards.add(AnkiCard.fromFirestore(doc.data()));
          } catch (e) {
            _logger.warning('Error parsing card ${doc.id}: $e');
          }
        }
      }
      
      _logger.info('Retrieved ${cards.length} AnkiCards from deck $deckId');
      return cards;
    } catch (e) {
      _logger.severe('Error getting AnkiCards from deck: $e');
      return [];
    }
  }

  /// Get cards due for review
  Future<List<AnkiCard>> getDueCardsFromDeck(String userID, String deckId, {int? limit}) async {
    try {
      if (userID.isEmpty || deckId.isEmpty) {
        _logger.warning('UserID or deckId is empty');
        return [];
      }

      Query query = firestore
          .collection('users')
          .doc(userID)
          .collection('decks')
          .doc(deckId)
          .collection('cards')
          .where('suspended', isEqualTo: false)
          .where('dueDate', isLessThanOrEqualTo: DateTime.now().toIso8601String())
          .orderBy('dueDate');
      
      if (limit != null && limit > 0) {
        query = query.limit(limit);
      }

      final snapshot = await query.get();

      final cards = <AnkiCard>[];
      for (final doc in snapshot.docs) {
        if (doc.data() != null) {
          try {
            final data = doc.data() as Map<String, dynamic>;
            cards.add(AnkiCard.fromFirestore(data));
          } catch (e) {
            _logger.warning('Error parsing card ${doc.id}: $e');
          }
        }
      }
      
      _logger.info('Retrieved ${cards.length} due cards from deck $deckId');
      return cards;
    } catch (e) {
      _logger.severe('Error getting due cards: $e');
      return [];
    }
  }

  /// Get new cards from a deck
  Future<List<AnkiCard>> getNewCardsFromDeck(String userID, String deckId, {int? limit}) async {
    try {
      if (userID.isEmpty || deckId.isEmpty) {
        _logger.warning('UserID or deckId is empty');
        return [];
      }

      Query query = firestore
          .collection('users')
          .doc(userID)
          .collection('decks')
          .doc(deckId)
          .collection('cards')
          .where('state', isEqualTo: CardState.newCard.value)
          .where('suspended', isEqualTo: false)
          .orderBy('created');
      
      if (limit != null && limit > 0) {
        query = query.limit(limit);
      }

      final snapshot = await query.get();

      final cards = <AnkiCard>[];
      for (final doc in snapshot.docs) {
        if (doc.data() != null) {
          try {
            final data = doc.data() as Map<String, dynamic>;
            cards.add(AnkiCard.fromFirestore(data));
          } catch (e) {
            _logger.warning('Error parsing card ${doc.id}: $e');
          }
        }
      }
      
      _logger.info('Retrieved ${cards.length} new cards from deck $deckId');
      return cards;
    } catch (e) {
      _logger.severe('Error getting new cards: $e');
      return [];
    }
  }

  /// Process a card review and update it
  Future<void> processCardReview(
    String userID, 
    String deckId, 
    AnkiCard card, 
    ReviewGrade grade,
  ) async {
    try {
      if (userID.isEmpty || deckId.isEmpty) {
        throw ArgumentError('UserID and deckId cannot be empty');
      }
      
      // Use SM2Service to process the review
      final sm2Service = SM2Service();
      final updatedCard = sm2Service.processReview(card, grade);
      
      // Update the card in Firestore
      await updateAnkiCard(userID, deckId, updatedCard);
      
      _logger.info('Processed review for card ${card.id} with grade ${grade.name}');
    } catch (e) {
      _logger.severe('Error processing card review: $e');
      rethrow;
    }
  }

  // ==================== Batch Operations ====================
  
  /// Suspend multiple cards
  Future<void> suspendCards(String userID, String deckId, List<String> cardIds) async {
    try {
      if (userID.isEmpty || deckId.isEmpty || cardIds.isEmpty) {
        throw ArgumentError('UserID, deckId, and cardIds cannot be empty');
      }
      
      final batch = firestore.batch();
      
      for (final cardId in cardIds) {
        final ref = firestore
            .collection('users')
            .doc(userID)
            .collection('decks')
            .doc(deckId)
            .collection('cards')
            .doc(cardId);
        
        batch.update(ref, {'suspended': true, 'modified': DateTime.now().toIso8601String()});
      }
      
      await batch.commit();
      await updateDeckStatistics(userID, deckId);
      
      _logger.info('Suspended ${cardIds.length} cards in deck $deckId');
    } catch (e) {
      _logger.severe('Error suspending cards: $e');
      rethrow;
    }
  }

  /// Unsuspend multiple cards
  Future<void> unsuspendCards(String userID, String deckId, List<String> cardIds) async {
    try {
      if (userID.isEmpty || deckId.isEmpty || cardIds.isEmpty) {
        throw ArgumentError('UserID, deckId, and cardIds cannot be empty');
      }
      
      final batch = firestore.batch();
      
      for (final cardId in cardIds) {
        final ref = firestore
            .collection('users')
            .doc(userID)
            .collection('decks')
            .doc(deckId)
            .collection('cards')
            .doc(cardId);
        
        batch.update(ref, {'suspended': false, 'modified': DateTime.now().toIso8601String()});
      }
      
      await batch.commit();
      await updateDeckStatistics(userID, deckId);
      
      _logger.info('Unsuspended ${cardIds.length} cards in deck $deckId');
    } catch (e) {
      _logger.severe('Error unsuspending cards: $e');
      rethrow;
    }
  }

  /// Delete multiple cards
  Future<void> deleteCards(String userID, String deckId, List<String> cardIds) async {
    try {
      if (userID.isEmpty || deckId.isEmpty || cardIds.isEmpty) {
        throw ArgumentError('UserID, deckId, and cardIds cannot be empty');
      }
      
      final batch = firestore.batch();
      
      for (final cardId in cardIds) {
        final ref = firestore
            .collection('users')
            .doc(userID)
            .collection('decks')
            .doc(deckId)
            .collection('cards')
            .doc(cardId);
        
        batch.delete(ref);
      }
      
      await batch.commit();
      await updateDeckStatistics(userID, deckId);
      
      _logger.info('Deleted ${cardIds.length} cards from deck $deckId');
    } catch (e) {
      _logger.severe('Error deleting cards: $e');
      rethrow;
    }
  }

  // ==================== Stream Methods ====================
  
  /// Stream of AnkiCards for real-time updates
  Stream<List<AnkiCard>> streamAnkiCardsFromDeck(String userID, String deckId) {
    if (userID.isEmpty || deckId.isEmpty) {
      _logger.warning('UserID or deckId is empty');
      return Stream.value([]);
    }

    return firestore
        .collection('users')
        .doc(userID)
        .collection('decks')
        .doc(deckId)
        .collection('cards')
        .snapshots()
        .map((snapshot) {
          final cards = <AnkiCard>[];
          for (final doc in snapshot.docs) {
            if (doc.data() != null) {
              try {
                cards.add(AnkiCard.fromFirestore(doc.data()));
              } catch (e) {
                _logger.warning('Error parsing card ${doc.id}: $e');
              }
            }
          }
          return cards;
        });
  }

  /// Stream of deck metadata for real-time updates
  Stream<Map<String, dynamic>?> streamDeckMetadata(String userID, String deckId) {
    if (userID.isEmpty || deckId.isEmpty) {
      _logger.warning('UserID or deckId is empty');
      return Stream.value(null);
    }

    return firestore
        .collection('users')
        .doc(userID)
        .collection('decks')
        .doc(deckId)
        .snapshots()
        .map((snapshot) {
          if (snapshot.exists && snapshot.data() != null) {
            return snapshot.data();
          }
          return null;
        });
  }

  // ==================== Legacy Compatibility Methods ====================
  // These methods provide backward compatibility for CardDeckManager and DeckTreeManager
  // They will be removed once the app fully transitions to AnkiCardManager
  
  /// Legacy V2 method: Get all decks with metadata
  Future<List<Map<String, dynamic>>> getAllDecksFromFirestore(String userID) async {
    try {
      if (userID.isEmpty) {
        _logger.warning('UserID is empty');
        return [];
      }
      
      final snapshot = await firestore
          .collection('users')
          .doc(userID)
          .collection('decks')
          .get();
      
      return snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return data;
      }).toList();
    } catch (e) {
      _logger.severe('Error getting decks: $e');
      return [];
    }
  }

  /// Legacy V2 method: Create deck with metadata
  Future<void> createDeckInFirestoreV2(String userID, Map<String, dynamic> deckData) async {
    try {
      if (userID.isEmpty) {
        throw ArgumentError('userID cannot be empty');
      }
      
      final deckId = deckData['id'] as String?;
      if (deckId == null || deckId.isEmpty) {
        throw ArgumentError('Deck ID cannot be null or empty');
      }
      
      await firestore
          .collection('users')
          .doc(userID)
          .collection('decks')
          .doc(deckId)
          .set(deckData);
    } catch (e) {
      _logger.severe('Error creating deck: $e');
      rethrow;
    }
  }

  /// Legacy V2 method: Update deck metadata
  Future<void> updateDeckInFirestore(String userID, String deckId, Map<String, dynamic> deckData) async {
    try {
      if (userID.isEmpty || deckId.isEmpty) {
        throw ArgumentError('userID and deckId cannot be empty');
      }
      
      await firestore
          .collection('users')
          .doc(userID)
          .collection('decks')
          .doc(deckId)
          .update(deckData);
    } catch (e) {
      _logger.severe('Error updating deck: $e');
      rethrow;
    }
  }

  /// Legacy V2 method: Delete deck
  Future<void> deleteDeckFromFirestore(String userID, String deckId) async {
    try {
      if (userID.isEmpty || deckId.isEmpty) {
        throw ArgumentError('userID and deckId cannot be empty');
      }
      
      // Use the new method
      await removeDeckFromFirestore(userID, deckId);
    } catch (e) {
      _logger.severe('Error deleting deck: $e');
      rethrow;
    }
  }
  
  /// Legacy method: Get all SingleCards from a deck (converts from AnkiCards)
  Future<List<SingleCard>> getAllCardsOfDeckFromFirestore(String userID, String deckName) async {
    _logger.warning('Using legacy method getAllCardsOfDeckFromFirestore - consider migrating to AnkiCards');
    
    try {
      // Get AnkiCards and convert them to SingleCards
      final ankiCards = await getAllAnkiCardsFromDeck(userID, deckName);
      final singleCards = ankiCards.map((ankiCard) => ankiCard.toSingleCard()).toList();
      
      _logger.info('Converted ${singleCards.length} AnkiCards to SingleCards for compatibility');
      return singleCards;
    } catch (e) {
      _logger.severe('Error in legacy getAllCardsOfDeckFromFirestore: $e');
      return [];
    }
  }

  /// Legacy method: Add a SingleCard (converts to AnkiCard)
  void addCardToFirestore(String userID, String currentDeckName, SingleCard card) {
    _logger.warning('Using legacy method addCardToFirestore - consider migrating to AnkiCards');
    
    // Convert SingleCard to AnkiCard and add it
    final ankiCard = AnkiCard.fromSingleCard(card, currentDeckName);
    addAnkiCardToFirestore(userID, currentDeckName, ankiCard).catchError((e) {
      _logger.severe('Error in legacy addCardToFirestore: $e');
    });
  }

  /// Legacy method: Remove a SingleCard
  void removeCardFromFirestore(String userID, String currentDeckName, SingleCard card) {
    _logger.warning('Using legacy method removeCardFromFirestore - consider migrating to AnkiCards');
    
    removeAnkiCardFromFirestore(userID, currentDeckName, card.id).catchError((e) {
      _logger.severe('Error in legacy removeCardFromFirestore: $e');
    });
  }

  /// Legacy method: Update card difficulty (used by learning system)
  void updateDifficultyOfCardInFirestore(String userID, String currentDeckName, SingleCard card) {
    _logger.warning('Using legacy method updateDifficultyOfCardInFirestore - consider using SM-2 review system');
    
    // Convert difficulty to ease factor and update
    final ankiCard = AnkiCard.fromSingleCard(card, currentDeckName);
    updateAnkiCard(userID, currentDeckName, ankiCard).catchError((e) {
      _logger.severe('Error in legacy updateDifficultyOfCardInFirestore: $e');
    });
  }
}