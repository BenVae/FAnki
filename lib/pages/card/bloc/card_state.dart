part of 'card_bloc.dart';

final class CardState {
  final bool isLoading;
  final FlashCardModel? card;
  final String? question;
  final String? answer;
  final bool isCardValid;
  final bool isEditingDone;

  const CardState({
    this.isLoading = false,
    this.card,
    this.question,
    this.answer,
    this.isCardValid = false,
    this.isEditingDone = false,
  });

  CardState copyWith({
    bool? isLoading,
    FlashCardModel? card,
    String? question,
    String? answer,
    bool? isCardValid,
    bool? isNewCard,
    bool? isEditingDone,
  }) {
    return CardState(
      isLoading: isLoading ?? this.isLoading,
      card: card ?? this.card,
      question: question ?? this.question,
      answer: answer ?? this.answer,
      isCardValid: isCardValid ?? this.isCardValid,
      isEditingDone: isEditingDone ?? this.isEditingDone,
    );
  }
}
