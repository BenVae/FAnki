import 'package:bloc/bloc.dart';

part 'deck_event.dart';
part 'deck_state.dart';

class DeckBloc extends Bloc<DeckEvent, DeckState> {
  DeckBloc() : super(const DeckState()) {
    on<InitDeckEvent>(_onInitBlocState);
    on<DeckNameChanged>(_onDeckNameChanged);
  }

  void _onInitBlocState(InitDeckEvent event, Emitter<DeckState> emit) {
    emit(
      state.copyWith(
        originalName: event.deckName,
        newDeckName: event.deckName,
        newDeckNameIsValid: _isValidDeckName(event.deckName),
      ),
    );
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
}
