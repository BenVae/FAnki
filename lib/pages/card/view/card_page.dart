import 'package:fanki/blocs/card_deck/bloc/card_deck_bloc.dart';
import 'package:fanki/pages/card/card.dart';
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
    final currentFlashCard = context.read<CardDeckBloc>().state.currentFlashCard;
    if (currentFlashCard != null) {
      _questionTextEditingController = TextEditingController(text: currentFlashCard.question);
      _answerTextEditingController = TextEditingController(text: currentFlashCard.answer);
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create/Edit Flashcard'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: BlocBuilder<CardDeckBloc, CardDeckState>(
          builder: (context, cardDeckState) {
            return BlocBuilder<CardBloc, CardState>(
              builder: (context, cardState) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    TextField(
                      decoration: const InputDecoration(
                        labelText: 'Question',
                        border: OutlineInputBorder(),
                      ),
                      controller: _questionTextEditingController,
                      onChanged: (question) => context.read<CardBloc>().add(QuestionChanged(question)),
                    ),
                    const SizedBox(height: 16.0),
                    TextField(
                      decoration: const InputDecoration(
                        labelText: 'Answer',
                        border: OutlineInputBorder(),
                      ),
                      controller: _answerTextEditingController,
                      onChanged: (answer) => context.read<CardBloc>().add(AnswerChanged(answer)),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        ElevatedButton(
                          onPressed: cardState.isCardValid
                              ? () {
                                  context
                                      .read<CardDeckBloc>()
                                      .add(CreateNewCard(question: cardState.question!, answer: cardState.answer!));
                                  context.go('/HomeTabView/DeckPage');
                                }
                              : null,
                          child: const Text('Save Flashcard'),
                        ),
                        if (!cardDeckState.isNewCard && cardDeckState.currentFlashCard != null)
                          ElevatedButton(
                            onPressed: () {
                              context.read<CardDeckBloc>().add(
                                    RemoveCardFromDeckById(cardId: cardDeckState.currentFlashCard!.id),
                                  );
                              context.go('/HomeTabView/DeckPage');
                            },
                            child: const Text('Delete Card'),
                          ),
                      ],
                    ),
                  ],
                );
              },
            );
          },
        ),
      ),
    );
  }
}
