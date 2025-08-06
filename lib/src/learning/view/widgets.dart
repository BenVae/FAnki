import 'dart:math' as math;
import 'package:card_repository/card_deck_manager.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../cubit/learning_cubit.dart';

Widget buildLearningCardView() {
  return Container(
    alignment: Alignment.bottomCenter,
    child: Column(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        BlocBuilder<LearningCubit, CardLearnState>(
          builder: (context, state) {
            if (state is CardLearningState) {
              return listOfLearningCardsAnimated(context, state);
            } else if (state is CardLoadingState) {
              return Center(
                child: CircularProgressIndicator(),
              );
            } else if (state is CardEmptyState) {
              return Center(
                child: Text('Keine Karten'),
              );
            } else {
              return Center(
                child: Text('Error z45424326'),
              );
            }
          },
        ),
      ],
    ),
  );
}

Widget listOfLearningCardsAnimated(
    BuildContext context, CardLearningState state) {
  return Expanded(
    child: AnimatedList(
      reverse: true,
      key: state.animatedListKey,
      initialItemCount: state.cards.length,
      padding: EdgeInsets.all(16),
      itemBuilder: (context, index, animation) {
        SingleCard card = state.cards[index];
        return SizeTransition(
          sizeFactor: animation,
          child: _FlashcardWidget(
            card: card,
            isAnswerVisible: state.answerIsVisible[index],
            onTap: () => context.read<LearningCubit>().toggleAnswerVisibility(index),
          ),
        );
      },
    ),
  );
}

class _FlashcardWidget extends StatefulWidget {
  final SingleCard card;
  final bool isAnswerVisible;
  final VoidCallback onTap;

  const _FlashcardWidget({
    required this.card,
    required this.isAnswerVisible,
    required this.onTap,
  });

  @override
  State<_FlashcardWidget> createState() => _FlashcardWidgetState();
}

class _FlashcardWidgetState extends State<_FlashcardWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _flipController;
  late Animation<double> _flipAnimation;

  @override
  void initState() {
    super.initState();
    _flipController = AnimationController(
      duration: Duration(milliseconds: 600),
      vsync: this,
    );
    _flipAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(
      parent: _flipController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void didUpdateWidget(_FlashcardWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isAnswerVisible != oldWidget.isAnswerVisible) {
      if (widget.isAnswerVisible) {
        _flipController.forward();
      } else {
        _flipController.reverse();
      }
    }
  }

  @override
  void dispose() {
    _flipController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 8, horizontal: 4),
      height: 300,
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedBuilder(
          animation: _flipAnimation,
          builder: (context, child) {
            final isShowingFront = _flipAnimation.value < 0.5;
            return Transform(
              alignment: Alignment.center,
              transform: Matrix4.identity()
                ..setEntry(3, 2, 0.001)
                ..rotateY(_flipAnimation.value * math.pi),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 10,
                      offset: Offset(0, 5),
                    ),
                  ],
                ),
                child: Card(
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Container(
                    padding: EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: isShowingFront
                            ? [Colors.blue.shade50, Colors.blue.shade100]
                            : [Colors.green.shade50, Colors.green.shade100],
                      ),
                    ),
                    child: Transform(
                      alignment: Alignment.center,
                      transform: Matrix4.identity()
                        ..rotateY(isShowingFront ? 0 : math.pi),
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            if (isShowingFront) ...[
                              Icon(
                                Icons.help_outline,
                                size: 32,
                                color: Colors.blue.shade700,
                              ),
                              SizedBox(height: 16),
                              Text(
                                widget.card.questionText,
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blue.shade900,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              SizedBox(height: 24),
                              Text(
                                'Tap to reveal answer',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.blue.shade600,
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                            ] else ...[
                              Icon(
                                Icons.lightbulb_outline,
                                size: 32,
                                color: Colors.green.shade700,
                              ),
                              SizedBox(height: 16),
                              Text(
                                widget.card.answerText,
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.green.shade900,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
