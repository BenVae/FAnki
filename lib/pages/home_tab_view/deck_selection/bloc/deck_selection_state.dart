part of 'deck_selection_bloc.dart';

final class DeckSelectionState {
  final bool isLoading;
  final List<DeckName> decks;
  final DeckName nameOfNewDeck;
  final DeckModel? deckModel;
  final bool newDeckNameIsValid;

  const DeckSelectionState({
    this.isLoading = true,
    this.decks = const [],
    this.nameOfNewDeck = const DeckName.pure(),
    this.deckModel,
    this.newDeckNameIsValid = false,
  });

  DeckSelectionState copyWith({
    bool? isLoading,
    List<DeckName>? decks,
    DeckName? nameOfNewDeck,
    DeckModel? deckModel,
    bool? newDeckNameIsValid,
  }) {
    return DeckSelectionState(
      isLoading: isLoading ?? this.isLoading,
      decks: decks ?? this.decks,
      nameOfNewDeck: nameOfNewDeck ?? this.nameOfNewDeck,
      deckModel: deckModel ?? this.deckModel,
      newDeckNameIsValid: newDeckNameIsValid ?? this.newDeckNameIsValid,
    );
  }
}
