import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/story_models.dart';
import 'dart:math' as math;

class FrequencyExplorer extends StatefulWidget {
  final List<SarDataLayer> sarLayers;
  final AliceThemeData? aliceTheme;
  final Function(String) onFrequencyTap;

  const FrequencyExplorer({
    super.key,
    required this.sarLayers,
    this.aliceTheme,
    required this.onFrequencyTap,
  });

  @override
  State<FrequencyExplorer> createState() => _FrequencyExplorerState();
}

class _FrequencyExplorerState extends State<FrequencyExplorer>
    with TickerProviderStateMixin {
  late AnimationController _mirrorController;
  late AnimationController _revealController;

  final Set<String> _revealedFrequencies = {};
  String? _selectedFrequency;

  @override
  void initState() {
    super.initState();
    _mirrorController = AnimationController(
      duration: const Duration(seconds: 4),
      vsync: this,
    )..repeat();

    _revealController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _mirrorController.dispose();
    _revealController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildMirrorTitle(),
        const SizedBox(height: 16),
        Text(
          'Tap each mirror to see what it reveals:',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16),
        Expanded(
          child: _buildFrequencyMirrors(),
        ),
      ],
    );
  }

  Widget _buildMirrorTitle() {
    return AnimatedBuilder(
      animation: _mirrorController,
      builder: (context, child) {
        return Transform.scale(
          scale: 1.0 + (0.05 * math.sin(_mirrorController.value * 2 * math.pi)),
          child: Text(
            'Through the Looking Glass',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              shadows: [
                Shadow(
                  color: const Color(0xFF8B5CF6).withValues(alpha: 0.8),
                  blurRadius: 10,
                  offset: Offset(
                    3 * math.sin(_mirrorController.value * 2 * math.pi),
                    3 * math.cos(_mirrorController.value * 2 * math.pi),
                  ),
                ),
              ],
            ),
            textAlign: TextAlign.center,
          ),
        );
      },
    );
  }

  Widget _buildFrequencyMirrors() {
    final frequencies = widget.sarLayers.map((layer) => layer.frequency).toSet().toList();

    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 0.75, // Even taller cards to fit all content
      ),
      itemCount: frequencies.length,
      itemBuilder: (context, index) {
        final frequency = frequencies[index];
        final isRevealed = _revealedFrequencies.contains(frequency);
        final isSelected = _selectedFrequency == frequency;

        return _buildFrequencyMirror(frequency, isRevealed, isSelected, index);
      },
    );
  }

  Widget _buildFrequencyMirror(String frequency, bool isRevealed, bool isSelected, int index) {
    return AnimatedBuilder(
      animation: _mirrorController,
      builder: (context, child) {
        final shimmer = math.sin(_mirrorController.value * 2 * math.pi + index) * 0.3;

        return GestureDetector(
          onTap: () => _handleFrequencyTap(frequency),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 500),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: isRevealed
                    ? [
                        _getFrequencyColor(frequency).withValues(alpha: 0.8),
                        _getFrequencyColor(frequency).withValues(alpha: 0.4),
                        Colors.black.withValues(alpha: 0.6),
                      ]
                    : [
                        Colors.grey.withValues(alpha: 0.6 + shimmer),
                        Colors.grey.withValues(alpha: 0.3 + shimmer),
                        Colors.black.withValues(alpha: 0.8),
                      ],
              ),
              border: Border.all(
                color: isSelected
                    ? Colors.white
                    : isRevealed
                        ? _getFrequencyColor(frequency)
                        : Colors.grey.withValues(alpha: 0.5),
                width: isSelected ? 3 : 1,
              ),
              boxShadow: isRevealed
                  ? [
                      BoxShadow(
                        color: _getFrequencyColor(frequency).withValues(alpha: 0.4),
                        blurRadius: 20,
                        spreadRadius: 2,
                      ),
                    ]
                  : null,
            ),
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildMirrorFrame(frequency, isRevealed, shimmer),
                  const SizedBox(height: 10),
                  Text(
                    frequency,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  if (isRevealed) ...[
                    const SizedBox(height: 6),
                    Text(
                      _getFrequencyCapability(frequency),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.white.withValues(alpha: 0.9),
                        fontSize: 12,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ] else ...[
                    const SizedBox(height: 6),
                    Icon(
                      Icons.help_outline,
                      color: Colors.white.withValues(alpha: 0.6),
                      size: 20,
                    ),
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildMirrorFrame(String frequency, bool isRevealed, double shimmer) {
    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [
            Colors.white.withValues(alpha: 0.3 + shimmer),
            Colors.white.withValues(alpha: 0.1),
            Colors.transparent,
          ],
        ),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.5),
          width: 2,
        ),
      ),
      child: Center(
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 600),
          child: isRevealed
              ? _buildFrequencyVisualization(frequency)
              : Icon(
                  Icons.visibility_off,
                  key: ValueKey('hidden_$frequency'),
                  size: 32,
                  color: Colors.white.withValues(alpha: 0.6),
                ),
        ),
      ),
    );
  }

  Widget _buildFrequencyVisualization(String frequency) {
    final color = _getFrequencyColor(frequency);
    final icon = _getFrequencyIcon(frequency);

    return AnimatedBuilder(
      animation: _revealController,
      builder: (context, child) {
        return Transform.scale(
          scale: _revealController.value,
          child: Container(
            key: ValueKey('revealed_$frequency'),
            width: 54,
            height: 54,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color.withValues(alpha: 0.8),
              boxShadow: [
                BoxShadow(
                  color: color.withValues(alpha: 0.6),
                  blurRadius: 15,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Icon(
              icon,
              color: Colors.white,
              size: 28,
            ),
          ),
        );
      },
    );
  }

  Widget _buildFrequencyInsightDialog(String frequency) {
    final insight = _getFrequencyInsight(frequency);
    final riddle = _getFrequencyRiddle(frequency);

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.75,
        ),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              _getFrequencyColor(frequency).withValues(alpha: 0.9),
              Colors.black,
            ],
          ),
          border: Border.all(
            color: _getFrequencyColor(frequency),
            width: 2,
          ),
        ),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Icon(
                    _getFrequencyIcon(frequency),
                    color: _getFrequencyColor(frequency),
                    size: 28,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      '$frequency Reveals:',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      HapticFeedback.lightImpact();
                      Navigator.of(context).pop();
                    },
                    icon: const Icon(Icons.close),
                    color: Colors.white,
                    iconSize: 28,
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Text(
                insight,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Colors.white.withValues(alpha: 0.95),
                  height: 1.5,
                ),
              ),
              if (riddle.isNotEmpty) ...[
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: Colors.white.withValues(alpha: 0.1),
                    border: Border.all(
                      color: const Color(0xFF8B5CF6).withValues(alpha: 0.5),
                      width: 1,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.quiz,
                            color: const Color(0xFF8B5CF6),
                            size: 24,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'Alice\'s Riddle:',
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                color: const Color(0xFF8B5CF6),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Text(
                        riddle,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.white.withValues(alpha: 0.85),
                          fontStyle: FontStyle.italic,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  void _handleFrequencyTap(String frequency) {
    HapticFeedback.mediumImpact();

    setState(() {
      if (!_revealedFrequencies.contains(frequency)) {
        _revealedFrequencies.add(frequency);
        _revealController.reset();
        _revealController.forward();
      }
      _selectedFrequency = frequency;
    });

    widget.onFrequencyTap(frequency);
    
    // Show the frequency insight in a dialog
    showDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.7),
      builder: (context) => _buildFrequencyInsightDialog(frequency),
    );
  }

  Color _getFrequencyColor(String frequency) {
    switch (frequency.toLowerCase()) {
      case 'c-band':
        return const Color(0xFF3B82F6); // Blue
      case 'l-band':
        return const Color(0xFF10B981); // Green
      case 'x-band':
        return const Color(0xFFEF4444); // Red
      case 'p-band':
        return const Color(0xFF8B5CF6); // Purple
      default:
        return const Color(0xFF6B7280); // Gray
    }
  }

  IconData _getFrequencyIcon(String frequency) {
    switch (frequency.toLowerCase()) {
      case 'c-band':
        return Icons.water;
      case 'l-band':
        return Icons.forest;
      case 'x-band':
        return Icons.zoom_in;
      case 'p-band':
        return Icons.layers;
      default:
        return Icons.radar;
    }
  }

  String _getFrequencyCapability(String frequency) {
    switch (frequency.toLowerCase()) {
      case 'c-band':
        return 'Surface Detection';
      case 'l-band':
        return 'Vegetation Penetration';
      case 'x-band':
        return 'High Resolution';
      case 'p-band':
        return 'Deep Penetration';
      default:
        return 'Unknown';
    }
  }

  String _getFrequencyInsight(String frequency) {
    switch (frequency.toLowerCase()) {
      case 'c-band':
        return 'C-band SAR excels at detecting surface phenomena like oil spills and ship wakes. The 5.6 cm wavelength interacts strongly with smooth water surfaces, making oil slicks appear as dark patches against the brighter water background. This is why we can spot that mysterious oil sheen near Fort McHenry!';
      case 'l-band':
        return 'L-band SAR penetrates through vegetation and even shallow water. With its 24 cm wavelength, it reveals the hidden structure beneath - like seeing through the Chesapeake\'s marshy coastlines to understand how vegetation health affects water quality and wildlife habitat.';
      case 'x-band':
        return 'X-band SAR provides the finest details with its 3.1 cm wavelength. It\'s perfect for identifying individual ships, their size, and even detecting unusual vessel behavior. Those mysterious nighttime ships on the Patuxent River would be clearly visible in X-band imagery.';
      case 'p-band':
        return 'P-band SAR has the deepest penetration capability, able to see through forest canopies to the ground below. While experimental, it could revolutionize our understanding of coastal forest health and its impact on water ecosystems.';
      default:
        return 'This frequency provides unique insights into our environment that aren\'t visible to the naked eye.';
    }
  }

  String _getFrequencyRiddle(String frequency) {
    final riddles = widget.aliceTheme?.sarToWonderlandMappings;
    if (riddles == null) return '';

    switch (frequency.toLowerCase()) {
      case 'c-band':
        return 'Why does the oil look dark when the water sparkles bright? What makes the ships leave glowing trails in the night?';
      case 'l-band':
        return 'How can we see through water to the marshes below? What secrets do the hidden plant roots know?';
      case 'x-band':
        return 'What makes the ships shine like stars in the bay? How can we see details from so far away?';
      default:
        return '';
    }
  }
}