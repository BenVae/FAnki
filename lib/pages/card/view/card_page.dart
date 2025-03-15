import 'package:fanki/pages/card/bloc/card_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class CardPage extends StatefulWidget {
  const CardPage({super.key});

  @override
  State<CardPage> createState() => _CardPageState();
}

class _CardPageState extends State<CardPage> {
  late final TextEditingController _questionTextEditingController;
  late final TextEditingController _answerTextEditingController;

  @override
  void initState() {
    super.initState();

    final currentFlashCard = context.read<CardBloc>().state.card;

    if (currentFlashCard != null) {
      context.read<CardBloc>().add(QuestionChanged(currentFlashCard.question));
      context.read<CardBloc>().add(AnswerChanged(currentFlashCard.answer));

      _questionTextEditingController =
          TextEditingController(text: currentFlashCard.question);
      _answerTextEditingController =
          TextEditingController(text: currentFlashCard.answer);
    } else {
      _questionTextEditingController = TextEditingController();
      _answerTextEditingController = TextEditingController();
    }
  }

  @override
  void dispose() {
    _questionTextEditingController.dispose();
    _answerTextEditingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cardBlocState = context.watch<CardBloc>().state;

    return Scaffold(
      appBar: AppBar(
        title: cardBlocState.card == null
            ? const Text('Create Flashcard')
            : const Text('Edit Flashcard'),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            context.read<CardBloc>().add(RemoveCurrentCardAndDeckFromState());
            context.pop();
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: BlocBuilder<CardBloc, CardState>(
          builder: (context, cardState) {
            return ListView(
              children: [
                Card(
                  elevation: 2.0,
                  margin: const EdgeInsets.only(bottom: 16.0),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: TextField(
                      decoration: const InputDecoration(
                        labelText: 'Question',
                        border: OutlineInputBorder(),
                      ),
                      controller: _questionTextEditingController,
                      onChanged: (question) => context
                          .read<CardBloc>()
                          .add(QuestionChanged(question)),
                    ),
                  ),
                ),
                Card(
                  elevation: 2.0,
                  margin: const EdgeInsets.only(bottom: 16.0),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: TextField(
                      decoration: const InputDecoration(
                        labelText: 'Answer',
                        border: OutlineInputBorder(),
                      ),
                      controller: _answerTextEditingController,
                      onChanged: (answer) =>
                          context.read<CardBloc>().add(AnswerChanged(answer)),
                    ),
                  ),
                ),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: cardState.isCardValid
                            ? () {
                                if (cardBlocState.card == null) {
                                  context.read<CardBloc>().add(
                                        CreateNewCard(
                                          question: cardState.question ?? '',
                                          answer: cardState.answer ?? '',
                                        ),
                                      );
                                } else {
                                  context.read<CardBloc>().add(
                                        UpdateCard(
                                          question: cardState.question ?? '',
                                          answer: cardState.answer ?? '',
                                        ),
                                      );
                                }
                                context.pop();
                              }
                            : null,
                        child: const Text('Save Flashcard'),
                      ),
                    ),
                    const SizedBox(width: 16.0),
                    if (cardBlocState.card != null)
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                const Color.fromARGB(255, 206, 76, 66),
                          ),
                          onPressed: () {
                            context
                                .read<CardBloc>()
                                .add(RemoveCurrentCardAndDeckFromState());
                            context.pop();
                          },
                          child: const Text('Delete Card'),
                        ),
                      ),
                  ],
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
