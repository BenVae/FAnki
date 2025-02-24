part of 'card_deck_bloc.dart';

final class CardDeckState {
  final bool isLoading;
  final String? deckName;
  final DeckModel? deck;
  final FlashCardModel? currentFlashCard;
  final bool isNewCard;

  const CardDeckState({
    this.isLoading = false,
    this.deckName,
    this.deck,
    this.currentFlashCard,
    this.isNewCard = true,
  });

  CardDeckState copyWith({
    bool? isLoading,
    String? deckName,
    DeckModel? deck,
    FlashCardModel? currentFlashCard,
    bool? isNewCard,
  }) {
    return CardDeckState(
      isLoading: isLoading ?? this.isLoading,
      deckName: deckName ?? this.deckName,
      deck: deck ?? this.deck,
      currentFlashCard: currentFlashCard ?? this.currentFlashCard,
      isNewCard: isNewCard ?? this.isNewCard,
    );
  }
}
