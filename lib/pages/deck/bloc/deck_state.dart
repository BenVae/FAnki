part of 'deck_bloc.dart';

final class DeckState {
  final bool isLoading;
  final String originalName;
  final String newDeckName;
  final bool isNewDeckNameValid;
  final DeckModel? deck;
  final bool isCardForEditingSelected;

  const DeckState({
    this.isLoading = false,
    this.originalName = '',
    this.newDeckName = '',
    this.isNewDeckNameValid = false,
    this.deck,
    this.isCardForEditingSelected = false,
  });

  DeckState copyWith({
    bool? isLoading,
    String? originalName,
    String? newDeckName,
    bool? isNewDeckNameValid,
    DeckModel? deck,
    ValueGetter<FlashCardModel?>? currentCard,
    bool? isCardForEditingSelected,
  }) {
    return DeckState(
      isLoading: isLoading ?? this.isLoading,
      originalName: originalName ?? this.originalName,
      newDeckName: newDeckName ?? this.newDeckName,
      isNewDeckNameValid: isNewDeckNameValid ?? this.isNewDeckNameValid,
      deck: deck ?? this.deck,
      isCardForEditingSelected:
          isCardForEditingSelected ?? this.isCardForEditingSelected,
    );
  }
}
