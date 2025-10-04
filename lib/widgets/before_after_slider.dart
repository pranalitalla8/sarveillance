import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/story_models.dart';
import 'dart:math' as math;

class BeforeAfterSlider extends StatefulWidget {
  final SarDataLayer? beforeData;
  final SarDataLayer? afterData;
  final Function(double) onInteraction;

  const BeforeAfterSlider({
    super.key,
    this.beforeData,
    this.afterData,
    required this.onInteraction,
  });

  @override
  State<BeforeAfterSlider> createState() => _BeforeAfterSliderState();
}

class _BeforeAfterSliderState extends State<BeforeAfterSlider>
    with TickerProviderStateMixin {
  late AnimationController _slideController;
  late AnimationController _waveController;

  double _sliderValue = 0.0;
  bool _isDragging = false;

  @override
  void initState() {
    super.initState();
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _waveController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _slideController.dispose();
    _waveController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildTimelineTitle(),
        const SizedBox(height: 24),
        Expanded(
          child: _buildComparisonView(),
        ),
        const SizedBox(height: 24),
        _buildSliderControl(),
        const SizedBox(height: 16),
        _buildDataInfo(),
      ],
    );
  }

  Widget _buildTimelineTitle() {
    return Text(
      'Journey Through Time',
      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
        color: Colors.white,
        fontWeight: FontWeight.bold,
      ),
      textAlign: TextAlign.center,
    );
  }

  Widget _buildComparisonView() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.3),
          width: 2,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: Stack(
          children: [
            _buildBeforeView(),
            _buildAfterView(),
            _buildSliderDivider(),
            _buildOverlayAnnotations(),
          ],
        ),
      ),
    );
  }

  Widget _buildBeforeView() {
    return Positioned.fill(
      child: AnimatedBuilder(
        animation: _waveController,
        builder: (context, child) {
          return CustomPaint(
            painter: SarDataPainter(
              data: widget.beforeData,
              animationValue: _waveController.value,
              isPristine: true,
            ),
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    const Color(0xFF0EA5E9).withValues(alpha: 0.6),
                    const Color(0xFF0284C7).withValues(alpha: 0.4),
                    const Color(0xFF0369A1).withValues(alpha: 0.2),
                  ],
                ),
              ),
              child: _buildPristineWaterContent(),
            ),
          );
        },
      ),
    );
  }

  Widget _buildAfterView() {
    final clipWidth = MediaQuery.of(context).size.width * _sliderValue;

    return Positioned.fill(
      child: ClipRect(
        clipper: _SliderClipper(clipWidth),
        child: AnimatedBuilder(
          animation: _waveController,
          builder: (context, child) {
            return CustomPaint(
              painter: SarDataPainter(
                data: widget.afterData,
                animationValue: _waveController.value,
                isPristine: false,
              ),
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      const Color(0xFFEF4444).withValues(alpha: 0.6),
                      const Color(0xFFDC2626).withValues(alpha: 0.4),
                      const Color(0xFFB91C1C).withValues(alpha: 0.2),
                    ],
                  ),
                ),
                child: _buildImpactedWaterContent(),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildPristineWaterContent() {
    return Stack(
      children: [
        // Gentle waves
        Positioned.fill(
          child: AnimatedBuilder(
            animation: _waveController,
            builder: (context, child) {
              return CustomPaint(
                painter: WavePatternPainter(
                  _waveController.value,
                  Colors.white.withValues(alpha: 0.3),
                  isCalm: true,
                ),
              );
            },
          ),
        ),
        // Natural features
        _buildFeaturePoint(0.3, 0.4, 'Healthy Marine Life', Colors.green),
        _buildFeaturePoint(0.7, 0.6, 'Clean Water', Colors.blue),
        _buildFeaturePoint(0.5, 0.7, 'Natural Ice Patterns', Colors.cyan),
      ],
    );
  }

  Widget _buildImpactedWaterContent() {
    return Stack(
      children: [
        // Disturbed waves
        Positioned.fill(
          child: AnimatedBuilder(
            animation: _waveController,
            builder: (context, child) {
              return CustomPaint(
                painter: WavePatternPainter(
                  _waveController.value,
                  Colors.white.withValues(alpha: 0.2),
                  isCalm: false,
                ),
              );
            },
          ),
        ),
        // Impact features
        _buildFeaturePoint(0.2, 0.3, 'Oil Spill', Colors.red),
        _buildFeaturePoint(0.8, 0.5, 'Illegal Dumping', Colors.orange),
        _buildFeaturePoint(0.4, 0.8, 'Ship Traffic', Colors.yellow),
        _buildFeaturePoint(0.6, 0.2, 'Disrupted Ice', Colors.purple),
      ],
    );
  }

  Widget _buildFeaturePoint(double x, double y, String label, Color color) {
    return Positioned(
      left: x * (MediaQuery.of(context).size.width - 100),
      top: y * 200,
      child: AnimatedBuilder(
        animation: _waveController,
        builder: (context, child) {
          final pulse = 1.0 + (0.3 * math.sin(_waveController.value * 2 * math.pi));
          return Transform.scale(
            scale: pulse,
            child: Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: color.withValues(alpha: 0.6),
                    blurRadius: 8,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Tooltip(
                message: label,
                child: const SizedBox(),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSliderDivider() {
    final screenWidth = MediaQuery.of(context).size.width;
    final dividerPosition = screenWidth * _sliderValue;

    return Positioned(
      left: dividerPosition - 2,
      top: 0,
      bottom: 0,
      child: Container(
        width: 4,
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.5),
              blurRadius: 8,
              spreadRadius: 1,
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 20,
              height: 20,
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.drag_handle,
                size: 16,
                color: Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOverlayAnnotations() {
    return Positioned.fill(
      child: Stack(
        children: [
          // Before label
          if (_sliderValue < 0.8)
            Positioned(
              left: 16,
              top: 16,
              child: _buildAnnotationChip('Before: 2000', const Color(0xFF0EA5E9)),
            ),
          // After label
          if (_sliderValue > 0.2)
            Positioned(
              right: 16,
              top: 16,
              child: _buildAnnotationChip('After: 2023', const Color(0xFFEF4444)),
            ),
        ],
      ),
    );
  }

  Widget _buildAnnotationChip(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white, width: 1),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildSliderControl() {
    return Column(
      children: [
        Text(
          'Drag to reveal the transformation',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Colors.white.withValues(alpha: 0.8),
          ),
        ),
        const SizedBox(height: 12),
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            activeTrackColor: const Color(0xFF8B5CF6),
            inactiveTrackColor: Colors.white.withValues(alpha: 0.3),
            thumbColor: Colors.white,
            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 12),
            overlayColor: const Color(0xFF8B5CF6).withValues(alpha: 0.3),
            trackHeight: 6,
          ),
          child: Slider(
            value: _sliderValue,
            onChanged: _handleSliderChange,
            onChangeStart: (_) {
              setState(() {
                _isDragging = true;
              });
              HapticFeedback.lightImpact();
            },
            onChangeEnd: (_) {
              setState(() {
                _isDragging = false;
              });
              HapticFeedback.mediumImpact();
            },
          ),
        ),
      ],
    );
  }

  Widget _buildDataInfo() {
    final beforeData = widget.beforeData;
    final afterData = widget.afterData;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.white.withValues(alpha: 0.1),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Current View: ${_sliderValue < 0.5 ? "Before" : "After"}',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (_sliderValue < 0.5 && beforeData != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    'Location: ${beforeData.location}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.white.withValues(alpha: 0.8),
                    ),
                  ),
                  Text(
                    'Date: ${beforeData.acquisitionDate.year}-${beforeData.acquisitionDate.month.toString().padLeft(2, '0')}-${beforeData.acquisitionDate.day.toString().padLeft(2, '0')}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.white.withValues(alpha: 0.8),
                    ),
                  ),
                ] else if (_sliderValue >= 0.5 && afterData != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    'Location: ${afterData.location}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.white.withValues(alpha: 0.8),
                    ),
                  ),
                  Text(
                    'Date: ${afterData.acquisitionDate.year}-${afterData.acquisitionDate.month.toString().padLeft(2, '0')}-${afterData.acquisitionDate.day.toString().padLeft(2, '0')}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.white.withValues(alpha: 0.8),
                    ),
                  ),
                ],
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFF8B5CF6).withValues(alpha: 0.2),
            ),
            child: Icon(
              _sliderValue < 0.5 ? Icons.eco : Icons.warning,
              color: _sliderValue < 0.5 ? Colors.green : Colors.orange,
              size: 24,
            ),
          ),
        ],
      ),
    );
  }

  void _handleSliderChange(double value) {
    setState(() {
      _sliderValue = value;
    });
    widget.onInteraction(value);

    // Trigger different haptic feedback based on significant positions
    if ((value - _sliderValue).abs() > 0.1) {
      HapticFeedback.selectionClick();
    }
  }
}

class _SliderClipper extends CustomClipper<Rect> {
  final double clipWidth;

  _SliderClipper(this.clipWidth);

  @override
  Rect getClip(Size size) {
    return Rect.fromLTWH(0, 0, clipWidth, size.height);
  }

  @override
  bool shouldReclip(covariant CustomClipper<Rect> oldClipper) {
    return oldClipper is _SliderClipper && oldClipper.clipWidth != clipWidth;
  }
}

class SarDataPainter extends CustomPainter {
  final SarDataLayer? data;
  final double animationValue;
  final bool isPristine;

  SarDataPainter({
    this.data,
    required this.animationValue,
    required this.isPristine,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;

    if (isPristine) {
      _paintPristineData(canvas, size, paint);
    } else {
      _paintImpactedData(canvas, size, paint);
    }
  }

  void _paintPristineData(Canvas canvas, Size size, Paint paint) {
    // Natural patterns
    for (int i = 0; i < 20; i++) {
      final x = (size.width / 5) * (i % 5);
      final y = (size.height / 4) * (i % 4);
      final offset = 20 * math.sin(animationValue * 2 * math.pi + i);

      paint.color = Colors.blue.withValues(alpha: 0.3 + (0.2 * math.sin(animationValue * math.pi + i)));
      canvas.drawCircle(Offset(x + offset, y), 5, paint);
    }
  }

  void _paintImpactedData(Canvas canvas, Size size, Paint paint) {
    // Impact patterns
    for (int i = 0; i < 15; i++) {
      final x = (size.width / 4) * (i % 4);
      final y = (size.height / 4) * (i % 4);
      final offset = 30 * math.sin(animationValue * 3 * math.pi + i);

      paint.color = Colors.red.withValues(alpha: 0.4 + (0.3 * math.sin(animationValue * 2 * math.pi + i)));
      canvas.drawRect(
        Rect.fromCenter(center: Offset(x + offset, y), width: 8, height: 8),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class WavePatternPainter extends CustomPainter {
  final double animationValue;
  final Color color;
  final bool isCalm;

  WavePatternPainter(this.animationValue, this.color, {required this.isCalm});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    final amplitude = isCalm ? 10.0 : 25.0;
    final frequency = isCalm ? 50.0 : 30.0;

    for (int wave = 0; wave < 5; wave++) {
      final path = Path();
      final yOffset = (size.height / 6) * wave;

      for (double x = 0; x <= size.width; x += 2) {
        final y = yOffset +
                  amplitude * math.sin((x / frequency) + animationValue * 2 * math.pi + wave) +
                  (wave * 5);
        if (x == 0) {
          path.moveTo(x, y);
        } else {
          path.lineTo(x, y);
        }
      }
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}