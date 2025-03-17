part of 'learning_bloc.dart';

sealed class LearningEvent {}

final class InitializeLearning extends LearningEvent {}

final class GetNextCard extends LearningEvent {}

final class ToggleAnswerVisibility extends LearningEvent {
  int cardIndex;

  ToggleAnswerVisibility({required this.cardIndex});
}
