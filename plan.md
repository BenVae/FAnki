# FAnki Development Plan - Roadmap Aligned

## Current Status
**Completed:**
- Core UI and infrastructure for AI card generation
- Enhanced flashcard learning interface with 3D flip animations
- Modern deck management UI with card-based layout
- Card creation interface with form validation and preview
- Progress tracking and statistics display
- **AI functionality with OpenAI integration - WORKING!** 🚀
- Tree-structured deck hierarchy with expand/collapse
- Fixed deck management initialization and loading issues
- **✅ Phase 1 Complete - Navigation & Deck Management Refactoring**

**Next Priority:** Architecture unification to resolve dual-system complexity

---

## Priority -0.5: Provider Context & UserID Architecture Fixes 🔧 ✅ COMPLETE
**Goal:** Fix critical provider context and userID synchronization issues

### Completed Tasks:
- [x] Fix CardDeckManager RepositoryProvider issue in StudyStatsView
- [x] Add error handling for missing CardDeckManager in StudyStatsView
- [x] Fix AiImportPage Provider context issue by adding CardDeckManager parameter
- [x] Enhanced CreateCardsCubit initialization with proper userID setting
- [x] Added deck synchronization between v1 (CardDeckManager) and v2 (DeckTreeManager) systems
- [x] Fixed navigation provider chains with proper context passing

### Latest Updates (Priority -0.25):
- [x] Enhanced authentication flow with comprehensive debugging
- [x] Added robust userID initialization in LoginCubitV2 and app.dart
- [x] Implemented card count synchronization between dual deck systems
- [x] Added frosted back button to CreateCardsView with proper SafeArea handling
- [x] Fixed deck count refresh after card creation and AI import operations
- [x] Enhanced DeckTreeManager with updateDeckCardCount functionality
- [x] Added comprehensive debugging output for tracking userID flow

### UI Improvements:
- [x] Implemented modern frosted glass back button in CreateCardsView
- [x] Fixed SafeArea and layout spacing issues in card creation interface
- [x] Improved visual hierarchy with proper app bar spacing

### Identified Architectural Issue:
- **Root Problem:** Dual deck management systems (CardDeckManager + DeckTreeManager) create synchronization complexity
- **Persistent Issue:** "userID is empty" errors due to timing and system conflicts
- **Next Phase Needed:** Complete architectural unification (see Priority 2.5)

### Technical Debt Created:
- Added comprehensive debugging print statements (need cleanup)
- Temporary dual-system synchronization (needs architectural fix)
- Complex refresh logic after navigation operations

---

## Priority -1: Critical Bug Fixes 🚨
**Goal:** Fix urgent issues and navigation simplification

### Implementation Tasks:
- [ ] Fix setState after dispose error in StudyStatsView
- [ ] Add current deck context to statistics view header
- [ ] Fix Settings SafeArea at top
- [ ] Resolve Firestore "document path must be non-empty string" error
- [ ] Simplify navigation: remove global nav, keep buttons only on deck view
- [ ] Add back buttons to Statistics and Settings views
- [ ] Fix deck loading validation and error handling

### Navigation Simplification:
- **Deck View Only**: Show Statistics & Settings buttons only on deck management
- **Other Views**: Simple back/close button only
- **No Global Nav**: Remove frosted navigation from all other screens

---

## Priority 0: Navigation & Deck Management Refactoring ✅ COMPLETE
**Goal:** Simplify navigation with deck management as the central hub

### Implementation Tasks:
- [x] Simplify navigation to only 2 buttons (Statistics, Settings)
- [x] Remove Learning and Create Cards from main navigation
- [x] Make deck management the default/home view
- [x] Add deck dropdown switcher with "Create New Deck" option
- [x] Create study count label widget (number only, auto-hide when 0)
- [x] Add tap-to-study functionality on decks
- [x] Create card creation dialog (AI vs Manual choice)
- [x] Move card creation to deck context menu
- [x] Update NavigationCubit to remove unused states

### Completed Features:
- **Study Count Labels**: Blue text on light blue bg, auto-hide when 0
- **Deck Dropdown**: Current deck + deck list + "Create New Deck" button
- **Card Creation Dialog**: Choice between AI and Manual creation
- **Deck Actions Menu**: Add Cards, Rename, Delete, Move options
- **Tap-to-Study**: Direct navigation from deck to learning view
- **Streamlined Navigation**: Simplified to essential components only

---

## Priority 1: Markdown/Rich Text for Card Back
**Goal:** Enable rich content formatting for answer cards

### Implementation Tasks:
- [ ] Update AI service prompt to inform GPT about markdown formatting capabilities:
  - [ ] Specify that answers can use markdown syntax
  - [ ] Include LaTeX formula support (e.g., `$...$` for inline, `$$...$$` for block)
  - [ ] Allow code blocks with syntax highlighting (```language)
  - [ ] Support for lists, tables, bold, italic, etc.
- [ ] Add flutter_markdown package for rendering
- [ ] Update Card model to support markdown content
- [ ] Implement markdown editor with live preview
- [ ] Add LaTeX/formula support (katex_flutter or similar)
- [ ] Update card display component to render markdown
- [ ] Add toolbar for common markdown formatting
- [ ] Support for code blocks with syntax highlighting
- [ ] Enable image embedding in cards

---

## Priority 2: Tree-Structured Decks (Anki-like) ✅ MOSTLY COMPLETE
**Goal:** Implement hierarchical deck organization like Anki

### Implementation Tasks:
- [x] Study Anki's deck structure (https://docs.ankiweb.net/getting-started.html)
- [x] Modify Deck model to support parent-child relationships
- [x] Update Firestore schema for nested deck structure
- [x] Create expandable tree view UI component
- [x] Implement deck path navigation (breadcrumbs)
- [x] Update deck selection to handle subdeck logic
- [ ] Add deck moving/reorganization functionality
- [ ] Support for deck inheritance settings
- [ ] Note: Focus on basic card type only (as specified)

### Completed:
- Implemented DeckTreeManager for hierarchical deck management
- Created tree view UI with expand/collapse functionality
- Added breadcrumb navigation for deck hierarchy
- Fixed initialization issues with ManageDecksCubitV2
- Resolved infinite loop in deck loading
- Updated deck selection to work with new tree structure

---

## Priority 2.5: CardDeckManager Architecture Unification 🏗️
**Goal:** Eliminate dual-system complexity and create bulletproof card creation flow

### Root Problem Analysis:
The userID empty errors stem from having two deck management systems (CardDeckManager + DeckTreeManager) that are poorly synchronized, creating race conditions and context dependency issues.

### Architectural Solution Options:

#### Option A: Eliminate CardDeckManager (Recommended)
- **Migrate all card operations** to work directly with DeckTreeManager/Firebase
- **Remove CardDeckManager dependency** from CreateCardsCubit
- **Create unified CardService** that handles all card CRUD operations
- **Simplify context chains** by removing dual system dependencies

#### Option B: Reverse Integration  
- **Make DeckTreeManager a wrapper** around CardDeckManager
- **Ensure CardDeckManager is always initialized** before any deck operations
- **Add synchronization layer** between the two systems

### Implementation Strategy (Option A - Recommended):

1. **Create Unified CardService**
   ```dart
   class CardService {
     final FirebaseApi _firebaseApi;
     final AuthenticationRepository _authRepo;
     
     Future<void> addCard(String deckId, String question, String answer);
     Future<List<Card>> getCardsForDeck(String deckId);
   }
   ```

2. **Update CreateCardsCubit**
   ```dart
   class CreateCardsCubit extends Cubit<CreateCardsState> {
     final CardService _cardService;
     final String _deckId; // Direct deck ID, no context dependency
   }
   ```

3. **Streamline Navigation Flow**
   - Pass deck IDs directly instead of relying on CardDeckManager state
   - Remove complex provider chains
   - Make card creation bulletproof with single system

### Benefits:
- **Eliminates userID timing issues** (always available from AuthRepo)
- **Removes dual-system synchronization** complexity
- **Simplifies context dependencies** (no more provider chains)
- **Makes card creation bulletproof** with direct deck ID passing
- **Easier to test and debug** with single system

---

## Priority 3: GitHub-like Study Timeline
**Goal:** Visual activity tracker showing study patterns

### Implementation Tasks:
- [ ] Create study_activity collection in Firestore
- [ ] Track daily study sessions with card counts
- [ ] Implement heatmap calendar widget
- [ ] Define color intensity thresholds:
  - Light: 1-10 cards reviewed
  - Medium: 11-30 cards reviewed  
  - Dark: 31+ cards reviewed
- [ ] it should only show the last month (always)
- [ ] I want this to be super minimalistic.

---

## Priority 4: Modern App Navigation
**Goal:** Improve overall navigation and settings

### Implementation Tasks:
- [ ] Create Settings page with:
  - [ ] Logout functionality
  - [ ] Licenses display
  - [ ] Version information
  - [ ] User preferences
- [ ] Add persistent deck switcher in top-left corner
- [ ] Refactor learning view to show single card at a time
- [ ] Implement navigation drawer or rail for main sections
- [ ] Add bottom navigation for mobile
- [ ] Create consistent back navigation
- [ ] Add keyboard shortcuts for desktop

---

## Additional Features (No Priority Order)

### Pie Chart for Card States
- [ ] Add fl_chart package
- [ ] Create statistics view with pie chart
- [ ] Show distribution of:
  - New cards
  - Learning cards
  - Review cards
  - Suspended cards
- [ ] Add filtering by deck
- [ ] Interactive chart with drill-down

### AI Usage Limitations
- [ ] Add user quota field in Firestore user document
- [ ] Track API calls per user
- [ ] Implement quota checking before AI operations
- [ ] Show remaining quota in UI
- [ ] Add special testing flag for unlimited access (for dev account)
- [ ] Consider token-based pricing display
- [ ] Add quota reset schedule (monthly/weekly)

---

## Technical Debt & Improvements

### Authentication Repository Tests
- [ ] Fix test failures after package updates
- [ ] Remove deprecated Google Sign-In code from tests
- [ ] Update mocks to match current implementation
- [ ] Ensure all tests pass with latest Firebase packages

### Code Quality
- [ ] Remove all print statements
- [ ] Add proper error logging
- [ ] Implement analytics tracking
- [ ] Add performance monitoring
- [ ] Create comprehensive test suite

---

## Development Workflow

### Phase 1: Critical Bug Fixes (Current)
1. Fix setState after dispose and SafeArea issues
2. Resolve Firestore document path errors
3. Simplify navigation structure (remove global nav)
4. Add proper back button navigation

### Phase 2: Content Enhancement
1. Implement Priority 1 (Markdown support)
2. Add LaTeX formula rendering
3. Enable code syntax highlighting

### Phase 3: Analytics & Polish
1. Implement Priority 3 (Study timeline)
2. Add pie chart visualization
3. Implement AI usage limitations
4. Testing and bug fixes

---

## Success Metrics
- Markdown rendering works for formulas and code
- Deck hierarchy supports 3+ levels of nesting
- Study timeline shows accurate activity data
- Navigation is consistent across all platforms
- AI usage is properly limited and tracked
- All tests pass with >80% coverage