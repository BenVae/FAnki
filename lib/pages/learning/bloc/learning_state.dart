part of 'learning_bloc.dart';

final class LearningState {
  final bool isLoading;
  final List<FlashCardModel> flashCards;
  final List<FlashCardModel> revealedCards;
  final List<bool> revealedCardsVisibility;
  // final FlashCardModel? currentFlashCard;

  const LearningState({
    this.isLoading = false,
    this.flashCards = const [],
    this.revealedCards = const [],
    this.revealedCardsVisibility = const [],
    // this.currentFlashCard,
  });

  LearningState copyWith({
    bool? isLoading,
    List<FlashCardModel>? flashCards,
    List<FlashCardModel>? revealedCards,
    List<bool>? revealedCardsVisibility,
    // FlashCardModel? currentFlashCard,
  }) {
    return LearningState(
      isLoading: isLoading ?? this.isLoading,
      flashCards: flashCards ?? this.flashCards,
      revealedCards: revealedCards ?? this.revealedCards,
      revealedCardsVisibility: revealedCardsVisibility ?? this.revealedCardsVisibility,
      // currentFlashCard: currentFlashCard ?? this.currentFlashCard,
    );
  }
}
