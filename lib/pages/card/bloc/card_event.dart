part of 'card_bloc.dart';

sealed class CreateCard {}

final class InitCard extends CreateCard {}

final class RemoveCurrentCardAndDeckFromState extends CreateCard {}

final class CreateNewCard extends CreateCard {
  final String question;
  final String answer;

  CreateNewCard({required this.question, required this.answer});
}

final class UpdateCard extends CreateCard {
  final String question;
  final String answer;

  UpdateCard({required this.question, required this.answer});
}

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
