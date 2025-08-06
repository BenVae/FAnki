import 'dart:io';
import 'package:syncfusion_flutter_pdf/pdf.dart';

class PdfProcessor {
  static Future<String> extractTextFromPdf(File pdfFile) async {
    try {
      // Load the PDF document
      final bytes = await pdfFile.readAsBytes();
      final PdfDocument document = PdfDocument(inputBytes: bytes);
      
      String fullText = '';
      
      // Extract text from each page
      for (int i = 0; i < document.pages.count; i++) {
        final PdfTextExtractor extractor = PdfTextExtractor(document);
        final String pageText = extractor.extractText(startPageIndex: i, endPageIndex: i);
        fullText += '$pageText\n\n';
      }
      
      // Dispose the document
      document.dispose();
      
      return fullText.trim();
    } catch (e) {
      throw Exception('Failed to extract text from PDF: $e');
    }
  }
  
  static List<String> chunkText(String text, {int maxChunkSize = 3000}) {
    final List<String> chunks = [];
    final List<String> paragraphs = text.split('\n\n');
    
    String currentChunk = '';
    
    for (final paragraph in paragraphs) {
      if (currentChunk.length + paragraph.length > maxChunkSize && currentChunk.isNotEmpty) {
        chunks.add(currentChunk.trim());
        currentChunk = '';
      }
      currentChunk += paragraph + '\n\n';
    }
    
    if (currentChunk.isNotEmpty) {
      chunks.add(currentChunk.trim());
    }
    
    return chunks;
  }
}