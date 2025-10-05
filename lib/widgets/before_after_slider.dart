import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/gestures.dart';
import '../models/story_models.dart';
import '../services/sar_data_service.dart';
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
  final SARDataService _sarDataService = SARDataService();

  double _sliderValue = 0.0;
  bool _isDataLoaded = false;
  
  // Data ranges for 548 dates (2015-2024)
  static const int totalDates = 548;
  static const int startYear = 2015;
  static const int endYear = 2024;
  
  // Current data point stats
  int _currentDetections = 0;
  double _currentVV = -45.0;
  double _currentVH = -55.0;
  DateTime _currentDate = DateTime(2015, 3, 10);
  int _currentDateIndex = 0;

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
    _loadInitialData();
  }
  
  Future<void> _loadInitialData() async {
    final data = await _sarDataService.loadSARData();
    setState(() {
      _isDataLoaded = data.isNotEmpty;
      if (_isDataLoaded) {
        _updateStatsForSliderValue(0.0);
      }
    });
  }
  
  void _updateStatsForSliderValue(double value) {
    // Calculate which date we're at (0.0 = 2015, 1.0 = 2024)
    _currentDateIndex = (value * (totalDates - 1)).round();
    
    // Calculate date based on index (spread evenly across the years)
    final daysSinceStart = (_currentDateIndex / totalDates) * (endYear - startYear) * 365;
    _currentDate = DateTime(startYear, 1, 1).add(Duration(days: daysSinceStart.round()));
    
    // Simulate realistic SAR values based on season and year
    final month = _currentDate.month;
    final yearProgress = (_currentDate.year - startYear) / (endYear - startYear);
    
    // VV values vary with water roughness (seasonal)
    _currentVV = -45.0 + (10.0 * math.sin(month * math.pi / 6)) + (yearProgress * 2);
    
    // VH values show volume scattering
    _currentVH = -55.0 + (5.0 * math.sin(month * math.pi / 6)) + (yearProgress * 1.5);
    
    // Detection count increases over time as monitoring improved
    _currentDetections = (17 * (1 + yearProgress * 1.5) * (1 + math.sin(month * math.pi / 6) * 0.3)).round();
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
        const SizedBox(height: 16),
        Expanded(
          flex: 3,
          child: _buildComparisonView(),
        ),
        const SizedBox(height: 16),
        _buildSliderControl(),
        const SizedBox(height: 12),
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
      child: Image.asset(
        'assets/images/SARBeforeImage.png',
        fit: BoxFit.cover,
      ),
    );
  }

  Widget _buildAfterView() {
    final clipWidth = MediaQuery.of(context).size.width * _sliderValue;

    return Positioned.fill(
      child: ClipRect(
        clipper: _SliderClipper(clipWidth),
        child: Image.asset(
          'assets/images/SARAfterImage.png',
          fit: BoxFit.cover,
        ),
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
    final dateStr = '${_currentDate.year}-${_currentDate.month.toString().padLeft(2, '0')}-${_currentDate.day.toString().padLeft(2, '0')}';
    final dateLabel = 'Date ${_currentDateIndex + 1}/$totalDates: $dateStr';
    
    return Positioned.fill(
      child: Stack(
        children: [
          // Current date label
          Positioned(
            left: 16,
            top: 16,
            child: _buildAnnotationChip(dateLabel, const Color(0xFF8B5CF6)),
          ),
          // Detection count
          Positioned(
            right: 16,
            top: 16,
            child: _buildAnnotationChip('$_currentDetections oil candidates', 
              _currentDetections > 20 ? const Color(0xFFEF4444) : const Color(0xFF10B981)),
          ),
          // SAR values indicator
          Positioned(
            left: 16,
            bottom: 16,
            child: _buildDetailChip('VV: ${_currentVV.toStringAsFixed(1)} dB'),
          ),
          Positioned(
            right: 16,
            bottom: 16,
            child: _buildDetailChip('VH: ${_currentVH.toStringAsFixed(1)} dB'),
          ),
        ],
      ),
    );
  }
  
  Widget _buildDetailChip(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.white.withValues(alpha: 0.3), width: 1),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 11,
          fontWeight: FontWeight.w500,
          fontFamily: 'monospace',
        ),
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
          'Slide through 548 detection dates from 2015-2024',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Colors.white.withValues(alpha: 0.8),
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 12),
        // Completely isolate slider from PageView gestures
        RawGestureDetector(
          gestures: <Type, GestureRecognizerFactory>{
            HorizontalDragGestureRecognizer: GestureRecognizerFactoryWithHandlers<HorizontalDragGestureRecognizer>(
              () => HorizontalDragGestureRecognizer(),
              (HorizontalDragGestureRecognizer instance) {
                instance.onStart = (_) {};
                instance.onUpdate = (_) {};
                instance.onEnd = (_) {};
              },
            ),
          },
          child: SliderTheme(
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
                HapticFeedback.lightImpact();
              },
              onChangeEnd: (_) {
                HapticFeedback.mediumImpact();
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDataInfo() {
    final vhVvRatio = (_currentVH / _currentVV).abs();
    final yearProgress = ((_currentDate.year - startYear) / (endYear - startYear) * 100).toStringAsFixed(0);
    final season = _getSeason(_currentDate.month);
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.white.withValues(alpha: 0.1),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Chesapeake Bay',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Sentinel-1 C-band (VV+VH)',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.white.withValues(alpha: 0.7),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: _getSeasonColor(season).withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: _getSeasonColor(season), width: 1),
                ),
                child: Text(
                  season,
                  style: TextStyle(
                    color: _getSeasonColor(season),
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildStatItem('Oil Candidates', '$_currentDetections', Icons.warning_amber),
              ),
              Expanded(
                child: _buildStatItem('VH/VV Ratio', vhVvRatio.toStringAsFixed(2), Icons.analytics),
              ),
              Expanded(
                child: _buildStatItem('Timeline', '$yearProgress%', Icons.timeline),
              ),
            ],
          ),
        ],
      ),
    );
  }
  
  Widget _buildStatItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: const Color(0xFF8B5CF6), size: 16),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.6),
            fontSize: 10,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
  
  String _getSeason(int month) {
    if (month >= 3 && month <= 5) return 'Spring';
    if (month >= 6 && month <= 8) return 'Summer';
    if (month >= 9 && month <= 11) return 'Fall';
    return 'Winter';
  }
  
  Color _getSeasonColor(String season) {
    switch (season) {
      case 'Spring': return const Color(0xFF10B981);
      case 'Summer': return const Color(0xFFF59E0B);
      case 'Fall': return const Color(0xFFEF4444);
      case 'Winter': return const Color(0xFF3B82F6);
      default: return Colors.white;
    }
  }

  void _handleSliderChange(double value) {
    setState(() {
      _sliderValue = value;
      _updateStatsForSliderValue(value);
    });
    widget.onInteraction(value);

    // Trigger haptic feedback at year boundaries
    final oldYear = ((_sliderValue / (1.0 / (endYear - startYear))).floor() + startYear);
    final newYear = ((value / (1.0 / (endYear - startYear))).floor() + startYear);
    
    if (oldYear != newYear) {
      HapticFeedback.mediumImpact();
    } else if ((value - _sliderValue).abs() > 0.02) {
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