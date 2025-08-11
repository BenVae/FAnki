import 'package:uuid/uuid.dart';
import 'package:logging/logging.dart';

final _logger = Logger('Deck');

/// Represents a deck or subdeck in the Anki-like tree structure
class Deck {
  final String id;
  final String name;
  final String? parentId;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int cardCount;
  final int newCards;
  final int learningCards;
  final int reviewCards;
  
  /// Full path from root to this deck (e.g., "Languages::Japanese::Kanji")
  final String path;
  
  /// Depth level in the tree (0 for root decks)
  final int level;
  
  /// Settings that can be inherited from parent
  final DeckSettings settings;
  
  /// Child decks (populated when building tree structure)
  List<Deck> children;

  Deck({
    String? id,
    required this.name,
    this.parentId,
    DateTime? createdAt,
    DateTime? updatedAt,
    this.cardCount = 0,
    this.newCards = 0,
    this.learningCards = 0,
    this.reviewCards = 0,
    required this.path,
    this.level = 0,
    DeckSettings? settings,
    List<Deck>? children,
  })  : id = id ?? const Uuid().v4(),
        createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now(),
        settings = settings ?? DeckSettings(),
        children = children ?? [];

  /// Create deck from Firestore data
  factory Deck.fromMap(Map<String, dynamic> map) {
    final id = map['id'] as String?;
    final name = map['name'] as String?;
    
    if (id == null || id.isEmpty) {
      throw ArgumentError('Deck ID cannot be null or empty');
    }
    
    if (name == null || name.isEmpty) {
      throw ArgumentError('Deck name cannot be null or empty');
    }
    
    return Deck(
      id: id,
      name: name,
      parentId: map['parentId'] as String?,
      createdAt: map['createdAt'] != null 
          ? DateTime.parse(map['createdAt'] as String)
          : DateTime.now(),
      updatedAt: map['updatedAt'] != null
          ? DateTime.parse(map['updatedAt'] as String)  
          : DateTime.now(),
      cardCount: map['cardCount'] as int? ?? 0,
      newCards: map['newCards'] as int? ?? 0,
      learningCards: map['learningCards'] as int? ?? 0,
      reviewCards: map['reviewCards'] as int? ?? 0,
      path: map['path'] as String? ?? map['name'] as String,
      level: map['level'] as int? ?? 0,
      settings: map['settings'] != null
          ? DeckSettings.fromMap(map['settings'] as Map<String, dynamic>)
          : DeckSettings(),
    );
  }

  /// Convert deck to Firestore data
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'parentId': parentId,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'cardCount': cardCount,
      'newCards': newCards,
      'learningCards': learningCards,
      'reviewCards': reviewCards,
      'path': path,
      'level': level,
      'settings': settings.toMap(),
    };
  }

  /// Get display name with indentation for tree view
  String get displayName {
    if (level == 0) return name;
    return '  ' * level + name;
  }

  /// Get the last part of the path (current deck name)
  String get shortName {
    final parts = path.split('::');
    return parts.last;
  }

  /// Check if this deck is a parent of another deck
  bool isParentOf(Deck other) {
    return other.parentId == id;
  }

  /// Check if this deck is a child of another deck
  bool isChildOf(Deck other) {
    return parentId == other.id;
  }

  /// Calculate total cards including all subdecks
  int get totalCards {
    int total = cardCount;
    _logger.finest('Calculating total cards for deck "$name": direct=$cardCount, children=${children.length}');
    for (final child in children) {
      final childTotal = child.totalCards;
      _logger.finest('Child "${child.name}" contributes $childTotal cards');
      total += childTotal;
    }
    _logger.finest('Deck "$name" total cards: $total');
    return total;
  }

  /// Copy with updated fields
  Deck copyWith({
    String? id,
    String? name,
    String? parentId,
    DateTime? createdAt,
    DateTime? updatedAt,
    int? cardCount,
    int? newCards,
    int? learningCards,
    int? reviewCards,
    String? path,
    int? level,
    DeckSettings? settings,
    List<Deck>? children,
  }) {
    return Deck(
      id: id ?? this.id,
      name: name ?? this.name,
      parentId: parentId ?? this.parentId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      cardCount: cardCount ?? this.cardCount,
      newCards: newCards ?? this.newCards,
      learningCards: learningCards ?? this.learningCards,
      reviewCards: reviewCards ?? this.reviewCards,
      path: path ?? this.path,
      level: level ?? this.level,
      settings: settings ?? this.settings,
      children: children ?? this.children,
    );
  }
}

/// Settings for a deck that can be inherited by subdecks
class DeckSettings {
  final int newCardsPerDay;
  final int reviewsPerDay;
  final bool buryRelatedCards;
  final bool showTimer;
  
  DeckSettings({
    this.newCardsPerDay = 20,
    this.reviewsPerDay = 200,
    this.buryRelatedCards = false,
    this.showTimer = true,
  });

  factory DeckSettings.fromMap(Map<String, dynamic> map) {
    return DeckSettings(
      newCardsPerDay: map['newCardsPerDay'] as int? ?? 20,
      reviewsPerDay: map['reviewsPerDay'] as int? ?? 200,
      buryRelatedCards: map['buryRelatedCards'] as bool? ?? false,
      showTimer: map['showTimer'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'newCardsPerDay': newCardsPerDay,
      'reviewsPerDay': reviewsPerDay,
      'buryRelatedCards': buryRelatedCards,
      'showTimer': showTimer,
    };
  }

  DeckSettings copyWith({
    int? newCardsPerDay,
    int? reviewsPerDay,
    bool? buryRelatedCards,
    bool? showTimer,
  }) {
    return DeckSettings(
      newCardsPerDay: newCardsPerDay ?? this.newCardsPerDay,
      reviewsPerDay: reviewsPerDay ?? this.reviewsPerDay,
      buryRelatedCards: buryRelatedCards ?? this.buryRelatedCards,
      showTimer: showTimer ?? this.showTimer,
    );
  }
}