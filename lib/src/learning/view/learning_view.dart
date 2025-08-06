import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubit/learning_cubit.dart';
import 'widgets.dart';

class LearningView extends StatelessWidget {
  const LearningView({super.key});

  @override
  Widget build(BuildContext context) {
    LearningCubit learningCubit = context.read<LearningCubit>();
    learningCubit.checkAndReloadDeck();
    return Column(
      children: [
        SizedBox(height: 8),
        BlocBuilder<LearningCubit, CardLearnState>(
          builder: (context, state) {
            if (state is CardLearningState) {
              return Container(
                margin: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Progress',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          '${state.cardsReviewed} / ${state.totalCards} cards',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: LinearProgressIndicator(
                        value: state.totalCards > 0 
                            ? state.cardsReviewed / state.totalCards 
                            : 0,
                        backgroundColor: Colors.grey.shade200,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          Colors.blue.shade400,
                        ),
                        minHeight: 8,
                      ),
                    ),
                  ],
                ),
              );
            }
            return SizedBox.shrink();
          },
        ),
        Expanded(
          child: Center(
            child: buildLearningCardView(),
          ),
        ),
        SizedBox(height: 16),
        BlocBuilder<LearningCubit, CardLearnState>(
          builder: (context, state) {
            final isAnswerVisible = state is CardLearningState && 
                state.answerIsVisible.isNotEmpty && 
                state.answerIsVisible[0];
            
            return AnimatedOpacity(
              opacity: isAnswerVisible ? 1.0 : 0.3,
              duration: Duration(milliseconds: 300),
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _DifficultyButton(
                      label: 'Again',
                      color: Colors.red.shade400,
                      onPressed: isAnswerVisible 
                          ? () => toggleOrAdvanceCard(learningCubit)
                          : null,
                    ),
                    SizedBox(width: 8),
                    _DifficultyButton(
                      label: 'Hard',
                      color: Colors.orange.shade400,
                      onPressed: isAnswerVisible 
                          ? () => toggleOrAdvanceCard(learningCubit)
                          : null,
                    ),
                    SizedBox(width: 8),
                    _DifficultyButton(
                      label: 'Good',
                      color: Colors.blue.shade400,
                      onPressed: isAnswerVisible 
                          ? () => toggleOrAdvanceCard(learningCubit)
                          : null,
                    ),
                    SizedBox(width: 8),
                    _DifficultyButton(
                      label: 'Easy',
                      color: Colors.green.shade400,
                      onPressed: isAnswerVisible 
                          ? () => toggleOrAdvanceCard(learningCubit)
                          : null,
                    ),
                  ],
                ),
              ),
            );
          },
        ),
        SizedBox(height: 50),
      ],
    );
  }

  void toggleOrAdvanceCard(LearningCubit cubit) {
    final state = cubit.state;

    if (state is CardLearningState) {
      if (state.answerIsVisible[0]) {
        cubit.nextCard();
      } else {
        cubit.toggleAnswerVisibility(0);
      }
    } else {
      cubit.toggleAnswerVisibility(0);
    }
  }
}

class _DifficultyButton extends StatelessWidget {
  final String label;
  final Color color;
  final VoidCallback? onPressed;

  const _DifficultyButton({
    required this.label,
    required this.color,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Material(
        color: onPressed != null ? color : Colors.grey.shade300,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Center(
              child: Text(
                label,
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
