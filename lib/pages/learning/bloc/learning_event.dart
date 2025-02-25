part of 'learning_bloc.dart';

sealed class LearningEvent {}

final class InitializeLearning extends LearningEvent {
  String deckName;

  InitializeLearning({required this.deckName});
}

final class GetNextCard extends LearningEvent {}
