import 'package:cloud_firestore/cloud_firestore.dart';
import 'models/single_card.dart';

class FirebaseApi {
  FirebaseFirestore firestore = FirebaseFirestore.instance;

  Future<String> getLastDeckFromFireStore(String userID) async {
    try {
      if (userID.isEmpty) {
        print('Error: userID is empty');
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
      print('Error getting lastDeck: $e');
      return '';
    }
  }

  void setLastDeckInFireStore(String userID, String lastDeck) {
    if (userID.isEmpty) {
      print('Error: userID is empty');
      return;
    }
    firestore.collection('users').doc(userID).set({'lastDeck': lastDeck});
  }

  void createDeckInFirestore(String userID, String deckName) {
    if (userID.isEmpty || deckName.isEmpty) {
      print('Error: userID or deckName is empty');
      return;
    }
    firestore
        .collection('users')
        .doc(userID)
        .collection('decks')
        .doc(deckName)
        .set({'updatedOn': FieldValue.serverTimestamp()})
        .then((value) => print('Deck $deckName created.'))
        .onError((error, stackTrace) {
          print('Deck $deckName could not be created. $error');
        });
  }

  void removeDeckFromFirestore(String userID, String deckName) {
    // Validate inputs
    if (userID.isEmpty) {
      print('Error: userID is empty');
      return;
    }
    if (deckName.isEmpty) {
      print('Error: deckName is empty');
      return;
    }
    
    firestore
        .collection('users')
        .doc(userID)
        .collection('decks')
        .doc(deckName)
        .collection('cards')
        .get()
        .then((snapshot) {
      for (DocumentSnapshot ds in snapshot.docs) {
        ds.reference.delete();
      }
    }).onError((error, stackTrace) => null);

    firestore
        .collection('users')
        .doc(userID)
        .collection('decks')
        .doc(deckName)
        .delete()
        .then((value) => print('Deck removed succesfully.'))
        .onError((error, stackTrace) {
      print('Deck $deckName could not be removed.');
    });
  }

  void addCardToFirestore(
      String userID, String currentDeckName, SingleCard card) {
    // Validate inputs
    if (userID.isEmpty) {
      print('Error: userID is empty');
      return;
    }
    if (currentDeckName.isEmpty) {
      print('Error: currentDeckName is empty');
      return;
    }
    if (card.id.isEmpty) {
      print('Error: card.id is empty');
      return;
    }
    
    var userDoc = firestore.collection('users').doc(userID);
    var deckDoc = userDoc.collection('decks').doc(currentDeckName);
    deckDoc.collection('cards').doc(card.id).set(card.cardToMap());
  }

  void addCardToFirestoreWithoutSingleCard(
      String userID, String currentDeckName, String question, String answer) {
    SingleCard sc = SingleCard(
        deckName: currentDeckName, questionText: question, answerText: answer);
    var userDoc = firestore.collection('users').doc(userID);
    var deckDoc = userDoc.collection('decks').doc(currentDeckName);
    deckDoc.collection('cards').doc(sc.id).set(sc.cardToMap());
  }

  void removeCardFromFirestore(
      String userID, String currentDeckName, SingleCard card) {
    // Validate inputs
    if (userID.isEmpty) {
      print('Error: userID is empty');
      return;
    }
    if (currentDeckName.isEmpty) {
      print('Error: currentDeckName is empty');
      return;
    }
    if (card.id.isEmpty) {
      print('Error: card.id is empty');
      return;
    }
    
    final deckCollection = firestore
        .collection('users')
        .doc(userID)
        .collection('decks')
        .doc(currentDeckName)
        .collection('cards');
    deckCollection.doc(card.id).delete();
  }

  void removeCardFromFirestoreByID(
      String userID, String currentDeckName, String id) {
    // Validate inputs
    if (userID.isEmpty) {
      print('Error: userID is empty');
      return;
    }
    if (currentDeckName.isEmpty) {
      print('Error: currentDeckName is empty');
      return;
    }
    if (id.isEmpty) {
      print('Error: card id is empty');
      return;
    }
    
    final deckCollection = firestore
        .collection('users')
        .doc(userID)
        .collection('decks')
        .doc(currentDeckName)
        .collection('cards');
    deckCollection.doc(id).delete();
  }

  Future<List<SingleCard>> getAllCardsOfDeckFromFirestore(
      String userID, String deckName) async {
    List<SingleCard> deck = [];

    // Validate inputs
    if (userID.isEmpty || deckName.isEmpty) {
      print('Error: userID or deckName is empty');
      return deck;
    }

    try {
      var userDoc = firestore.collection('users').doc(userID);
      var docRef =
          userDoc.collection('decks').doc(deckName).collection('cards');
      await docRef.get().then(
        (QuerySnapshot querySnapshot) {
          for (var doc in querySnapshot.docs) {
            if (doc.exists) {
              final cardMap = doc.data() as Map<String, dynamic>;
              SingleCard card = SingleCard.fromMap(cardMap);
              deck.add(card);
            } else {
              print('Document does not exist');
            }
          }
        },
        onError: (e) => print('Error getting document: $e'),
      );
      print('Ending of getAllCardsOfDeckFromFirestore');
    } catch (e) {
      print('Error in getAllCardsOfDeckFromFirestore: $e');
    }
    return deck;
  }

  Future<List<SingleCard>> getAllCardsOfDeckFromFirestoreAndListen(
      String userID, String currentDeckName) async {
    List<SingleCard> deck = [];

    var userDoc = firestore.collection('users').doc(userID);
    var docRef =
        userDoc.collection('decks').doc(currentDeckName).collection('cards');

    docRef.snapshots().listen((QuerySnapshot querySnapshot) {
      for (var doc in querySnapshot.docs) {
        SingleCard sc = SingleCard.fromMap(doc as Map<String, dynamic>);
        deck.add(sc);
      }
    });
    return deck;
  }

  Future<List<String>> getAllDecknamesFromFirestore(String userID) async {
    List<String> deckNames = [];

    // Validate input
    if (userID.isEmpty) {
      print('Error: userID is empty');
      return deckNames;
    }

    try {
      var userDoc = firestore.collection('users').doc(userID);
      var docRef = userDoc.collection('decks');

      await docRef.get().then(
        (QuerySnapshot querySnapshot) {
          for (var doc in querySnapshot.docs) {
            if (doc.exists) {
              if (!deckNames.contains(doc.id)) {
                deckNames.add(doc.id);
              }
            } else {
              print('Document does not exist');
            }
          }
        },
        onError: (e) => print('Error getting document: $e'),
      );
    } catch (e) {
      print('Error in getAllDecknamesFromFirestore: $e');
    }
    return deckNames;
  }

  void updateDifficultyOfCardInFirestore(
      String userID, String currentDeckName, SingleCard card) {
    firestore
        .collection('users')
        .doc(userID)
        .collection('decks')
        .doc(currentDeckName)
        .collection('cards')
        .doc(card.id)
        .set(card.cardToMap())
        .then((value) => print('Difficulty has been updated'))
        .onError((error, stackTrace) =>
            print('Update of difficulty was not successful. $error'));
  }

  // New methods for hierarchical deck support
  
  /// Get all decks with their metadata
  Future<List<Map<String, dynamic>>> getAllDecksFromFirestore(String userID) async {
    try {
      // Validate input
      if (userID.isEmpty) {
        print('Error: userID is empty');
        return [];
      }
      
      final snapshot = await firestore
          .collection('users')
          .doc(userID)
          .collection('decks_v2')
          .get();
      
      return snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return data;
      }).toList();
    } catch (e) {
      print('Error getting decks: $e');
      return [];
    }
  }

  /// Create a new deck with v2 structure
  Future<void> createDeckInFirestoreV2(String userID, Map<String, dynamic> deckData) async {
    try {
      // Validate inputs
      if (userID.isEmpty) {
        throw ArgumentError('userID cannot be empty');
      }
      
      final deckId = deckData['id'] as String?;
      if (deckId == null || deckId.isEmpty) {
        throw ArgumentError('Deck ID cannot be null or empty');
      }
      
      final deckName = deckData['name'] as String?;
      if (deckName == null || deckName.isEmpty) {
        throw ArgumentError('Deck name cannot be null or empty');
      }
      
      await firestore
          .collection('users')
          .doc(userID)
          .collection('decks_v2')
          .doc(deckId)
          .set(deckData);
    } catch (e) {
      print('Error creating deck: $e');
      throw e;
    }
  }

  /// Update deck metadata
  Future<void> updateDeckInFirestore(String userID, String deckId, Map<String, dynamic> deckData) async {
    try {
      // Validate inputs
      if (userID.isEmpty) {
        throw ArgumentError('userID cannot be empty');
      }
      
      if (deckId.isEmpty) {
        throw ArgumentError('deckId cannot be empty');
      }
      
      await firestore
          .collection('users')
          .doc(userID)
          .collection('decks_v2')
          .doc(deckId)
          .update(deckData);
    } catch (e) {
      print('Error updating deck: $e');
      throw e;
    }
  }

  /// Delete a deck
  Future<void> deleteDeckFromFirestore(String userID, String deckId) async {
    try {
      // Validate inputs
      if (userID.isEmpty) {
        throw ArgumentError('userID cannot be empty');
      }
      
      if (deckId.isEmpty) {
        throw ArgumentError('deckId cannot be empty');
      }
      
      // Delete all cards in the deck first
      final cardsSnapshot = await firestore
          .collection('users')
          .doc(userID)
          .collection('decks_v2')
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
          .collection('decks_v2')
          .doc(deckId)
          .delete();
    } catch (e) {
      print('Error deleting deck: $e');
      throw e;
    }
  }
}
