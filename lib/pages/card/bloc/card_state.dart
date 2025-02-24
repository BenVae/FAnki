part of 'card_bloc.dart';

final class CardState {
  final bool isLoading;
  final String? question;
  final String? answer;
  final bool isCardValid;

  const CardState({this.isLoading = false, this.question, this.answer, this.isCardValid = false});

  CardState copyWith({
    bool? isLoading,
    String? question,
    String? answer,
    bool? isCardValid,
  }) {
    return CardState(
      isLoading: isLoading ?? this.isLoading,
      question: question ?? this.question,
      answer: answer ?? this.answer,
      isCardValid: isCardValid ?? this.isCardValid,
    );
  }
}
