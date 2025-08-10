import 'package:flutter_bloc/flutter_bloc.dart';

enum NavigationState { decks, stats, settings, learning }

class NavigationCubit extends Cubit<NavigationState> {
  NavigationCubit() : super(NavigationState.decks);
  
  NavigationState? _previousState;

  void goToDecks() {
    _previousState = state;
    emit(NavigationState.decks);
  }
  
  void goToStats() {
    _previousState = state;
    emit(NavigationState.stats);
  }

  void goToSettings() {
    _previousState = state;
    emit(NavigationState.settings);
  }
  
  void goToLearning() {
    _previousState = state;
    emit(NavigationState.learning);
  }
  
  void goBack() {
    if (_previousState != null) {
      emit(_previousState!);
    } else {
      emit(NavigationState.decks); // Default to decks view
    }
  }
}
