import 'dart:math';

import 'package:bloc/bloc.dart';
import 'package:deck_repository/deck_repository.dart';

part 'learning_event.dart';
part 'learning_state.dart';

class LearningBloc extends Bloc<LearningEvent, LearningState> {
  final DeckRepository _deckRepository;

  LearningBloc({required DeckRepository deckRepository})
      : _deckRepository = deckRepository,
        super(const LearningState()) {
    on<InitializeLearning>(_initialize);
    on<GetNextCard>(_getNextCard);
  }

  void _initialize(InitializeLearning event, Emitter<LearningState> emit) {
    emit(state.copyWith(isLoading: true));
    final flashCards = _deckRepository.getFlashCardsFromSelectedDeck();
    emit(state.copyWith(
      isLoading: false,
      flashCards: flashCards,
    ));
  }

  void _getNextCard(GetNextCard event, Emitter<LearningState> emit) {
    if (state.flashCards.isEmpty) {
      emit(state.copyWith(isLoading: false));
      return;
    }

    final random = Random();
    final randomIndex = random.nextInt(state.flashCards.length);
    final nextFlashCard = state.flashCards[randomIndex];

    emit(state.copyWith(
      isLoading: false,
      currentFlashCard: nextFlashCard,
    ));
  }
}
