import 'dart:math' show Random;

import 'package:kartei/main.dart';
import 'package:bloc/bloc.dart';
import 'package:authentication_repository/authentication_repository.dart';
import 'package:card_repository/card_deck_manager.dart';
import 'package:flutter/material.dart';

class LearningCubit extends Cubit<CardLearnState> {
  final AuthenticationRepository _repo;
  final CardDeckManager _cdm;
  final StudyActivityManager _activityManager = StudyActivityManager();

  String _deckName = '';

  List<SingleCard> _cards = [];
  List<bool> _answereIsVisible = [];
  int _cardsReviewed = 0;
  int _totalCards = 0;

  final GlobalKey<AnimatedListState> animatedListKey =
      GlobalKey<AnimatedListState>();

  LearningCubit(AuthenticationRepository repo, CardDeckManager cardDeckManager)
      : _repo = repo,
        _cdm = cardDeckManager,
        super(CardLoadingState()) {
    deckName = _cdm.currentDeckName;
    loadCards();
    // log.info(_repo.toString());

    // Initialize activity manager with user ID
    final userId = _repo.currentUser.email ?? '';
    if (userId.isNotEmpty) {
      _activityManager.setUserId(userId);
      _activityManager.startSession();
    }
  }

  set deckName(String value) {
    _deckName = value;
  }

  void toggleAnswerVisibility(int index) {
    if (state is CardLearningState) {
      final currentState = state as CardLearningState;
      _answereIsVisible[index] = !_answereIsVisible[index];
      emit(currentState.copyWithNewCards(
          cards: currentState.cards,
          answerIsVisible: _answereIsVisible,
          cardsReviewed: currentState.cardsReviewed,
          totalCards: currentState.totalCards));
    } else {
      // log.warning('Wrong state 3454243 $state');
      nextCard();
    }
  }

  void nextCard() {
    if (_cards.isNotEmpty) {
      int randomIndex = Random().nextInt(_cards.length);
      SingleCard newCard = _cards[randomIndex];
      _cardsReviewed++;

      // Track card review
      _activityManager.trackCardReview(
        deckId: _deckName,
        isNewCard: false, // Could track if card is new based on difficulty
      );

      if (state is CardLearningState) {
        final currentState = state as CardLearningState;
        List<SingleCard> updatedCards = List.from(currentState.cards);
        updatedCards.insert(0, newCard);
        _answereIsVisible.insert(0, false);
        emit(currentState.copyWithNewCards(
            cards: updatedCards,
            answerIsVisible: _answereIsVisible,
            cardsReviewed: _cardsReviewed,
            totalCards: _totalCards));
        animatedListKey.currentState?.insertItem(0);
      }
    } else {
      emit(CardEmptyState());
    }
  }

  void firstCard() {
    if (_cards.isNotEmpty) {
      int randomIndex = Random().nextInt(_cards.length);
      SingleCard newCard = _cards[randomIndex];
      _answereIsVisible.add(false);
      _totalCards = _cards.length;
      _cardsReviewed = 0;
      CardLearningState state = CardLearningState(
          cards: [newCard],
          animatedListKey: animatedListKey,
          answerIsVisible: _answereIsVisible,
          cardsReviewed: _cardsReviewed,
          totalCards: _totalCards);
      emit(state);
    } else {
      // log.severe('No first card');
      emit(CardEmptyState());
    }
  }

  void loadCards() async {
    _answereIsVisible = [];
    emit(CardLoadingState());
    try {
      await _cdm.loadDeck();
      _cards = await _cdm.getCurrentDeckCards();
      firstCard();
    } catch (e) {
      emit(CardErrorState(e.toString()));
    }
  }

  bool answerIsVisible(int index) {
    if (state is CardLearningState) {
      final currentState = state as CardLearningState;
      return currentState._answerIsVisible[index];
    } else {
      return false;
    }
  }

  void checkAndReloadDeck() {
    if (_deckName != _cdm.currentDeckName) {
      deckName = _cdm.currentDeckName;
      loadCards();
    } else if (_cards.isEmpty) {
      loadCards();
    }
  }

  /// Call this when learning session ends or app is paused
  void endSession() async {
    await _activityManager.endSession();
  }

  @override
  Future<void> close() {
    // Save session when cubit is closed
    endSession();
    return super.close();
  }
}

abstract class CardLearnState {}

class CardLearningState extends CardLearnState {
  final List<SingleCard> _cards;
  final GlobalKey<AnimatedListState> _animatedListKey;
  final List<bool> _answerIsVisible;
  final int cardsReviewed;
  final int totalCards;

  List<bool> get answerIsVisible => _answerIsVisible;
  List<SingleCard> get cards => _cards;
  GlobalKey<AnimatedListState> get animatedListKey => _animatedListKey;

  CardLearningState({
    required List<SingleCard> cards,
    required GlobalKey<AnimatedListState> animatedListKey,
    required List<bool> answerIsVisible,
    this.cardsReviewed = 0,
    this.totalCards = 0,
  })  : _cards = cards,
        _animatedListKey = animatedListKey,
        _answerIsVisible = answerIsVisible;

  CardLearningState copyWithNewVisibility(
      {required List<bool> answerIsVisible}) {
    return CardLearningState(
      answerIsVisible: answerIsVisible,
      cards: _cards,
      animatedListKey: _animatedListKey,
      cardsReviewed: cardsReviewed,
      totalCards: totalCards,
    );
  }

  CardLearningState copyWithNewCards({
    required List<SingleCard> cards,
    required List<bool> answerIsVisible,
    int? cardsReviewed,
    int? totalCards,
  }) {
    return CardLearningState(
      cards: cards,
      animatedListKey: _animatedListKey,
      answerIsVisible: answerIsVisible,
      cardsReviewed: cardsReviewed ?? this.cardsReviewed,
      totalCards: totalCards ?? this.totalCards,
    );
  }
}

class CardLoadingState extends CardLearnState {}

class CardEmptyState extends CardLearnState {}

class CardErrorState extends CardLearnState {
  final String error;

  CardErrorState(this.error) {
    // log.info(error);
  }
}
