part of 'deck_bloc.dart';

final class DeckState {
  final bool isLoading;
  final String originalName;
  final String newDeckName;
  final bool newDeckNameIsValid;

  const DeckState({
    this.isLoading = false,
    this.originalName = '',
    this.newDeckName = '',
    this.newDeckNameIsValid = false,
  });

  DeckState copyWith({
    bool? isLoading,
    String? originalName,
    String? newDeckName,
    bool? newDeckNameIsValid,
  }) {
    return DeckState(
      isLoading: isLoading ?? this.isLoading,
      originalName: originalName ?? this.originalName,
      newDeckName: newDeckName ?? this.newDeckName,
      newDeckNameIsValid: newDeckNameIsValid ?? this.newDeckNameIsValid,
    );
  }
}
