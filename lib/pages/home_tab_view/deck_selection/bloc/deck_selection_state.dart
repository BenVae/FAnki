part of 'deck_selection_bloc.dart';

final class DeckSelectionState {
  final bool isLoading;
  final List<DeckName> decks;
  final bool isCurrentDeckSelected;
  final DeckName nameOfNewDeck;
  final bool newDeckNameIsValid;

  const DeckSelectionState({
    this.isLoading = true,
    this.decks = const [],
    this.isCurrentDeckSelected = false,
    this.nameOfNewDeck = const DeckName.pure(),
    this.newDeckNameIsValid = false,
  });

  DeckSelectionState copyWith({
    bool? isLoading,
    List<DeckName>? decks,
    bool? isCurrentDeckSelected,
    DeckName? nameOfNewDeck,
    bool? newDeckNameIsValid,
  }) {
    return DeckSelectionState(
      isLoading: isLoading ?? this.isLoading,
      decks: decks ?? this.decks,
      isCurrentDeckSelected:
          isCurrentDeckSelected ?? this.isCurrentDeckSelected,
      nameOfNewDeck: nameOfNewDeck ?? this.nameOfNewDeck,
      newDeckNameIsValid: newDeckNameIsValid ?? this.newDeckNameIsValid,
    );
  }
}
