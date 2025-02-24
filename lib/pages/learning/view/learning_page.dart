import 'package:fanki/pages/learning/bloc/learning_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:deck_repository/deck_repository.dart';

class LearningPage extends StatefulWidget {
  const LearningPage({Key? key}) : super(key: key);

  @override
  _LearningPageState createState() => _LearningPageState();
}

class _LearningPageState extends State<LearningPage> {
  // Local list to hold revealed flashcards so you can scroll through previous ones.
  final List<FlashCardModel> _revealedCards = [];

  @override
  void initState() {
    super.initState();
    // Initialize learning. Make sure the LearningBloc is provided above this widget.
    context.read<LearningBloc>().add(InitializeLearning());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Learning')),
      body: BlocConsumer<LearningBloc, LearningState>(
        listener: (context, state) {
          // When a new card is selected, add it to the list if it's not already there.
          if (state.currentFlashCard != null && !_revealedCards.any((card) => card.id == state.currentFlashCard!.id)) {
            setState(() {
              _revealedCards.add(state.currentFlashCard!);
            });
          }
        },
        builder: (context, state) {
          if (state.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          // Display all revealed cards in a scrollable list.
          return ListView.builder(
            itemCount: _revealedCards.length,
            itemBuilder: (context, index) {
              final flashCard = _revealedCards[index];

              // Each flashcard is an ExpansionTile. Tapping it reveals the answer.
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                child: ExpansionTile(
                  title: Text(flashCard.question),
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text(flashCard.answer),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        // Tapping the FAB requests a new flashcard.
        onPressed: () {
          context.read<LearningBloc>().add(GetNextCard());
        },
        child: const Icon(Icons.navigate_next),
      ),
    );
  }
}
