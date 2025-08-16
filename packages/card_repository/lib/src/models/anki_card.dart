import 'package:uuid/uuid.dart';
import 'package:logging/logging.dart';
import 'single_card.dart';

final _logger = Logger('AnkiCard');

/// Card states in the SM-2 spaced repetition system
enum CardState {
  /// New card that hasn't been studied yet
  newCard('NEW'),
  
  /// Card currently being learned (in learning steps)
  learning('LEARNING'),
  
  /// Card in review phase (graduated from learning)
  review('REVIEW'),
  
  /// Card being relearned after being forgotten
  relearning('RELEARNING');

  const CardState(this.value);
  final String value;

  static CardState fromString(String value) {
    return CardState.values.firstWhere(
      (state) => state.value == value,
      orElse: () => CardState.newCard,
    );
  }
}

/// Comprehensive Anki card model implementing SM-2 spaced repetition algorithm
class AnkiCard {
  /// Unique identifier for the card
  final String id;
  
  /// ID of the deck this card belongs to
  final String deckId;
  
  /// The question/front side of the card
  final String questionText;
  
  /// The answer/back side of the card
  final String answerText;
  
  /// Current state of the card in the spaced repetition system
  final CardState state;
  
  /// Number of successful repetitions (resets to 0 when card is forgotten)
  final int repetitions;
  
  /// Ease factor for SM-2 algorithm (default 2.5, range 1.3-4.0)
  final double easeFactor;
  
  /// Current interval in days before next review
  final int interval;
  
  /// When the card is next due for review
  final DateTime dueDate;
  
  /// When the card was last reviewed
  final DateTime? lastReviewed;
  
  /// Number of times the card has been forgotten (lapses)
  final int lapses;
  
  /// Learning steps in minutes for new and relearning cards
  final List<int> learningSteps;
  
  /// Current step in the learning process
  final int currentStep;
  
  /// Whether the card is suspended (not shown in reviews)
  final bool suspended;
  
  /// Tags associated with this card
  final List<String> tags;
  
  /// Note type (e.g., 'Basic', 'Cloze', 'Reverse')
  final String noteType;
  
  /// When the card was created
  final DateTime created;
  
  /// When the card was last modified
  final DateTime modified;

  AnkiCard({
    String? id,
    required this.deckId,
    required this.questionText,
    required this.answerText,
    this.state = CardState.newCard,
    this.repetitions = 0,
    this.easeFactor = 2.5,
    this.interval = 0,
    DateTime? dueDate,
    this.lastReviewed,
    this.lapses = 0,
    List<int>? learningSteps,
    this.currentStep = 0,
    this.suspended = false,
    List<String>? tags,
    this.noteType = 'Basic',
    DateTime? created,
    DateTime? modified,
  }) : id = id ?? const Uuid().v4(),
       dueDate = dueDate ?? DateTime.now(),
       learningSteps = learningSteps ?? [1, 10], // Default Anki learning steps
       tags = tags ?? [],
       created = created ?? DateTime.now(),
       modified = modified ?? DateTime.now() {
    // Validate ease factor bounds
    if (easeFactor < 1.3 || easeFactor > 4.0) {
      _logger.warning('Ease factor $easeFactor is outside recommended range (1.3-4.0)');
    }
    
    // Validate current step
    if (currentStep < 0 || currentStep >= this.learningSteps.length) {
      _logger.warning('Current step $currentStep is outside learning steps range');
    }
  }

  /// Create AnkiCard from Firestore data
  factory AnkiCard.fromFirestore(Map<String, dynamic> data) {
    final id = data['id'] as String?;
    final deckId = data['deckId'] as String?;
    final questionText = data['questionText'] as String?;
    final answerText = data['answerText'] as String?;
    
    if (id == null || id.isEmpty) {
      throw ArgumentError('AnkiCard ID cannot be null or empty');
    }
    if (deckId == null || deckId.isEmpty) {
      throw ArgumentError('AnkiCard deckId cannot be null or empty');
    }
    if (questionText == null || questionText.isEmpty) {
      throw ArgumentError('AnkiCard questionText cannot be null or empty');
    }
    if (answerText == null || answerText.isEmpty) {
      throw ArgumentError('AnkiCard answerText cannot be null or empty');
    }

    return AnkiCard(
      id: id,
      deckId: deckId,
      questionText: questionText,
      answerText: answerText,
      state: CardState.fromString(data['state'] as String? ?? 'NEW'),
      repetitions: data['repetitions'] as int? ?? 0,
      easeFactor: (data['easeFactor'] as num?)?.toDouble() ?? 2.5,
      interval: data['interval'] as int? ?? 0,
      dueDate: data['dueDate'] != null
          ? DateTime.parse(data['dueDate'] as String)
          : DateTime.now(),
      lastReviewed: data['lastReviewed'] != null
          ? DateTime.parse(data['lastReviewed'] as String)
          : null,
      lapses: data['lapses'] as int? ?? 0,
      learningSteps: (data['learningSteps'] as List<dynamic>?)
          ?.map((step) => step as int)
          .toList() ?? [1, 10],
      currentStep: data['currentStep'] as int? ?? 0,
      suspended: data['suspended'] as bool? ?? false,
      tags: (data['tags'] as List<dynamic>?)
          ?.map((tag) => tag as String)
          .toList() ?? [],
      noteType: data['noteType'] as String? ?? 'Basic',
      created: data['created'] != null
          ? DateTime.parse(data['created'] as String)
          : DateTime.now(),
      modified: data['modified'] != null
          ? DateTime.parse(data['modified'] as String)
          : DateTime.now(),
    );
  }

  /// Convert AnkiCard to Firestore data
  Map<String, dynamic> toFirestore() {
    return {
      'id': id,
      'deckId': deckId,
      'questionText': questionText,
      'answerText': answerText,
      'state': state.value,
      'repetitions': repetitions,
      'easeFactor': easeFactor,
      'interval': interval,
      'dueDate': dueDate.toIso8601String(),
      'lastReviewed': lastReviewed?.toIso8601String(),
      'lapses': lapses,
      'learningSteps': learningSteps,
      'currentStep': currentStep,
      'suspended': suspended,
      'tags': tags,
      'noteType': noteType,
      'created': created.toIso8601String(),
      'modified': modified.toIso8601String(),
    };
  }

  /// Create AnkiCard from legacy map data (compatibility method)
  factory AnkiCard.fromMap(Map<String, dynamic> map) {
    return AnkiCard.fromFirestore(map);
  }

  /// Convert AnkiCard to legacy map format (compatibility method)
  Map<String, dynamic> toMap() {
    return toFirestore();
  }

  /// Convert from existing SingleCard to AnkiCard
  factory AnkiCard.fromSingleCard(SingleCard singleCard, String deckId) {
    // Map SingleCard difficulty to ease factor
    // SingleCard difficulty ranges from 0.01 to 1.0
    // AnkiCard ease factor ranges from 1.3 to 4.0
    final mappedEaseFactor = 1.3 + (singleCard.difficulty * (4.0 - 1.3));
    
    return AnkiCard(
      id: singleCard.id,
      deckId: deckId,
      questionText: singleCard.questionText,
      answerText: singleCard.answerText,
      easeFactor: mappedEaseFactor,
      // All other fields use default values for new cards
    );
  }

  /// Convert AnkiCard to SingleCard format (for backward compatibility)
  SingleCard toSingleCard() {
    // Map ease factor back to difficulty
    final mappedDifficulty = (easeFactor - 1.3) / (4.0 - 1.3);
    
    return SingleCard(
      id: id,
      deckName: deckId, // Note: This loses the actual deck name
      questionText: questionText,
      answerText: answerText,
      difficulty: mappedDifficulty.clamp(0.01, 1.0),
    );
  }

  /// Check if the card is due for review
  bool get isDue {
    if (suspended) return false;
    return DateTime.now().isAfter(dueDate) || DateTime.now().isAtSameMomentAs(dueDate);
  }

  /// Check if the card is new
  bool get isNew => state == CardState.newCard;

  /// Check if the card is in learning phase
  bool get isLearning => state == CardState.learning || state == CardState.relearning;

  /// Check if the card is in review phase
  bool get isReview => state == CardState.review;

  /// Get days until next review
  int get daysUntilDue {
    final now = DateTime.now();
    final difference = dueDate.difference(DateTime(now.year, now.month, now.day));
    return difference.inDays;
  }

  /// Create a copy with updated fields
  AnkiCard copyWith({
    String? id,
    String? deckId,
    String? questionText,
    String? answerText,
    CardState? state,
    int? repetitions,
    double? easeFactor,
    int? interval,
    DateTime? dueDate,
    DateTime? lastReviewed,
    int? lapses,
    List<int>? learningSteps,
    int? currentStep,
    bool? suspended,
    List<String>? tags,
    String? noteType,
    DateTime? created,
    DateTime? modified,
  }) {
    return AnkiCard(
      id: id ?? this.id,
      deckId: deckId ?? this.deckId,
      questionText: questionText ?? this.questionText,
      answerText: answerText ?? this.answerText,
      state: state ?? this.state,
      repetitions: repetitions ?? this.repetitions,
      easeFactor: easeFactor ?? this.easeFactor,
      interval: interval ?? this.interval,
      dueDate: dueDate ?? this.dueDate,
      lastReviewed: lastReviewed ?? this.lastReviewed,
      lapses: lapses ?? this.lapses,
      learningSteps: learningSteps ?? this.learningSteps,
      currentStep: currentStep ?? this.currentStep,
      suspended: suspended ?? this.suspended,
      tags: tags ?? this.tags,
      noteType: noteType ?? this.noteType,
      created: created ?? this.created,
      modified: modified ?? DateTime.now(), // Always update modified time
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AnkiCard && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'AnkiCard(id: $id, deckId: $deckId, question: ${questionText.length > 50 ? '${questionText.substring(0, 50)}...' : questionText}, state: ${state.value}, easeFactor: $easeFactor, interval: $interval, due: $dueDate)';
  }
}