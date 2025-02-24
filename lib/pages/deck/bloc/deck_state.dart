part of 'deck_bloc.dart';

final class DeckState {
  final bool isLoading;

  const DeckState({
    this.isLoading = false,
  });

  DeckState copyWith({
    bool? isLoading,
  }) {
    return DeckState(
      isLoading: isLoading ?? this.isLoading,
    );
  }
}
