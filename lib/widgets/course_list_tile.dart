import 'package:flutter/material.dart';
import '../models/course.dart';
import '../services/pyq_data_service.dart';
import '../utils/string_extensions.dart';

class CourseListTile extends StatelessWidget {
  final Course course;
  final bool isExpanded;
  final VoidCallback onTap;

  const CourseListTile({
    super.key,
    required this.course,
    this.isExpanded = false,
    required this.onTap,
  });

  String _shortenLabel(String label, String suffix) {
    String shortLabel = label;
    if (label.toLowerCase().contains('end semester')) {
      shortLabel = 'End';
    } else if (label.toLowerCase().contains('mid semester')) {
      shortLabel = 'Mid';
    } else if (label.toLowerCase().contains('assignment')) {
      shortLabel = 'Asgn';
    } else if (label.toLowerCase().contains('quiz')) {
      shortLabel = 'Quiz';
    } else if (label.toLowerCase().contains('supplementary')) {
      shortLabel = 'Supp';
    } else if (label.toLowerCase().contains('makeup')) {
      shortLabel = 'Mkup';
    }

    String shortSuffix = suffix;
    if (suffix.length >= 4) {
      if (suffix.contains('-')) {
        final parts = suffix.split('-');
        shortSuffix = '${parts[0].substring(parts[0].length - 2)}-${parts[1].substring(parts[1].length - 2)}';
      } else {
        shortSuffix = suffix.substring(suffix.length - 2);
      }
    }

    return '$shortLabel $shortSuffix';
  }

  MaterialColor _getPaperColor(String label) {
    final lower = label.toLowerCase();
    if (lower.contains('end semester')) return Colors.green;
    if (lower.contains('mid semester')) return Colors.purple;
    if (lower.contains('assignment') || lower.contains('nptel')) return Colors.indigo;
    if (lower.contains('lab')) return Colors.teal;
    if (lower.contains('quiz')) return Colors.orange;
    if (lower.contains('supplementary') || lower.contains('makeup')) return Colors.deepPurple;
    return Colors.blueGrey;
  }

  IconData _getCategoryIcon(String courseId) {
    final id = courseId.toUpperCase();
    if (id.startsWith('CSET')) return Icons.computer;
    if (id.startsWith('EMAT')) return Icons.calculate;
    if (id.startsWith('EPHY')) return Icons.science;
    if (id.startsWith('UVAC')) return Icons.eco;
    return Icons.menu_book;
  }

  Color _getCategoryColor(String courseId) {
    final id = courseId.toUpperCase();
    if (id.startsWith('CSET')) return Colors.blue;
    if (id.startsWith('EMAT')) return Colors.orange;
    if (id.startsWith('EPHY')) return Colors.teal;
    if (id.startsWith('UVAC')) return Colors.green;
    return Colors.indigo;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    final courseName = course.name
        .replaceAll('_', ' ')
        .split(' ')
        .map((word) => word.capitalize())
        .join(' ');

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: _getCategoryColor(course.primaryCourseId).withValues(alpha: isDark ? 0.2 : 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                _getCategoryIcon(course.primaryCourseId),
                size: 18,
                color: _getCategoryColor(course.primaryCourseId),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    courseName,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    course.joinedCourseIds.toUpperCase(),
                    style: TextStyle(
                      fontSize: 12,
                      fontFamily: 'monospace',
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            AnimatedRotation(
              turns: isExpanded ? 0.25 : 0,
              duration: const Duration(milliseconds: 200),
              child: Icon(
                Icons.chevron_right,
                size: 20,
                color: theme.colorScheme.outline.withValues(alpha: 0.5),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
