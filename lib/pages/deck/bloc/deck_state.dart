part of 'deck_bloc.dart';

final class DeckState {
  final bool isLoading;
  final String originalName;
  final String newDeckName;
  final bool isNewDeckNameValid;
  final DeckModel? deck;

  const DeckState({
    this.isLoading = false,
    this.originalName = '',
    this.newDeckName = '',
    this.isNewDeckNameValid = false,
    this.deck,
  });

  DeckState copyWith({
    bool? isLoading,
    String? originalName,
    String? newDeckName,
    bool? isNewDeckNameValid,
    DeckModel? deck,
  }) {
    return DeckState(
      isLoading: isLoading ?? this.isLoading,
      originalName: originalName ?? this.originalName,
      newDeckName: newDeckName ?? this.newDeckName,
      isNewDeckNameValid: isNewDeckNameValid ?? this.isNewDeckNameValid,
      deck: deck ?? this.deck,
    );
  }
}
