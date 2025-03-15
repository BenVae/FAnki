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

final class DeleteDeckEvent extends DeckEvent {}

final class EditCardEvent extends DeckEvent {
  final int cardId;

  const EditCardEvent({required this.cardId});
}

final class CreateCardEvent extends DeckEvent {}
