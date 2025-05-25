import 'package:flutter/material.dart';
import 'package:waste_management_app/models/tutorial.dart';
import 'package:waste_management_app/screens/user/tutorial_detail_screen.dart';
import 'package:waste_management_app/services/api_service.dart';

class TutorialsScreen extends StatefulWidget {
  const TutorialsScreen({Key? key}) : super(key: key);

  @override
  State<TutorialsScreen> createState() => _TutorialsScreenState();
}

class _TutorialsScreenState extends State<TutorialsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late Future<List<Tutorial>> _tutorialsFuture;

  final List<String> _categories = [
    'All',
    'Composting',
    'Recycling',
    'Upcycling',
    'Waste Reduction',
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _categories.length, vsync: this);
    _loadTutorials();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _loadTutorials() {
    _tutorialsFuture = ApiService.getTutorials();
  }

  List<Tutorial> _filterTutorials(List<Tutorial> tutorials, String category) {
    if (category == 'All') {
      return tutorials;
    }
    return tutorials
        .where((tutorial) => tutorial.category == category)
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // Tab Bar
          TabBar(
            controller: _tabController,
            isScrollable: true,
            tabs: _categories.map((category) => Tab(text: category)).toList(),
            labelColor: Theme.of(context).colorScheme.primary,
            unselectedLabelColor: Colors.grey,
            indicatorColor: Theme.of(context).colorScheme.primary,
            onTap: (_) {
              setState(() {});
            },
          ),

          // Tab Content
          Expanded(
            child: FutureBuilder<List<Tutorial>>(
              future: _tutorialsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text('No tutorials available.'));
                } else {
                  final allTutorials = snapshot.data!;

                  return TabBarView(
                    controller: _tabController,
                    children:
                        _categories.map((category) {
                          final filteredTutorials = _filterTutorials(
                            allTutorials,
                            category,
                          );

                          if (filteredTutorials.isEmpty) {
                            return const Center(
                              child: Text('No tutorials in this category.'),
                            );
                          }

                          return RefreshIndicator(
                            onRefresh: () async {
                              _loadTutorials();
                              setState(() {});
                            },
                            child: ListView.builder(
                              padding: const EdgeInsets.all(16),
                              itemCount: filteredTutorials.length,
                              itemBuilder: (context, index) {
                                final tutorial = filteredTutorials[index];
                                return GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder:
                                            (context) => TutorialDetailScreen(
                                              tutorial: tutorial,
                                            ),
                                      ),
                                    );
                                  },
                                  child: Card(
                                    margin: const EdgeInsets.only(bottom: 16),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        // Tutorial Image
                                        ClipRRect(
                                          borderRadius:
                                              const BorderRadius.vertical(
                                                top: Radius.circular(16),
                                              ),
                                          child: Image.network(
                                            tutorial.imageUrl,
                                            height: 180,
                                            width: double.infinity,
                                            fit: BoxFit.cover,
                                            errorBuilder: (
                                              context,
                                              error,
                                              stackTrace,
                                            ) {
                                              return Container(
                                                height: 180,
                                                color: Colors.grey.shade300,
                                                child: const Icon(
                                                  Icons.image_not_supported,
                                                  size: 50,
                                                  color: Colors.grey,
                                                ),
                                              );
                                            },
                                          ),
                                        ),

                                        // Tutorial Content
                                        Padding(
                                          padding: const EdgeInsets.all(16),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              // Category Chip
                                              Chip(
                                                label: Text(tutorial.category),
                                                backgroundColor: Theme.of(
                                                      context,
                                                    ).colorScheme.primary
                                                    .withOpacity(0.1),
                                                labelStyle: TextStyle(
                                                  color:
                                                      Theme.of(
                                                        context,
                                                      ).colorScheme.primary,
                                                ),
                                              ),
                                              const SizedBox(height: 8),

                                              // Title
                                              Text(
                                                tutorial.title,
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .titleLarge
                                                    ?.copyWith(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                              ),
                                              const SizedBox(height: 8),

                                              // Description
                                              Text(
                                                tutorial.description,
                                                maxLines: 2,
                                                overflow: TextOverflow.ellipsis,
                                                style:
                                                    Theme.of(
                                                      context,
                                                    ).textTheme.bodyMedium,
                                              ),
                                              const SizedBox(height: 16),

                                              // View Button
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.end,
                                                children: [
                                                  TextButton.icon(
                                                    onPressed: () {
                                                      Navigator.push(
                                                        context,
                                                        MaterialPageRoute(
                                                          builder:
                                                              (context) =>
                                                                  TutorialDetailScreen(
                                                                    tutorial:
                                                                        tutorial,
                                                                  ),
                                                        ),
                                                      );
                                                    },
                                                    icon: const Icon(
                                                      Icons.arrow_forward,
                                                    ),
                                                    label: const Text(
                                                      'View Tutorial',
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                          );
                        }).toList(),
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
