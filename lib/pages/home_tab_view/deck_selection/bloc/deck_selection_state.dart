part of 'deck_selection_bloc.dart';

final class DeckSelectionState {
  final bool isLoading;
  final List<DeckName> decks;
  // final DeckName currentDeckName;
  final DeckModel? deckModel;
  final bool deckNameIsValid;

  const DeckSelectionState({
    this.isLoading = true,
    this.decks = const [],
    // this.currentDeckName = const DeckName.pure(),
    this.deckModel,
    this.deckNameIsValid = false,
  });

  DeckSelectionState copyWith({
    bool? isLoading,
    List<DeckName>? decks,
    DeckName? currentDeckName,
    DeckModel? deckModel,
    bool? deckNameIsValid,
  }) {
    return DeckSelectionState(
      isLoading: isLoading ?? this.isLoading,
      decks: decks ?? this.decks,
      // currentDeckName: currentDeckName ?? this.currentDeckName,
      deckModel: deckModel ?? this.deckModel,
      deckNameIsValid: deckNameIsValid ?? this.deckNameIsValid,
    );
  }
}
