import 'package:flutter_bloc/flutter_bloc.dart';

enum NavigationState { learning, createCards, decks, stats, login }

class NavigationCubit extends Cubit<NavigationState> {
  NavigationCubit() : super(NavigationState.login);

  void goToCreateCards() => emit(NavigationState.createCards);

  void goToLearning() => emit(NavigationState.learning);

  void goToDecks() => emit(NavigationState.decks);
  
  void goToStats() => emit(NavigationState.stats);

  void goToLogin() => emit(NavigationState.login);
}
