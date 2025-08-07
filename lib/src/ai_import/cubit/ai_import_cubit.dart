import 'dart:io';
import 'package:bloc/bloc.dart';
import 'package:card_repository/card_deck_manager.dart';
import 'package:ai_service/ai_service.dart';
import '../../env.dart';

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
  AiImportCubit({required this.cardDeckManager}) : super(AiImportInitial()) {
    if (Env.openaiApiKey.isNotEmpty) {
      _aiService = AiService(apiKey: Env.openaiApiKey);
    }
  }

  final CardDeckManager cardDeckManager;
  AiService? _aiService;
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
    
    if (_aiService == null) {
      emit(AiImportError('AI service not configured. Please check your API key.'));
      return;
    }
    
    emit(AiImportProcessing());
    
    try {
      // Generate cards using AI service
      generatedCards = await _aiService!.generateCardsFromPdf(selectedPdf!);
      
      // Get suggested deck name from first card or use default
      if (generatedCards.isNotEmpty) {
        // Extract text from PDF to suggest deck name
        final pdfText = await PdfProcessor.extractTextFromPdf(selectedPdf!);
        suggestedDeckName = await _aiService!.suggestDeckName(pdfText.substring(0, pdfText.length > 1000 ? 1000 : pdfText.length));
      } else {
        suggestedDeckName = 'AI Generated Deck';
      }
      
      emit(AiImportPreview(generatedCards, suggestedDeckName));
    } catch (e) {
      // Log error for debugging
      emit(AiImportError('Failed to generate cards: ${e.toString()}'));
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
      // Create deck if it doesn't exist, or set as current if it does
      bool deckCreated = cardDeckManager.createDeck(deckName);
      if (!deckCreated) {
        // Deck already exists, just set it as current
        cardDeckManager.currentDeckName = deckName;
      }
      
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