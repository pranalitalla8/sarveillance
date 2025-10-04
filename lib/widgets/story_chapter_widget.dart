import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/story_models.dart';
import '../widgets/frequency_explorer.dart';
import '../widgets/before_after_slider.dart';
import '../widgets/personal_story_viewer.dart';
import '../widgets/solution_demo.dart';
import '../widgets/interactive_timeline.dart';

class StoryChapterWidget extends StatefulWidget {
  final StoryChapter chapter;
  final bool isActive;
  final StoryProgress progress;
  final Function(String, Map<String, dynamic>) onInteraction;
  final VoidCallback onComplete;

  const StoryChapterWidget({
    super.key,
    required this.chapter,
    required this.isActive,
    required this.progress,
    required this.onInteraction,
    required this.onComplete,
  });

  @override
  State<StoryChapterWidget> createState() => _StoryChapterWidgetState();
}

class _StoryChapterWidgetState extends State<StoryChapterWidget>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _scaleController;

  bool _isInteractionCompleted = false;
  final Set<String> _completedInteractions = {};

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    if (widget.isActive) {
      _fadeController.forward();
      _scaleController.forward();
    }
  }

  @override
  void didUpdateWidget(StoryChapterWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isActive && !oldWidget.isActive) {
      _fadeController.forward();
      _scaleController.forward();
    } else if (!widget.isActive && oldWidget.isActive) {
      _fadeController.reverse();
      _scaleController.reverse();
    }
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _scaleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([_fadeController, _scaleController]),
      builder: (context, child) {
        return Transform.scale(
          scale: 0.9 + (0.1 * _scaleController.value),
          child: Opacity(
            opacity: _fadeController.value.clamp(0.0, 1.0),
            child: _buildChapterContent(),
          ),
        );
      },
    );
  }

  Widget _buildChapterContent() {
    final screenHeight = MediaQuery.of(context).size.height;

    return SafeArea(
      child: SingleChildScrollView(
        child: Container(
          constraints: BoxConstraints(
            minHeight: screenHeight * 0.8,
          ),
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 40), // Space for progress bar
              _buildChapterHeader(),
              const SizedBox(height: 32),
              SizedBox(
                height: screenHeight * 0.5,
                child: _buildInteractiveContent(),
              ),
              const SizedBox(height: 100), // Space for navigation
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildChapterHeader() {
    final aliceTheme = widget.chapter.aliceTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            _buildChapterIcon(),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.chapter.title,
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      shadows: [
                        Shadow(
                          color: Colors.black.withValues(alpha: 0.5),
                          offset: const Offset(2, 2),
                          blurRadius: 4,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.chapter.subtitle,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: const Color(0xFF94A3B8),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        if (aliceTheme?.chapterQuote != null) ...[
          _buildAliceQuote(aliceTheme!.chapterQuote),
          const SizedBox(height: 16),
        ],
        Text(
          widget.chapter.description,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            color: const Color(0xFFE2E8F0),
            height: 1.6,
          ),
        ),
      ],
    );
  }

  Widget _buildChapterIcon() {
    final icons = {
      'intro': Icons.radar,
      'before_pristine': Icons.water_drop,
      'human_impact': Icons.local_cafe,
      'multi_frequency': Icons.auto_awesome,
      'detection_secrets': Icons.visibility_off,
      'personal_dmv': Icons.home,
      'future_solution': Icons.gavel,
    };

    final icon = icons[widget.chapter.id] ?? Icons.help;

    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: [
            const Color(0xFF3B82F6),
            const Color(0xFF8B5CF6),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF8B5CF6).withValues(alpha: 0.3),
            blurRadius: 15,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Icon(
        icon,
        color: Colors.white,
        size: 30,
      ),
    );
  }

  Widget _buildAliceQuote(String quote) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.white.withValues(alpha: 0.1),
        border: Border.all(
          color: const Color(0xFF8B5CF6).withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.format_quote,
            color: const Color(0xFF8B5CF6),
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              quote,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.white,
                fontStyle: FontStyle.italic,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInteractiveContent() {
    switch (widget.chapter.interactionType) {
      case StoryInteractionType.introduction:
        return _buildIntroductionContent();
      case StoryInteractionType.beforeAfter:
        return _buildBeforeAfterContent();
      case StoryInteractionType.humanImpact:
        return _buildHumanImpactContent();
      case StoryInteractionType.multiFrequency:
        return _buildMultiFrequencyContent();
      case StoryInteractionType.personalInsight:
        return _buildPersonalInsightContent();
      case StoryInteractionType.futureProjection:
        return _buildFutureProjectionContent();
      case StoryInteractionType.solution:
        return _buildSolutionContent();
    }
  }

  Widget _buildIntroductionContent() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          TweenAnimationBuilder<double>(
            duration: const Duration(seconds: 3),
            tween: Tween(begin: 0, end: 1),
            builder: (context, value, child) {
              return Transform.scale(
                scale: value,
                child: Container(
                  width: 200,
                  height: 200,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        const Color(0xFF3B82F6).withValues(alpha: 0.8),
                        const Color(0xFF8B5CF6).withValues(alpha: 0.4),
                        Colors.transparent,
                      ],
                    ),
                  ),
                  child: const Icon(
                    Icons.radar,
                    size: 100,
                    color: Colors.white,
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 40),
          Text(
            'Tap to reveal the hidden world of SAR',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _handleIntroInteraction,
            icon: const Icon(Icons.touch_app),
            label: const Text('Begin the Journey'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF8B5CF6),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBeforeAfterContent() {
    return BeforeAfterSlider(
      beforeData: widget.chapter.sarLayers.isNotEmpty ? widget.chapter.sarLayers[0] : null,
      afterData: widget.chapter.sarLayers.length > 1 ? widget.chapter.sarLayers[1] : null,
      onInteraction: (value) => _handleSliderInteraction('before_after', value),
    );
  }

  Widget _buildHumanImpactContent() {
    return InteractiveTimeline(
      chapter: widget.chapter,
      onImpactTap: (impact) => _handleTimelineInteraction(impact),
    );
  }

  Widget _buildMultiFrequencyContent() {
    return FrequencyExplorer(
      sarLayers: widget.chapter.sarLayers,
      aliceTheme: widget.chapter.aliceTheme,
      onFrequencyTap: (frequency) => _handleFrequencyInteraction(frequency),
    );
  }

  Widget _buildPersonalInsightContent() {
    return PersonalStoryViewer(
      personalStory: widget.chapter.personalStory,
      onStoryTap: (story) => _handlePersonalStoryInteraction(story),
    );
  }

  Widget _buildFutureProjectionContent() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.auto_awesome,
            size: 80,
            color: Colors.purple.withValues(alpha: 0.7),
          ),
          const SizedBox(height: 24),
          Text(
            'Future Predictions',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Scenario modeling coming soon...',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: Colors.white70,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSolutionContent() {
    return SolutionDemo(
      solution: widget.chapter.solution,
      onSolutionInteraction: (tech) => _handleSolutionInteraction(tech),
    );
  }

  void _handleIntroInteraction() {
    HapticFeedback.mediumImpact();
    widget.onInteraction('intro_tap', {'discovery': 'SAR introduction completed'});

    setState(() {
      _isInteractionCompleted = true;
    });

    Future.delayed(const Duration(milliseconds: 1500), () {
      widget.onComplete();
    });
  }

  void _handleSliderInteraction(String type, double value) {
    widget.onInteraction('slider_$type', {'value': value});

    if (value > 0.8 && !_completedInteractions.contains('slider_complete')) {
      _completedInteractions.add('slider_complete');
      _checkChapterCompletion();
    }
  }

  void _handleTimelineInteraction(String impact) {
    HapticFeedback.lightImpact();
    widget.onInteraction('timeline_$impact', {'impact': impact});

    _completedInteractions.add('timeline_$impact');
    _checkChapterCompletion();
  }

  void _handleFrequencyInteraction(String frequency) {
    HapticFeedback.lightImpact();
    widget.onInteraction('frequency_$frequency', {
      'frequency': frequency,
      'discovery': 'Revealed $frequency frequency secrets'
    });

    _completedInteractions.add('frequency_$frequency');
    _checkChapterCompletion();
  }

  void _handlePersonalStoryInteraction(String story) {
    HapticFeedback.lightImpact();
    widget.onInteraction('personal_$story', {'story': story});

    _completedInteractions.add('personal_$story');
    _checkChapterCompletion();
  }

  void _handleSolutionInteraction(String technology) {
    HapticFeedback.lightImpact();
    widget.onInteraction('solution_$technology', {'technology': technology});

    _completedInteractions.add('solution_$technology');
    _checkChapterCompletion();
  }

  void _checkChapterCompletion() {
    // Different completion criteria for different chapters
    bool isComplete = false;

    switch (widget.chapter.interactionType) {
      case StoryInteractionType.introduction:
        isComplete = _isInteractionCompleted;
        break;
      case StoryInteractionType.beforeAfter:
        isComplete = _completedInteractions.contains('slider_complete');
        break;
      case StoryInteractionType.humanImpact:
        isComplete = _completedInteractions.length >= 2; // At least 2 timeline interactions
        break;
      case StoryInteractionType.multiFrequency:
        isComplete = _completedInteractions.length >= 2; // At least 2 frequencies explored
        break;
      case StoryInteractionType.personalInsight:
        isComplete = _completedInteractions.length >= 1; // At least 1 personal story
        break;
      case StoryInteractionType.futureProjection:
        isComplete = true; // Auto-complete for now
        break;
      case StoryInteractionType.solution:
        isComplete = _completedInteractions.length >= 2; // At least 2 solutions explored
        break;
    }

    if (isComplete && !_isInteractionCompleted) {
      setState(() {
        _isInteractionCompleted = true;
      });

      Future.delayed(const Duration(milliseconds: 800), () {
        widget.onComplete();
      });
    }
  }
}