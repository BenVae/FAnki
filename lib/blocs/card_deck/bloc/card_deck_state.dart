part of 'card_deck_bloc.dart';

typedef ValueGetter<T> = T Function();

final class CardDeckState {
  final bool isLoading;
  final String? deckName;
  final DeckModel? deck;
  final FlashCardModel? currentCard;
  final bool isNewCard;

  const CardDeckState({
    this.isLoading = false,
    this.deckName,
    this.deck,
    this.currentCard,
    this.isNewCard = true,
  });

  CardDeckState copyWith({
    bool? isLoading,
    ValueGetter<String?>? deckName,
    ValueGetter<DeckModel?>? deck,
    ValueGetter<FlashCardModel?>? currentCard,
    bool? isNewCard,
  }) {
    return CardDeckState(
      isLoading: isLoading ?? this.isLoading,
      deckName: deckName != null ? deckName() : this.deckName,
      deck: deck != null ? deck() : this.deck,
      currentCard: currentCard != null ? currentCard() : this.currentCard,
      isNewCard: isNewCard ?? this.isNewCard,
    );
  }
}
