import 'package:flutter/material.dart';
import 'package:card_repository/card_deck_manager.dart';

class DeckBreadcrumbs extends StatelessWidget {
  final List<Deck> ancestors;
  final Deck? currentDeck;
  final Function(Deck?) onNavigate;

  const DeckBreadcrumbs({
    super.key,
    required this.ancestors,
    this.currentDeck,
    required this.onNavigate,
  });

  @override
  Widget build(BuildContext context) {
    final allDecks = [
      null, // Root level
      ...ancestors,
      if (currentDeck != null) currentDeck!,
    ];

    return Container(
      height: 40,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        itemCount: allDecks.length,
        separatorBuilder: (context, index) => Padding(
          padding: EdgeInsets.symmetric(horizontal: 4),
          child: Icon(
            Icons.chevron_right,
            size: 16,
            color: Colors.grey.shade400,
          ),
        ),
        itemBuilder: (context, index) {
          final deck = allDecks[index];
          final isLast = index == allDecks.length - 1;
          final isRoot = deck == null;
          
          return InkWell(
            onTap: isLast ? null : () => onNavigate(deck),
            borderRadius: BorderRadius.circular(16),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: isLast 
                    ? Theme.of(context).primaryColor.withValues(alpha: 0.1)
                    : null,
                borderRadius: BorderRadius.circular(16),
                border: isLast 
                    ? Border.all(
                        color: Theme.of(context).primaryColor.withValues(alpha: 0.3),
                        width: 1,
                      )
                    : null,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    isRoot ? Icons.home : Icons.folder,
                    size: 16,
                    color: isLast 
                        ? Theme.of(context).primaryColor
                        : Colors.grey.shade600,
                  ),
                  SizedBox(width: 4),
                  Text(
                    isRoot ? 'All Decks' : deck!.name,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: isLast ? FontWeight.bold : FontWeight.normal,
                      color: isLast 
                          ? Theme.of(context).primaryColor
                          : Colors.grey.shade700,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}