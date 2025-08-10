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

**Next Priority:** Critical bug fixes and navigation simplification

---

## Priority -1: Critical Bug Fixes 🚨
**Goal:** Fix urgent issues and simplify navigation structure

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