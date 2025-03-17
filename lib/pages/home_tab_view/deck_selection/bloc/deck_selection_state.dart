part of 'deck_selection_bloc.dart';

final class DeckSelectionState {
  final bool isLoading;
  final List<DeckName> decks;
  final bool isCurrentDeckSelected;
  final DeckName nameOfNewDeck;
  final bool newDeckNameIsValid;
  final SelectDeckPurpose purpose;

  const DeckSelectionState({
    this.isLoading = true,
    this.decks = const [],
    this.isCurrentDeckSelected = false,
    this.nameOfNewDeck = const DeckName.pure(),
    this.newDeckNameIsValid = false,
    this.purpose = SelectDeckPurpose.learning,
  });

  DeckSelectionState copyWith({
    bool? isLoading,
    List<DeckName>? decks,
    bool? isCurrentDeckSelected,
    DeckName? nameOfNewDeck,
    bool? newDeckNameIsValid,
    SelectDeckPurpose? purpose,
  }) {
    return DeckSelectionState(
      isLoading: isLoading ?? this.isLoading,
      decks: decks ?? this.decks,
      isCurrentDeckSelected: isCurrentDeckSelected ?? this.isCurrentDeckSelected,
      nameOfNewDeck: nameOfNewDeck ?? this.nameOfNewDeck,
      newDeckNameIsValid: newDeckNameIsValid ?? this.newDeckNameIsValid,
      purpose: purpose ?? this.purpose,
    );
  }
}
