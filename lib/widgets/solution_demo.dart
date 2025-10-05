import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/story_models.dart';
import 'dart:math' as math;

class SolutionDemo extends StatefulWidget {
  final SolutionComponents? solution;
  final Function(String) onSolutionInteraction;

  const SolutionDemo({
    super.key,
    this.solution,
    required this.onSolutionInteraction,
  });

  @override
  State<SolutionDemo> createState() => _SolutionDemoState();
}

class _SolutionDemoState extends State<SolutionDemo>
    with TickerProviderStateMixin {
  late AnimationController _crownController;
  late AnimationController _deploymentController;

  int _selectedTechIndex = 0;
  final Set<String> _exploredTechnologies = {};
  bool _isDeploymentActive = false;

  @override
  void initState() {
    super.initState();
    _crownController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat();

    _deploymentController = AnimationController(
      duration: const Duration(seconds: 5),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _crownController.dispose();
    _deploymentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.solution == null) {
      return _buildEmptyState();
    }

    return Column(
      children: [
        _buildQueenHeader(),
        const SizedBox(height: 24),
        Expanded(
          child: _buildSolutionContent(),
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
            Icons.construction,
            size: 80,
            color: Colors.white.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'Solution Demo Coming Soon',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQueenHeader() {
    return AnimatedBuilder(
      animation: _crownController,
      builder: (context, child) {
        final sparkle = math.sin(_crownController.value * 4 * math.pi) * 0.2;

        return Column(
          children: [
            Row(
              children: [
                Transform.scale(
                  scale: 1.0 + sparkle,
                  child: Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [
                          const Color(0xFFDC2626),
                          const Color(0xFFEF4444),
                          const Color(0xFFDC2626),
                        ],
                        transform: GradientRotation(_crownController.value * 2 * math.pi),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFDC2626).withValues(alpha: 0.4 + sparkle),
                          blurRadius: 20,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.gavel,
                      color: Colors.white,
                      size: 30,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Transform.rotate(
                        angle: sparkle * 0.1,
                        child: Text(
                          'The Queen\'s Decree',
                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            shadows: [
                              Shadow(
                                color: const Color(0xFFDC2626).withValues(alpha: 0.8),
                                blurRadius: 10,
                                offset: Offset(sparkle * 3, sparkle * 3),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Royal technology solution for marine protection',
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
            _buildRoyalProclamation(),
          ],
        );
      },
    );
  }

  Widget _buildRoyalProclamation() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        gradient: LinearGradient(
          colors: [
            const Color(0xFFDC2626).withValues(alpha: 0.3),
            const Color(0xFFEF4444).withValues(alpha: 0.2),
          ],
        ),
        border: Border.all(
          color: const Color(0xFFDC2626).withValues(alpha: 0.5),
          width: 2,
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(
                Icons.campaign,
                color: const Color(0xFFDC2626),
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Royal Proclamation',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: const Color(0xFFDC2626),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            '"By order of the Queen: All waters of the realm shall be protected by the finest technology. Oil spills shall be detected swiftly, illegal ships shall hide no more, and our marine ecosystems shall thrive!"',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.white.withValues(alpha: 0.9),
              fontStyle: FontStyle.italic,
              height: 1.4,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildSolutionContent() {
    final solution = widget.solution!;

    return SingleChildScrollView(
      child: Column(
        children: [
          _buildTechnologySelector(solution.technologies),
          const SizedBox(height: 24),
          _buildSelectedTechnologyDetails(solution.technologies),
          const SizedBox(height: 24),
          _buildImpactPreview(solution.expectedImpacts),
          const SizedBox(height: 24),
          _buildDeploymentDemo(solution),
        ],
      ),
    );
  }

  Widget _buildTechnologySelector(List<Technology> technologies) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Royal Technology Arsenal',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 200, // Increased from 140 to 200 for better visibility
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: technologies.length,
            itemBuilder: (context, index) {
              final tech = technologies[index];
              final isSelected = _selectedTechIndex == index;
              final isExplored = _exploredTechnologies.contains(tech.name);

              return _buildTechnologyCard(tech, isSelected, isExplored, index);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildTechnologyCard(Technology tech, bool isSelected, bool isExplored, int index) {
    return AnimatedBuilder(
      animation: _crownController,
      builder: (context, child) {
        final glow = math.sin(_crownController.value * 2 * math.pi + index) * 0.3;

        return GestureDetector(
          onTap: () => _handleTechnologyTap(index, tech.name),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            width: 160,
            margin: const EdgeInsets.only(right: 16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: isSelected
                    ? [
                        const Color(0xFFDC2626),
                        const Color(0xFFB91C1C),
                      ]
                    : isExplored
                        ? [
                            const Color(0xFF10B981).withValues(alpha: 0.7),
                            const Color(0xFF059669).withValues(alpha: 0.7),
                          ]
                        : [
                            Colors.white.withValues(alpha: 0.2 + glow),
                            Colors.white.withValues(alpha: 0.1 + glow),
                          ],
              ),
              border: Border.all(
                color: isSelected
                    ? Colors.white
                    : isExplored
                        ? const Color(0xFF10B981)
                        : Colors.transparent,
                width: 2,
              ),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: const Color(0xFFDC2626).withValues(alpha: 0.4),
                        blurRadius: 15,
                        spreadRadius: 2,
                      ),
                    ]
                  : null,
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        _getTechnologyIcon(tech.category),
                        color: Colors.white,
                        size: 24,
                      ),
                      const Spacer(),
                      if (isExplored)
                        Icon(
                          Icons.check_circle,
                          color: Colors.white,
                          size: 16,
                        ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    tech.name,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(4),
                      color: _getMaturityColor(tech.maturityLevel).withValues(alpha: 0.7),
                    ),
                    child: Text(
                      tech.maturityLevel,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSelectedTechnologyDetails(List<Technology> technologies) {
    if (_selectedTechIndex >= technologies.length) return const SizedBox.shrink();

    final tech = technologies[_selectedTechIndex];

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 500),
      child: Container(
        key: ValueKey(tech.name),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            colors: [
              const Color(0xFFDC2626).withValues(alpha: 0.3),
              Colors.black.withValues(alpha: 0.6),
            ],
          ),
          border: Border.all(
            color: const Color(0xFFDC2626),
            width: 2,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  _getTechnologyIcon(tech.category),
                  color: const Color(0xFFDC2626),
                  size: 28,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        tech.name,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              color: _getMaturityColor(tech.maturityLevel).withValues(alpha: 0.3),
                              border: Border.all(
                                color: _getMaturityColor(tech.maturityLevel),
                                width: 1,
                              ),
                            ),
                            child: Text(
                              tech.maturityLevel.toUpperCase(),
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: _getMaturityColor(tech.maturityLevel),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              color: const Color(0xFF8B5CF6).withValues(alpha: 0.3),
                              border: Border.all(
                                color: const Color(0xFF8B5CF6),
                                width: 1,
                              ),
                            ),
                            child: Text(
                              tech.category.toUpperCase(),
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: const Color(0xFF8B5CF6),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              tech.description,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.white.withValues(alpha: 0.9),
                height: 1.4,
              ),
            ),
            if (tech.capabilities.isNotEmpty) ...[
              const SizedBox(height: 16),
              _buildCapabilities(tech.capabilities),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildCapabilities(List<String> capabilities) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Capabilities',
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: capabilities.map((capability) {
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: const Color(0xFF3B82F6).withValues(alpha: 0.3),
                border: Border.all(
                  color: const Color(0xFF3B82F6),
                  width: 1,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.check,
                    color: const Color(0xFF3B82F6),
                    size: 14,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    capability,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildImpactPreview(List<Impact> impacts) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Expected Royal Impact',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        ...impacts.map((impact) => _buildImpactCard(impact)),
      ],
    );
  }

  Widget _buildImpactCard(Impact impact) {
    final categoryColor = _getCategoryColor(impact.category);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: categoryColor.withValues(alpha: 0.2),
        border: Border.all(
          color: categoryColor.withValues(alpha: 0.5),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                _getCategoryIcon(impact.category),
                color: categoryColor,
                size: 20,
              ),
              const SizedBox(width: 12),
              Text(
                impact.category.toUpperCase(),
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: categoryColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: _getMagnitudeColor(impact.magnitude).withValues(alpha: 0.3),
                ),
                child: Text(
                  '${impact.magnitude.toUpperCase()} IMPACT',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: _getMagnitudeColor(impact.magnitude),
                    fontWeight: FontWeight.bold,
                    fontSize: 10,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            impact.description,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.white.withValues(alpha: 0.9),
              height: 1.4,
            ),
          ),
          if (impact.beneficiaries.isNotEmpty) ...[
            const SizedBox(height: 8),
            Wrap(
              spacing: 6,
              children: impact.beneficiaries.map((beneficiary) {
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    color: categoryColor.withValues(alpha: 0.3),
                  ),
                  child: Text(
                    beneficiary,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.white,
                      fontSize: 10,
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDeploymentDemo(SolutionComponents solution) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Royal Deployment Plan',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              colors: [
                const Color(0xFF10B981).withValues(alpha: 0.3),
                Colors.black.withValues(alpha: 0.6),
              ],
            ),
            border: Border.all(
              color: const Color(0xFF10B981),
              width: 2,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                solution.implementation,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.white.withValues(alpha: 0.9),
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Icon(
                    Icons.schedule,
                    color: const Color(0xFF10B981),
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Timeline: ${solution.timeline}',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: const Color(0xFF10B981),
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.visible,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _buildDeploymentButton(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDeploymentButton() {
    return AnimatedBuilder(
      animation: _deploymentController,
      builder: (context, child) {
        return SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: _isDeploymentActive ? null : _startDeploymentDemo,
            icon: _isDeploymentActive
                ? SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      value: _deploymentController.value,
                      strokeWidth: 2,
                      valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : const Icon(Icons.rocket_launch),
            label: Text(
              _isDeploymentActive
                  ? 'Deploying... ${(_deploymentController.value * 100).toInt()}%'
                  : 'Launch Royal Solution',
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF10B981),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        );
      },
    );
  }

  void _handleTechnologyTap(int index, String techName) {
    HapticFeedback.mediumImpact();

    setState(() {
      _selectedTechIndex = index;
      _exploredTechnologies.add(techName);
    });

    widget.onSolutionInteraction('technology_$techName');
  }

  void _startDeploymentDemo() {
    HapticFeedback.heavyImpact();

    setState(() {
      _isDeploymentActive = true;
    });

    _deploymentController.reset();
    _deploymentController.forward().then((_) {
      setState(() {
        _isDeploymentActive = false;
      });

      widget.onSolutionInteraction('deployment_complete');

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Royal solution deployed successfully!'),
          backgroundColor: const Color(0xFF10B981),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
    });
  }

  IconData _getTechnologyIcon(String category) {
    switch (category) {
      case 'monitoring':
        return Icons.satellite;
      case 'detection':
        return Icons.radar;
      case 'response':
        return Icons.emergency;
      case 'prevention':
        return Icons.shield;
      default:
        return Icons.computer;
    }
  }

  Color _getMaturityColor(String maturityLevel) {
    switch (maturityLevel) {
      case 'prototype':
        return const Color(0xFFEAB308);
      case 'pilot':
        return const Color(0xFF3B82F6);
      case 'operational':
        return const Color(0xFF10B981);
      default:
        return const Color(0xFF6B7280);
    }
  }

  Color _getCategoryColor(String category) {
    switch (category) {
      case 'environmental':
        return const Color(0xFF10B981);
      case 'economic':
        return const Color(0xFF3B82F6);
      case 'social':
        return const Color(0xFFEC4899);
      default:
        return const Color(0xFF6B7280);
    }
  }

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'environmental':
        return Icons.eco;
      case 'economic':
        return Icons.attach_money;
      case 'social':
        return Icons.group;
      default:
        return Icons.help;
    }
  }

  Color _getMagnitudeColor(String magnitude) {
    switch (magnitude) {
      case 'high':
        return const Color(0xFF10B981);
      case 'medium':
        return const Color(0xFFEAB308);
      case 'low':
        return const Color(0xFFEF4444);
      default:
        return const Color(0xFF6B7280);
    }
  }
}