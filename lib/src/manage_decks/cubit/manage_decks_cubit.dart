import 'package:bloc/bloc.dart';
import 'package:card_repository/card_deck_manager.dart';

import '../../main.dart';

class ManageDecksCubit extends Cubit<DeckState> {
  final CardDeckManager _cdm;
  int _selectedDeckIndex = -1;

  ManageDecksCubit({required CardDeckManager cardDeckManager})
      : _cdm = cardDeckManager,
        super(DeckStateLoading()) {
    loadDeckNames();
  }

  void selectDeck(String deckName) {
    if (state is DeckStateFinished) {
      DeckStateFinished currentState = state as DeckStateFinished;
      final selectedDeck = _cdm.deckNames.indexOf(deckName);
      _cdm.setCurrentDeck(deckName);
      emit(currentState.copyWith(
        selectedDeck: selectedDeck,
        cardCounts: _cdm.deckCardCounts,
      ));
    } else if (state is DeckStateLoading) {
      _selectedDeckIndex = _cdm.deckNames.indexOf(deckName);
    } else {
      log.severe('Error 73462432');
    }
  }

  void loadDeckNames() async {
    emit(DeckStateLoading());
    _cdm.getCurrentDeckCards();
    selectDeck(_cdm.currentDeckName);
    emit(DeckStateFinished(
      deckNames: _cdm.deckNames, 
      selectedDeck: _selectedDeckIndex,
      cardCounts: _cdm.deckCardCounts,
    ));
  }

  void createDeck(String deckName) {
    _cdm.createDeck(deckName);
    loadDeckNames();
  }

  void removeDeck(String deckName) {
    if (deckIsSelectedDeck(deckName)) {
      if (_cdm.deckNames.length > 1) {
        int newSelectedDeckIndex =
            _cdm.deckNames.indexOf(deckName) == 0 ? 1 : 0;
        String newSelectedDeckName = _cdm.deckNames[newSelectedDeckIndex];
        selectDeck(newSelectedDeckName);
      } else {
        _selectedDeckIndex = -1;
        _cdm.setCurrentDeck('');
      }
    }
    _cdm.removeDeck(deckName);
    loadDeckNames();
  }

  bool deckIsSelectedDeck(String deckName) {
    if (_selectedDeckIndex == _cdm.deckNames.indexOf(deckName)) {
      return true;
    }
    return false;
  }
}

abstract class DeckState {}

class DeckStateFinished extends DeckState {
  final List<String> deckNames;
  final int selectedDeck;
  final Map<String, int> cardCounts;

  DeckStateFinished({
    required this.deckNames,
    required this.selectedDeck,
    required this.cardCounts,
  });

  DeckState copyWith({
    List<String>? deckNames,
    int? selectedDeck,
    Map<String, int>? cardCounts,
  }) {
    return DeckStateFinished(
      deckNames: deckNames ?? this.deckNames,
      selectedDeck: selectedDeck ?? this.selectedDeck,
      cardCounts: cardCounts ?? this.cardCounts,
    );
  }

  List<String> get getDeckNames => deckNames;
}

class DeckStateLoading extends DeckState {}

class DeckStateError extends DeckState {}
