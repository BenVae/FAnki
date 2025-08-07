import 'package:cloud_firestore/cloud_firestore.dart';
import 'models/study_activity.dart';

class StudyActivityManager {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String _userId = '';
  DateTime? _sessionStartTime;
  int _sessionCardsReviewed = 0;
  int _sessionNewCards = 0;
  Map<String, int> _sessionDeckActivity = {};

  /// Set the user ID for tracking
  void setUserId(String userId) {
    _userId = userId.toLowerCase();
  }

  /// Start a new study session
  void startSession() {
    _sessionStartTime = DateTime.now();
    _sessionCardsReviewed = 0;
    _sessionNewCards = 0;
    _sessionDeckActivity.clear();
  }

  /// Track a card review
  void trackCardReview({
    required String deckId,
    bool isNewCard = false,
  }) {
    if (_sessionStartTime == null) {
      startSession();
    }
    
    _sessionCardsReviewed++;
    if (isNewCard) {
      _sessionNewCards++;
    }
    
    _sessionDeckActivity[deckId] = (_sessionDeckActivity[deckId] ?? 0) + 1;
  }

  /// End the current session and save to Firestore
  Future<void> endSession() async {
    if (_sessionStartTime == null || _sessionCardsReviewed == 0) {
      return; // No session to save
    }

    final minutesSpent = DateTime.now().difference(_sessionStartTime!).inMinutes;
    final today = _getDateOnly(DateTime.now());
    
    // Get or create today's activity
    final activity = await _getTodayActivity() ?? StudyActivity(
      userId: _userId,
      date: today,
      cardsReviewed: 0,
    );

    // Update with session data
    final updatedActivity = activity.copyWith(
      cardsReviewed: activity.cardsReviewed + _sessionCardsReviewed,
      newCardsStudied: activity.newCardsStudied + _sessionNewCards,
      minutesSpent: activity.minutesSpent + minutesSpent,
      deckActivity: _mergeDeckActivity(activity.deckActivity, _sessionDeckActivity),
    );

    // Save to Firestore
    await _saveActivity(updatedActivity);

    // Reset session
    _sessionStartTime = null;
    _sessionCardsReviewed = 0;
    _sessionNewCards = 0;
    _sessionDeckActivity.clear();
  }

  /// Get today's activity if it exists
  Future<StudyActivity?> _getTodayActivity() async {
    if (_userId.isEmpty) return null;

    final today = _getDateOnly(DateTime.now());
    final todayStr = today.toIso8601String().split('T')[0];

    try {
      final snapshot = await _firestore
          .collection('users')
          .doc(_userId)
          .collection('study_activity')
          .doc(todayStr)
          .get();

      if (snapshot.exists && snapshot.data() != null) {
        final data = snapshot.data()!;
        data['id'] = snapshot.id;
        return StudyActivity.fromMap(data);
      }
    } catch (e) {
      print('Error getting today activity: $e');
    }
    
    return null;
  }

  /// Save activity to Firestore
  Future<void> _saveActivity(StudyActivity activity) async {
    if (_userId.isEmpty) return;

    final dateStr = activity.date.toIso8601String().split('T')[0];
    
    try {
      await _firestore
          .collection('users')
          .doc(_userId)
          .collection('study_activity')
          .doc(dateStr)
          .set(activity.toMap());
    } catch (e) {
      print('Error saving activity: $e');
    }
  }

  /// Get activities for the last N days
  Future<List<StudyActivity>> getRecentActivities({int days = 30}) async {
    if (_userId.isEmpty) return [];

    final startDate = DateTime.now().subtract(Duration(days: days));
    
    try {
      final snapshot = await _firestore
          .collection('users')
          .doc(_userId)
          .collection('study_activity')
          .where('date', isGreaterThanOrEqualTo: startDate.toIso8601String())
          .orderBy('date', descending: true)
          .get();

      return snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return StudyActivity.fromMap(data);
      }).toList();
    } catch (e) {
      print('Error getting recent activities: $e');
      return [];
    }
  }

  /// Get daily study data for heatmap (last month)
  Future<List<DailyStudyData>> getDailyStudyData() async {
    final activities = await getRecentActivities(days: 35); // Get a bit more for complete weeks
    final Map<String, int> dailyCards = {};
    
    // Aggregate cards by date
    for (final activity in activities) {
      final dateKey = activity.date.toIso8601String().split('T')[0];
      dailyCards[dateKey] = activity.cardsReviewed;
    }
    
    // Create daily data for the last 35 days (5 weeks)
    final List<DailyStudyData> dailyData = [];
    final today = _getDateOnly(DateTime.now());
    
    for (int i = 34; i >= 0; i--) {
      final date = today.subtract(Duration(days: i));
      final dateKey = date.toIso8601String().split('T')[0];
      final cardCount = dailyCards[dateKey] ?? 0;
      
      dailyData.add(DailyStudyData(
        date: date,
        totalCards: cardCount,
        intensity: DailyStudyData.calculateIntensity(cardCount),
      ));
    }
    
    return dailyData;
  }

  /// Get total stats for a period
  Future<Map<String, dynamic>> getStudyStats({int days = 30}) async {
    final activities = await getRecentActivities(days: days);
    
    int totalCards = 0;
    int totalMinutes = 0;
    int studyDays = 0;
    int currentStreak = 0;
    int longestStreak = 0;
    
    // Calculate stats
    for (final activity in activities) {
      if (activity.cardsReviewed > 0) {
        totalCards += activity.cardsReviewed;
        totalMinutes += activity.minutesSpent;
        studyDays++;
      }
    }
    
    // Calculate streaks
    final today = _getDateOnly(DateTime.now());
    DateTime checkDate = today;
    bool foundGap = false;
    
    // Current streak
    while (!foundGap) {
      final hasActivity = activities.any((a) => 
        _getDateOnly(a.date).isAtSameMomentAs(checkDate) && a.cardsReviewed > 0
      );
      
      if (hasActivity) {
        currentStreak++;
        checkDate = checkDate.subtract(Duration(days: 1));
      } else if (checkDate.isAtSameMomentAs(today)) {
        // Today doesn't have activity yet, check yesterday
        checkDate = checkDate.subtract(Duration(days: 1));
      } else {
        foundGap = true;
      }
      
      // Don't check beyond our data range
      if (checkDate.isBefore(today.subtract(Duration(days: days)))) {
        break;
      }
    }
    
    // Calculate longest streak
    int tempStreak = 0;
    for (int i = 0; i < days; i++) {
      final date = today.subtract(Duration(days: i));
      final hasActivity = activities.any((a) => 
        _getDateOnly(a.date).isAtSameMomentAs(date) && a.cardsReviewed > 0
      );
      
      if (hasActivity) {
        tempStreak++;
        longestStreak = tempStreak > longestStreak ? tempStreak : longestStreak;
      } else {
        tempStreak = 0;
      }
    }
    
    return {
      'totalCards': totalCards,
      'totalMinutes': totalMinutes,
      'studyDays': studyDays,
      'currentStreak': currentStreak,
      'longestStreak': longestStreak,
      'averageCards': studyDays > 0 ? (totalCards / studyDays).round() : 0,
    };
  }

  /// Merge two deck activity maps
  Map<String, int> _mergeDeckActivity(
    Map<String, int> existing,
    Map<String, int> session,
  ) {
    final merged = Map<String, int>.from(existing);
    session.forEach((deckId, count) {
      merged[deckId] = (merged[deckId] ?? 0) + count;
    });
    return merged;
  }

  /// Get date only (no time component)
  DateTime _getDateOnly(DateTime dateTime) {
    return DateTime(dateTime.year, dateTime.month, dateTime.day);
  }
}