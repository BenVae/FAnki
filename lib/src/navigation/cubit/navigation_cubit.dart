import 'package:flutter_bloc/flutter_bloc.dart';

enum NavigationState { learning, createCards, decks, stats, login }

class NavigationCubit extends Cubit<NavigationState> {
  NavigationCubit() : super(NavigationState.login);
  
  NavigationState? _previousState;

  void goToCreateCards() {
    _previousState = state;
    emit(NavigationState.createCards);
  }

  void goToLearning() {
    _previousState = state;
    emit(NavigationState.learning);
  }

  void goToDecks() {
    _previousState = state;
    emit(NavigationState.decks);
  }
  
  void goToStats() {
    _previousState = state;
    emit(NavigationState.stats);
  }

  void goToLogin() {
    _previousState = state;
    emit(NavigationState.login);
  }
  
  void goBack() {
    if (_previousState != null && _previousState != NavigationState.learning) {
      emit(_previousState!);
    } else {
      emit(NavigationState.decks); // Default to decks view
    }
  }
}
