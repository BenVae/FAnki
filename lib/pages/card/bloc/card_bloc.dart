import 'package:bloc/bloc.dart';

part 'card_event.dart';
part 'card_state.dart';

class CardBloc extends Bloc<CreateCard, CardState> {
  CardBloc() : super(const CardState()) {
    on<QuestionChanged>(_onQuestionChanged);
    on<AnswerChanged>(_onAnswerChanged);
  }

  void _onQuestionChanged(QuestionChanged event, Emitter<CardState> emit) {
    final question = event.question;
    emit(
      state.copyWith(
        question: question,
        isCardValid: _isCardValid(question: question),
      ),
    );
  }

  void _onAnswerChanged(AnswerChanged event, Emitter<CardState> emit) {
    final answer = event.answer;
    emit(
      state.copyWith(
        answer: answer,
        isCardValid: _isCardValid(answer: answer),
      ),
    );
  }

  bool _isCardValid({String? question, String? answer}) {
    question ??= state.question;
    answer ??= state.answer;
    return question != null && answer != null && question.isNotEmpty && answer.isNotEmpty;
  }
}
