import 'package:bloc/bloc.dart';
import 'package:deck_repository/deck_repository.dart';

part 'deck_event.dart';
part 'deck_state.dart';

class DeckBloc extends Bloc<DeckEvent, DeckState> {
  final DeckRepository _deckRepository;

  DeckBloc({required DeckRepository deckRepository})
      : _deckRepository = deckRepository,
        super(const DeckState()) {
    on<InitDeckEvent>(_onInitBlocState);
    on<DeckNameChanged>(_onDeckNameChanged);
    on<RenameDeckEvent>(_onRenameDeck);
  }

  void _onInitBlocState(InitDeckEvent event, Emitter<DeckState> emit) {
    try {
      String deckName = _deckRepository.getCurrentDeckName();
      DeckModel deck = _deckRepository.getCurrentDeck();
      emit(
        state.copyWith(
          originalName: deckName,
          newDeckName: deckName,
          newDeckNameIsValid: _isValidDeckName(deckName),
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
  }

  void _onDeckNameChanged(DeckNameChanged event, Emitter<DeckState> emit) {
    bool isValidDeckName = _isValidDeckName(event.deckName);
    emit(
      state.copyWith(
        newDeckName: event.deckName,
        newDeckNameIsValid: isValidDeckName,
      ),
    );
  }

  bool _isValidDeckName(String deckName) {
    return deckName.isNotEmpty && deckName != state.originalName;
  }

  Future<void> _onRenameDeck(
      RenameDeckEvent event, Emitter<DeckState> emit) async {
    emit(state.copyWith(isLoading: true));
    await _deckRepository.renameDeck(newDeckName: event.newDeckName);
    DeckModel deck = _deckRepository.getCurrentDeck();
    emit(state.copyWith(isLoading: false, deck: deck));
  }
}
