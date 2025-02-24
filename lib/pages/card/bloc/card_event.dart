part of 'card_bloc.dart';

sealed class CreateCard {}

final class QuestionAnswerChanged extends CreateCard {
  final String question;
  final String answer;

  QuestionAnswerChanged({required this.question, required this.answer});
}

final class QuestionChanged extends CreateCard {
  final String question;

  QuestionChanged(this.question);
}

class AnswerChanged extends CreateCard {
  final String answer;

  AnswerChanged(this.answer);
}
