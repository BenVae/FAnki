part of 'deck_bloc.dart';

sealed class DeckEvent {
  const DeckEvent();
}

final class InitDeckEvent extends DeckEvent {}

final class DeckNameChanged extends DeckEvent {
  final String deckName;

  const DeckNameChanged({required this.deckName});
}

final class RenameDeckEvent extends DeckEvent {
  final String newDeckName;

  const RenameDeckEvent({required this.newDeckName});
}
