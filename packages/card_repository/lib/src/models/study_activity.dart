import 'package:uuid/uuid.dart';

/// Represents a single study session activity
class StudyActivity {
  final String id;
  final String userId;
  final DateTime date;
  final int cardsReviewed;
  final int newCardsStudied;
  final int minutesSpent;
  final Map<String, int> deckActivity; // deckId -> cards reviewed
  
  StudyActivity({
    String? id,
    required this.userId,
    required this.date,
    required this.cardsReviewed,
    this.newCardsStudied = 0,
    this.minutesSpent = 0,
    Map<String, int>? deckActivity,
  })  : id = id ?? const Uuid().v4(),
        deckActivity = deckActivity ?? {};

  /// Create from Firestore data
  factory StudyActivity.fromMap(Map<String, dynamic> map) {
    return StudyActivity(
      id: map['id'] as String,
      userId: map['userId'] as String,
      date: DateTime.parse(map['date'] as String),
      cardsReviewed: map['cardsReviewed'] as int? ?? 0,
      newCardsStudied: map['newCardsStudied'] as int? ?? 0,
      minutesSpent: map['minutesSpent'] as int? ?? 0,
      deckActivity: Map<String, int>.from(map['deckActivity'] ?? {}),
    );
  }

  /// Convert to Firestore data
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'date': date.toIso8601String(),
      'cardsReviewed': cardsReviewed,
      'newCardsStudied': newCardsStudied,
      'minutesSpent': minutesSpent,
      'deckActivity': deckActivity,
    };
  }

  /// Create a copy with updated fields
  StudyActivity copyWith({
    String? id,
    String? userId,
    DateTime? date,
    int? cardsReviewed,
    int? newCardsStudied,
    int? minutesSpent,
    Map<String, int>? deckActivity,
  }) {
    return StudyActivity(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      date: date ?? this.date,
      cardsReviewed: cardsReviewed ?? this.cardsReviewed,
      newCardsStudied: newCardsStudied ?? this.newCardsStudied,
      minutesSpent: minutesSpent ?? this.minutesSpent,
      deckActivity: deckActivity ?? this.deckActivity,
    );
  }
}

/// Daily aggregated study data for heatmap
class DailyStudyData {
  final DateTime date;
  final int totalCards;
  final int intensity; // 0-3 for heatmap coloring
  
  DailyStudyData({
    required this.date,
    required this.totalCards,
    required this.intensity,
  });

  /// Calculate intensity based on card count
  static int calculateIntensity(int cardCount) {
    if (cardCount == 0) return 0;
    if (cardCount <= 10) return 1;
    if (cardCount <= 30) return 2;
    return 3;
  }
}