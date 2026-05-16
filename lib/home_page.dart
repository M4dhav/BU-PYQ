import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:url_launcher/url_launcher.dart';
import 'models/course.dart';
import 'services/pyq_data_service.dart';
import 'widgets/contribute_footer.dart';
import 'widgets/course_card.dart';
import 'widgets/course_list_tile.dart';
import 'widgets/paper_button.dart';

class HomePage extends StatefulWidget {
  const HomePage({
    super.key,
    required this.title,
    required this.themeMode,
    required this.onThemeToggle,
    required this.onAccentColorChange,
    required this.currentAccentColor,
  });

  final String title;
  final ThemeMode themeMode;
  final VoidCallback onThemeToggle;
  final Function(Color) onAccentColorChange;
  final Color currentAccentColor;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Course> courses = [];
  List<Course> filteredCourses = [];
  final PyqDataService pyqDataService = PyqDataService();
  TextEditingController searchController = TextEditingController();
  String searchQuery = '';
  bool filterMidSem = false;
  bool filterEndSem = false;
  String? selectedYear;
  final Set<String> selectedTypes = {};
  bool isGridView = true;
  bool isLoading = true;
  bool isStreamComplete = false;
  double loadingProgress = 0.0;
  int totalCourses = 0;
  int loadedCourses = 0;
  String? errorMessage;
  final Set<int> _expandedCourseNums = {};

  String _getCategoryName(String courseId) {
    final id = courseId.toUpperCase();
    if (id.startsWith('CSET')) return 'CS CORE';
    if (id.startsWith('EMAT')) return 'MATH & FOUNDATIONS';
    if (id.startsWith('EPHY')) return 'PHYSICS & SCIENCES';
    if (id.startsWith('UVAC')) return 'VALUE ADDED COURSES';
    return 'GENERAL';
  }

  void _toggleCourseExpanded(int courseNum) {
    setState(() {
      if (!_expandedCourseNums.remove(courseNum)) {
        _expandedCourseNums.add(courseNum);
      }
    });
  }

  void _showColorPicker() {
    final colors = [
      Colors.deepPurple,
      Colors.indigo,
      Colors.blue,
      Colors.teal,
      Colors.green,
      Colors.orange,
      Colors.deepOrange,
      Colors.pink,
      Colors.blueGrey,
      const Color(0xFF6750A4), // Material 3 Default
      const Color(0xFF2196F3),
      const Color(0xFFE91E63),
    ];

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Pick Accent Color'),
            content: SizedBox(
              width: 300,
              child: GridView.builder(
                shrinkWrap: true,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 4,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                ),
                itemCount: colors.length,
                itemBuilder: (context, index) {
                  final color = colors[index];
                  final isSelected =
                      widget.currentAccentColor.value == color.value;
                  return GestureDetector(
                    onTap: () {
                      widget.onAccentColorChange(color);
                      Navigator.pop(context);
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: color,
                        shape: BoxShape.circle,
                        border:
                            isSelected
                                ? Border.all(color: Colors.white, width: 3)
                                : null,
                        boxShadow:
                            isSelected
                                ? [
                                  BoxShadow(
                                    color: color.withValues(alpha: 0.5),
                                    blurRadius: 8,
                                    spreadRadius: 2,
                                  ),
                                ]
                                : null,
                      ),
                      child:
                          isSelected
                              ? const Icon(
                                Icons.check,
                                color: Colors.white,
                                size: 20,
                              )
                              : null,
                    ),
                  );
                },
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
            ],
          ),
    );
  }

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _loadCourses();
    });
  }

  Future<void> _loadCourses() async {
    setState(() {
      isLoading = true;
      isStreamComplete = false;
      loadingProgress = 0.0;
      loadedCourses = 0;
      courses.clear();
      filteredCourses.clear();
      errorMessage = null;
    });

    try {
      await for (final course in pyqDataService.fetchCoursesStream()) {
        setState(() {
          courses.add(course);
          loadedCourses++;
          if (searchQuery.isEmpty) {
            filteredCourses = List.from(courses);
          } else {
            filterDocuments(searchQuery);
          }
        });
      }

      setState(() {
        isStreamComplete = true;
        isLoading = false;
        loadingProgress = 1.0;
        totalCourses = courses.length;
      });
    } catch (e) {
      setState(() {
        errorMessage = 'Failed to load courses: ${e.toString()}';
        isLoading = false;
        isStreamComplete = true;
      });
    }
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  void filterDocuments(String query) {
    setState(() {
      searchQuery = query;

      if (query.isNotEmpty) {
        _expandedCourseNums.clear();
      }

      final queryWords =
          query
              .toLowerCase()
              .split(' ')
              .where((word) => word.isNotEmpty)
              .toList();

      filteredCourses =
          courses.where((course) {
            bool matchesFilters = true;

            if (filterMidSem || filterEndSem) {
              bool hasMidSem = false;
              bool hasEndSem = false;

              for (final paper in course.papers) {
                final lowerLabel = paper.label.toLowerCase();
                if (lowerLabel.contains('mid semester')) hasMidSem = true;
                if (lowerLabel.contains('end semester')) hasEndSem = true;
              }

              if (filterMidSem && filterEndSem) {
                matchesFilters = hasMidSem || hasEndSem;
              } else if (filterMidSem) {
                matchesFilters = hasMidSem;
              } else if (filterEndSem) {
                matchesFilters = hasEndSem;
              }
            }

            if (selectedYear != null) {
              bool hasYear = false;
              for (final paper in course.papers) {
                if (paper.paperSuffix.contains(selectedYear!.substring(0, 4)) ||
                    paper.paperSuffix == selectedYear) {
                  hasYear = true;
                  break;
                }
              }
              if (!hasYear) matchesFilters = false;
            }

            if (selectedTypes.isNotEmpty) {
              bool hasType = false;
              for (final paper in course.papers) {
                final lower = paper.label.toLowerCase();
                for (final type in selectedTypes) {
                  if (lower.contains(type.toLowerCase())) {
                    hasType = true;
                    break;
                  }
                }
                if (hasType) break;
              }
              if (!hasType) matchesFilters = false;
            }

            if (!matchesFilters) return false;

            if (query.isEmpty) return true;

            final courseName = course.name.toLowerCase();
            final courseCodes = course.courseId
                .map((id) => id.toLowerCase())
                .join(' ');
            final description =
                '$courseName ${course.joinedCourseIds.toLowerCase()}';

            bool matchesAllWords = true;
            for (final word in queryWords) {
              if (!courseName.contains(word) &&
                  !courseCodes.contains(word) &&
                  !description.contains(word)) {
                matchesAllWords = false;
                break;
              }
            }

            final lowerQuery = query.toLowerCase();
            final exactPhraseMatch =
                courseName.contains(lowerQuery) ||
                courseCodes.contains(lowerQuery) ||
                description.contains(lowerQuery);

            return matchesAllWords || exactPhraseMatch;
          }).toList();
    });
  }

  Widget _buildCoursesView(BuildContext context) {
    if (filteredCourses.isEmpty && isStreamComplete) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.search_off, size: 64, color: Colors.grey.shade400),
              const SizedBox(height: 16),
              Text(
                'No matches for "$searchQuery"',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 6),
              Text(
                'Try a different course name or code',
                style: TextStyle(color: Colors.grey.shade600),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              TextButton.icon(
                onPressed: () {
                  searchController.clear();
                  filterDocuments('');
                },
                icon: const Icon(Icons.clear),
                label: const Text('Clear search'),
              ),
            ],
          ),
        ),
      );
    }

    final screenWidth = MediaQuery.of(context).size.width;

    int crossAxisCount = isGridView ? 2 : 1;
    final Map<String, List<Course>> groupedCourses = {};
    final List<String> categoriesOrder = [
      'CS CORE',
      'MATH & FOUNDATIONS',
      'PHYSICS & SCIENCES',
      'VALUE ADDED COURSES',
      'GENERAL',
    ];

    for (var course in filteredCourses) {
      final cat = _getCategoryName(course.primaryCourseId);
      groupedCourses.putIfAbsent(cat, () => []).add(course);
    }

    final activeCategories =
        categoriesOrder
            .where((cat) => groupedCourses.containsKey(cat))
            .toList();

    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: activeCategories.length + 1,
      itemBuilder: (context, catIndex) {
        if (catIndex == activeCategories.length) {
          return const Padding(
            padding: EdgeInsets.fromLTRB(24, 8, 24, 24),
            child: ContributeFooterCard(),
          );
        }

        final category = activeCategories[catIndex];
        final categoryCourses = groupedCourses[category]!;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
              child: Text(
                category,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                  color: Theme.of(
                    context,
                  ).colorScheme.primary.withValues(alpha: 0.8),
                ),
              ),
            ),
            if (isGridView)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount:
                      screenWidth >= 1200 ? 4 : (screenWidth >= 700 ? 3 : 2),
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 16,
                  childAspectRatio:
                      screenWidth >= 1200
                          ? 1.2
                          : (screenWidth >= 700 ? 1.0 : 0.72),
                  children: [
                    for (final course in categoryCourses)
                      CourseCard(course: course),
                  ],
                ),
              )
            else
              Card(
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                elevation: 0,
                color: Theme.of(
                  context,
                ).colorScheme.surfaceContainerLow.withValues(alpha: 0.5),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                clipBehavior: Clip.antiAlias,
                child: Column(
                  children: [
                    for (int i = 0; i < categoryCourses.length; i++) ...[
                      CourseListTile(
                        course: categoryCourses[i],
                        isExpanded: _expandedCourseNums.contains(
                          categoryCourses[i].courseNum,
                        ),
                        onTap:
                            () => _toggleCourseExpanded(
                              categoryCourses[i].courseNum,
                            ),
                      ),
                      if (_expandedCourseNums.contains(
                        categoryCourses[i].courseNum,
                      ))
                        Padding(
                          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                          child: Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children:
                                categoryCourses[i].papers
                                    .map(
                                      (paper) => PaperButton(
                                        label: paper.label,
                                        url: PyqDataService.paperUrl(paper),
                                      ),
                                    )
                                    .toList(),
                          ),
                        ),
                      if (i < categoryCourses.length - 1)
                        Divider(
                          height: 1,
                          indent: 16,
                          endIndent: 16,
                          color: Theme.of(
                            context,
                          ).colorScheme.outlineVariant.withValues(alpha: 0.5),
                        ),
                    ],
                  ],
                ),
              ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'BU Scholar',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
            ),
            Text(
              'Previous Year Papers',
              style: TextStyle(fontSize: 11, fontWeight: FontWeight.w400),
            ),
          ],
        ),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        elevation: 2,
        centerTitle: false,
        actions: [
          IconButton(
            tooltip: 'Accent Color',
            icon: const Icon(Icons.settings_outlined),
            onPressed: _showColorPicker,
          ),
          IconButton(
            tooltip: 'Contribute papers',
            icon: const Icon(Icons.handshake_outlined),
            onPressed: () async {
              await launchUrl(
                Uri.parse(contributionsUrl),
                mode: LaunchMode.externalApplication,
              );
            },
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: TextButton.icon(
              onPressed: () async {
                await launchUrl(Uri.parse("https://github.com/M4dhav"));
              },
              icon: SvgPicture.asset(
                'assets/github-mark.svg',
                width: 18,
                height: 18,
              ),
              label: const Text(
                'Made with ❤️ by M4dhav',
                style: TextStyle(fontSize: 12),
              ),
              style: TextButton.styleFrom(
                foregroundColor: Theme.of(context).colorScheme.onSurface,
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextField(
                  controller: searchController,
                  decoration: InputDecoration(
                    hintText: 'Search for courses...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                    suffixIcon: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          child: Text(
                            (searchQuery.isEmpty &&
                                    !filterMidSem &&
                                    !filterEndSem &&
                                    selectedYear == null &&
                                    selectedTypes.isEmpty)
                                ? '${courses.length} courses'
                                : '${filteredCourses.length} / ${courses.length}',
                            style: TextStyle(
                              fontSize: 12,
                              color: Theme.of(context).hintColor,
                            ),
                          ),
                        ),
                        if (searchController.text.isNotEmpty)
                          IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              searchController.clear();
                              filterDocuments('');
                            },
                          )
                        else
                          const SizedBox(width: 12),
                      ],
                    ),
                    suffixIconConstraints: const BoxConstraints(
                      minWidth: 0,
                      minHeight: 0,
                    ),
                  ),
                  onChanged: filterDocuments,
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            ActionChip(
                              avatar: const Icon(Icons.tune, size: 16),
                              label: const Text('Filters'),
                              onPressed: () => _showFilterSheet(context),
                              backgroundColor:
                                  (selectedYear != null ||
                                          selectedTypes.isNotEmpty)
                                      ? Theme.of(
                                        context,
                                      ).colorScheme.primaryContainer
                                      : null,
                            ),
                            const SizedBox(width: 8),
                            FilterChip(
                              label: const Text('Mid Semester'),
                              selected: filterMidSem,
                              onSelected: (selected) {
                                setState(() {
                                  filterMidSem = selected;
                                  filterDocuments(searchQuery);
                                });
                              },
                              selectedColor: Colors.purple.withValues(
                                alpha: 0.15,
                              ),
                              checkmarkColor: Colors.purple.shade800,
                              labelStyle: TextStyle(
                                color:
                                    filterMidSem
                                        ? Colors.purple.shade800
                                        : null,
                                fontWeight:
                                    filterMidSem ? FontWeight.w600 : null,
                              ),
                            ),
                            const SizedBox(width: 8),
                            FilterChip(
                              label: const Text('End Semester'),
                              selected: filterEndSem,
                              onSelected: (selected) {
                                setState(() {
                                  filterEndSem = selected;
                                  filterDocuments(searchQuery);
                                });
                              },
                              selectedColor: Colors.green.withValues(
                                alpha: 0.15,
                              ),
                              checkmarkColor: Colors.green.shade800,
                              labelStyle: TextStyle(
                                color:
                                    filterEndSem ? Colors.green.shade800 : null,
                                fontWeight:
                                    filterEndSem ? FontWeight.w600 : null,
                              ),
                            ),
                            const SizedBox(width: 8),
                            for (final year in ['2024-25', '2022-23'])
                              Padding(
                                padding: const EdgeInsets.only(right: 8.0),
                                child: FilterChip(
                                  label: Text(year),
                                  selected: selectedYear == year,
                                  onSelected: (selected) {
                                    setState(() {
                                      selectedYear = selected ? year : null;
                                      filterDocuments(searchQuery);
                                    });
                                  },
                                  selectedColor: Colors.blue.withValues(
                                    alpha: 0.15,
                                  ),
                                  checkmarkColor: Colors.blue.shade800,
                                  labelStyle: TextStyle(
                                    color:
                                        selectedYear == year
                                            ? Colors.blue.shade800
                                            : null,
                                    fontWeight:
                                        selectedYear == year
                                            ? FontWeight.w600
                                            : null,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton.filledTonal(
                      icon: Icon(
                        isGridView ? Icons.view_list : Icons.grid_view,
                      ),
                      onPressed: () => setState(() => isGridView = !isGridView),
                      tooltip:
                          isGridView
                              ? 'Switch to List View'
                              : 'Switch to Grid View',
                    ),
                    const SizedBox(width: 8),
                    IconButton.filledTonal(
                      icon: Icon(
                        Theme.of(context).brightness == Brightness.dark
                            ? Icons.light_mode
                            : Icons.dark_mode,
                      ),
                      onPressed: widget.onThemeToggle,
                      tooltip: 'Toggle Theme',
                    ),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: Column(
              children: [
                if (isLoading && !isStreamComplete)
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      children: [
                        LinearProgressIndicator(value: null),
                        const SizedBox(height: 8),
                        Text(
                          'Loading courses... ($loadedCourses loaded)',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                Expanded(
                  child:
                      errorMessage != null
                          ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(
                                  Icons.error_outline,
                                  size: 64,
                                  color: Colors.red,
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'Error Loading Courses',
                                  style:
                                      Theme.of(context).textTheme.headlineSmall,
                                ),
                                const SizedBox(height: 8),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 32,
                                  ),
                                  child: Text(
                                    errorMessage!,
                                    textAlign: TextAlign.center,
                                    style:
                                        Theme.of(context).textTheme.bodyMedium,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                ElevatedButton(
                                  onPressed: () {
                                    _loadCourses();
                                  },
                                  child: const Text('Retry'),
                                ),
                              ],
                            ),
                          )
                          : courses.isEmpty && isStreamComplete
                          ? const Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.school_outlined,
                                  size: 64,
                                  color: Colors.grey,
                                ),
                                SizedBox(height: 16),
                                Text(
                                  'No Courses Available',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(height: 8),
                                Text(
                                  'No course materials have been uploaded yet.',
                                  style: TextStyle(color: Colors.grey),
                                ),
                              ],
                            ),
                          )
                          : _buildCoursesView(context),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showFilterSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return DraggableScrollableSheet(
              initialChildSize: 0.6,
              maxChildSize: 0.9,
              minChildSize: 0.4,
              expand: false,
              builder: (context, scrollController) {
                return SingleChildScrollView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Detailed Filters',
                            style: Theme.of(context).textTheme.headlineSmall
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          TextButton(
                            onPressed: () {
                              setState(() {
                                filterMidSem = false;
                                filterEndSem = false;
                                selectedYear = null;
                                selectedTypes.clear();
                                filterDocuments(searchController.text);
                              });
                              Navigator.pop(context);
                            },
                            child: const Text('Clear All'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'Academic Year',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        children:
                            ['2025-26', '2024-25', '2023-24', '2022-23'].map((
                              year,
                            ) {
                              final isSelected = selectedYear == year;
                              return ChoiceChip(
                                label: Text(year),
                                selected: isSelected,
                                onSelected: (val) {
                                  setState(() {
                                    selectedYear = val ? year : null;
                                    filterDocuments(searchController.text);
                                  });
                                  setSheetState(() {});
                                },
                              );
                            }).toList(),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'Paper Type',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        children:
                            [
                              'Assignment',
                              'Lab',
                              'Quiz',
                              'Supplementary',
                              'Makeup',
                              'Notes',
                            ].map((type) {
                              final isSelected = selectedTypes.contains(type);
                              return FilterChip(
                                label: Text(type),
                                selected: isSelected,
                                onSelected: (val) {
                                  setState(() {
                                    if (val) {
                                      selectedTypes.add(type);
                                    } else {
                                      selectedTypes.remove(type);
                                    }
                                    filterDocuments(searchController.text);
                                  });
                                  setSheetState(() {});
                                },
                              );
                            }).toList(),
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Apply Filters'),
                        ),
                      ),
                      const SizedBox(height: 32),
                    ],
                  ),
                );
              },
            );
          },
        );
      },
    );
  }
}
