import 'dart:io';
import 'dart:convert';
import 'package:dart_openai/dart_openai.dart';
import 'package:card_repository/card_deck_manager.dart';
import 'pdf_processor.dart';

class AiService {
  static const String _systemPrompt = '''
You are an expert at creating educational flashcards from academic content.
Your task is to generate question-answer pairs suitable for spaced repetition learning.

Guidelines:
1. Create clear, concise questions that test understanding
2. Answers should be brief but complete
3. Focus on key concepts, definitions, and important facts
4. Avoid yes/no questions when possible
5. Make questions specific enough to have one clear answer

Formatting capabilities for answers:
- You can use Markdown syntax for rich text formatting
- LaTeX formulas: Use \$...\$ for inline math and \$\$...\$\$ for display math
- Code blocks: Use triple backticks with language name for syntax highlighting
- Lists: Use - or * for bullet points, 1. 2. 3. for numbered lists
- Emphasis: Use **bold**, *italic*, or ***bold italic***
- Tables: Use | Header | Header | with |---|---| separators
- Links: Use [text](url) format

Use these formatting options when they enhance clarity, especially for:
- Mathematical formulas and equations
- Code snippets and technical syntax
- Structured information that benefits from lists or tables
- Important terms that should be emphasized

Return the flashcards as a JSON array with this format:
[
  {"question": "...", "answer": "..."},
  {"question": "...", "answer": "..."}
]
''';

  static const String _deckNamePrompt = '''
Based on the content provided, suggest a concise and descriptive name for a flashcard deck.
The name should be 2-5 words and clearly indicate the topic.
Return only the deck name, nothing else.
''';

  final String apiKey;
  
  AiService({required this.apiKey}) {
    OpenAI.apiKey = apiKey;
  }

  Future<List<SingleCard>> generateCardsFromPdf(File pdfFile) async {
    try {
      // Extract text from PDF
      final String pdfText = await PdfProcessor.extractTextFromPdf(pdfFile);
      
      if (pdfText.isEmpty) {
        throw Exception('No text found in PDF');
      }
      
      // Chunk text if it's too long
      final List<String> chunks = PdfProcessor.chunkText(pdfText);
      final List<SingleCard> allCards = [];
      
      for (final chunk in chunks) {
        final cards = await _generateCardsFromText(chunk);
        allCards.addAll(cards);
      }
      
      return allCards;
    } catch (e) {
      throw Exception('Failed to generate cards: $e');
    }
  }

  Future<List<SingleCard>> _generateCardsFromText(String text) async {
    try {
      final response = await OpenAI.instance.chat.create(
        model: "gpt-4o-mini",
        messages: [
          OpenAIChatCompletionChoiceMessageModel(
            role: OpenAIChatMessageRole.system,
            content: [
              OpenAIChatCompletionChoiceMessageContentItemModel.text(_systemPrompt),
            ],
          ),
          OpenAIChatCompletionChoiceMessageModel(
            role: OpenAIChatMessageRole.user,
            content: [
              OpenAIChatCompletionChoiceMessageContentItemModel.text(
                'Generate flashcards from this content:\n\n$text'
              ),
            ],
          ),
        ],
        temperature: 0.7,
        maxTokens: 2000,
      );
      
      final content = response.choices.first.message.content?.first.text ?? '';
      
      // Parse JSON response
      final jsonStart = content.indexOf('[');
      final jsonEnd = content.lastIndexOf(']') + 1;
      
      if (jsonStart == -1 || jsonEnd == 0) {
        throw Exception('Invalid response format from AI');
      }
      
      final jsonString = content.substring(jsonStart, jsonEnd);
      
      try {
        final List<dynamic> cardsJson = json.decode(jsonString);
        final cards = <SingleCard>[];
        
        for (final cardJson in cardsJson) {
          if (cardJson is Map<String, dynamic>) {
            final question = cardJson['question'] as String? ?? '';
            final answer = cardJson['answer'] as String? ?? '';
            
            if (question.isNotEmpty && answer.isNotEmpty) {
              cards.add(SingleCard(
                deckName: 'AI Generated',
                questionText: question,
                answerText: answer,
              ));
            }
          }
        }
        
        if (cards.isEmpty) {
          throw Exception('No valid cards could be generated from the text');
        }
        
        return cards;
      } catch (e) {
        // Log error for debugging - in production use proper logging
        throw Exception('Failed to parse cards from AI response: $e');
      }
    } catch (e) {
      throw Exception('Failed to generate cards from text: $e');
    }
  }

  Future<String> suggestDeckName(String pdfContent) async {
    try {
      final response = await OpenAI.instance.chat.create(
        model: "gpt-3.5-turbo",
        messages: [
          OpenAIChatCompletionChoiceMessageModel(
            role: OpenAIChatMessageRole.system,
            content: [
              OpenAIChatCompletionChoiceMessageContentItemModel.text(_deckNamePrompt),
            ],
          ),
          OpenAIChatCompletionChoiceMessageModel(
            role: OpenAIChatMessageRole.user,
            content: [
              OpenAIChatCompletionChoiceMessageContentItemModel.text(
                'Content: ${pdfContent.substring(0, pdfContent.length > 1000 ? 1000 : pdfContent.length)}...'
              ),
            ],
          ),
        ],
        temperature: 0.5,
        maxTokens: 20,
      );
      
      return response.choices.first.message.content?.first.text?.trim() ?? 'Study Cards';
    } catch (e) {
      return 'Study Cards';
    }
  }
}