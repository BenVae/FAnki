part of 'deck_bloc.dart';

sealed class DeckEvent {
  const DeckEvent();
}

final class InitDeckEvent extends DeckEvent {
  final String deckName;

  const InitDeckEvent({required this.deckName});
}

final class DeckNameChanged extends DeckEvent {
  final String deckName;

  const DeckNameChanged({required this.deckName});
}
