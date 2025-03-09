part of 'deck_selection_bloc.dart';

sealed class DeckSelectionEvent {
  const DeckSelectionEvent();
}

final class FetchDecks extends DeckSelectionEvent {}

final class GetDeckFromRepository extends DeckSelectionEvent {
  final String deckName;

  GetDeckFromRepository({required this.deckName});
}

final class DeckNameInputChange extends DeckSelectionEvent {
  final String deckName;

  const DeckNameInputChange({required this.deckName});
}

final class CreateDeck extends DeckSelectionEvent {}

final class SelectDeckEvent extends DeckSelectionEvent {
  final String deckName;

  const SelectDeckEvent({required this.deckName});
}
