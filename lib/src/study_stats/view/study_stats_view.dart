import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:card_repository/card_deck_manager.dart';
import 'package:authentication_repository/authentication_repository.dart';
import '../../widgets/study_heatmap.dart';

class StudyStatsView extends StatefulWidget {
  const StudyStatsView({super.key});

  @override
  State<StudyStatsView> createState() => _StudyStatsViewState();
}

class _StudyStatsViewState extends State<StudyStatsView> {
  final StudyActivityManager _activityManager = StudyActivityManager();
  List<DailyStudyData> _dailyData = [];
  Map<String, dynamic> _stats = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initializeAndLoad();
  }

  Future<void> _initializeAndLoad() async {
    // Get user ID from authentication repository
    final authRepo = RepositoryProvider.of<AuthenticationRepository>(context);
    final userId = authRepo.currentUser.email ?? '';
    
    if (userId.isNotEmpty) {
      _activityManager.setUserId(userId);
      await _loadData();
    } else {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    
    try {
      final dailyData = await _activityManager.getDailyStudyData();
      final stats = await _activityManager.getStudyStats();
      
      setState(() {
        _dailyData = dailyData;
        _stats = stats;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Center(
        child: CircularProgressIndicator(),
      );
    }

    return SingleChildScrollView(
      padding: EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Icon(
                Icons.insights,
                size: 32,
                color: Colors.blue.shade600,
              ),
              SizedBox(width: 12),
              Text(
                'Study Statistics',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade900,
                ),
              ),
            ],
          ),
          SizedBox(height: 24),
          
          // Stats cards
          GridView.count(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            crossAxisCount: MediaQuery.of(context).size.width > 600 ? 3 : 2,
            mainAxisSpacing: 16,
            crossAxisSpacing: 16,
            childAspectRatio: 1.5,
            children: [
              _StatCard(
                title: 'Current Streak',
                value: '${_stats['currentStreak'] ?? 0}',
                unit: 'days',
                icon: Icons.local_fire_department,
                color: Colors.orange,
              ),
              _StatCard(
                title: 'Total Cards',
                value: '${_stats['totalCards'] ?? 0}',
                unit: 'reviewed',
                icon: Icons.style,
                color: Colors.blue,
              ),
              _StatCard(
                title: 'Study Days',
                value: '${_stats['studyDays'] ?? 0}',
                unit: 'days',
                icon: Icons.calendar_today,
                color: Colors.green,
              ),
              _StatCard(
                title: 'Average',
                value: '${_stats['averageCards'] ?? 0}',
                unit: 'cards/day',
                icon: Icons.trending_up,
                color: Colors.purple,
              ),
              _StatCard(
                title: 'Time Spent',
                value: '${_stats['totalMinutes'] ?? 0}',
                unit: 'minutes',
                icon: Icons.timer,
                color: Colors.teal,
              ),
              _StatCard(
                title: 'Best Streak',
                value: '${_stats['longestStreak'] ?? 0}',
                unit: 'days',
                icon: Icons.emoji_events,
                color: Colors.amber,
              ),
            ],
          ),
          
          SizedBox(height: 24),
          
          // Heatmap
          StudyHeatmap(
            dailyData: _dailyData,
            onDayTapped: (date) {
              // Could show detailed stats for that day
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Study details for ${date.toString().split(' ')[0]}'),
                  duration: Duration(seconds: 2),
                ),
              );
            },
          ),
          
          SizedBox(height: 24),
          
          // Motivational message
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.blue.shade50, Colors.blue.shade100],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.lightbulb_outline,
                  size: 32,
                  color: Colors.blue.shade700,
                ),
                SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _getMotivationalTitle(),
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue.shade900,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        _getMotivationalMessage(),
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.blue.shade700,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _getMotivationalTitle() {
    final streak = _stats['currentStreak'] ?? 0;
    if (streak >= 7) return 'Outstanding Dedication!';
    if (streak >= 3) return 'Great Progress!';
    if (streak >= 1) return 'Keep Going!';
    return 'Start Your Journey!';
  }

  String _getMotivationalMessage() {
    final streak = _stats['currentStreak'] ?? 0;
    final average = _stats['averageCards'] ?? 0;
    
    if (streak >= 7) {
      return 'You\'ve been studying for $streak days straight! Your consistency is paying off.';
    }
    if (streak >= 3) {
      return 'A $streak day streak! You\'re building a strong habit.';
    }
    if (streak >= 1) {
      return 'You\'re on day $streak. Every day counts!';
    }
    if (average > 0) {
      return 'You\'ve reviewed an average of $average cards per study day. Start a new streak today!';
    }
    return 'Begin your learning journey today. Small steps lead to big achievements!';
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final String unit;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.title,
    required this.value,
    required this.unit,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
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
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(
                icon,
                size: 24,
                color: color.withValues(alpha: 0.8),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  unit,
                  style: TextStyle(
                    fontSize: 11,
                    color: color,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade900,
                ),
              ),
              Text(
                title,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}