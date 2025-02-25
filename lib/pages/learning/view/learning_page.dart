import 'package:fanki/pages/learning/bloc/learning_bloc.dart';
import 'package:fanki/pages/widgets/flashcard.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class LearningPage extends StatefulWidget {
  const LearningPage({super.key});

  @override
  State<LearningPage> createState() => _LearningPageState();
}

class _LearningPageState extends State<LearningPage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Learning'),
        centerTitle: true,
      ),
      body: BlocBuilder<LearningBloc, LearningState>(
        builder: (context, state) {
          if (state.isLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state.flashCards.isEmpty) {
            return const Center(child: Text('There are no cards in this deck.'));
          } else {
            return ListView.builder(
              shrinkWrap: true,
              itemCount: state.revealedCards.length,
              itemBuilder: (context, index) {
                final flashCard = state.revealedCards[index];
                return GestureDetector(
                  onTap: () => context.read<LearningBloc>().add(ToggleAnswerVisibility(cardIndex: index)),
                  child: FlashCard(
                    id: flashCard.id,
                    question: flashCard.question,
                    answer: flashCard.answer,
                    visible: state.revealedCardsVisibility.isEmpty ? false : state.revealedCardsVisibility[index],
                  ),
                );
              },
            );
          }
        },
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Expanded(
              child: ElevatedButton(
                onPressed: () {
                  if (context.read<LearningBloc>().state.revealedCardsVisibility.last) {
                    context.read<LearningBloc>().add(GetNextCard());
                  } else {
                    int cardIndex = context.read<LearningBloc>().state.revealedCardsVisibility.length - 1;
                    context.read<LearningBloc>().add(ToggleAnswerVisibility(cardIndex: cardIndex));
                  }
                },
                child: const Text('Easy'),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: ElevatedButton(
                onPressed: () {
                  if (context.read<LearningBloc>().state.revealedCardsVisibility.last) {
                    context.read<LearningBloc>().add(GetNextCard());
                  } else {
                    int cardIndex = context.read<LearningBloc>().state.revealedCardsVisibility.length - 1;
                    context.read<LearningBloc>().add(ToggleAnswerVisibility(cardIndex: cardIndex));
                  }
                },
                child: const Text('Normal'),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: ElevatedButton(
                onPressed: () {
                  if (context.read<LearningBloc>().state.revealedCardsVisibility.last) {
                    context.read<LearningBloc>().add(GetNextCard());
                  } else {
                    int cardIndex = context.read<LearningBloc>().state.revealedCardsVisibility.length - 1;
                    context.read<LearningBloc>().add(ToggleAnswerVisibility(cardIndex: cardIndex));
                  }
                },
                child: const Text('Hard'),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: ElevatedButton(
                onPressed: () {
                  if (context.read<LearningBloc>().state.revealedCardsVisibility.last) {
                    context.read<LearningBloc>().add(GetNextCard());
                  } else {
                    int cardIndex = context.read<LearningBloc>().state.revealedCardsVisibility.length - 1;
                    context.read<LearningBloc>().add(ToggleAnswerVisibility(cardIndex: cardIndex));
                  }
                },
                child: const Text('Difficult'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
