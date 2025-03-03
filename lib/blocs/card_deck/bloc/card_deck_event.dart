part of 'card_deck_bloc.dart';

sealed class CardDeckEvent {}

final class DeckRepositorySubscriptionRequested extends CardDeckEvent {}

final class GetDeckFromRepository extends CardDeckEvent {
  final String deckName;

  GetDeckFromRepository({required this.deckName});
}

final class RemoveCardFromDeckById extends CardDeckEvent {
  final int cardId;

  RemoveCardFromDeckById({required this.cardId});
}

final class CreateNewCard extends CardDeckEvent {
  final String question;
  final String answer;

  CreateNewCard({required this.question, required this.answer});
}

final class RenameDeck extends CardDeckEvent {
  final String deckName;

  RenameDeck({required this.deckName});
}

final class DeleteDeckEvent extends CardDeckEvent {
  final String deckName;

  DeleteDeckEvent({required this.deckName});
}

final class EditCardEvent extends CardDeckEvent {
  final int cardId;
  final String question;
  final String answer;

  EditCardEvent(
      {required this.cardId, required this.question, required this.answer});
}

final class SetFlashCardForEditingOrCreating extends CardDeckEvent {
  final int? cardId;

  SetFlashCardForEditingOrCreating({this.cardId});
}

final class RemoveCurrentCardAndDeckFromState extends CardDeckEvent {}
