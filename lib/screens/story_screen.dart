import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/story_models.dart';
import '../data/story_data.dart';
import '../widgets/story_chapter_widget.dart';
import '../widgets/alice_themed_background.dart';

class StoryScreen extends StatefulWidget {
  const StoryScreen({super.key});

  @override
  State<StoryScreen> createState() => _StoryScreenState();
}

class _StoryScreenState extends State<StoryScreen> with TickerProviderStateMixin {
  late PageController _pageController;
  late AnimationController _fadeController;
  late AnimationController _chapterTransitionController;

  int _currentChapter = 0;
  bool _isTransitioning = false;
  int? _expectedNextPage; // Track the expected next page from button navigation

  StoryProgress _progress = const StoryProgress();

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _chapterTransitionController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _fadeController.forward();
    _initializeProgress();
  }

  void _initializeProgress() {
    final chaptersMap = <String, bool>{};
    for (final chapter in StoryData.chapters) {
      chaptersMap[chapter.id] = false;
    }

    setState(() {
      _progress = StoryProgress(
        chaptersCompleted: chaptersMap,
        chapterStartTimes: {StoryData.chapters[0].id: DateTime.now()},
      );
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    _fadeController.dispose();
    _chapterTransitionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          AliceThemedBackground(
            currentChapter: _currentChapter,
            animationController: _fadeController,
          ),
          _buildStoryContent(),
          _buildNavigationOverlay(),
          _buildProgressIndicator(),
          if (_isTransitioning) _buildTransitionOverlay(),
        ],
      ),
    );
  }

  Widget _buildStoryContent() {
    return GestureDetector(
      // Absorb all horizontal drag gestures to prevent accidental page changes
      onHorizontalDragStart: (_) {},
      onHorizontalDragUpdate: (_) {},
      onHorizontalDragEnd: (_) {},
      child: PageView.builder(
        controller: _pageController,
        onPageChanged: _onPageChanged,
        itemCount: StoryData.chapters.length,
        physics: const NeverScrollableScrollPhysics(), // Disable swiping
        itemBuilder: (context, index) {
          final chapter = StoryData.chapters[index];
          return SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: StoryChapterWidget(
              chapter: chapter,
              isActive: index == _currentChapter,
              progress: _progress,
              onInteraction: _onChapterInteraction,
              onComplete: () => _onChapterComplete(chapter.id),
            ),
          );
        },
      ),
    );
  }

  Widget _buildNavigationOverlay() {
    return Positioned(
      left: 0,
      right: 0,
      bottom: 0,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.bottomCenter,
            end: Alignment.topCenter,
            colors: [
              Colors.black.withOpacity(0.8),
              Colors.transparent,
            ],
          ),
        ),
        child: SafeArea(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildNavigationButton(
                icon: Icons.arrow_back_rounded,
                label: 'Previous',
                onPressed: _currentChapter > 0 ? _goToPrevious : null,
                isEnabled: _currentChapter > 0,
              ),
              _buildChapterIndicator(),
              _buildNavigationButton(
                icon: Icons.arrow_forward_rounded,
                label: 'Next',
                onPressed: _currentChapter < StoryData.chapters.length - 1 ? _goToNext : null,
                isEnabled: _currentChapter < StoryData.chapters.length - 1,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavigationButton({
    required IconData icon,
    required String label,
    required VoidCallback? onPressed,
    required bool isEnabled,
  }) {
    return AnimatedOpacity(
      duration: const Duration(milliseconds: 300),
      opacity: isEnabled ? 1.0 : 0.3,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(25),
          border: Border.all(
            color: Colors.white.withOpacity(0.3),
            width: 1,
          ),
          color: Colors.black.withOpacity(0.6),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(25),
            onTap: onPressed,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (icon == Icons.arrow_back_rounded) ...[
                    Icon(icon, color: Colors.white, size: 20),
                    const SizedBox(width: 8),
                  ],
                  Text(
                    label,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                  if (icon == Icons.arrow_forward_rounded) ...[
                    const SizedBox(width: 8),
                    Icon(icon, color: Colors.white, size: 20),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildChapterIndicator() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: Colors.white.withOpacity(0.2),
        border: Border.all(
          color: Colors.white.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Text(
        '${_currentChapter + 1} of ${StoryData.chapters.length}',
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildProgressIndicator() {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: SafeArea(
        child: Container(
          margin: const EdgeInsets.all(16),
          height: 4,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(2),
            color: Colors.white.withOpacity(0.3),
          ),
          child: FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: (_currentChapter + 1) / StoryData.chapters.length,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(2),
                gradient: const LinearGradient(
                  colors: [
                    Color(0xFF3B82F6), // Blue
                    Color(0xFF8B5CF6), // Purple
                    Color(0xFFEC4899), // Pink
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTransitionOverlay() {
    return AnimatedBuilder(
      animation: _chapterTransitionController,
      builder: (context, child) {
        return Container(
          color: Colors.black.withOpacity(
            0.8 * (1 - _chapterTransitionController.value),
          ),
          child: Center(
            child: Transform.scale(
              scale: 0.8 + (0.2 * _chapterTransitionController.value),
              child: Opacity(
                opacity: (1 - _chapterTransitionController.value).clamp(0.0, 1.0),
                child: _buildChapterTransitionCard(),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildChapterTransitionCard() {
    if (_currentChapter >= StoryData.chapters.length) return const SizedBox.shrink();

    final chapter = StoryData.chapters[_currentChapter];
    final aliceTheme = chapter.aliceTheme;

    return Container(
      margin: const EdgeInsets.all(32),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.purple.withOpacity(0.3),
            blurRadius: 20,
            spreadRadius: 5,
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Chapter ${_currentChapter + 1}',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: const Color(0xFF8B5CF6),
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            chapter.title,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: Colors.black87,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          if (aliceTheme?.chapterQuote != null) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFF3F4F6),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: const Color(0xFF8B5CF6).withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Text(
                aliceTheme!.chapterQuote,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.black87,
                  fontStyle: FontStyle.italic,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ],
      ),
    );
  }

  void _onPageChanged(int index) {
    // Only allow page changes to the expected page set by navigation buttons
    if (_expectedNextPage != index) {
      print('DEBUG: Blocked unauthorized page change from $_currentChapter to $index (expected: $_expectedNextPage)');
      // Force the page back to current chapter
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_pageController.hasClients && _pageController.page != _currentChapter.toDouble()) {
          _pageController.jumpToPage(_currentChapter);
        }
      });
      return;
    }

    if (_isTransitioning) {
      _expectedNextPage = null; // Clear expected page
      return;
    }

    print('DEBUG: Authorized page change from $_currentChapter to $index');

    setState(() {
      _currentChapter = index;
      _expectedNextPage = null; // Clear expected page after successful navigation
    });

    _triggerHapticFeedback();
    _showChapterTransition();

    // Update progress tracking
    final chapter = StoryData.chapters[index];
    final updatedStartTimes = Map<String, DateTime>.from(_progress.chapterStartTimes);
    updatedStartTimes[chapter.id] = DateTime.now();

    setState(() {
      _progress = StoryProgress(
        chaptersCompleted: _progress.chaptersCompleted,
        interactionsCompleted: _progress.interactionsCompleted,
        discoveries: _progress.discoveries,
        chapterStartTimes: updatedStartTimes,
        timeSpentPerChapter: _progress.timeSpentPerChapter,
      );
    });
  }

  void _showChapterTransition() {
    if (_currentChapter == 0) return; // No transition for first chapter

    setState(() {
      _isTransitioning = true;
    });

    _chapterTransitionController.reset();
    _chapterTransitionController.forward().then((_) {
      setState(() {
        _isTransitioning = false;
      });
    });
  }

  void _onChapterInteraction(String interactionId, Map<String, dynamic> data) {
    _triggerHapticFeedback();

    // Update interaction progress
    final chapterId = StoryData.chapters[_currentChapter].id;
    final updatedInteractions = Map<String, List<String>>.from(_progress.interactionsCompleted);

    if (!updatedInteractions.containsKey(chapterId)) {
      updatedInteractions[chapterId] = [];
    }

    if (!updatedInteractions[chapterId]!.contains(interactionId)) {
      updatedInteractions[chapterId]!.add(interactionId);
    }

    // Add discoveries
    final updatedDiscoveries = List<String>.from(_progress.discoveries);
    if (data.containsKey('discovery')) {
      updatedDiscoveries.add(data['discovery']);
    }

    setState(() {
      _progress = StoryProgress(
        chaptersCompleted: _progress.chaptersCompleted,
        interactionsCompleted: updatedInteractions,
        discoveries: updatedDiscoveries,
        chapterStartTimes: _progress.chapterStartTimes,
        timeSpentPerChapter: _progress.timeSpentPerChapter,
      );
    });
  }

  void _onChapterComplete(String chapterId) {
    final updatedCompleted = Map<String, bool>.from(_progress.chaptersCompleted);
    updatedCompleted[chapterId] = true;

    // Calculate time spent
    final startTime = _progress.chapterStartTimes[chapterId];
    final updatedTimeSpent = Map<String, Duration>.from(_progress.timeSpentPerChapter);

    if (startTime != null) {
      updatedTimeSpent[chapterId] = DateTime.now().difference(startTime);
    }

    setState(() {
      _progress = StoryProgress(
        chaptersCompleted: updatedCompleted,
        interactionsCompleted: _progress.interactionsCompleted,
        discoveries: _progress.discoveries,
        chapterStartTimes: _progress.chapterStartTimes,
        timeSpentPerChapter: updatedTimeSpent,
      );
    });

    _triggerHapticFeedback();

    // Auto-advance removed - user must manually navigate with buttons
  }

  void _goToNext() {
    if (_currentChapter < StoryData.chapters.length - 1) {
      final nextPage = _currentChapter + 1;
      print('DEBUG: Next button pressed - expecting page change to $nextPage');
      _expectedNextPage = nextPage; // Set the expected page BEFORE navigation
      _pageController.nextPage(
        duration: const Duration(milliseconds: 600),
        curve: Curves.easeInOutCubic,
      );
    }
  }

  void _goToPrevious() {
    if (_currentChapter > 0) {
      final prevPage = _currentChapter - 1;
      print('DEBUG: Previous button pressed - expecting page change to $prevPage');
      _expectedNextPage = prevPage; // Set the expected page BEFORE navigation
      _pageController.previousPage(
        duration: const Duration(milliseconds: 600),
        curve: Curves.easeInOutCubic,
      );
    }
  }

  void _triggerHapticFeedback() {
    HapticFeedback.lightImpact();
  }
}