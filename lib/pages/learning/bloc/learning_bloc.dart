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
    on<ToggleAnswerVisibility>(_toggleAnswerVisibility);
  }

  void _initialize(InitializeLearning event, Emitter<LearningState> emit) async {
    emit(LearningState());
    DeckModel deck = await _deckRepository.loadDeckByName(event.deckName);
    emit(
      state.copyWith(
        isLoading: false,
        deckName: event.deckName,
        flashCards: deck.flashCards,
      ),
    );
  }

  void _getNextCard(GetNextCard event, Emitter<LearningState> emit) {
    if (state.flashCards.isEmpty) {
      return;
    }

    final randomIndex = Random().nextInt(state.flashCards.length);
    final nextFlashCard = state.flashCards[randomIndex];
    final newRevealedCards = List<FlashCardModel>.from(state.revealedCards)..insert(0, nextFlashCard);
    List<bool> newRevealedCardsVisibility = List<bool>.from(state.revealedCardsVisibility)..insert(0, false);

    emit(state.copyWith(
      revealedCards: newRevealedCards,
      revealedCardsVisibility: newRevealedCardsVisibility,
    ));
  }

  void _toggleAnswerVisibility(ToggleAnswerVisibility event, Emitter<LearningState> emit) {
    List<bool> newRevealedCardsVisibility = List<bool>.from(state.revealedCardsVisibility);
    newRevealedCardsVisibility[event.cardIndex] = !newRevealedCardsVisibility[event.cardIndex];

    emit(state.copyWith(
      revealedCardsVisibility: newRevealedCardsVisibility,
    ));
  }
}
