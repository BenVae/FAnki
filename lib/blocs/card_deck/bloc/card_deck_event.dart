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

final class SetFlashCardForEditingOrCreating extends CardDeckEvent {
  final int? cardId;

  SetFlashCardForEditingOrCreating({this.cardId});
}
