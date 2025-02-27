import 'package:bloc/bloc.dart';

part 'deck_event.dart';
part 'deck_state.dart';

class DeckBloc extends Bloc<DeckEvent, DeckState> {
  DeckBloc() : super(const DeckState()) {
    on<DeckNameChanged>(_onDeckNameChanged);
  }

  void _onDeckNameChanged(DeckNameChanged event, Emitter<DeckState> emit) {
    emit(
      state.copyWith(
        newDeckName: event.deckName,
        newDeckNameIsValid: _isValidDeckName(event.deckName),
      ),
    );
  }

  bool _isValidDeckName(String deckName) {
    return deckName.isNotEmpty;
  }
}
