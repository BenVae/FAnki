import 'package:flutter_test/flutter_test.dart';
import 'package:card_repository/card_deck_manager.dart';

void main() {
  late SM2Service sm2Service;
  late AnkiCard testCard;

  setUp(() {
    sm2Service = SM2Service();
    testCard = AnkiCard(
      deckId: 'test-deck',
      questionText: 'Test question',
      answerText: 'Test answer',
    );
  });

  group('SM2Service', () {
    test('should initialize with correct constants', () {
      expect(SM2Service.initialEase, 2.5);
      expect(SM2Service.minEase, 1.3);
      expect(SM2Service.maxEase, 4.0);
      expect(SM2Service.defaultLearningSteps, [1, 10]);
      expect(SM2Service.defaultRelearningSteps, [10]);
    });

    test('should process new card correctly', () {
      final result = sm2Service.processReview(testCard, ReviewGrade.good);
      
      expect(result.state, CardState.learning);
      expect(result.currentStep, 0);
      expect(result.lastReviewed, isNotNull);
      expect(result.dueDate.isAfter(DateTime.now()), true);
    });

    test('should graduate card from learning to review', () {
      // Start with learning card at last step
      var learningCard = testCard.copyWith(
        state: CardState.learning,
        currentStep: 1, // Last step in default [1, 10]
      );
      
      final result = sm2Service.processReview(learningCard, ReviewGrade.good);
      
      expect(result.state, CardState.review);
      expect(result.repetitions, 1);
      expect(result.easeFactor, SM2Service.initialEase);
      expect(result.interval, 1); // Graduating interval
    });

    test('should handle review card with good grade', () {
      var reviewCard = testCard.copyWith(
        state: CardState.review,
        repetitions: 2,
        easeFactor: 2.5,
        interval: 6,
      );
      
      final result = sm2Service.processReview(reviewCard, ReviewGrade.good);
      
      expect(result.state, CardState.review);
      expect(result.repetitions, 3);
      expect(result.interval, greaterThan(6)); // Should increase
    });

    test('should handle lapse correctly', () {
      var reviewCard = testCard.copyWith(
        state: CardState.review,
        repetitions: 5,
        easeFactor: 2.5,
        lapses: 0,
      );
      
      final result = sm2Service.processReview(reviewCard, ReviewGrade.again);
      
      expect(result.state, CardState.relearning);
      expect(result.lapses, 1);
      expect(result.currentStep, 0);
      expect(result.easeFactor, lessThan(2.5)); // Should decrease
    });

    test('should calculate interval correctly', () {
      expect(sm2Service.calculateInterval(1, 2.5, 0), 1);
      expect(sm2Service.calculateInterval(2, 2.5, 1), 6);
      expect(sm2Service.calculateInterval(3, 2.5, 6), 15);
    });

    test('should calculate ease factor correctly', () {
      expect(sm2Service.calculateEaseFactor(2.5, ReviewGrade.good), 2.5);
      expect(sm2Service.calculateEaseFactor(2.5, ReviewGrade.easy), greaterThan(2.5));
      expect(sm2Service.calculateEaseFactor(2.5, ReviewGrade.hard), lessThan(2.5));
      expect(sm2Service.calculateEaseFactor(2.5, ReviewGrade.again), lessThan(2.5));
    });

    test('should enforce ease factor bounds', () {
      // Test minimum bound
      var result = sm2Service.calculateEaseFactor(1.3, ReviewGrade.again);
      expect(result, greaterThanOrEqualTo(SM2Service.minEase));
      
      // Test maximum bound (would require many easy reviews)
      result = sm2Service.calculateEaseFactor(3.9, ReviewGrade.easy);
      expect(result, lessThanOrEqualTo(SM2Service.maxEase));
    });

    test('should get due cards correctly', () {
      final cards = [
        // New card
        AnkiCard(deckId: 'test', questionText: 'Q1', answerText: 'A1'),
        // Learning card due now
        AnkiCard(
          deckId: 'test', 
          questionText: 'Q2', 
          answerText: 'A2',
          state: CardState.learning,
          dueDate: DateTime.now().subtract(Duration(minutes: 1)),
        ),
        // Review card due tomorrow
        AnkiCard(
          deckId: 'test', 
          questionText: 'Q3', 
          answerText: 'A3',
          state: CardState.review,
          dueDate: DateTime.now().add(Duration(days: 1)),
        ),
        // Suspended card
        AnkiCard(
          deckId: 'test', 
          questionText: 'Q4', 
          answerText: 'A4',
          suspended: true,
        ),
      ];

      final dueCards = sm2Service.getDueCards(cards);
      
      // Should include learning card (due) and new card, but not future review or suspended
      expect(dueCards.length, 2);
      expect(dueCards[0].state, CardState.learning); // Learning cards first
      expect(dueCards[1].state, CardState.newCard); // Then new cards
    });

    test('should calculate deck stats correctly', () {
      final cards = [
        AnkiCard(deckId: 'test', questionText: 'Q1', answerText: 'A1'), // new
        AnkiCard(deckId: 'test', questionText: 'Q2', answerText: 'A2', state: CardState.learning), // learning
        AnkiCard(deckId: 'test', questionText: 'Q3', answerText: 'A3', state: CardState.review), // review
        AnkiCard(deckId: 'test', questionText: 'Q4', answerText: 'A4', suspended: true), // suspended
      ];

      final stats = sm2Service.getDeckStats(cards);
      
      expect(stats['new'], 1);
      expect(stats['learning'], 1);
      expect(stats['review'], 1);
      expect(stats['total'], 4);
      expect(stats['suspended'], 1);
    });
  });

  group('ReviewGrade', () {
    test('should have correct values', () {
      expect(ReviewGrade.again.value, 1);
      expect(ReviewGrade.hard.value, 2);
      expect(ReviewGrade.good.value, 4);
      expect(ReviewGrade.easy.value, 5);
    });

    test('should convert from value correctly', () {
      expect(ReviewGrade.fromValue(1), ReviewGrade.again);
      expect(ReviewGrade.fromValue(2), ReviewGrade.hard);
      expect(ReviewGrade.fromValue(4), ReviewGrade.good);
      expect(ReviewGrade.fromValue(5), ReviewGrade.easy);
      expect(ReviewGrade.fromValue(99), ReviewGrade.again); // fallback
    });
  });
}