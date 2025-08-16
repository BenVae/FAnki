import 'package:logging/logging.dart';
import '../firebase_api.dart';
import '../models/anki_card.dart';
import 'sm2_service.dart';

final _logger = Logger('CardScheduler');

/// Configuration settings for deck study behavior
class StudySettings {
  /// Maximum number of new cards to introduce per day
  final int newCardsPerDay;
  
  /// Maximum number of cards to review per day
  final int maxReviewsPerDay;
  
  /// Learning steps in minutes for new cards
  final List<int> learningSteps;
  
  /// Relearning steps in minutes for lapsed cards
  final List<int> relearningSteps;
  
  /// Initial ease factor for new cards
  final double initialEase;
  
  /// Multiplier for hard answers
  final double hardMultiplier;
  
  /// Bonus multiplier for easy answers
  final double easyBonus;
  
  /// Global interval modifier
  final double intervalModifier;
  
  /// Whether to show answer timer during reviews
  final bool showAnswerTimer;
  
  /// Whether to show remaining card count
  final bool showRemainingCount;

  const StudySettings({
    this.newCardsPerDay = 20,
    this.maxReviewsPerDay = 200,
    this.learningSteps = const [1, 10],
    this.relearningSteps = const [10],
    this.initialEase = 2.5,
    this.hardMultiplier = 1.2,
    this.easyBonus = 1.3,
    this.intervalModifier = 1.0,
    this.showAnswerTimer = true,
    this.showRemainingCount = true,
  });

  /// Create StudySettings from map data
  factory StudySettings.fromMap(Map<String, dynamic> map) {
    return StudySettings(
      newCardsPerDay: map['newCardsPerDay'] as int? ?? 20,
      maxReviewsPerDay: map['maxReviewsPerDay'] as int? ?? 200,
      learningSteps: (map['learningSteps'] as List<dynamic>?)
          ?.map((step) => step as int)
          .toList() ?? const [1, 10],
      relearningSteps: (map['relearningSteps'] as List<dynamic>?)
          ?.map((step) => step as int)
          .toList() ?? const [10],
      initialEase: (map['initialEase'] as num?)?.toDouble() ?? 2.5,
      hardMultiplier: (map['hardMultiplier'] as num?)?.toDouble() ?? 1.2,
      easyBonus: (map['easyBonus'] as num?)?.toDouble() ?? 1.3,
      intervalModifier: (map['intervalModifier'] as num?)?.toDouble() ?? 1.0,
      showAnswerTimer: map['showAnswerTimer'] as bool? ?? true,
      showRemainingCount: map['showRemainingCount'] as bool? ?? true,
    );
  }

  /// Convert StudySettings to map
  Map<String, dynamic> toMap() {
    return {
      'newCardsPerDay': newCardsPerDay,
      'maxReviewsPerDay': maxReviewsPerDay,
      'learningSteps': learningSteps,
      'relearningSteps': relearningSteps,
      'initialEase': initialEase,
      'hardMultiplier': hardMultiplier,
      'easyBonus': easyBonus,
      'intervalModifier': intervalModifier,
      'showAnswerTimer': showAnswerTimer,
      'showRemainingCount': showRemainingCount,
    };
  }

  /// Create a copy with updated fields
  StudySettings copyWith({
    int? newCardsPerDay,
    int? maxReviewsPerDay,
    List<int>? learningSteps,
    List<int>? relearningSteps,
    double? initialEase,
    double? hardMultiplier,
    double? easyBonus,
    double? intervalModifier,
    bool? showAnswerTimer,
    bool? showRemainingCount,
  }) {
    return StudySettings(
      newCardsPerDay: newCardsPerDay ?? this.newCardsPerDay,
      maxReviewsPerDay: maxReviewsPerDay ?? this.maxReviewsPerDay,
      learningSteps: learningSteps ?? this.learningSteps,
      relearningSteps: relearningSteps ?? this.relearningSteps,
      initialEase: initialEase ?? this.initialEase,
      hardMultiplier: hardMultiplier ?? this.hardMultiplier,
      easyBonus: easyBonus ?? this.easyBonus,
      intervalModifier: intervalModifier ?? this.intervalModifier,
      showAnswerTimer: showAnswerTimer ?? this.showAnswerTimer,
      showRemainingCount: showRemainingCount ?? this.showRemainingCount,
    );
  }

  @override
  String toString() {
    return 'StudySettings(newCardsPerDay: $newCardsPerDay, maxReviewsPerDay: $maxReviewsPerDay, learningSteps: $learningSteps, relearningSteps: $relearningSteps)';
  }
}

/// A study session containing organized queues of cards for review
class StudySession {
  /// Cards currently in learning steps (highest priority)
  final List<AnkiCard> learningCards;
  
  /// Cards due for review
  final List<AnkiCard> reviewCards;
  
  /// New cards available for study
  final List<AnkiCard> newCards;
  
  /// Settings for this study session
  final StudySettings settings;
  
  /// Current position in the session
  int _currentIndex = 0;
  
  /// Whether the session has been started
  bool _started = false;

  StudySession({
    required this.learningCards,
    required this.reviewCards,
    required this.newCards,
    required this.settings,
  });

  /// Get the next card to study based on priority order
  /// Priority: Learning cards > Review cards > New cards
  AnkiCard? getNextCard() {
    if (!_started) {
      _started = true;
      _currentIndex = 0;
    }

    // Create combined queue in priority order
    final allCards = <AnkiCard>[];
    allCards.addAll(learningCards);
    allCards.addAll(reviewCards);
    allCards.addAll(newCards);

    if (_currentIndex >= allCards.length) {
      return null; // Session complete
    }

    return allCards[_currentIndex++];
  }

  /// Get the current card without advancing
  AnkiCard? getCurrentCard() {
    final allCards = <AnkiCard>[];
    allCards.addAll(learningCards);
    allCards.addAll(reviewCards);
    allCards.addAll(newCards);

    if (_currentIndex >= allCards.length) {
      return null;
    }

    return allCards[_currentIndex];
  }

  /// Check if there are more cards to study
  bool get hasMoreCards {
    final totalCards = learningCards.length + reviewCards.length + newCards.length;
    return _currentIndex < totalCards;
  }

  /// Get total number of cards in session
  int get totalCards => learningCards.length + reviewCards.length + newCards.length;

  /// Get number of cards remaining
  int get remainingCards => totalCards - _currentIndex;

  /// Get study progress as percentage (0.0 to 1.0)
  double get progress {
    if (totalCards == 0) return 1.0;
    return _currentIndex / totalCards;
  }

  /// Reset session to beginning
  void reset() {
    _currentIndex = 0;
    _started = false;
  }

  /// Get session statistics
  Map<String, int> getStats() {
    return {
      'learning': learningCards.length,
      'review': reviewCards.length,
      'new': newCards.length,
      'total': totalCards,
      'remaining': remainingCards,
      'completed': _currentIndex,
    };
  }

  @override
  String toString() {
    return 'StudySession(learning: ${learningCards.length}, review: ${reviewCards.length}, new: ${newCards.length}, progress: ${(_currentIndex / totalCards * 100).toStringAsFixed(1)}%)';
  }
}

/// Manages card scheduling and review queues for the Anki system
class CardScheduler {
  // ignore: unused_field
  final FirebaseApi _firebaseApi; // TODO: Will be used when AnkiCard Firebase support is implemented
  final SM2Service _sm2Service;

  CardScheduler(this._firebaseApi) : _sm2Service = SM2Service();

  /// Get cards due for review from a specific deck
  /// 
  /// Returns cards that are due for review, sorted by overdue duration
  /// (most overdue first). Respects the daily review limit.
  Future<List<AnkiCard>> getReviewQueue(String userID, String deckId, int limit) async {
    try {
      _logger.info('Getting review queue for deck $deckId with limit $limit');
      
      if (userID.isEmpty || deckId.isEmpty) {
        _logger.warning('UserID or Deck ID is empty');
        return [];
      }

      if (limit <= 0) {
        _logger.warning('Invalid limit: $limit');
        return [];
      }

      // Get all cards from the deck
      final allCards = await _firebaseApi.getAllAnkiCardsFromDeck(userID, deckId);
      
      final now = DateTime.now();
      final reviewCards = allCards
          .where((card) => card.isReview && isCardDue(card))
          .toList();

      // Sort by overdue duration (most overdue first)
      reviewCards.sort((a, b) {
        final aDaysOverdue = now.difference(a.dueDate).inDays;
        final bDaysOverdue = now.difference(b.dueDate).inDays;
        return bDaysOverdue.compareTo(aDaysOverdue);
      });

      final result = reviewCards.take(limit).toList();
      _logger.info('Found ${result.length} review cards for deck $deckId');
      return result;
    } catch (e) {
      _logger.severe('Error getting review queue: $e');
      return [];
    }
  }

  /// Get new cards from a specific deck
  /// 
  /// Returns new cards respecting the daily limit, sorted by creation date
  /// (oldest first).
  Future<List<AnkiCard>> getNewCards(String userID, String deckId, int limit) async {
    try {
      _logger.info('Getting new cards for deck $deckId with limit $limit');
      
      if (userID.isEmpty || deckId.isEmpty) {
        _logger.warning('UserID or Deck ID is empty');
        return [];
      }

      if (limit <= 0) {
        _logger.warning('Invalid limit: $limit');
        return [];
      }

      // Get all cards from the deck
      final allCards = await _firebaseApi.getAllAnkiCardsFromDeck(userID, deckId);
      
      final newCards = allCards
          .where((card) => card.isNew && !card.suspended)
          .toList();

      // Sort by creation date (oldest first)
      newCards.sort((a, b) => a.created.compareTo(b.created));

      final result = newCards.take(limit).toList();
      _logger.info('Found ${result.length} new cards for deck $deckId');
      return result;
    } catch (e) {
      _logger.severe('Error getting new cards: $e');
      return [];
    }
  }

  /// Get cards currently in learning steps
  /// 
  /// Returns cards in learning or relearning state that are due,
  /// sorted by due time.
  Future<List<AnkiCard>> getLearningCards(String userID, String deckId) async {
    try {
      _logger.info('Getting learning cards for deck $deckId');
      
      if (userID.isEmpty || deckId.isEmpty) {
        _logger.warning('UserID or Deck ID is empty');
        return [];
      }

      // Get all cards from the deck
      final allCards = await _firebaseApi.getAllAnkiCardsFromDeck(userID, deckId);
      
      final learningCards = allCards
          .where((card) => card.isLearning && isCardDue(card) && !card.suspended)
          .toList();

      // Sort by due time (earliest first)
      learningCards.sort((a, b) => a.dueDate.compareTo(b.dueDate));

      _logger.info('Found ${learningCards.length} learning cards for deck $deckId');
      return learningCards;
    } catch (e) {
      _logger.severe('Error getting learning cards: $e');
      return [];
    }
  }

  /// Check if a card is due for review
  /// 
  /// A card is due if:
  /// - It's not suspended
  /// - Current time is at or after the due date
  bool isCardDue(AnkiCard card) {
    if (card.suspended) {
      return false;
    }

    final now = DateTime.now();
    return now.isAfter(card.dueDate) || now.isAtSameMomentAs(card.dueDate);
  }

  /// Create a study session for a deck with mixed card types
  /// 
  /// Combines learning, review, and new cards into a single session
  /// respecting daily limits and priority ordering.
  Future<StudySession> createStudySession(String userID, String deckId, StudySettings settings) async {
    try {
      _logger.info('Creating study session for deck $deckId');
      
      if (userID.isEmpty || deckId.isEmpty) {
        throw ArgumentError('UserID and Deck ID cannot be empty');
      }

      // Get different types of cards
      final learningCards = await getLearningCards(userID, deckId);
      final reviewCards = await getReviewQueue(userID, deckId, settings.maxReviewsPerDay);
      final newCards = await getNewCards(userID, deckId, settings.newCardsPerDay);

      _logger.info('Study session created: ${learningCards.length} learning, ${reviewCards.length} review, ${newCards.length} new cards');

      return StudySession(
        learningCards: learningCards,
        reviewCards: reviewCards,
        newCards: newCards,
        settings: settings,
      );
    } catch (e) {
      _logger.severe('Error creating study session: $e');
      rethrow;
    }
  }

  /// Get the next card from a study session
  /// 
  /// Returns the next card based on priority:
  /// 1. Learning cards (time-sensitive)
  /// 2. Review cards (due cards)
  /// 3. New cards (daily limit)
  AnkiCard? getNextCard(StudySession session) {
    try {
      final nextCard = session.getNextCard();
      
      if (nextCard != null) {
        _logger.fine('Next card: ${nextCard.id} (state: ${nextCard.state.value})');
      } else {
        _logger.info('No more cards in session');
      }
      
      return nextCard;
    } catch (e) {
      _logger.severe('Error getting next card: $e');
      return null;
    }
  }

  /// Get comprehensive statistics for a deck
  /// 
  /// Returns detailed statistics about card distribution and due cards.
  Future<Map<String, dynamic>> getDeckStatistics(String userID, String deckId) async {
    try {
      _logger.info('Getting deck statistics for $deckId');
      
      if (userID.isEmpty || deckId.isEmpty) {
        _logger.warning('UserID or Deck ID is empty');
        return <String, dynamic>{};
      }

      // Get all cards from the deck
      final allCards = await _firebaseApi.getAllAnkiCardsFromDeck(userID, deckId);
      
      // Use SM2Service to get basic stats
      final basicStats = _sm2Service.getDeckStats(allCards);
      
      // Add additional scheduling-specific stats
      final now = DateTime.now();
      var overdueCount = 0;
      var scheduledToday = 0;
      
      for (final card in allCards) {
        if (card.isReview && card.isDue) {
          final daysDue = now.difference(card.dueDate).inDays;
          if (daysDue > 0) {
            overdueCount++;
          }
        }
        
        // Check if card is scheduled for today
        final today = DateTime(now.year, now.month, now.day);
        final cardDueDate = DateTime(card.dueDate.year, card.dueDate.month, card.dueDate.day);
        if (cardDueDate.isAtSameMomentAs(today)) {
          scheduledToday++;
        }
      }
      
      final enhancedStats = Map<String, dynamic>.from(basicStats);
      enhancedStats.addAll({
        'overdue': overdueCount,
        'scheduledToday': scheduledToday,
        'avgEase': allCards.isEmpty ? 0.0 : allCards.map((c) => c.easeFactor).reduce((a, b) => a + b) / allCards.length,
        'avgInterval': allCards.where((c) => c.isReview).isEmpty ? 0.0 : 
            allCards.where((c) => c.isReview).map((c) => c.interval).reduce((a, b) => a + b) / allCards.where((c) => c.isReview).length,
      });
      
      _logger.info('Deck statistics calculated for $deckId');
      return enhancedStats;
    } catch (e) {
      _logger.severe('Error getting deck statistics: $e');
      return <String, dynamic>{};
    }
  }

  /// Update a card after review and reschedule it
  /// 
  /// Processes the review using SM2Service and updates the card's scheduling.
  Future<AnkiCard> processCardReview(String userID, String deckId, AnkiCard card, ReviewGrade grade) async {
    try {
      _logger.info('Processing review for card ${card.id} with grade ${grade.name}');
      
      // Use SM2Service to process the review
      final updatedCard = _sm2Service.processReview(card, grade);
      
      // Save updated card to Firebase
      await _firebaseApi.updateAnkiCard(userID, deckId, updatedCard);
      
      _logger.info('Card ${card.id} updated: next due ${updatedCard.dueDate}, interval ${updatedCard.interval} days');
      return updatedCard;
    } catch (e) {
      _logger.severe('Error processing card review: $e');
      rethrow;
    }
  }

  /// Get cards due within a specific time range
  /// 
  /// Useful for planning future study sessions.
  Future<List<AnkiCard>> getCardsDueInRange(String userID, String deckId, DateTime startDate, DateTime endDate) async {
    try {
      _logger.info('Getting cards due between $startDate and $endDate for deck $deckId');
      
      if (userID.isEmpty || deckId.isEmpty) {
        _logger.warning('UserID or Deck ID is empty');
        return [];
      }

      if (startDate.isAfter(endDate)) {
        throw ArgumentError('Start date must be before end date');
      }

      // Get all cards from the deck
      final allCards = await _firebaseApi.getAllAnkiCardsFromDeck(userID, deckId);
      
      final cardsInRange = allCards
          .where((card) => 
              !card.suspended &&
              card.dueDate.isAfter(startDate) &&
              card.dueDate.isBefore(endDate.add(const Duration(days: 1))))
          .toList();

      // Sort by due date
      cardsInRange.sort((a, b) => a.dueDate.compareTo(b.dueDate));

      _logger.info('Found ${cardsInRange.length} cards due in range for deck $deckId');
      return cardsInRange;
    } catch (e) {
      _logger.severe('Error getting cards in date range: $e');
      return [];
    }
  }

  /// Get the SM2Service instance for direct access if needed
  SM2Service get sm2Service => _sm2Service;
}