import 'package:flutter/material.dart';
import '../models/course.dart';
import '../services/pyq_data_service.dart';
import '../utils/string_extensions.dart';

class CourseCard extends StatelessWidget {
  final Course course;

  const CourseCard({super.key, required this.course});

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
    final courseCode = course.joinedCourseIds.toUpperCase();

    final papers = course.papers;

    // Categorize papers
    int midCount = 0;
    int endCount = 0;
    int suppCount = 0;
    int assignCount = 0;

    for (final paper in papers) {
      final label = paper.label.toLowerCase();
      if (label.contains('mid')) {
        midCount++;
      } else if (label.contains('end')) {
        endCount++;
      } else if (label.contains('makeup') || label.contains('supple')) {
        suppCount++;
      } else if (label.contains('assign') ||
          label.contains('lab') ||
          label.contains('note')) {
        assignCount++;
      }
    }

    return Card(
      elevation: 0,
      color: theme.colorScheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
        side: BorderSide(
          color: theme.colorScheme.outlineVariant.withValues(alpha: 0.3),
          width: 1.5,
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Top Section: Icon and Name
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        color: _getCategoryColor(
                          course.primaryCourseId,
                        ).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Icon(
                        _getCategoryIcon(course.primaryCourseId),
                        size: 28,
                        color: _getCategoryColor(course.primaryCourseId),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            courseName,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                              height: 1.1,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            courseCode,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                // Stats 2x2 Grid
                Column(
                  children: [
                    Row(
                      children: [
                        _StatBox(label: 'MID SEMESTER', value: '$midCount'),
                        const SizedBox(width: 10),
                        _StatBox(label: 'END SEMESTER', value: '$endCount'),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        _StatBox(label: 'SUPP / MAKE', value: '$suppCount'),
                        const SizedBox(width: 10),
                        _StatBox(label: 'ASSIGN / LAB', value: '$assignCount'),
                      ],
                    ),
                  ],
                ),
              ],
            ),
            // Bottom Action Button
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () => _showCourseOptions(context),
                style: FilledButton.styleFrom(
                  backgroundColor: isDark ? Colors.white : Colors.black,
                  foregroundColor: isDark ? Colors.black : Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  elevation: 0,
                ),
                child: const Text(
                  'Explore Resources',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showCourseOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.6,
          minChildSize: 0.4,
          maxChildSize: 0.9,
          expand: false,
          builder: (context, scrollController) {
            return Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      margin: const EdgeInsets.only(bottom: 24),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.outlineVariant,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  Text(
                    'Course Resources',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    course.name.capitalizeAll(),
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Expanded(
                    child:
                        course.papers.isEmpty
                            ? const Center(
                              child: Text('No papers available yet.'),
                            )
                            : ListView.separated(
                              controller: scrollController,
                              itemCount: course.papers.length,
                              separatorBuilder:
                                  (context, index) => const Divider(height: 1),
                              itemBuilder: (context, index) {
                                final paper = course.papers[index];
                                return ListTile(
                                  contentPadding: const EdgeInsets.symmetric(
                                    vertical: 8,
                                  ),
                                  leading: Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color:
                                          Theme.of(
                                            context,
                                          ).colorScheme.surfaceContainerHighest,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: const Icon(
                                      Icons.picture_as_pdf_outlined,
                                    ),
                                  ),
                                  title: Text(
                                    paper.label,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  subtitle: Text('Year: ${paper.paperSuffix}'),
                                  trailing: const Icon(Icons.chevron_right),
                                  onTap: () {
                                    Navigator.pop(context);
                                    Navigator.pushNamed(
                                      context,
                                      '/pdf_viewer',
                                      arguments: PyqDataService.paperUrl(paper),
                                    );
                                  },
                                );
                              },
                            ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

class _StatBox extends StatelessWidget {
  final String label;
  final String value;

  const _StatBox({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerLow,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: theme.colorScheme.outlineVariant.withValues(alpha: 0.25),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Flexible(
              child: Text(
                label,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.2,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 4),
            Text(
              value,
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
                fontSize: 15,
                color: theme.colorScheme.onSurface,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
