import 'dart:io';
import 'package:bloc/bloc.dart';
import 'package:card_repository/card_deck_manager.dart';

// States
abstract class AiImportState {}

class AiImportInitial extends AiImportState {}

class AiImportPdfSelected extends AiImportState {
  final String fileName;
  AiImportPdfSelected(this.fileName);
}

class AiImportProcessing extends AiImportState {}

class AiImportPreview extends AiImportState {
  final List<SingleCard> cards;
  final String suggestedDeckName;
  
  AiImportPreview(this.cards, this.suggestedDeckName);
}

class AiImportSaving extends AiImportState {}

class AiImportSuccess extends AiImportState {
  final int cardCount;
  AiImportSuccess(this.cardCount);
}

class AiImportError extends AiImportState {
  final String message;
  AiImportError(this.message);
}

// Cubit
class AiImportCubit extends Cubit<AiImportState> {
  AiImportCubit({required this.cardDeckManager}) : super(AiImportInitial());

  final CardDeckManager cardDeckManager;
  File? selectedPdf;
  List<SingleCard> generatedCards = [];
  String suggestedDeckName = '';

  void selectPdf(File file) {
    selectedPdf = file;
    emit(AiImportPdfSelected(file.path.split('/').last));
  }

  void clearSelection() {
    selectedPdf = null;
    generatedCards = [];
    suggestedDeckName = '';
    emit(AiImportInitial());
  }

  Future<void> generateCards() async {
    if (selectedPdf == null) return;
    
    emit(AiImportProcessing());
    
    try {
      // TODO: Implement actual PDF processing and AI generation
      await Future.delayed(Duration(seconds: 3)); // Simulate processing
      
      // Mock generated cards for now
      generatedCards = [
        SingleCard(
          deckName: 'AI Generated',
          questionText: 'What is Flutter?',
          answerText: 'A cross-platform UI framework by Google',
        ),
        SingleCard(
          deckName: 'AI Generated',
          questionText: 'What is BLoC pattern?',
          answerText: 'Business Logic Component - a state management pattern',
        ),
      ];
      
      suggestedDeckName = 'Flutter Basics';
      
      emit(AiImportPreview(generatedCards, suggestedDeckName));
    } catch (e) {
      emit(AiImportError(e.toString()));
    }
  }

  void removeCard(String cardId) {
    generatedCards = generatedCards.where((card) => card.id != cardId).toList();
    emit(AiImportPreview(generatedCards, suggestedDeckName));
  }

  void updateCard(String cardId, String question, String answer) {
    final index = generatedCards.indexWhere((card) => card.id == cardId);
    if (index != -1) {
      generatedCards[index].questionText = question;
      generatedCards[index].answerText = answer;
      emit(AiImportPreview(generatedCards, suggestedDeckName));
    }
  }

  void updateDeckName(String name) {
    suggestedDeckName = name;
    emit(AiImportPreview(generatedCards, suggestedDeckName));
  }

  Future<void> addCardsToDecks(String deckName) async {
    emit(AiImportSaving());
    
    try {
      // Set the current deck name
      cardDeckManager.currentDeckName = deckName;
      
      // Add each card to the deck
      for (var card in generatedCards) {
        cardDeckManager.addCardWithQA(
          card.questionText,
          card.answerText,
        );
      }
      
      emit(AiImportSuccess(generatedCards.length));
    } catch (e) {
      emit(AiImportError('Failed to save cards: $e'));
    }
  }
}