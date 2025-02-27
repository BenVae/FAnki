part of 'deck_bloc.dart';

sealed class DeckEvent {
  const DeckEvent();
}

final class DeckNameChanged extends DeckEvent {
  final String deckName;

  const DeckNameChanged({required this.deckName});
}
