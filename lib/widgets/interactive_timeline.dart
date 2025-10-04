import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/story_models.dart';
import 'dart:math' as math;

class InteractiveTimeline extends StatefulWidget {
  final StoryChapter chapter;
  final Function(String) onImpactTap;

  const InteractiveTimeline({
    super.key,
    required this.chapter,
    required this.onImpactTap,
  });

  @override
  State<InteractiveTimeline> createState() => _InteractiveTimelineState();
}

class _InteractiveTimelineState extends State<InteractiveTimeline>
    with TickerProviderStateMixin {
  late AnimationController _timelineController;
  late AnimationController _chaosController;

  final Set<String> _revealedEvents = {};
  String? _selectedEvent;

  final List<TimelineEvent> _events = [
    TimelineEvent(
      id: 'baseline',
      year: 2000,
      title: 'Pristine Waters',
      description: 'Our DMV waters in their natural state',
      type: TimelineEventType.baseline,
      impact: 'Natural shipping patterns, healthy marine life',
      sarSignature: 'Clean backscatter patterns',
      aliceReference: 'The peaceful garden before Alice arrived',
    ),
    TimelineEvent(
      id: 'shipping_increase',
      year: 2010,
      title: 'Shipping Surge',
      description: 'Increased commercial traffic in Baltimore Harbor',
      type: TimelineEventType.human_impact,
      impact: 'Ship wake interference, habitat disruption',
      sarSignature: 'Increased bright returns from metal hulls',
      aliceReference: 'The first uninvited guests at the tea party',
    ),
    TimelineEvent(
      id: 'climate_effects',
      year: 2015,
      title: 'Changing Ice Patterns',
      description: 'Potomac River ice seasons becoming shorter',
      type: TimelineEventType.environmental,
      impact: 'Disrupted seasonal ecosystems',
      sarSignature: 'Altered freeze-thaw cycle signatures',
      aliceReference: 'The White Queen\'s domain melting away',
    ),
    TimelineEvent(
      id: 'covid_shipping',
      year: 2020,
      title: 'Pandemic Shipping Changes',
      description: 'COVID-19 alters global shipping patterns',
      type: TimelineEventType.human_impact,
      impact: 'Irregular traffic, some areas cleaner, others busier',
      sarSignature: 'Patchy activity patterns in SAR data',
      aliceReference: 'The Mad Hatter\'s schedule goes even madder',
    ),
    TimelineEvent(
      id: 'oil_incident',
      year: 2022,
      title: 'Fort McHenry Oil Discovery',
      description: 'Personal discovery of oil sheen during kayaking',
      type: TimelineEventType.pollution,
      impact: 'Local ecosystem contamination',
      sarSignature: 'Dark patches in C-band SAR imagery',
      aliceReference: 'Spilled tea staining the tablecloth',
    ),
    TimelineEvent(
      id: 'illegal_activity',
      year: 2023,
      title: 'Mysterious Night Ships',
      description: 'Unusual vessel activity without proper identification',
      type: TimelineEventType.illegal,
      impact: 'Potential illegal dumping, navigation hazards',
      sarSignature: 'Unidentified bright returns in X-band',
      aliceReference: 'The Cheshire Cat\'s invisible mischief',
    ),
    TimelineEvent(
      id: 'current_state',
      year: 2024,
      title: 'Current Challenges',
      description: 'Multiple threats to our marine environment',
      type: TimelineEventType.current,
      impact: 'Cumulative environmental stress',
      sarSignature: 'Complex multi-signature patterns',
      aliceReference: 'The Queen\'s court in complete chaos',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _timelineController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    _chaosController = AnimationController(
      duration: const Duration(seconds: 4),
      vsync: this,
    )..repeat();

    _timelineController.forward();
  }

  @override
  void dispose() {
    _timelineController.dispose();
    _chaosController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildTimelineTitle(),
        const SizedBox(height: 24),
        Expanded(
          child: _buildTimelineContent(),
        ),
        if (_selectedEvent != null) ...[
          const SizedBox(height: 16),
          _buildEventDetail(),
        ],
      ],
    );
  }

  Widget _buildTimelineTitle() {
    return AnimatedBuilder(
      animation: _chaosController,
      builder: (context, child) {
        final shake = math.sin(_chaosController.value * 8 * math.pi) * 2;
        return Transform.translate(
          offset: Offset(shake, 0),
          child: Column(
            children: [
              Text(
                'The Mad Hatter\'s Tea Party',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  shadows: [
                    Shadow(
                      color: const Color(0xFFEF4444).withValues(alpha: 0.6),
                      blurRadius: 10,
                      offset: Offset(shake, shake),
                    ),
                  ],
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'A chaotic timeline of human impacts',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.white.withValues(alpha: 0.8),
                  fontStyle: FontStyle.italic,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTimelineContent() {
    return SingleChildScrollView(
      child: Column(
        children: [
          ...List.generate(_events.length, (index) {
            final event = _events[index];
            final isLast = index == _events.length - 1;

            return Column(
              children: [
                _buildTimelineEvent(event, index),
                if (!isLast) _buildTimelineConnector(index),
              ],
            );
          }),
        ],
      ),
    );
  }

  Widget _buildTimelineEvent(TimelineEvent event, int index) {
    final isRevealed = _revealedEvents.contains(event.id);
    final isSelected = _selectedEvent == event.id;
    final animationDelay = index * 0.2;

    return AnimatedBuilder(
      animation: _timelineController,
      builder: (context, child) {
        final slideValue = math.max(0.0, (_timelineController.value - animationDelay) / 0.8);
        final opacity = math.min(1.0, slideValue * 2);
        final slideOffset = (1 - slideValue) * 100;

        return AnimatedBuilder(
          animation: _chaosController,
          builder: (context, child) {
            final chaos = _getChaosAmount(event.type) *
                         math.sin(_chaosController.value * 2 * math.pi + index);

            return Transform.translate(
              offset: Offset(slideOffset + chaos, 0),
              child: Opacity(
                opacity: opacity,
                child: GestureDetector(
                  onTap: () => _handleEventTap(event),
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Row(
                      children: [
                        _buildEventMarker(event, isRevealed, isSelected),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildEventCard(event, isRevealed, isSelected),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildEventMarker(TimelineEvent event, bool isRevealed, bool isSelected) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: _getEventColor(event.type),
        border: Border.all(
          color: isSelected ? Colors.white : _getEventColor(event.type),
          width: isSelected ? 3 : 1,
        ),
        boxShadow: isRevealed
            ? [
                BoxShadow(
                  color: _getEventColor(event.type).withValues(alpha: 0.6),
                  blurRadius: 15,
                  spreadRadius: 2,
                ),
              ]
            : null,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            _getEventIcon(event.type),
            color: Colors.white,
            size: 16,
          ),
          const SizedBox(height: 2),
          Text(
            event.year.toString(),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 8,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEventCard(TimelineEvent event, bool isRevealed, bool isSelected) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: isRevealed
            ? _getEventColor(event.type).withValues(alpha: 0.2)
            : Colors.white.withValues(alpha: 0.1),
        border: Border.all(
          color: isSelected
              ? Colors.white
              : _getEventColor(event.type).withValues(alpha: 0.5),
          width: isSelected ? 2 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  event.title,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              if (!isRevealed)
                Icon(
                  Icons.touch_app,
                  color: Colors.white.withValues(alpha: 0.6),
                  size: 16,
                ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            event.description,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Colors.white.withValues(alpha: 0.9),
            ),
          ),
          if (isRevealed) ...[
            const SizedBox(height: 12),
            _buildAliceQuote(event.aliceReference),
          ],
        ],
      ),
    );
  }

  Widget _buildAliceQuote(String quote) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: const Color(0xFF8B5CF6).withValues(alpha: 0.2),
        border: Border.all(
          color: const Color(0xFF8B5CF6).withValues(alpha: 0.5),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.format_quote,
            color: const Color(0xFF8B5CF6),
            size: 16,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              quote,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.white.withValues(alpha: 0.9),
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimelineConnector(int index) {
    return AnimatedBuilder(
      animation: _chaosController,
      builder: (context, child) {
        final nextEvent = _events[index + 1];
        final chaos = _getChaosAmount(nextEvent.type) *
                     math.sin(_chaosController.value * 3 * math.pi + index);

        return Transform.translate(
          offset: Offset(chaos * 0.5, 0),
          child: Container(
            margin: const EdgeInsets.only(left: 40),
            height: 30,
            width: 2,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  _getEventColor(_events[index].type),
                  _getEventColor(nextEvent.type),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildEventDetail() {
    final event = _events.firstWhere((e) => e.id == _selectedEvent!);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 400),
      padding: const EdgeInsets.all(20),
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          colors: [
            _getEventColor(event.type).withValues(alpha: 0.3),
            Colors.black.withValues(alpha: 0.7),
          ],
        ),
        border: Border.all(
          color: _getEventColor(event.type),
          width: 2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                _getEventIcon(event.type),
                color: _getEventColor(event.type),
                size: 24,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  event.title,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildDetailRow('Impact', event.impact),
          const SizedBox(height: 8),
          _buildDetailRow('SAR Signature', event.sarSignature),
          const SizedBox(height: 12),
          ElevatedButton.icon(
            onPressed: () => setState(() => _selectedEvent = null),
            icon: const Icon(Icons.close),
            label: const Text('Close'),
            style: ElevatedButton.styleFrom(
              backgroundColor: _getEventColor(event.type),
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return RichText(
      text: TextSpan(
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
          color: Colors.white.withValues(alpha: 0.9),
        ),
        children: [
          TextSpan(
            text: '$label: ',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          TextSpan(text: value),
        ],
      ),
    );
  }

  void _handleEventTap(TimelineEvent event) {
    HapticFeedback.mediumImpact();

    setState(() {
      _revealedEvents.add(event.id);
      _selectedEvent = _selectedEvent == event.id ? null : event.id;
    });

    widget.onImpactTap(event.id);
  }

  Color _getEventColor(TimelineEventType type) {
    switch (type) {
      case TimelineEventType.baseline:
        return const Color(0xFF10B981); // Green
      case TimelineEventType.human_impact:
        return const Color(0xFFEF4444); // Red
      case TimelineEventType.environmental:
        return const Color(0xFF3B82F6); // Blue
      case TimelineEventType.pollution:
        return const Color(0xFFB45309); // Orange
      case TimelineEventType.illegal:
        return const Color(0xFF8B5CF6); // Purple
      case TimelineEventType.current:
        return const Color(0xFFDC2626); // Dark Red
    }
  }

  IconData _getEventIcon(TimelineEventType type) {
    switch (type) {
      case TimelineEventType.baseline:
        return Icons.eco;
      case TimelineEventType.human_impact:
        return Icons.directions_boat;
      case TimelineEventType.environmental:
        return Icons.ac_unit;
      case TimelineEventType.pollution:
        return Icons.oil_barrel;
      case TimelineEventType.illegal:
        return Icons.visibility_off;
      case TimelineEventType.current:
        return Icons.warning;
    }
  }

  double _getChaosAmount(TimelineEventType type) {
    switch (type) {
      case TimelineEventType.baseline:
        return 0.0;
      case TimelineEventType.human_impact:
        return 3.0;
      case TimelineEventType.environmental:
        return 2.0;
      case TimelineEventType.pollution:
        return 5.0;
      case TimelineEventType.illegal:
        return 8.0;
      case TimelineEventType.current:
        return 10.0;
    }
  }
}

class TimelineEvent {
  final String id;
  final int year;
  final String title;
  final String description;
  final TimelineEventType type;
  final String impact;
  final String sarSignature;
  final String aliceReference;

  const TimelineEvent({
    required this.id,
    required this.year,
    required this.title,
    required this.description,
    required this.type,
    required this.impact,
    required this.sarSignature,
    required this.aliceReference,
  });
}

enum TimelineEventType {
  baseline,
  human_impact,
  environmental,
  pollution,
  illegal,
  current,
}