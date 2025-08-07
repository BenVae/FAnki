import 'package:flutter/material.dart';
import 'package:card_repository/card_deck_manager.dart';

class StudyHeatmap extends StatelessWidget {
  final List<DailyStudyData> dailyData;
  final Function(DateTime)? onDayTapped;

  const StudyHeatmap({
    super.key,
    required this.dailyData,
    this.onDayTapped,
  });

  @override
  Widget build(BuildContext context) {
    // Group data by weeks
    final weeks = _groupByWeeks(dailyData);
    
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
        mainAxisSize: MainAxisSize.min,
        children: [
          // Title
          Text(
            'Study Activity',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade900,
            ),
          ),
          SizedBox(height: 12),
          
          // Month labels
          _buildMonthLabels(weeks),
          SizedBox(height: 4),
          
          // Heatmap grid with day labels
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Day of week labels
              Column(
                children: [
                  SizedBox(height: 2),
                  ..._buildDayLabels(),
                ],
              ),
              SizedBox(width: 8),
              
              // Heatmap cells
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  reverse: true,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: weeks.reversed.map((week) => _buildWeekColumn(week)).toList(),
                  ),
                ),
              ),
            ],
          ),
          
          // Legend
          SizedBox(height: 16),
          _buildLegend(),
        ],
      ),
    );
  }

  /// Group daily data into weeks
  List<List<DailyStudyData>> _groupByWeeks(List<DailyStudyData> data) {
    final weeks = <List<DailyStudyData>>[];
    List<DailyStudyData> currentWeek = [];
    
    for (final day in data) {
      currentWeek.add(day);
      if (day.date.weekday == DateTime.sunday || day == data.last) {
        // Pad the week if needed
        while (currentWeek.length < 7 && weeks.isEmpty) {
          // Add padding for the first week
          final firstDay = currentWeek.first.date;
          final dayOfWeek = firstDay.weekday % 7; // Convert to 0-6 (Sun-Sat)
          if (dayOfWeek > 0) {
            currentWeek.insert(0, DailyStudyData(
              date: firstDay.subtract(Duration(days: 1)),
              totalCards: -1, // Indicator for padding
              intensity: -1,
            ));
          } else {
            break;
          }
        }
        weeks.add(List.from(currentWeek));
        currentWeek.clear();
      }
    }
    
    return weeks;
  }

  /// Build month labels
  Widget _buildMonthLabels(List<List<DailyStudyData>> weeks) {
    final months = <String, int>{};
    final monthNames = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 
                       'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    
    // Count weeks per month
    for (final week in weeks) {
      for (final day in week) {
        if (day.intensity >= 0) {
          final monthKey = '${day.date.year}-${day.date.month}';
          months[monthKey] = (months[monthKey] ?? 0) + 1;
        }
      }
    }
    
    return Container(
      height: 20,
      padding: EdgeInsets.only(left: 40),
      child: Row(
        children: months.entries.map((entry) {
          final parts = entry.key.split('-');
          final month = int.parse(parts[1]);
          return Container(
            width: entry.value * 3.5, // Approximate width per week
            child: Text(
              monthNames[month - 1],
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  /// Build day of week labels
  List<Widget> _buildDayLabels() {
    final days = ['S', 'M', 'T', 'W', 'T', 'F', 'S'];
    return days.map((day) => Container(
      height: 14,
      width: 32,
      alignment: Alignment.centerRight,
      child: Text(
        day,
        style: TextStyle(
          fontSize: 11,
          color: Colors.grey.shade600,
        ),
      ),
    )).toList();
  }

  /// Build a week column
  Widget _buildWeekColumn(List<DailyStudyData> week) {
    // Ensure week has 7 days (pad if needed)
    while (week.length < 7) {
      week.add(DailyStudyData(
        date: DateTime.now(),
        totalCards: -1,
        intensity: -1,
      ));
    }
    
    return Column(
      children: week.map((day) => _buildDayCell(day)).toList(),
    );
  }

  /// Build a single day cell
  Widget _buildDayCell(DailyStudyData day) {
    if (day.intensity < 0) {
      // Padding cell
      return Container(
        width: 14,
        height: 14,
        margin: EdgeInsets.all(1),
      );
    }
    
    final color = _getIntensityColor(day.intensity);
    final isToday = _isToday(day.date);
    
    return Tooltip(
      message: '${_formatDate(day.date)}\n${day.totalCards} cards',
      child: InkWell(
        onTap: onDayTapped != null ? () => onDayTapped!(day.date) : null,
        child: Container(
          width: 14,
          height: 14,
          margin: EdgeInsets.all(1),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
            border: isToday ? Border.all(
              color: Colors.grey.shade700,
              width: 1,
            ) : null,
          ),
        ),
      ),
    );
  }

  /// Get color based on intensity
  Color _getIntensityColor(int intensity) {
    switch (intensity) {
      case 0:
        return Colors.grey.shade200;
      case 1:
        return Colors.green.shade300;
      case 2:
        return Colors.green.shade500;
      case 3:
        return Colors.green.shade700;
      default:
        return Colors.grey.shade200;
    }
  }

  /// Build legend
  Widget _buildLegend() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Less',
          style: TextStyle(
            fontSize: 11,
            color: Colors.grey.shade600,
          ),
        ),
        SizedBox(width: 4),
        ...List.generate(4, (index) => Container(
          width: 12,
          height: 12,
          margin: EdgeInsets.symmetric(horizontal: 2),
          decoration: BoxDecoration(
            color: _getIntensityColor(index),
            borderRadius: BorderRadius.circular(2),
          ),
        )),
        SizedBox(width: 4),
        Text(
          'More',
          style: TextStyle(
            fontSize: 11,
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }

  /// Check if date is today
  bool _isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year && 
           date.month == now.month && 
           date.day == now.day;
  }

  /// Format date for tooltip
  String _formatDate(DateTime date) {
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
                   'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }
}