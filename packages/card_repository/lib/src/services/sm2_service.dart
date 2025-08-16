import 'package:logging/logging.dart';
import '../models/anki_card.dart';

final _logger = Logger('SM2Service');

/// Review grade values for the SM-2 spaced repetition algorithm
enum ReviewGrade {
  /// Complete failure, restart learning
  again(1),
  
  /// Difficult recall, reduce interval
  hard(2),
  
  /// Normal recall, standard interval
  good(4),
  
  /// Perfect recall, bonus interval
  easy(5);

  const ReviewGrade(this.value);
  final int value;
  
  /// Get ReviewGrade from integer value
  static ReviewGrade fromValue(int value) {
    return ReviewGrade.values.firstWhere(
      (grade) => grade.value == value,
      orElse: () => ReviewGrade.again,
    );
  }
}

/// SM-2 Spaced Repetition Algorithm Service
/// 
/// Implements the complete SuperMemo SM-2 algorithm for optimal spacing
/// of flashcard reviews based on user performance.
class SM2Service {
  // SM-2 Algorithm Constants
  static const double initialEase = 2.5;
  static const double minEase = 1.3;
  static const double maxEase = 4.0;
  static const List<int> defaultLearningSteps = [1, 10]; // minutes
  static const List<int> defaultRelearningSteps = [10]; // minutes
  
  // Interval modifiers
  static const double hardMultiplier = 1.2;
  static const double easyMultiplier = 1.3;
  static const int graduatingInterval = 1; // days
  static const int easyInterval = 4; // days
  static const int maxNewInterval = 365; // days
  static const int minInterval = 1; // days

  /// Process a card review according to the SM-2 algorithm
  /// 
  /// Takes a card and the user's performance grade, returns an updated card
  /// with new scheduling parameters according to the SM-2 algorithm.
  AnkiCard processReview(AnkiCard card, ReviewGrade grade) {
    _logger.info('Processing review for card ${card.id} with grade ${grade.name}');
    
    final now = DateTime.now();
    
    // Handle different card states
    switch (card.state) {
      case CardState.newCard:
        return _processNewCard(card, grade, now);
      
      case CardState.learning:
        return _processLearningCard(card, grade, now);
      
      case CardState.review:
        return _processReviewCard(card, grade, now);
      
      case CardState.relearning:
        return _processRelearningCard(card, grade, now);
    }
  }

  /// Process a new card review
  AnkiCard _processNewCard(AnkiCard card, ReviewGrade grade, DateTime now) {
    _logger.fine('Processing new card ${card.id}');
    
    // All new cards move to learning state regardless of grade
    return card.copyWith(
      state: CardState.learning,
      currentStep: 0,
      dueDate: _calculateLearningDueDate(card.learningSteps[0]),
      lastReviewed: now,
      modified: now,
    );
  }

  /// Process a card in learning state
  AnkiCard _processLearningCard(AnkiCard card, ReviewGrade grade, DateTime now) {
    _logger.fine('Processing learning card ${card.id} at step ${card.currentStep}');
    
    switch (grade) {
      case ReviewGrade.again:
        // Reset to first learning step
        return card.copyWith(
          currentStep: 0,
          dueDate: _calculateLearningDueDate(card.learningSteps[0]),
          lastReviewed: now,
          modified: now,
        );
      
      case ReviewGrade.hard:
      case ReviewGrade.good:
        // Move to next step or graduate
        final nextStep = card.currentStep + 1;
        
        if (nextStep >= card.learningSteps.length) {
          // Graduate to review state
          return _graduateFromLearning(card, grade, now);
        } else {
          // Move to next learning step
          return card.copyWith(
            currentStep: nextStep,
            dueDate: _calculateLearningDueDate(card.learningSteps[nextStep]),
            lastReviewed: now,
            modified: now,
          );
        }
      
      case ReviewGrade.easy:
        // Graduate immediately with easy interval
        return _graduateFromLearning(card, grade, now);
    }
  }

  /// Process a card in review state
  AnkiCard _processReviewCard(AnkiCard card, ReviewGrade grade, DateTime now) {
    _logger.fine('Processing review card ${card.id}');
    
    switch (grade) {
      case ReviewGrade.again:
        // Lapse - move to relearning
        final newLapses = card.lapses + 1;
        final newEaseFactor = calculateEaseFactor(card.easeFactor, grade);
        
        return card.copyWith(
          state: CardState.relearning,
          currentStep: 0,
          easeFactor: newEaseFactor,
          lapses: newLapses,
          dueDate: _calculateLearningDueDate(defaultRelearningSteps[0]),
          lastReviewed: now,
          modified: now,
        );
      
      case ReviewGrade.hard:
      case ReviewGrade.good:
      case ReviewGrade.easy:
        // Continue in review state with new interval
        final newRepetitions = card.repetitions + 1;
        final newEaseFactor = calculateEaseFactor(card.easeFactor, grade);
        final newInterval = calculateInterval(newRepetitions, newEaseFactor, card.interval);
        final adjustedInterval = _applyGradeModifier(newInterval, grade);
        final dueDate = calculateNextDue(card, adjustedInterval);
        
        return card.copyWith(
          repetitions: newRepetitions,
          easeFactor: newEaseFactor,
          interval: adjustedInterval,
          dueDate: dueDate,
          lastReviewed: now,
          modified: now,
        );
    }
  }

  /// Process a card in relearning state
  AnkiCard _processRelearningCard(AnkiCard card, ReviewGrade grade, DateTime now) {
    _logger.fine('Processing relearning card ${card.id} at step ${card.currentStep}');
    
    switch (grade) {
      case ReviewGrade.again:
        // Reset to first relearning step
        return card.copyWith(
          currentStep: 0,
          dueDate: _calculateLearningDueDate(defaultRelearningSteps[0]),
          lastReviewed: now,
          modified: now,
        );
      
      case ReviewGrade.hard:
      case ReviewGrade.good:
        // Move to next step or re-graduate
        final nextStep = card.currentStep + 1;
        
        if (nextStep >= defaultRelearningSteps.length) {
          // Re-graduate to review state
          return _regraduateFromRelearning(card, now);
        } else {
          // Move to next relearning step
          return card.copyWith(
            currentStep: nextStep,
            dueDate: _calculateLearningDueDate(defaultRelearningSteps[nextStep]),
            lastReviewed: now,
            modified: now,
          );
        }
      
      case ReviewGrade.easy:
        // Re-graduate immediately
        return _regraduateFromRelearning(card, now);
    }
  }

  /// Graduate a card from learning to review state
  AnkiCard _graduateFromLearning(AnkiCard card, ReviewGrade grade, DateTime now) {
    _logger.fine('Graduating card ${card.id} from learning');
    
    final interval = grade == ReviewGrade.easy ? easyInterval : graduatingInterval;
    final easeFactor = grade == ReviewGrade.easy 
        ? calculateEaseFactor(initialEase, grade)
        : initialEase;
    
    return card.copyWith(
      state: CardState.review,
      repetitions: 1,
      easeFactor: easeFactor,
      interval: interval,
      currentStep: 0,
      dueDate: calculateNextDue(card, interval),
      lastReviewed: now,
      modified: now,
    );
  }

  /// Re-graduate a card from relearning to review state
  AnkiCard _regraduateFromRelearning(AnkiCard card, DateTime now) {
    _logger.fine('Re-graduating card ${card.id} from relearning');
    
    return card.copyWith(
      state: CardState.review,
      interval: graduatingInterval,
      currentStep: 0,
      dueDate: calculateNextDue(card, graduatingInterval),
      lastReviewed: now,
      modified: now,
    );
  }

  /// Calculate the next interval using the SM-2 algorithm
  /// 
  /// The interval is calculated based on:
  /// - repetitions: Number of successful reviews
  /// - easeFactor: Current ease factor for the card
  /// - previousInterval: The previous interval in days
  int calculateInterval(int repetitions, double easeFactor, int previousInterval) {
    if (repetitions <= 1) {
      return graduatingInterval;
    } else if (repetitions == 2) {
      return 6;
    } else {
      final interval = (previousInterval * easeFactor).round();
      return interval.clamp(minInterval, maxNewInterval);
    }
  }

  /// Calculate the new ease factor based on the review grade
  /// 
  /// The ease factor is adjusted according to the SM-2 formula:
  /// EF' = EF + (0.1 - (5-q) * (0.08 + (5-q) * 0.02))
  /// where q is the quality of the response (grade value)
  double calculateEaseFactor(double currentEase, ReviewGrade grade) {
    final q = grade.value;
    final newEase = currentEase + (0.1 - (5 - q) * (0.08 + (5 - q) * 0.02));
    return newEase.clamp(minEase, maxEase);
  }

  /// Calculate the next due date for a card
  /// 
  /// For learning cards, this is based on learning steps in minutes.
  /// For review cards, this is based on the interval in days.
  DateTime calculateNextDue(AnkiCard card, int intervalInDays) {
    final now = DateTime.now();
    return DateTime(
      now.year,
      now.month,
      now.day,
    ).add(Duration(days: intervalInDays));
  }

  /// Calculate due date for learning steps (in minutes)
  DateTime _calculateLearningDueDate(int stepInMinutes) {
    return DateTime.now().add(Duration(minutes: stepInMinutes));
  }

  /// Apply grade-specific modifiers to intervals
  int _applyGradeModifier(int interval, ReviewGrade grade) {
    switch (grade) {
      case ReviewGrade.hard:
        return (interval * hardMultiplier).round().clamp(minInterval, maxNewInterval);
      case ReviewGrade.easy:
        return (interval * easyMultiplier).round().clamp(minInterval, maxNewInterval);
      case ReviewGrade.good:
      case ReviewGrade.again:
        return interval;
    }
  }

  /// Get the next cards due for review from a list of cards
  /// 
  /// Returns cards that are due for review, sorted by priority:
  /// 1. Learning and relearning cards (by due time)
  /// 2. Review cards (by due date)
  /// 3. New cards (by creation date)
  List<AnkiCard> getDueCards(List<AnkiCard> cards, {int? limit}) {
    // Filter out suspended cards
    final activeCards = cards.where((card) => !card.suspended).toList();
    
    // Separate cards by type and filter due cards
    final learningCards = <AnkiCard>[];
    final reviewCards = <AnkiCard>[];
    final newCards = <AnkiCard>[];
    
    for (final card in activeCards) {
      if (card.isLearning && card.isDue) {
        learningCards.add(card);
      } else if (card.isReview && card.isDue) {
        reviewCards.add(card);
      } else if (card.isNew) {
        newCards.add(card);
      }
    }
    
    // Sort each category
    learningCards.sort((a, b) => a.dueDate.compareTo(b.dueDate));
    reviewCards.sort((a, b) => a.dueDate.compareTo(b.dueDate));
    newCards.sort((a, b) => a.created.compareTo(b.created));
    
    // Combine in priority order
    final dueCards = <AnkiCard>[];
    dueCards.addAll(learningCards);
    dueCards.addAll(reviewCards);
    dueCards.addAll(newCards);
    
    // Apply limit if specified
    if (limit != null && limit > 0) {
      return dueCards.take(limit).toList();
    }
    
    return dueCards;
  }

  /// Get statistics for a deck
  /// 
  /// Returns a map with counts of cards in different states
  Map<String, int> getDeckStats(List<AnkiCard> cards) {
    var newCount = 0;
    var learningCount = 0;
    var reviewCount = 0;
    var dueCount = 0;
    
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
    
    return {
      'new': newCount,
      'learning': learningCount,
      'review': reviewCount,
      'due': dueCount,
      'total': cards.length,
      'suspended': cards.where((c) => c.suspended).length,
    };
  }
}