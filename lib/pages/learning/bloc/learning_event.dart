part of 'learning_bloc.dart';

sealed class LearningEvent {}

final class InitializeLearning extends LearningEvent {}

final class GetNextCard extends LearningEvent {}
