import 'package:bloc/bloc.dart';
import 'package:deck_repository/deck_repository.dart';

import '../models/models.dart';

part 'deck_selection_event.dart';
part 'deck_selection_state.dart';

class DeckSelectionBloc extends Bloc<DeckSelectionEvent, DeckSelectionState> {
  final DeckRepository _deckRepository;

  DeckSelectionBloc({required DeckRepository deckRepository})
      : _deckRepository = deckRepository,
        super(const DeckSelectionState()) {
    on<FetchDecks>(_onFetchDecks);
    on<SelectDeckEvent>(_onSelectDeck);
    on<ResetState>(_onResetState);

    on<SyncDecksEvent>(_onSyncDecksEvent);

    on<DeckNameInputChange>(_onDeckNameInputChanged);
    on<CreateDeck>(_onCreateDeck);
  }

  Future<void> _onSyncDecksEvent(
      SyncDecksEvent event, Emitter<DeckSelectionState> emit) async {
    emit(state.copyWith(isLoading: true));
    try {
      await _deckRepository.syncWithSupabase();
    } catch (e) {
      emit(state.copyWith(isLoading: false));
      return;
    }
    add(FetchDecks());
  }

  Future<void> _onFetchDecks(
      FetchDecks event, Emitter<DeckSelectionState> emit) async {
    emit(state.copyWith(isLoading: true));
    List<String> deckNamesFromRepo = await _deckRepository.getDeckNames();
    List<DeckName> deckNames = [];
    for (String deckName in deckNamesFromRepo) {
      deckNames.add(DeckName.dirty(deckName));
    }
    emit(state.copyWith(isLoading: false, decks: deckNames));
  }

  Future<void> _onSelectDeck(
      SelectDeckEvent event, Emitter<DeckSelectionState> emit) async {
    emit(state.copyWith(isLoading: true));
    try {
      await _deckRepository.setCurrentDeckByName(event.deckName);
    } catch (e) {
      emit(state.copyWith(isLoading: false, isCurrentDeckSelected: false));
      return;
    }
    emit(state.copyWith(
        isLoading: false, isCurrentDeckSelected: true, purpose: event.purpose));
  }

  Future<void> _onResetState(
      ResetState event, Emitter<DeckSelectionState> emit) async {
    emit(state.copyWith(
        isLoading: false,
        isCurrentDeckSelected: false,
        purpose: SelectDeckPurpose.selecting));
  }

  Future<void> _onDeckNameInputChanged(
      DeckNameInputChange event, Emitter<DeckSelectionState> emit) async {
    final deckName = DeckName.dirty(event.deckName);
    final deckNameIsUsed = await _deckRepository.isDeckNameUsed(event.deckName);
    final deckNameIsValid = deckName.isValid && !deckNameIsUsed;
    emit(state.copyWith(
        nameOfNewDeck: deckName, newDeckNameIsValid: deckNameIsValid));
  }

  Future<void> _onCreateDeck(
      CreateDeck event, Emitter<DeckSelectionState> emit) async {
    String deckName = state.nameOfNewDeck.value;
    await _deckRepository.createDeck(deckName);
    add(FetchDecks());
    emit(state.copyWith(nameOfNewDeck: DeckName.pure()));
  }
}
