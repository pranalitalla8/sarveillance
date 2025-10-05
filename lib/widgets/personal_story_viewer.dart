import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/story_models.dart';
import 'dart:math' as math;

class PersonalStoryViewer extends StatefulWidget {
  final PersonalNarrative? personalStory;
  final Function(String) onStoryTap;

  const PersonalStoryViewer({
    super.key,
    this.personalStory,
    required this.onStoryTap,
  });

  @override
  State<PersonalStoryViewer> createState() => _PersonalStoryViewerState();
}

class _PersonalStoryViewerState extends State<PersonalStoryViewer>
    with TickerProviderStateMixin {
  late AnimationController _heartbeatController;
  late AnimationController _flowController;

  int _selectedLocationIndex = 0;
  final Set<String> _visitedLocations = {};

  @override
  void initState() {
    super.initState();
    _heartbeatController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat();

    _flowController = AnimationController(
      duration: const Duration(seconds: 6),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _heartbeatController.dispose();
    _flowController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.personalStory == null) {
      return _buildEmptyState();
    }

    return Column(
      children: [
        _buildPersonalHeader(),
        const SizedBox(height: 24),
        Expanded(
          child: _buildStoryContent(),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.person_outline,
            size: 80,
            color: Colors.white.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'Personal Stories Coming Soon',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPersonalHeader() {
    return AnimatedBuilder(
      animation: _heartbeatController,
      builder: (context, child) {
        final heartbeat = 1.0 + (0.1 * math.sin(_heartbeatController.value * 2 * math.pi));

        return Transform.scale(
          scale: heartbeat,
          child: Column(
            children: [
              Row(
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: const LinearGradient(
                        colors: [
                          Color(0xFFEC4899),
                          Color(0xFF8B5CF6),
                        ],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFEC4899).withValues(alpha: 0.4),
                          blurRadius: 15,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.favorite,
                      color: Colors.white,
                      size: 30,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Alice\'s Neighborhood',
                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'A personal journey through familiar DMV waters',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.white.withValues(alpha: 0.8),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _buildAuthorInfo(),
            ],
          ),
        );
      },
    );
  }

  Widget _buildAuthorInfo() {
    final personalStory = widget.personalStory!;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        gradient: LinearGradient(
          colors: [
            const Color(0xFFEC4899).withValues(alpha: 0.2),
            const Color(0xFF8B5CF6).withValues(alpha: 0.2),
          ],
        ),
        border: Border.all(
          color: const Color(0xFFEC4899).withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.person,
                color: const Color(0xFFEC4899),
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                personalStory.authorName,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            personalStory.authorContext,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Colors.white.withValues(alpha: 0.9),
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStoryContent() {
    final personalStory = widget.personalStory!;

    return SingleChildScrollView(
      child: Column(
        children: [
          _buildLocationSelector(personalStory.dmvSpots),
          const SizedBox(height: 24),
          _buildSelectedLocationDetails(personalStory.dmvSpots),
          const SizedBox(height: 24),
          _buildLocalStories(personalStory.stories),
        ],
      ),
    );
  }

  Widget _buildLocationSelector(List<FamiliarLocation> locations) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Familiar Places',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 120, // Compact height to match Royal Technology Arsenal
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: locations.length,
            itemBuilder: (context, index) {
              final location = locations[index];
              final isSelected = _selectedLocationIndex == index;
              final isVisited = _visitedLocations.contains(location.name);

              return _buildLocationCard(location, isSelected, isVisited, index);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildLocationCard(FamiliarLocation location, bool isSelected, bool isVisited, int index) {
    return AnimatedBuilder(
      animation: _flowController,
      builder: (context, child) {
        final wave = math.sin(_flowController.value * 2 * math.pi + index) * 5;

        return GestureDetector(
          onTap: () => _handleLocationTap(index, location.name),
          child: Transform.translate(
            offset: Offset(0, wave),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              width: 160, // Increased from 140 to 160 for more content space
              margin: const EdgeInsets.only(right: 16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: isSelected
                      ? [
                          const Color(0xFF3B82F6),
                          const Color(0xFF1E40AF),
                        ]
                      : isVisited
                          ? [
                              const Color(0xFF10B981).withValues(alpha: 0.7),
                              const Color(0xFF059669).withValues(alpha: 0.7),
                            ]
                          : [
                              Colors.white.withValues(alpha: 0.2),
                              Colors.white.withValues(alpha: 0.1),
                            ],
                ),
                border: Border.all(
                  color: isSelected ? Colors.white : Colors.transparent,
                  width: 2,
                ),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: const Color(0xFF3B82F6).withValues(alpha: 0.4),
                          blurRadius: 15,
                          spreadRadius: 2,
                        ),
                      ]
                    : null,
              ),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          _getLocationIcon(location.category),
                          color: Colors.white,
                          size: 20,
                        ),
                        const Spacer(),
                        if (isVisited)
                          Icon(
                            Icons.check_circle,
                            color: Colors.white,
                            size: 16,
                          ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      location.name,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const Spacer(),
                    Text(
                      location.category,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.white.withValues(alpha: 0.8),
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSelectedLocationDetails(List<FamiliarLocation> locations) {
    if (_selectedLocationIndex >= locations.length) return const SizedBox.shrink();

    final location = locations[_selectedLocationIndex];

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 500),
      child: Container(
        key: ValueKey(location.name),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            colors: [
              const Color(0xFF3B82F6).withValues(alpha: 0.3),
              Colors.black.withValues(alpha: 0.6),
            ],
          ),
          border: Border.all(
            color: const Color(0xFF3B82F6),
            width: 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  _getLocationIcon(location.category),
                  color: const Color(0xFF3B82F6),
                  size: 24,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    location.name,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              location.description,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.white.withValues(alpha: 0.9),
                height: 1.4,
              ),
            ),
            const SizedBox(height: 16),
            _buildPersonalStorySection(location),
            if (location.observedChanges.isNotEmpty) ...[
              const SizedBox(height: 16),
              _buildEnvironmentalChanges(location.observedChanges),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildPersonalStorySection(FamiliarLocation location) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: const Color(0xFFEC4899).withValues(alpha: 0.2),
        border: Border.all(
          color: const Color(0xFFEC4899).withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.auto_stories,
                color: const Color(0xFFEC4899),
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Personal Memory',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: const Color(0xFFEC4899),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            location.personalStory,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.white.withValues(alpha: 0.9),
              fontStyle: FontStyle.italic,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEnvironmentalChanges(List<EnvironmentalChange> changes) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Observed Changes',
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        ...changes.map((change) => _buildChangeCard(change)),
      ],
    );
  }

  Widget _buildChangeCard(EnvironmentalChange change) {
    final impactColor = _getImpactColor(change.impact);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: impactColor.withValues(alpha: 0.2),
        border: Border.all(
          color: impactColor.withValues(alpha: 0.5),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                _getImpactIcon(change.impact),
                color: impactColor,
                size: 16,
              ),
              const SizedBox(width: 8),
              Text(
                change.type.replaceAll('_', ' ').toUpperCase(),
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: impactColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(4),
                  color: impactColor.withValues(alpha: 0.3),
                ),
                child: Text(
                  change.timeframe.replaceAll('_', ' '),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.white,
                    fontSize: 10,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            change.description,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Colors.white.withValues(alpha: 0.9),
              height: 1.3,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(
                Icons.radar,
                color: const Color(0xFF8B5CF6),
                size: 14,
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  change.sarEvidence,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: const Color(0xFF8B5CF6),
                    fontSize: 11,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLocalStories(List<LocalStory> stories) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Local Impact Stories',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        ...stories.asMap().entries.map((entry) {
          final index = entry.key;
          final story = entry.value;
          return _buildLocalStoryCard(story, index);
        }),
      ],
    );
  }

  Widget _buildLocalStoryCard(LocalStory story, int index) {
    return GestureDetector(
      onTap: () => _handleStoryTap(story.title),
      child: AnimatedBuilder(
        animation: _flowController,
        builder: (context, child) {
          final float = math.sin(_flowController.value * 2 * math.pi + index * 0.5) * 3;

          return Transform.translate(
            offset: Offset(0, float),
            child: Container(
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                gradient: LinearGradient(
                  colors: [
                    _getCategoryColor(story.category).withValues(alpha: 0.3),
                    Colors.black.withValues(alpha: 0.6),
                  ],
                ),
                border: Border.all(
                  color: _getCategoryColor(story.category).withValues(alpha: 0.5),
                  width: 1,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        _getCategoryIcon(story.category),
                        color: _getCategoryColor(story.category),
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          story.title,
                          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Icon(
                        Icons.touch_app,
                        color: Colors.white.withValues(alpha: 0.6),
                        size: 16,
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    story.description,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.white.withValues(alpha: 0.9),
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(
                        Icons.place,
                        color: Colors.white.withValues(alpha: 0.6),
                        size: 14,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        story.location,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.white.withValues(alpha: 0.8),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _handleLocationTap(int index, String locationName) {
    HapticFeedback.mediumImpact();

    setState(() {
      _selectedLocationIndex = index;
      _visitedLocations.add(locationName);
    });

    widget.onStoryTap('location_$locationName');
  }

  void _handleStoryTap(String storyTitle) {
    HapticFeedback.lightImpact();
    widget.onStoryTap('story_$storyTitle');
  }

  IconData _getLocationIcon(String category) {
    switch (category) {
      case 'sailing':
        return Icons.sailing;
      case 'fishing':
        return Icons.phishing;
      case 'swimming':
        return Icons.pool;
      case 'studying':
        return Icons.school;
      default:
        return Icons.place;
    }
  }

  Color _getImpactColor(String impact) {
    switch (impact) {
      case 'positive':
        return const Color(0xFF10B981);
      case 'negative':
        return const Color(0xFFEF4444);
      case 'mixed':
        return const Color(0xFFEAB308);
      default:
        return const Color(0xFF6B7280);
    }
  }

  IconData _getImpactIcon(String impact) {
    switch (impact) {
      case 'positive':
        return Icons.trending_up;
      case 'negative':
        return Icons.trending_down;
      case 'mixed':
        return Icons.swap_vert;
      default:
        return Icons.help;
    }
  }

  Color _getCategoryColor(String category) {
    switch (category) {
      case 'childhood_memory':
        return const Color(0xFFEC4899);
      case 'environmental_change':
        return const Color(0xFFEF4444);
      case 'community_impact':
        return const Color(0xFF8B5CF6);
      default:
        return const Color(0xFF6B7280);
    }
  }

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'childhood_memory':
        return Icons.child_care;
      case 'environmental_change':
        return Icons.nature;
      case 'community_impact':
        return Icons.group;
      default:
        return Icons.auto_stories;
    }
  }
}