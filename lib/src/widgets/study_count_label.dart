import 'package:flutter/material.dart';

class StudyCountLabel extends StatelessWidget {
  final int count;
  
  const StudyCountLabel({
    super.key,
    required this.count,
  });

  @override
  Widget build(BuildContext context) {
    print('StudyCountLabel: Received count = $count');
    
    // Don't show label if count is 0
    if (count <= 0) {
      print('StudyCountLabel: Hiding label because count <= 0');
      return const SizedBox.shrink();
    }
    
    print('StudyCountLabel: Showing label with count = $count');

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.blue.shade100,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.blue.shade200,
          width: 0.5,
        ),
      ),
      child: Text(
        count.toString(),
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: Colors.blue.shade700,
        ),
      ),
    );
  }
}