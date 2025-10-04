import 'package:flutter/material.dart';

class SarViewer extends StatefulWidget {
  const SarViewer({super.key});

  @override
  State<SarViewer> createState() => _SarViewerState();
}

class _SarViewerState extends State<SarViewer> {
  double _zoom = 1.0;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: RadialGradient(
          center: const Alignment(0.3, -0.3),
          radius: 1.5,
          colors: [
            const Color(0xFF1E293B),
            const Color(0xFF0F172A),
            Colors.black,
          ],
        ),
      ),
      child: Stack(
        children: [
          Positioned.fill(
            child: InteractiveViewer(
              minScale: 0.5,
              maxScale: 10.0,
              onInteractionUpdate: (details) {
                setState(() {
                  _zoom = details.scale;
                });
              },
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF1E293B),
                  border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
                ),
                child: Stack(
                  children: [
                    const Center(
                      child: Text(
                        'SAR Data Visualization\n\n📡\n\nInteractive Viewer',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Color(0xFF64748B),
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    _buildGridOverlay(),
                    _buildDataPoints(),
                    _buildAnnotations(),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            top: 16,
            right: 16,
            child: _buildStatusBar(),
          ),
        ],
      ),
    );
  }

  Widget _buildGridOverlay() {
    return CustomPaint(
      painter: GridPainter(),
      size: Size.infinite,
    );
  }

  Widget _buildDataPoints() {
    return Stack(
      children: [
        Positioned(
          top: 150,
          left: 200,
          child: _buildDataPoint('High Intensity', Colors.red),
        ),
        Positioned(
          top: 300,
          left: 400,
          child: _buildDataPoint('Medium Intensity', Colors.orange),
        ),
        Positioned(
          top: 450,
          left: 150,
          child: _buildDataPoint('Low Intensity', Colors.green),
        ),
      ],
    );
  }

  Widget _buildDataPoint(String label, Color color) {
    return Container(
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
    );
  }

  Widget _buildAnnotations() {
    return Stack(
      children: [
        Positioned(
          top: 100,
          left: 300,
          child: _buildAnnotation('Damaged Infrastructure'),
        ),
        Positioned(
          top: 400,
          left: 500,
          child: _buildAnnotation('Flooded Area'),
        ),
      ],
    );
  }

  Widget _buildAnnotation(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Theme.of(context).colorScheme.primary, width: 1),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }


  Widget _buildStatusBar() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.location_on, size: 12),
                const SizedBox(width: 2),
                Text(
                  '28.54°N, 81.38°W',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
            const SizedBox(height: 2),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.zoom_in, size: 12),
                const SizedBox(width: 2),
                Text(
                  '1:${(50000 / _zoom).toInt()}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.1)
      ..strokeWidth = 0.5;

    const gridSpacing = 50.0;

    for (double x = 0; x < size.width; x += gridSpacing) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }

    for (double y = 0; y < size.height; y += gridSpacing) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}