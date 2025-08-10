import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:card_repository/card_deck_manager.dart';
import 'package:authentication_repository/authentication_repository.dart';
import '../cubit/manage_decks_cubit_v2.dart';
import '../../widgets/deck_tree_view.dart';
import '../../widgets/deck_breadcrumbs.dart';
import '../../widgets/study_count_label.dart';
import '../../widgets/card_creation_dialog.dart';
import '../../navigation/cubit/navigation_cubit.dart';
import '../../create_cards/view/create_cards_view.dart';
import '../../ai_import/view/ai_import_page.dart';
import '../../create_cards/cubit/create_cards_cubit.dart';

class ManageDecksViewV2 extends StatefulWidget {
  const ManageDecksViewV2({super.key});

  @override
  State<ManageDecksViewV2> createState() => _ManageDecksViewV2State();
}

class _ManageDecksViewV2State extends State<ManageDecksViewV2> {
  @override
  void initState() {
    super.initState();
    // Initialize the cubit when the view is first shown
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeIfNeeded();
    });
  }

  void _initializeIfNeeded() async {
    final cubit = context.read<ManageDecksCubitV2>();
    // Check if we need to initialize by checking current state
    if (cubit.state is DeckStateV2Loading) {
      cubit.initialize();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      floatingActionButton: BlocBuilder<ManageDecksCubitV2, DeckStateV2>(
        builder: (context, state) {
          if (state is DeckStateV2Loaded) {
            return FloatingActionButton.extended(
              onPressed: () => _showCreateDeckDialog(context, null),
              icon: Icon(Icons.add),
              label: Text('New Deck'),
              backgroundColor: Colors.blue.shade600,
            );
          }
          return Container();
        },
      ),
      body: SafeArea(
        child: BlocBuilder<ManageDecksCubitV2, DeckStateV2>(
        builder: (context, state) {
          if (state is DeckStateV2Loading) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text(
                    'Loading decks...',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            );
          }
          
          if (state is DeckStateV2Error) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 64,
                    color: Colors.red.shade400,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Error loading decks',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.red.shade700,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    state.message,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () => context.read<ManageDecksCubitV2>().loadDecks(),
                    icon: Icon(Icons.refresh),
                    label: Text('Retry'),
                  ),
                ],
              ),
            );
          }
          
          if (state is DeckStateV2Loaded) {
            final cubit = context.read<ManageDecksCubitV2>();
            
            return Column(
              children: [
                // Header with title and actions
                Container(
                  padding: EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 10,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.folder_open,
                            size: 32,
                            color: Colors.blue.shade600,
                          ),
                          SizedBox(width: 12),
                          Text(
                            'Deck Management',
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey.shade900,
                            ),
                          ),
                        ],
                      ),
                      
                      // Deck Dropdown Switcher
                      SizedBox(height: 16),
                      _buildDeckDropdown(context, state),
                      
                      if (state.currentDeck != null) ...[
                        SizedBox(height: 16),
                        DeckBreadcrumbs(
                          ancestors: cubit.getAncestors(state.currentDeck!.id),
                          currentDeck: state.currentDeck,
                          onNavigate: (deck) {
                            if (deck != null) {
                              cubit.selectDeck(deck);
                            }
                          },
                        ),
                      ],
                    ],
                  ),
                ),
                
                // Deck tree view
                Expanded(
                  child: state.rootDecks.isEmpty
                      ? _buildEmptyState(context)
                      : Container(
                          margin: EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.05),
                                blurRadius: 10,
                                offset: Offset(0, 2),
                              ),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(16),
                            child: DeckTreeView(
                              rootDecks: state.rootDecks,
                              selectedDeckId: state.selectedDeckId,
                              expandedDeckIds: state.expandedDeckIds,
                              onToggleExpansion: (deckId) {
                                cubit.toggleDeckExpansion(deckId);
                              },
                              onDeckSelected: (deck) {
                                cubit.selectDeck(deck);
                                _handleDeckTap(context, deck);
                              },
                              onCreateSubdeck: (parentDeck) {
                                _showCreateDeckDialog(context, parentDeck);
                              },
                              onRenameDeck: (deck) {
                                _showRenameDeckDialog(context, deck);
                              },
                              onDeleteDeck: (deck) {
                                cubit.deleteDeck(
                                  deck.id,
                                  deleteSubdecks: deck.children.isEmpty,
                                );
                              },
                              onMoveDeck: (deck, newParent) {
                                cubit.moveDeck(
                                  deck.id,
                                  newParent?.id,
                                );
                              },
                              onAddCards: (deck) {
                                _showAddCardsDialog(context, deck);
                              },
                            ),
                          ),
                        ),
                ),
                
                // Status bar
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border(
                      top: BorderSide(color: Colors.grey.shade200),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.info_outline, size: 16, color: Colors.grey.shade600),
                      SizedBox(width: 8),
                      Text(
                        '${state.allDecks.length} deck${state.allDecks.length != 1 ? 's' : ''}',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      if (state.currentDeck != null) ...[
                        Text(' • ', style: TextStyle(color: Colors.grey.shade400)),
                        Text(
                          '${state.currentDeck!.totalCards} cards in current deck',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            );
          }
          
          return Container();
        },
      ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.folder_off,
            size: 80,
            color: Colors.grey.shade300,
          ),
          SizedBox(height: 24),
          Text(
            'No Decks Yet',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade700,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Create your first deck to start learning',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey.shade500,
            ),
          ),
          SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: () => _showCreateDeckDialog(context, null),
            icon: Icon(Icons.add),
            label: Text('Create First Deck'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue.shade600,
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  static void _showCreateDeckDialog(BuildContext context, Deck? parentDeck) {
    final controller = TextEditingController();
    final cubit = context.read<ManageDecksCubitV2>(); // Get cubit outside dialog
    
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(
          parentDeck != null 
              ? 'Create Subdeck in "${parentDeck.name}"'
              : 'Create New Deck',
        ),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(
            labelText: 'Deck Name',
            hintText: 'Enter deck name',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            prefixIcon: Icon(Icons.folder),
          ),
          autofocus: true,
          onSubmitted: (_) {
            if (controller.text.isNotEmpty) {
              cubit.createDeck( // Use the captured cubit
                name: controller.text,
                parentId: parentDeck?.id,
              );
              Navigator.of(dialogContext).pop();
            }
          },
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (controller.text.isNotEmpty) {
                cubit.createDeck( // Use the captured cubit
                  name: controller.text,
                  parentId: parentDeck?.id,
                );
                Navigator.of(dialogContext).pop();
              }
            },
            style: ElevatedButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text('Create'),
          ),
        ],
      ),
    );
  }

  Widget _buildDeckDropdown(BuildContext context, DeckStateV2Loaded state) {
    final currentDeck = state.currentDeck;
    final allDecks = state.allDecks;
    
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(12),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String?>(
          value: currentDeck?.id,
          hint: Text('Select a deck'),
          isExpanded: true,
          icon: Icon(Icons.keyboard_arrow_down),
          items: [
            ...allDecks.map((deck) => DropdownMenuItem<String?>(
              value: deck.id,
              child: Row(
                children: [
                  Icon(
                    deck.children.isNotEmpty ? Icons.folder : Icons.style,
                    size: 16,
                    color: Colors.grey.shade600,
                  ),
                  SizedBox(width: 8),
                  Expanded(child: Text(deck.name)),
                  StudyCountLabel(count: deck.totalCards),
                ],
              ),
            )),
            DropdownMenuItem<String?>(
              value: null,
              child: Row(
                children: [
                  Icon(Icons.add, size: 16, color: Colors.blue.shade600),
                  SizedBox(width: 8),
                  Text(
                    'Create New Deck',
                    style: TextStyle(
                      color: Colors.blue.shade600,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
          onChanged: (deckId) {
            if (deckId == null) {
              _showDeckCreationOptions(context, null);
            } else {
              final deck = allDecks.firstWhere((d) => d.id == deckId);
              context.read<ManageDecksCubitV2>().selectDeck(deck);
            }
          },
        ),
      ),
    );
  }

  void _handleDeckTap(BuildContext context, Deck deck) {
    if (deck.totalCards > 0) {
      // Navigate to learning view if deck has cards
      context.read<NavigationCubit>().goToLearning();
    } else {
      // Show snackbar if no cards available
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.info_outline, color: Colors.white),
              SizedBox(width: 8),
              Text('No cards available for study'),
            ],
          ),
          backgroundColor: Colors.orange.shade600,
          behavior: SnackBarBehavior.floating,
          margin: EdgeInsets.all(16),
        ),
      );
    }
  }

  void _showAddCardsDialog(BuildContext context, Deck deck) async {
    final result = await showDialog<CardCreationType>(
      context: context,
      builder: (context) => CardCreationDialog(),
    );

    if (result != null && context.mounted) {
      if (result == CardCreationType.ai) {
        _navigateToAiImport(context, deck);
      } else {
        _navigateToManualCreation(context, deck);
      }
    }
  }

  void _navigateToAiImport(BuildContext context, Deck deck) {
    // Set the current deck in the cubit before navigation
    context.read<ManageDecksCubitV2>().selectDeck(deck);
    final cardDeckManager = context.read<ManageDecksCubitV2>().cdm;
    
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (builderContext) => RepositoryProvider.value(
          value: RepositoryProvider.of<AuthenticationRepository>(context),
          child: BlocProvider(
            create: (providerContext) => CreateCardsCubit(
              repo: RepositoryProvider.of<AuthenticationRepository>(providerContext),
              cardDeckManager: cardDeckManager,
            ),
            child: AiImportPage(cardDeckManager: cardDeckManager),
          ),
        ),
      ),
    );
  }

  void _navigateToManualCreation(BuildContext context, Deck deck) {
    // Set the current deck in the cubit before navigation
    context.read<ManageDecksCubitV2>().selectDeck(deck);
    final cardDeckManager = context.read<ManageDecksCubitV2>().cdm;
    
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (builderContext) => RepositoryProvider.value(
          value: RepositoryProvider.of<AuthenticationRepository>(context),
          child: BlocProvider(
            create: (providerContext) => CreateCardsCubit(
              repo: RepositoryProvider.of<AuthenticationRepository>(providerContext),
              cardDeckManager: cardDeckManager,
            ),
            child: Scaffold(
              appBar: AppBar(
                title: Text('Create Cards'),
                leading: IconButton(
                  icon: Icon(Icons.arrow_back),
                  onPressed: () => Navigator.of(builderContext).pop(),
                ),
              ),
              body: CreateCardsView(),
            ),
          ),
        ),
      ),
    );
  }

  void _showDeckCreationOptions(BuildContext context, Deck? parentDeck) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(
          parentDeck != null 
              ? 'Create Subdeck in "${parentDeck.name}"'
              : 'Create New Deck',
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'How would you like to create this deck?',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey.shade600,
              ),
            ),
            SizedBox(height: 20),
            // AI Option
            InkWell(
              onTap: () {
                Navigator.of(dialogContext).pop();
                _navigateToAICardCreation(context, parentDeck);
              },
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.purple.shade300),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.purple.shade100,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        Icons.smart_toy,
                        color: Colors.purple.shade600,
                        size: 24,
                      ),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'AI Generation',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          SizedBox(height: 2),
                          Text(
                            'Upload documents to automatically generate cards',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 12),
            // Manual Option
            InkWell(
              onTap: () {
                Navigator.of(dialogContext).pop();
                _showCreateDeckDialog(context, parentDeck);
              },
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.blue.shade300),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade100,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        Icons.edit,
                        color: Colors.blue.shade600,
                        size: 24,
                      ),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Manual Creation',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          SizedBox(height: 2),
                          Text(
                            'Create an empty deck and add cards manually',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: Text('Cancel'),
          ),
        ],
      ),
    );
  }

  void _navigateToAICardCreation(BuildContext context, Deck? parentDeck) {
    // First show dialog to get deck name, then navigate to AI import
    final controller = TextEditingController();
    final cubit = context.read<ManageDecksCubitV2>(); // Get cubit outside dialog
    
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text('Enter Deck Name'),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(
            labelText: 'Deck Name',
            hintText: 'Enter deck name for AI generation',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            prefixIcon: Icon(Icons.smart_toy),
          ),
          autofocus: true,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (controller.text.isNotEmpty) {
                Navigator.of(dialogContext).pop();
                // Create the deck first, then navigate to AI import
                cubit.createDeck( // Use the captured cubit
                  name: controller.text,
                  parentId: parentDeck?.id,
                );
                // Navigate to AI import view
                _navigateToAIImport(context, controller.text);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.purple.shade600,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text('Create & Generate'),
          ),
        ],
      ),
    );
  }

  void _navigateToAIImport(BuildContext context, String deckName) {
    // Get the CardDeckManager from ManageDecksCubitV2  
    final cardDeckManager = context.read<ManageDecksCubitV2>().cdm;
    
    // Navigate to AI import view with CardDeckManager and proper context
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (builderContext) => RepositoryProvider.value(
          value: RepositoryProvider.of<AuthenticationRepository>(context),
          child: BlocProvider(
            create: (providerContext) => CreateCardsCubit(
              repo: RepositoryProvider.of<AuthenticationRepository>(providerContext),
              cardDeckManager: cardDeckManager,
            ),
            child: AiImportPage(cardDeckManager: cardDeckManager),
          ),
        ),
      ),
    );
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.smart_toy, color: Colors.white),
            SizedBox(width: 8),
            Expanded(
              child: Text('Deck "$deckName" created! You can now generate cards with AI.'),
            ),
          ],
        ),
        backgroundColor: Colors.purple.shade600,
      ),
    );
  }

  void _showRenameDeckDialog(BuildContext context, Deck deck) {
    final controller = TextEditingController(text: deck.name);
    
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text('Rename Deck'),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(
            labelText: 'Deck Name',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            prefixIcon: Icon(Icons.edit),
          ),
          autofocus: true,
          onSubmitted: (_) {
            if (controller.text.isNotEmpty && controller.text != deck.name) {
              context.read<ManageDecksCubitV2>().renameDeck(
                deck.id,
                controller.text,
              );
              Navigator.of(dialogContext).pop();
            }
          },
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (controller.text.isNotEmpty && controller.text != deck.name) {
                context.read<ManageDecksCubitV2>().renameDeck(
                  deck.id,
                  controller.text,
                );
                Navigator.of(dialogContext).pop();
              }
            },
            style: ElevatedButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text('Rename'),
          ),
        ],
      ),
    );
  }
}