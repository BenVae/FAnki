# AI-Powered Anki Card Generation - Implementation Plan

## Phase 1: Foundation & Setup
**Goal:** Set up the AI service package and basic infrastructure

### Tasks:
- [x] Create new package `packages/ai_service` with proper structure
- [x] Add necessary dependencies (OpenAI SDK, PDF processing libraries)
- [ ] Set up AI service configuration and API key management
- [x] Create base AI service class with error handling
- [x] Add Flutter Hooks dependency to pubspec.yaml
- [ ] Write unit tests for AI service initialization

## Phase 2: PDF Processing
**Goal:** Implement PDF upload and text extraction capabilities

### Tasks:
- [x] Add file_picker dependency for PDF selection
- [x] Implement PDF text extraction service
- [ ] Create PDF metadata extraction (title, pages, etc.)
- [ ] Add image extraction from PDFs for OCR (if needed)
- [x] Implement chunking logic for large PDFs
- [ ] Create error handling for corrupted/unsupported PDFs
- [ ] Write tests for PDF processing

## Phase 3: AI Integration
**Goal:** Connect to AI service for content processing

### Tasks:
- [x] Implement OpenAI API integration
- [x] Create prompt templates for card generation
- [ ] Implement PDF content to flashcard conversion logic (currently using mock data)
- [x] Add deck name suggestion feature
- [ ] Create batch processing for multiple cards
- [ ] Implement rate limiting and quota management
- [ ] Add retry logic for failed AI requests
- [ ] Write unit tests

## Phase 4: UI Implementation - PDF Import ✅
**Goal:** Create user interface for PDF import and processing

### Tasks:
- [x] Create new feature: `lib/src/ai_import/`
- [x] Implement ImportPdfCubit with states (idle, processing, success, error)
- [x] Create PDF upload UI with drag-and-drop support
- [x] Add processing progress indicator
- [ ] Implement preview of extracted content
- [ ] Convert existing StatefulWidgets to use Flutter Hooks
- [ ] Add PDF history/recent imports section
- [ ] Write widget tests

## Phase 5: Card Generation & Review UI ✅
**Goal:** Build interface for reviewing and editing AI-generated cards

### Tasks:
- [x] Create card preview/edit interface
- [x] Implement bulk card editing capabilities
- [ ] Add card quality indicators (AI confidence scores)
- [x] Create deck selection/creation UI with AI suggestions
- [x] Implement selective card import (checkbox selection)
- [x] Add manual card editing before import
- [ ] Create undo/redo functionality
- [ ] Write UI tests

## Phase 6: Integration with Existing System ✅
**Goal:** Seamlessly integrate new features with current app

### Tasks:
- [x] Update navigation to include PDF import option
- [x] Modify card_repository to handle bulk imports
- [ ] Add AI-generated flag to SingleCard model
- [ ] Update Firebase schema for AI metadata
- [x] Integrate with existing deck management
- [x] Update app navigation (add import button/menu)
- [x] Ensure backward compatibility
- [ ] Write unit tests

## Phase 7: Advanced Features
**Goal:** Enhance AI capabilities and user experience

### Tasks:
- [ ] Implement smart card formatting (Q&A, cloze deletion, etc.)
- [ ] Add language detection and translation support
- [ ] Create custom prompt templates per subject
- [ ] Implement image-based card generation from diagrams
- [ ] Add batch processing for multiple PDFs
- [ ] Create learning statistics for AI-generated cards
- [ ] Implement feedback loop for card quality improvement

## Phase 8: Optimization & Polish
**Goal:** Refine performance and user experience

### Tasks:
- [ ] Optimize PDF processing performance
- [ ] Implement caching for processed PDFs
- [ ] Add offline support with queued processing
- [ ] Refine AI prompts based on user feedback
- [ ] Complete Flutter Hooks migration for all widgets
- [ ] Add comprehensive error messages and recovery
- [ ] Implement analytics for AI usage
- [ ] Performance testing and optimization

## Phase 9: Testing & Documentation
**Goal:** Ensure quality and maintainability

### Tasks:
- [ ] Write comprehensive unit tests (>80% coverage)
- [ ] Add E2E tests for critical paths
- [ ] Update README with AI features
- [ ] Create user documentation for PDF import
- [ ] Document AI service API
- [ ] Add inline code documentation
- [ ] Create troubleshooting guide

## Phase 10: Deployment & Monitoring
**Goal:** Release and monitor the new features

### Tasks:
- [ ] Configure API keys for production
- [ ] Set up error tracking for AI features
- [ ] Implement usage monitoring and quotas
- [ ] Create feature flags for gradual rollout
- [ ] Update app store descriptions
- [ ] Set up cost monitoring for AI API usage
- [ ] Create backup/fallback mechanisms
- [ ] Plan for scaling AI operations

---

## Current Status: 
**Completed:** Core UI and infrastructure for AI card generation
**Next Priority:** Connect real OpenAI API and implement proper JSON parsing

## Immediate Next Steps:

### 1. Enable Real AI Processing
- [ ] Add OpenAI API key to environment configuration
- [ ] Implement proper JSON parsing in `ai_service.dart`
- [ ] Test with actual PDF files
- [ ] Handle API errors gracefully

### 2. Improve PDF Processing
- [ ] Add support for various PDF formats
- [ ] Implement better text extraction for complex layouts
- [ ] Add progress tracking during extraction
- [ ] Handle large PDFs (>100 pages) efficiently

### 3. Enhance Card Generation
- [ ] Implement proper prompt engineering for better card quality
- [ ] Add different card types (multiple choice, true/false, etc.)
- [ ] Implement subject-specific prompts
- [ ] Add card difficulty estimation

### 4. Polish User Experience
- [ ] Add loading states for all async operations
- [ ] Implement proper error messages
- [ ] Add tooltips and help text
- [ ] Create onboarding flow for first-time users

### 5. Testing
- [ ] Test with various PDF types (lectures, textbooks, articles)
- [ ] Verify Firebase integration works correctly
- [ ] Test error scenarios (no internet, invalid PDF, API down)
- [ ] Performance test with large batches of cards

## Technical Debt to Address:
- [ ] Replace mock data in `ai_import_cubit.dart` with real AI calls
- [ ] Implement proper JSON decoding in AI service
- [ ] Add proper error handling throughout the flow
- [ ] Implement cleanup of temporary PDF files
- [ ] Add logging for debugging and monitoring

## Key Technical Decisions:
1. **AI Provider**: OpenAI GPT-4 for card generation, GPT-3.5-turbo for simpler tasks
2. **PDF Library**: Syncfusion Flutter PDF for robust PDF handling
3. **State Management**: Maintain BLoC pattern, gradually introduce Flutter Hooks
4. **API Management**: Implement token counting and cost estimation upfront
5. **Batch Size**: Process PDFs in 2-3 page chunks for optimal token usage

## Success Metrics:
- Average 15-20 quality cards generated per lecture PDF
- Processing cost < $0.10 per typical 20-page PDF
- User satisfaction with card quality > 85%
- Processing time < 20 seconds for standard lecture PDF
- Reduction in manual card creation time by 80%