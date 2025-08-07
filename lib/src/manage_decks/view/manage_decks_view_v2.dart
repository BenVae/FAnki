import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:card_repository/card_deck_manager.dart';
import '../cubit/manage_decks_cubit_v2.dart';
import '../../widgets/deck_tree_view.dart';
import '../../widgets/deck_breadcrumbs.dart';

class ManageDecksViewV2 extends StatelessWidget {
  const ManageDecksViewV2({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: BlocBuilder<ManageDecksCubitV2, DeckStateV2>(
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
                          Spacer(),
                          ElevatedButton.icon(
                            onPressed: () => _showCreateDeckDialog(context, null),
                            icon: Icon(Icons.add),
                            label: Text('New Deck'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue.shade600,
                              foregroundColor: Colors.white,
                              padding: EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 12,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ],
                      ),
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
                              onDeckSelected: (deck) {
                                cubit.selectDeck(deck);
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

  void _showCreateDeckDialog(BuildContext context, Deck? parentDeck) {
    final controller = TextEditingController();
    
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
              context.read<ManageDecksCubitV2>().createDeck(
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
                context.read<ManageDecksCubitV2>().createDeck(
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