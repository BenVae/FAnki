import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:deck_repository/deck_repository.dart';

part 'card_deck_event.dart';
part 'card_deck_state.dart';

class CardDeckBloc extends Bloc<CardDeckEvent, CardDeckState> {
  final DeckRepository _deckRepository;

  CardDeckBloc({required DeckRepository deckRepository})
      : _deckRepository = deckRepository,
        super(const CardDeckState()) {
    on<GetDeckFromRepository>(_getDeckFromRepository);
    on<RemoveCardFromDeckById>(_removeCard);
    on<CreateNewCard>(_createNewFlashCard);
    on<EditCardEvent>(_editCard);
    on<SetFlashCardForEditingOrCreating>(_setCurrentFlashCard);
    on<RemoveCurrentCardAndDeckFromState>(_removeCurrentCardAndDeckFromState);
  }

  Future<void> _getDeckFromRepository(GetDeckFromRepository event, Emitter<CardDeckState> emit) async {
    emit(state.copyWith(isLoading: true));
    DeckModel deck = await _deckRepository.loadDeckByName(event.deckName);
    emit(state.copyWith(isLoading: false, deckName: () => _deckRepository.getCurrentDeckName(), deck: () => deck));
  }

  Future<void> _removeCard(RemoveCardFromDeckById event, Emitter<CardDeckState> emit) async {
    emit(state.copyWith(isLoading: true));
    DeckModel deck = await _deckRepository.removeFlashCardFromSelectedDeckById(event.cardId);
    emit(state.copyWith(isLoading: false, deck: () => deck));
  }

  Future<void> _createNewFlashCard(CreateNewCard event, Emitter<CardDeckState> emit) async {
    emit(state.copyWith(isLoading: true));
    DeckModel deck = await _deckRepository.addFlashCard(question: event.question, answer: event.answer);
    emit(state.copyWith(isLoading: false, deck: () => deck));
  }

  Future<void> _editCard(EditCardEvent event, Emitter<CardDeckState> emit) async {
    emit(state.copyWith(isLoading: true));
    DeckModel deck =
        await _deckRepository.editFlashCard(cardId: event.cardId, question: event.question, answer: event.answer);
    emit(state.copyWith(isLoading: false, deck: () => deck));
  }

  Future<void> _setCurrentFlashCard(SetFlashCardForEditingOrCreating event, Emitter<CardDeckState> emit) async {
    bool isNewCard = event.cardId == null ? true : false;
    FlashCardModel? card = _deckRepository.setCurrentFlashCard(cardId: event.cardId);
    emit(state.copyWith(isLoading: false, isNewCard: isNewCard, currentCard: () => card));
  }

  Future<void> _removeCurrentCardAndDeckFromState(
      RemoveCurrentCardAndDeckFromState event, Emitter<CardDeckState> emit) async {
    emit(state.copyWith(currentCard: () => null, deckName: () => null));
  }
}
