part of 'learning_bloc.dart';

final class LearningState {
  final bool isLoading;
  final List<FlashCardModel> flashCards;
  final FlashCardModel? currentFlashCard;

  const LearningState({
    this.isLoading = false,
    this.flashCards = const [],
    this.currentFlashCard,
  });

  LearningState copyWith({
    bool? isLoading,
    List<FlashCardModel>? flashCards,
    FlashCardModel? currentFlashCard,
  }) {
    return LearningState(
      isLoading: isLoading ?? this.isLoading,
      flashCards: flashCards ?? this.flashCards,
      currentFlashCard: currentFlashCard ?? this.currentFlashCard,
    );
  }
}
