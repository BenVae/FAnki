part of 'deck_bloc.dart';

final class DeckState {
  final bool isLoading;
  final String newDeckName;
  final bool newDeckNameIsValid;

  const DeckState({
    this.isLoading = false,
    this.newDeckName = '',
    this.newDeckNameIsValid = false,
  });

  DeckState copyWith({
    bool? isLoading,
    String? newDeckName,
    bool? newDeckNameIsValid,
  }) {
    return DeckState(
      isLoading: isLoading ?? this.isLoading,
      newDeckName: newDeckName ?? this.newDeckName,
      newDeckNameIsValid: newDeckNameIsValid ?? this.newDeckNameIsValid,
    );
  }
}
