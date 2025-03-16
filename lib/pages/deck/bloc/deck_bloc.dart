import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:deck_repository/deck_repository.dart';
import 'package:flutter/foundation.dart';

part 'deck_event.dart';
part 'deck_state.dart';

class DeckBloc extends Bloc<DeckEvent, DeckState> {
  final DeckRepository _deckRepository;
  late final StreamSubscription<EditingCardStatus> _subscription;

  DeckBloc({required DeckRepository deckRepository})
      : _deckRepository = deckRepository,
        super(const DeckState()) {
    on<InitDeckEvent>(_onInitBlocState);
    on<DeckNameChanged>(_onDeckNameChanged);
    on<RenameDeckEvent>(_onRenameDeck);
    on<DeleteDeckEvent>(_onDeleteDeck);
    on<EditCardEvent>(_onEditCard);
    on<CreateCardEvent>(_onCreateCard);
  }

  void _onInitBlocState(InitDeckEvent event, Emitter<DeckState> emit) async {
    try {
      String deckName = _deckRepository.getCurrentDeckName();
      DeckModel deck = _deckRepository.getCurrentDeck();
      emit(
        state.copyWith(
          originalName: deckName,
          newDeckName: deckName,
          isNewDeckNameValid: false,
          deck: deck,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          deck: null,
        ),
      );
    }

    await emit.forEach<EditingCardStatus>(
      _deckRepository.editingCardStatus,
      onData: (status) {
        switch (status) {
          case EditingCardStatus.init:
            return state.copyWith(isCardForEditingSelected: EditingCardStatus.init);
          case EditingCardStatus.editing:
            return state.copyWith(isCardForEditingSelected: EditingCardStatus.editing);
          case EditingCardStatus.notEditing:
            return state.copyWith(isCardForEditingSelected: EditingCardStatus.notEditing);
        }
      },
      onError: (error, stackTrace) {
        addError(error, stackTrace);
        return state;
      },
    );
  }

  void _onDeckNameChanged(DeckNameChanged event, Emitter<DeckState> emit) {
    bool isValidDeckName = _isValidDeckName(event.deckName);
    emit(
      state.copyWith(
        newDeckName: event.deckName,
        isNewDeckNameValid: isValidDeckName,
      ),
    );
  }

  bool _isValidDeckName(String deckName) {
    return deckName.isNotEmpty && deckName != state.originalName;
  }

  Future<void> _onRenameDeck(RenameDeckEvent event, Emitter<DeckState> emit) async {
    emit(state.copyWith(isLoading: true));
    await _deckRepository.renameDeck(newDeckName: event.newDeckName);
    DeckModel deck = _deckRepository.getCurrentDeck();
    emit(state.copyWith(isLoading: false, deck: deck));
  }

  Future<void> _onDeleteDeck(DeleteDeckEvent event, Emitter<DeckState> emit) async {
    emit(state.copyWith(isLoading: true));
    await _deckRepository.deleteCurrentDeck();
    emit(state.copyWith(isLoading: false, deck: null));
  }

  Future<void> _onEditCard(EditCardEvent event, Emitter<DeckState> emit) async {
    try {
      _deckRepository.setCurrentFlashCard(cardId: event.cardId);
    } catch (e) {
      //TODO Fehlermeldung hinzufügen
      emit(state.copyWith(isLoading: false, isCardForEditingSelected: EditingCardStatus.notEditing));
    }
    emit(state.copyWith(isLoading: false, isCardForEditingSelected: EditingCardStatus.editing));
  }

  Future<void> _onCreateCard(CreateCardEvent event, Emitter<DeckState> emit) async {
    emit(state.copyWith(isLoading: false));
  }

  @override
  Future<void> close() async {
    // await _subscription.cancel();
    super.close();
  }
}
