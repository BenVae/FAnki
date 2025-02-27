part of 'learning_bloc.dart';

final class LearningState {
  final bool isLoading;
  final String deckName;
  final List<FlashCardModel> flashCards;
  final List<FlashCardModel> revealedCards;
  final List<bool> revealedCardsVisibility;

  const LearningState({
    this.isLoading = false,
    this.deckName = '',
    this.flashCards = const [],
    this.revealedCards = const [],
    this.revealedCardsVisibility = const [],
  });

  LearningState copyWith({
    bool? isLoading,
    String? deckName,
    List<FlashCardModel>? flashCards,
    List<FlashCardModel>? revealedCards,
    List<bool>? revealedCardsVisibility,
  }) {
    return LearningState(
      isLoading: isLoading ?? this.isLoading,
      deckName: deckName ?? this.deckName,
      flashCards: flashCards ?? this.flashCards,
      revealedCards: revealedCards ?? this.revealedCards,
      revealedCardsVisibility: revealedCardsVisibility ?? this.revealedCardsVisibility,
    );
  }
}
