import 'package:fanki/pages/learning/bloc/learning_bloc.dart';
import 'package:fanki/pages/widgets/flashcard.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class LearningPage extends StatefulWidget {
  const LearningPage({super.key});

  @override
  State<LearningPage> createState() => _LearningPageState();
}

class _LearningPageState extends State<LearningPage> {
  late final GlobalKey<AnimatedListState> _animatedListKey = GlobalKey();
  late final ScrollController _scrollController = ScrollController();

  void _addItem(int index) {
    // index = 0;
    _animatedListKey.currentState?.insertItem(
      index,
      duration: const Duration(milliseconds: 100),
    );
  }

  @override
  void initState() {
    super.initState();
    context.read<LearningBloc>().add(InitializeLearning());
  }

  @override
  void dispose() {
    _scrollController.dispose();
    // context.read<LearningBloc>().close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: BlocBuilder<LearningBloc, LearningState>(
          builder: (context, state) {
            return Text(state.deckName);
          },
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            context.go('/HomeTabView');
          },
        ),
      ),
      body: BlocConsumer<LearningBloc, LearningState>(
        listenWhen: (previous, current) {
          return current.revealedCards.isNotEmpty && previous.revealedCards.length < current.revealedCards.length;
        },
        listener: (context, state) => _addItem(state.revealedCards.length - 1),
        builder: (context, state) {
          if (state.isLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state.flashCards.isEmpty) {
            return const Center(child: Text('There are no cards in this deck.'));
          } else {
            return AnimatedList(
              key: _animatedListKey,
              controller: _scrollController,
              reverse: true,
              initialItemCount: state.revealedCards.length,
              itemBuilder: (context, index, animation) {
                final flashCard = state.revealedCards[index];
                return SizeTransition(
                  sizeFactor: animation,
                  child: GestureDetector(
                    onTap: () => context.read<LearningBloc>().add(ToggleAnswerVisibility(cardIndex: index)),
                    child: FlashCard(
                      id: flashCard.id,
                      question: flashCard.question,
                      answer: flashCard.answer,
                      visible: state.revealedCardsVisibility.isEmpty ? false : state.revealedCardsVisibility[index],
                    ),
                  ),
                );
              },
            );
          }
        },
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 30),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildOptionButton(context, 'Easy'),
            const SizedBox(width: 8),
            _buildOptionButton(context, 'Normal'),
            const SizedBox(width: 8),
            _buildOptionButton(context, 'Hard'),
            const SizedBox(width: 8),
            _buildOptionButton(context, 'Difficult'),
          ],
        ),
      ),
    );
  }

  Expanded _buildOptionButton(BuildContext context, String label) {
    return Expanded(
      child: ElevatedButton(
        onPressed: () {
          final revealedCardsVisibility = context.read<LearningBloc>().state.revealedCardsVisibility;
          if (revealedCardsVisibility.isEmpty || revealedCardsVisibility.first) {
            context.read<LearningBloc>().add(GetNextCard());
          } else {
            final cardIndex = 0;
            context.read<LearningBloc>().add(ToggleAnswerVisibility(cardIndex: cardIndex));
          }
        },
        child: Text(label),
      ),
    );
  }
}
