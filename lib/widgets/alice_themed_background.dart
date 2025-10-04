import 'package:flutter/material.dart';
import 'dart:math' as math;

class AliceThemedBackground extends StatefulWidget {
  final int currentChapter;
  final AnimationController animationController;

  const AliceThemedBackground({
    super.key,
    required this.currentChapter,
    required this.animationController,
  });

  @override
  State<AliceThemedBackground> createState() => _AliceThemedBackgroundState();
}

class _AliceThemedBackgroundState extends State<AliceThemedBackground>
    with TickerProviderStateMixin {
  late AnimationController _floatingController;
  late AnimationController _twinkleController;
  late AnimationController _rabbitHoleController;

  @override
  void initState() {
    super.initState();
    _floatingController = AnimationController(
      duration: const Duration(seconds: 6),
      vsync: this,
    )..repeat();

    _twinkleController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);

    _rabbitHoleController = AnimationController(
      duration: const Duration(seconds: 8),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _floatingController.dispose();
    _twinkleController.dispose();
    _rabbitHoleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        _buildBaseGradient(),
        _buildChapterSpecificBackground(),
        _buildFloatingElements(),
        _buildTwinklingStars(),
        if (widget.currentChapter == 0) _buildRabbitHoleEffect(),
      ],
    );
  }

  Widget _buildBaseGradient() {
    final gradients = _getChapterGradients();
    final currentGradient = gradients[widget.currentChapter % gradients.length];

    return AnimatedBuilder(
      animation: widget.animationController,
      builder: (context, child) {
        final animationValue = widget.animationController.value.clamp(0.0, 1.0);
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: currentGradient.map((color) =>
                color.withOpacity((0.7 + (0.3 * animationValue)).clamp(0.0, 1.0))
              ).toList(),
            ),
          ),
        );
      },
    );
  }

  Widget _buildChapterSpecificBackground() {
    switch (widget.currentChapter) {
      case 0: // Down the Rabbit Hole
        return _buildRabbitHoleBackground();
      case 1: // The World Before
        return _buildPristineWaterBackground();
      case 2: // Mad Hatter's Tea Party
        return _buildChaoticTeaPartyBackground();
      case 3: // Through the Looking Glass
        return _buildMirrorWorldBackground();
      case 4: // Cheshire Cat's Secrets
        return _buildMysteriousForestBackground();
      case 5: // Alice's Neighborhood
        return _buildFamiliarPlacesBackground();
      case 6: // Queen's Decree
        return _buildRoyalGardenBackground();
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildRabbitHoleBackground() {
    return AnimatedBuilder(
      animation: _rabbitHoleController,
      builder: (context, child) {
        return CustomPaint(
          painter: RabbitHolePainter(_rabbitHoleController.value),
          size: Size.infinite,
        );
      },
    );
  }

  Widget _buildPristineWaterBackground() {
    return CustomPaint(
      painter: WaterWavesPainter(widget.animationController.value),
      size: Size.infinite,
    );
  }

  Widget _buildChaoticTeaPartyBackground() {
    return AnimatedBuilder(
      animation: _floatingController,
      builder: (context, child) {
        return CustomPaint(
          painter: TeaPartyChaosPainter(_floatingController.value),
          size: Size.infinite,
        );
      },
    );
  }

  Widget _buildMirrorWorldBackground() {
    return AnimatedBuilder(
      animation: widget.animationController,
      builder: (context, child) {
        return CustomPaint(
          painter: MirrorEffectPainter(widget.animationController.value),
          size: Size.infinite,
        );
      },
    );
  }

  Widget _buildMysteriousForestBackground() {
    return CustomPaint(
      painter: ForestShadowsPainter(widget.animationController.value),
      size: Size.infinite,
    );
  }

  Widget _buildFamiliarPlacesBackground() {
    return CustomPaint(
      painter: LocalWatersPainter(widget.animationController.value),
      size: Size.infinite,
    );
  }

  Widget _buildRoyalGardenBackground() {
    return CustomPaint(
      painter: RoyalGardenPainter(widget.animationController.value),
      size: Size.infinite,
    );
  }

  Widget _buildFloatingElements() {
    return AnimatedBuilder(
      animation: _floatingController,
      builder: (context, child) {
        return Stack(
          children: _generateFloatingElements(),
        );
      },
    );
  }

  List<Widget> _generateFloatingElements() {
    final elements = <Widget>[];
    final screenSize = MediaQuery.of(context).size;

    // Generate floating elements based on current chapter
    final elementData = _getChapterFloatingElements();

    for (int i = 0; i < elementData.length; i++) {
      final element = elementData[i];
      final offset = _calculateFloatingOffset(i, screenSize);

      elements.add(
        Positioned(
          left: offset.dx,
          top: offset.dy,
          child: Transform.rotate(
            angle: math.sin(_floatingController.value * 2 * math.pi + i) * 0.1,
            child: Opacity(
              opacity: (0.3 + (0.4 * math.sin(_floatingController.value * math.pi + i))).clamp(0.0, 1.0),
              child: Icon(
                element['icon'],
                size: element['size'],
                color: element['color'],
              ),
            ),
          ),
        ),
      );
    }

    return elements;
  }

  Offset _calculateFloatingOffset(int index, Size screenSize) {
    final baseX = (screenSize.width / 6) * (index % 6);
    final baseY = (screenSize.height / 4) * (index % 4);

    final floatX = baseX + (50 * math.sin(_floatingController.value * 2 * math.pi + index));
    final floatY = baseY + (30 * math.cos(_floatingController.value * 2 * math.pi + index * 0.7));

    return Offset(floatX, floatY);
  }

  Widget _buildTwinklingStars() {
    return AnimatedBuilder(
      animation: _twinkleController,
      builder: (context, child) {
        return CustomPaint(
          painter: TwinklingStarsPainter(_twinkleController.value),
          size: Size.infinite,
        );
      },
    );
  }

  Widget _buildRabbitHoleEffect() {
    return AnimatedBuilder(
      animation: _rabbitHoleController,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            gradient: RadialGradient(
              center: const Alignment(0.0, -0.3),
              radius: 1.5 + (0.5 * _rabbitHoleController.value),
              colors: [
                Colors.transparent,
                Colors.black.withOpacity(0.3),
                Colors.black.withOpacity(0.8),
              ],
              stops: const [0.0, 0.7, 1.0],
            ),
          ),
        );
      },
    );
  }

  List<List<Color>> _getChapterGradients() {
    return [
      // Chapter 0: Down the Rabbit Hole
      [const Color(0xFF1E293B), const Color(0xFF0F172A), const Color(0xFF020617)],
      // Chapter 1: The World Before
      [const Color(0xFF0EA5E9), const Color(0xFF0284C7), const Color(0xFF0369A1)],
      // Chapter 2: Mad Hatter's Tea Party
      [const Color(0xFFDC2626), const Color(0xFFB91C1C), const Color(0xFF991B1B)],
      // Chapter 3: Through the Looking Glass
      [const Color(0xFF8B5CF6), const Color(0xFF7C3AED), const Color(0xFF6D28D9)],
      // Chapter 4: Cheshire Cat's Secrets
      [const Color(0xFF059669), const Color(0xFF047857), const Color(0xFF065F46)],
      // Chapter 5: Alice's Neighborhood
      [const Color(0xFFF59E0B), const Color(0xFFD97706), const Color(0xFFB45309)],
      // Chapter 6: Queen's Decree
      [const Color(0xFFDC2626), const Color(0xFFEF4444), const Color(0xFFF87171)],
    ];
  }

  List<Map<String, dynamic>> _getChapterFloatingElements() {
    switch (widget.currentChapter) {
      case 0: // Rabbit Hole
        return [
          {'icon': Icons.access_time, 'size': 24.0, 'color': Colors.white.withOpacity(0.6)},
          {'icon': Icons.pets, 'size': 20.0, 'color': Colors.white.withOpacity(0.4)},
          {'icon': Icons.star, 'size': 16.0, 'color': Colors.yellow.withOpacity(0.5)},
        ];
      case 1: // Pristine Waters
        return [
          {'icon': Icons.water_drop, 'size': 20.0, 'color': Colors.blue.withOpacity(0.6)},
          {'icon': Icons.sailing, 'size': 24.0, 'color': Colors.white.withOpacity(0.5)},
          {'icon': Icons.eco, 'size': 18.0, 'color': Colors.green.withOpacity(0.4)},
        ];
      case 2: // Tea Party Chaos
        return [
          {'icon': Icons.local_cafe, 'size': 22.0, 'color': Colors.brown.withOpacity(0.6)},
          {'icon': Icons.cake, 'size': 20.0, 'color': Colors.pink.withOpacity(0.5)},
          {'icon': Icons.schedule, 'size': 18.0, 'color': Colors.red.withOpacity(0.4)},
        ];
      case 3: // Looking Glass
        return [
          {'icon': Icons.auto_awesome, 'size': 24.0, 'color': Colors.purple.withOpacity(0.6)},
          {'icon': Icons.flip, 'size': 20.0, 'color': Colors.white.withOpacity(0.5)},
          {'icon': Icons.camera_alt, 'size': 18.0, 'color': Colors.cyan.withOpacity(0.4)},
        ];
      case 4: // Cheshire Cat
        return [
          {'icon': Icons.visibility_off, 'size': 22.0, 'color': Colors.purple.withOpacity(0.6)},
          {'icon': Icons.pets, 'size': 20.0, 'color': Colors.pink.withOpacity(0.5)},
          {'icon': Icons.search, 'size': 18.0, 'color': Colors.green.withOpacity(0.4)},
        ];
      case 5: // Neighborhood
        return [
          {'icon': Icons.home, 'size': 24.0, 'color': Colors.orange.withOpacity(0.6)},
          {'icon': Icons.location_on, 'size': 20.0, 'color': Colors.red.withOpacity(0.5)},
          {'icon': Icons.family_restroom, 'size': 18.0, 'color': Colors.blue.withOpacity(0.4)},
        ];
      case 6: // Queen's Decree
        return [
          {'icon': Icons.gavel, 'size': 24.0, 'color': const Color(0xFFFFD700).withValues(alpha: 0.6)},
          {'icon': Icons.policy, 'size': 20.0, 'color': Colors.red.withOpacity(0.5)},
          {'icon': Icons.security, 'size': 18.0, 'color': Colors.white.withOpacity(0.4)},
        ];
      default:
        return [];
    }
  }
}

// Custom painters for different chapter backgrounds
class RabbitHolePainter extends CustomPainter {
  final double animation;

  RabbitHolePainter(this.animation);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    final center = Offset(size.width * 0.5, size.height * 0.3);

    // Draw spiral rabbit hole
    for (int i = 0; i < 8; i++) {
      final radius = 50.0 + (i * 30) + (20 * math.sin(animation * 2 * math.pi + i));
      paint.color = Colors.white.withOpacity(0.1 - (i * 0.01));
      canvas.drawCircle(center, radius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class WaterWavesPainter extends CustomPainter {
  final double animation;

  WaterWavesPainter(this.animation);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    for (int i = 0; i < 5; i++) {
      final path = Path();
      paint.color = Colors.blue.withOpacity(0.3 - (i * 0.05));

      for (double x = 0; x <= size.width; x += 5) {
        final y = size.height * 0.7 +
                  (20 * math.sin((x / 50) + animation * 2 * math.pi + i)) +
                  (i * 10);
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

class TeaPartyChaosPainter extends CustomPainter {
  final double animation;

  TeaPartyChaosPainter(this.animation);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;

    // Draw scattered playing cards
    for (int i = 0; i < 12; i++) {
      final x = (size.width / 4) * (i % 4) + (50 * math.sin(animation * 2 * math.pi + i));
      final y = (size.height / 3) * (i % 3) + (30 * math.cos(animation * 2 * math.pi + i));

      paint.color = (i % 2 == 0) ? Colors.red.withOpacity(0.2) : Colors.black.withOpacity(0.2);

      canvas.save();
      canvas.translate(x, y);
      canvas.rotate(animation * 2 * math.pi + i);
      canvas.drawRRect(
        RRect.fromLTRBR(-15, -20, 15, 20, const Radius.circular(4)),
        paint,
      );
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class MirrorEffectPainter extends CustomPainter {
  final double animation;

  MirrorEffectPainter(this.animation);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    // Draw mirror reflection lines
    final centerX = size.width * 0.5;

    for (int i = 0; i < 10; i++) {
      final offset = (i * 20) + (10 * math.sin(animation * 2 * math.pi + i));
      paint.color = Colors.white.withOpacity(0.2 - (i * 0.01));

      // Left side
      canvas.drawLine(
        Offset(centerX - offset, 0),
        Offset(centerX - offset, size.height),
        paint,
      );

      // Right side (mirrored)
      canvas.drawLine(
        Offset(centerX + offset, 0),
        Offset(centerX + offset, size.height),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class ForestShadowsPainter extends CustomPainter {
  final double animation;

  ForestShadowsPainter(this.animation);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;

    // Draw mysterious tree shadows
    for (int i = 0; i < 8; i++) {
      final x = (size.width / 8) * i;
      final height = 100 + (50 * math.sin(animation * math.pi + i));

      paint.color = Colors.black.withOpacity(0.1 + (0.1 * math.sin(animation * 2 * math.pi + i)));

      final path = Path();
      path.moveTo(x, size.height);
      path.lineTo(x + 20, size.height - height);
      path.lineTo(x + 40, size.height - height * 0.8);
      path.lineTo(x + 60, size.height);
      path.close();

      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class LocalWatersPainter extends CustomPainter {
  final double animation;

  LocalWatersPainter(this.animation);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    // Draw familiar coastline silhouette
    final path = Path();
    paint.color = Colors.white.withOpacity(0.3);

    for (double x = 0; x <= size.width; x += 10) {
      final y = size.height * 0.6 +
                (30 * math.sin((x / 100) + animation * math.pi)) +
                (15 * math.cos((x / 50) + animation * 2 * math.pi));
      if (x == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class RoyalGardenPainter extends CustomPainter {
  final double animation;

  RoyalGardenPainter(this.animation);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;

    // Draw organized garden pattern
    for (int row = 0; row < 4; row++) {
      for (int col = 0; col < 6; col++) {
        final x = (size.width / 6) * col + 30;
        final y = (size.height / 4) * row + 50;

        paint.color = ((row + col) % 2 == 0)
          ? Colors.red.withOpacity(0.2 + (0.1 * math.sin(animation * 2 * math.pi)))
          : Colors.white.withOpacity(0.1 + (0.1 * math.cos(animation * 2 * math.pi)));

        canvas.drawCircle(Offset(x, y), 15, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class TwinklingStarsPainter extends CustomPainter {
  final double animation;

  TwinklingStarsPainter(this.animation);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;

    final random = math.Random(42); // Fixed seed for consistent positions

    for (int i = 0; i < 20; i++) {
      final x = random.nextDouble() * size.width;
      final y = random.nextDouble() * size.height * 0.6; // Only in upper part

      final opacity = (0.3 + (0.7 * math.sin(animation * 2 * math.pi + i))).clamp(0.0, 1.0);
      paint.color = Colors.white.withOpacity(opacity);

      canvas.drawCircle(Offset(x, y), 1 + (1 * opacity), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}