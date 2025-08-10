import 'package:flutter/material.dart';
import 'package:card_repository/card_deck_manager.dart';

class DeckTreeView extends StatefulWidget {
  final List<Deck> rootDecks;
  final String? selectedDeckId;
  final Set<String> expandedDeckIds;
  final Function(String) onToggleExpansion;
  final Function(Deck) onDeckSelected;
  final Function(Deck) onCreateSubdeck;
  final Function(Deck) onRenameDeck;
  final Function(Deck) onDeleteDeck;
  final Function(Deck, Deck?) onMoveDeck;

  const DeckTreeView({
    super.key,
    required this.rootDecks,
    this.selectedDeckId,
    Set<String>? expandedDeckIds,
    required this.onToggleExpansion,
    required this.onDeckSelected,
    required this.onCreateSubdeck,
    required this.onRenameDeck,
    required this.onDeleteDeck,
    required this.onMoveDeck,
  }) : expandedDeckIds = expandedDeckIds ?? const {};

  @override
  State<DeckTreeView> createState() => _DeckTreeViewState();
}

class _DeckTreeViewState extends State<DeckTreeView> {
  @override
  Widget build(BuildContext context) {
    return ListView(
      children: widget.rootDecks.map((deck) => _buildDeckTile(deck)).toList(),
    );
  }

  Widget _buildDeckTile(Deck deck, {int indent = 0}) {
    final hasChildren = deck.children.isNotEmpty;
    final isExpanded = widget.expandedDeckIds.contains(deck.id);
    final isSelected = deck.id == widget.selectedDeckId;
    
    return Column(
      children: [
        Container(
          margin: EdgeInsets.only(left: indent * 16.0),
          decoration: BoxDecoration(
            color: isSelected 
                ? Theme.of(context).primaryColor.withValues(alpha: 0.1)
                : null,
            borderRadius: BorderRadius.circular(8),
          ),
          child: ListTile(
            leading: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (hasChildren)
                  IconButton(
                    icon: Icon(
                      isExpanded 
                          ? Icons.keyboard_arrow_down 
                          : Icons.keyboard_arrow_right,
                      size: 20,
                    ),
                    onPressed: () {
                      widget.onToggleExpansion(deck.id);
                    },
                    padding: EdgeInsets.zero,
                    constraints: BoxConstraints(minWidth: 32, minHeight: 32),
                  )
                else
                  SizedBox(width: 32),
                Icon(
                  hasChildren ? Icons.folder : Icons.style,
                  color: isSelected 
                      ? Theme.of(context).primaryColor 
                      : Colors.grey.shade600,
                  size: 20,
                ),
              ],
            ),
            title: Row(
              children: [
                Expanded(
                  child: Text(
                    deck.name,
                    style: TextStyle(
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      color: isSelected 
                          ? Theme.of(context).primaryColor 
                          : null,
                    ),
                  ),
                ),
                if (deck.totalCards > 0)
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade100,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${deck.totalCards}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.blue.shade700,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
            subtitle: deck.newCards > 0 || deck.reviewCards > 0
                ? Row(
                    children: [
                      if (deck.newCards > 0) ...[
                        Icon(Icons.fiber_new, size: 14, color: Colors.green),
                        SizedBox(width: 2),
                        Text(
                          '${deck.newCards}',
                          style: TextStyle(fontSize: 12, color: Colors.green),
                        ),
                        SizedBox(width: 8),
                      ],
                      if (deck.reviewCards > 0) ...[
                        Icon(Icons.replay, size: 14, color: Colors.orange),
                        SizedBox(width: 2),
                        Text(
                          '${deck.reviewCards}',
                          style: TextStyle(fontSize: 12, color: Colors.orange),
                        ),
                      ],
                    ],
                  )
                : null,
            trailing: PopupMenuButton<String>(
              icon: Icon(Icons.more_vert, size: 20),
              onSelected: (value) => _handleDeckAction(value, deck),
              itemBuilder: (context) => [
                PopupMenuItem(
                  value: 'add_subdeck',
                  child: Row(
                    children: [
                      Icon(Icons.add, size: 18),
                      SizedBox(width: 8),
                      Text('Add Subdeck'),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: 'rename',
                  child: Row(
                    children: [
                      Icon(Icons.edit, size: 18),
                      SizedBox(width: 8),
                      Text('Rename'),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: 'move',
                  child: Row(
                    children: [
                      Icon(Icons.drive_file_move, size: 18),
                      SizedBox(width: 8),
                      Text('Move'),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: 'delete',
                  child: Row(
                    children: [
                      Icon(Icons.delete, size: 18, color: Colors.red),
                      SizedBox(width: 8),
                      Text('Delete', style: TextStyle(color: Colors.red)),
                    ],
                  ),
                ),
              ],
            ),
            onTap: () => widget.onDeckSelected(deck),
          ),
        ),
        if (hasChildren && isExpanded)
          ...deck.children.map((child) => _buildDeckTile(child, indent: indent + 1)),
      ],
    );
  }

  void _handleDeckAction(String action, Deck deck) {
    switch (action) {
      case 'add_subdeck':
        widget.onCreateSubdeck(deck);
        break;
      case 'rename':
        _showRenameDeckDialog(deck);
        break;
      case 'move':
        _showMoveDeckDialog(deck);
        break;
      case 'delete':
        _showDeleteDeckDialog(deck);
        break;
    }
  }

  void _showRenameDeckDialog(Deck deck) {
    final controller = TextEditingController(text: deck.name);
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Rename Deck'),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(
            labelText: 'Deck Name',
            border: OutlineInputBorder(),
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (controller.text.isNotEmpty && controller.text != deck.name) {
                widget.onRenameDeck(deck);
                Navigator.of(context).pop();
              }
            },
            child: Text('Rename'),
          ),
        ],
      ),
    );
  }

  void _showMoveDeckDialog(Deck deck) {
    // This would show a dialog with a tree view to select the new parent
    // For now, just call the move function with null (move to root)
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Move Deck'),
        content: Text('Move "${deck.name}" to root level?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              widget.onMoveDeck(deck, null);
              Navigator.of(context).pop();
            },
            child: Text('Move'),
          ),
        ],
      ),
    );
  }

  void _showDeleteDeckDialog(Deck deck) {
    final hasSubdecks = deck.children.isNotEmpty;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete Deck'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Are you sure you want to delete "${deck.name}"?'),
            if (hasSubdecks) ...[
              SizedBox(height: 16),
              Text(
                'This deck contains ${deck.children.length} subdeck(s).',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text('What would you like to do with them?'),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Cancel'),
          ),
          if (hasSubdecks) ...[
            TextButton(
              onPressed: () {
                widget.onDeleteDeck(deck);
                Navigator.of(context).pop();
              },
              child: Text('Keep Subdecks'),
            ),
          ],
          ElevatedButton(
            onPressed: () {
              widget.onDeleteDeck(deck);
              Navigator.of(context).pop();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: Text(hasSubdecks ? 'Delete All' : 'Delete'),
          ),
        ],
      ),
    );
  }
}