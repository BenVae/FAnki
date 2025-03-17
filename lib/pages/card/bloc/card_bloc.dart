import 'package:bloc/bloc.dart';
import 'package:deck_repository/deck_repository.dart';

part 'card_event.dart';
part 'card_state.dart';

enum EditingCardStatus { init, editing, notEditing }

class CardBloc extends Bloc<CreateCard, CardState> {
  final DeckRepository _deckRepository;

  CardBloc({required DeckRepository deckRepository})
      : _deckRepository = deckRepository,
        super(const CardState()) {
    on<InitCard>(_onInitBlocState);
    on<RemoveCurrentCardAndDeckFromState>(_onRemoveCurrentCardAndDeckFromState);
    on<CreateNewCard>(_onCreateNewCard);
    on<UpdateCard>(_onUpdateCard);

    on<QuestionAnswerChanged>(_onQuestionAndAnswerChanged);
    on<QuestionChanged>(_onQuestionChanged);
    on<AnswerChanged>(_onAnswerChanged);
  }

  void _onInitBlocState(InitCard event, Emitter<CardState> emit) {
    final card = _deckRepository.getCurrentFlashCard();
    emit(
      state.copyWith(
        card: card,
        question: card?.question,
        answer: card?.answer,
        isCardValid: _isCardValid(question: card?.question, answer: card?.answer),
      ),
    );
  }

  void _onRemoveCurrentCardAndDeckFromState(RemoveCurrentCardAndDeckFromState event, Emitter<CardState> emit) {
    if (state.card != null) {
      _deckRepository.removeFlashCardFromSelectedDeckById(state.card!.id);
    }
    emit(state.copyWith(isLoading: false, card: null, question: null, answer: null));
  }

  Future<void> _onCreateNewCard(CreateNewCard event, Emitter<CardState> emit) async {
    emit(state.copyWith(isLoading: true));
    bool success = await _deckRepository.addFlashCard(question: event.question, answer: event.answer);
    emit(state.copyWith(isLoading: false, isEditingDone: success));
  }

  Future<void> _onUpdateCard(UpdateCard event, Emitter<CardState> emit) async {
    emit(state.copyWith(isLoading: true));
    bool success =
        await _deckRepository.updateFlashCard(cardId: state.card!.id, question: state.question!, answer: state.answer!);
    emit(state.copyWith(isLoading: false, isEditingDone: success));
  }

  void _onQuestionAndAnswerChanged(QuestionAnswerChanged event, Emitter<CardState> emit) {
    final question = event.question;
    final answer = event.answer;
    emit(
      state.copyWith(
        question: question,
        answer: answer,
        isCardValid: _isCardValid(question: question, answer: answer),
      ),
    );
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

  void onGoingBack() {
    // _deckRepository.startEditingCard(EditingCardStatus.notEditing);
  }

  bool _isCardValid({String? question, String? answer}) {
    question ??= state.question;
    answer ??= state.answer;
    return question != null && answer != null && question.isNotEmpty && answer.isNotEmpty;
  }

  @override
  Future<void> close() async {
    super.close();
  }
}
