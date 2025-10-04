import 'package:flutter/material.dart';
import '../widgets/educational_card.dart';
import '../widgets/learning_path.dart';

class DiscoverScreen extends StatefulWidget {
  const DiscoverScreen({super.key});

  @override
  State<DiscoverScreen> createState() => _DiscoverScreenState();
}

class _DiscoverScreenState extends State<DiscoverScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final List<Map<String, dynamic>> _educationalContent = [
    {
      'title': 'What is SAR?',
      'subtitle': 'Synthetic Aperture Radar Basics',
      'description': 'Learn about the fundamentals of SAR technology and how it differs from optical satellites.',
      'icon': Icons.radar,
      'color': const Color(0xFF0B3D91),
      'duration': '5 min read',
      'difficulty': 'Beginner',
      'content': '''
Synthetic Aperture Radar (SAR) is a form of radar that is used to create two-dimensional images or three-dimensional reconstructions of objects, such as landscapes.

Key advantages of SAR:
• Works day and night
• Penetrates clouds and weather
• Can measure surface deformation
• Provides all-weather monitoring capabilities

SAR sends out radio waves and measures the time it takes for them to bounce back from the Earth's surface.
''',
    },
    {
      'title': 'Interferometry',
      'subtitle': 'Measuring Ground Movement',
      'description': 'Discover how InSAR can detect millimeter-scale changes in the Earth\'s surface.',
      'icon': Icons.timeline,
      'color': const Color(0xFF059669),
      'duration': '8 min read',
      'difficulty': 'Intermediate',
      'content': '''
Interferometric SAR (InSAR) compares two or more SAR images of the same area taken at different times to detect changes.

Applications include:
• Earthquake monitoring
• Volcanic activity detection
• Glacier movement tracking
• Urban subsidence monitoring
• Infrastructure monitoring

InSAR can detect ground movement as small as a few millimeters!
''',
    },
    {
      'title': 'Polarimetry',
      'subtitle': 'Understanding Wave Properties',
      'description': 'Learn how different polarizations reveal unique characteristics of Earth surfaces.',
      'icon': Icons.waves,
      'color': const Color(0xFF7C3AED),
      'duration': '6 min read',
      'difficulty': 'Advanced',
      'content': '''
SAR polarimetry analyzes the polarization properties of electromagnetic waves to extract detailed information about surface characteristics.

Common polarizations:
• HH (Horizontal transmit, Horizontal receive)
• VV (Vertical transmit, Vertical receive)
• HV (Horizontal transmit, Vertical receive)
• VH (Vertical transmit, Horizontal receive)

Different surfaces interact differently with polarized waves, providing unique signatures.
''',
    },
    {
      'title': 'Change Detection',
      'subtitle': 'Monitoring Environmental Changes',
      'description': 'Explore techniques for identifying temporal changes in satellite imagery.',
      'icon': Icons.compare,
      'color': const Color(0xFFDC2626),
      'duration': '7 min read',
      'difficulty': 'Intermediate',
      'content': '''
Change detection in SAR involves comparing images from different time periods to identify alterations in the landscape.

Methods include:
• Coherence analysis
• Amplitude comparison
• Phase difference analysis
• Machine learning approaches

Applications range from deforestation monitoring to disaster response.
''',
    },
    {
      'title': 'Applications',
      'subtitle': 'Real-World SAR Uses',
      'description': 'Discover how SAR technology is used across various industries and research fields.',
      'icon': Icons.public,
      'color': const Color(0xFF0891B2),
      'duration': '10 min read',
      'difficulty': 'Beginner',
      'content': '''
SAR technology has numerous applications across different fields:

Disaster Management:
• Flood mapping
• Earthquake damage assessment
• Wildfire monitoring

Environmental Monitoring:
• Deforestation tracking
• Glacier monitoring
• Ocean monitoring

Urban Planning:
• Infrastructure monitoring
• Urban growth analysis
• Land use classification
''',
    },
  ];

  final List<Map<String, dynamic>> _learningPaths = [
    {
      'title': 'SAR Fundamentals',
      'description': 'Start your journey with the basics of radar technology',
      'lessons': ['What is SAR?', 'SAR vs Optical', 'Basic Principles', 'Signal Processing'],
      'progress': 0.0,
      'color': const Color(0xFF0B3D91),
    },
    {
      'title': 'Advanced Techniques',
      'description': 'Master complex SAR analysis methods',
      'lessons': ['Interferometry', 'Polarimetry', 'Tomography', 'Machine Learning'],
      'progress': 0.0,
      'color': const Color(0xFF7C3AED),
    },
    {
      'title': 'Applications & Case Studies',
      'description': 'Explore real-world applications',
      'lessons': ['Disaster Response', 'Climate Monitoring', 'Urban Planning', 'Research'],
      'progress': 0.0,
      'color': const Color(0xFF059669),
    },
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Discover SAR'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Theme.of(context).colorScheme.primaryContainer,
                Theme.of(context).colorScheme.surface,
              ],
            ),
          ),
        ),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Learn', icon: Icon(Icons.school)),
            Tab(text: 'Paths', icon: Icon(Icons.route)),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildLearnTab(),
          _buildPathsTab(),
        ],
      ),
    );
  }

  Widget _buildLearnTab() {
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Educational Content',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: 8),
                Text(
                  'Learn about SAR technology and Earth observation',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                  ),
                ),
              ],
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: _buildStaggeredGrid(),
          ),
        ),
      ],
    );
  }

  Widget _buildStaggeredGrid() {
    return LayoutBuilder(
      builder: (context, constraints) {
        const double spacing = 16.0;
        const int crossAxisCount = 2;
        final double cardWidth = (constraints.maxWidth - spacing) / crossAxisCount;

        List<Widget> leftColumn = [];
        List<Widget> rightColumn = [];

        for (int i = 0; i < _educationalContent.length; i++) {
          final card = SizedBox(
            width: cardWidth,
            child: EducationalCard(
              content: _educationalContent[i],
              onTap: () => _showContentDetail(_educationalContent[i]),
            ),
          );

          if (i % 2 == 0) {
            leftColumn.add(card);
            if (i < _educationalContent.length - 1) {
              leftColumn.add(const SizedBox(height: spacing));
            }
          } else {
            rightColumn.add(card);
            if (i < _educationalContent.length - 1) {
              rightColumn.add(const SizedBox(height: spacing));
            }
          }
        }

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                children: leftColumn,
              ),
            ),
            const SizedBox(width: spacing),
            Expanded(
              child: Column(
                children: rightColumn,
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildPathsTab() {
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Learning Paths',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: 8),
                Text(
                  'Structured learning journeys to master SAR',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                  ),
                ),
              ],
            ),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.all(16),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: LearningPath(
                    pathData: _learningPaths[index],
                    onTap: () => _startLearningPath(_learningPaths[index]),
                  ),
                );
              },
              childCount: _learningPaths.length,
            ),
          ),
        ),
      ],
    );
  }

  void _showContentDetail(Map<String, dynamic> content) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.8,
        maxChildSize: 0.95,
        minChildSize: 0.5,
        builder: (context, scrollController) => Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          child: Column(
            children: [
              Container(
                margin: const EdgeInsets.only(top: 8),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: content['color'],
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              content['icon'],
                              color: Colors.white,
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  content['title'],
                                  style: Theme.of(context).textTheme.headlineSmall,
                                ),
                                Text(
                                  content['subtitle'],
                                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                    color: Theme.of(context).colorScheme.primary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Chip(
                            label: Text(content['duration']),
                            avatar: const Icon(Icons.access_time, size: 16),
                          ),
                          const SizedBox(width: 8),
                          Chip(
                            label: Text(content['difficulty']),
                            avatar: const Icon(Icons.star, size: 16),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      Text(
                        content['content'],
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                      const SizedBox(height: 32),
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () => Navigator.pop(context),
                              icon: const Icon(Icons.bookmark_add),
                              label: const Text('Save for Later'),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () => Navigator.pop(context),
                              icon: const Icon(Icons.share),
                              label: const Text('Share'),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _startLearningPath(Map<String, dynamic> pathData) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Start ${pathData['title']}?'),
        content: Text('This learning path includes ${pathData['lessons'].length} lessons. Would you like to begin?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Started ${pathData['title']} learning path'),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            child: const Text('Start Learning'),
          ),
        ],
      ),
    );
  }
}