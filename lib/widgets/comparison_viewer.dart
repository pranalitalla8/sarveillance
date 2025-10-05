import 'package:flutter/material.dart';

class ComparisonViewer extends StatelessWidget {
  final String mode;
  final double sliderPosition;
  final Function(double) onSliderChanged;
  final String leftDataset;
  final String rightDataset;

  const ComparisonViewer({
    super.key,
    required this.mode,
    required this.sliderPosition,
    required this.onSliderChanged,
    required this.leftDataset,
    required this.rightDataset,
  });

  @override
  Widget build(BuildContext context) {
    switch (mode) {
      case 'side_by_side':
        return _buildSideBySideView(context);
      case 'overlay':
        return _buildOverlayView(context);
      case 'swipe':
        return _buildSwipeView(context);
      case 'difference':
        return _buildDifferenceView(context);
      default:
        return _buildSideBySideView(context);
    }
  }

  Widget _buildSideBySideView(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _buildImagePanel(context, leftDataset, 'Before'),
        ),
        Container(
          width: 2,
          color: Theme.of(context).colorScheme.primary,
        ),
        Expanded(
          child: _buildImagePanel(context, rightDataset, 'After'),
        ),
      ],
    );
  }

  Widget _buildOverlayView(BuildContext context) {
    return Stack(
      children: [
        _buildImagePanel(context, leftDataset, 'Base Layer'),
        Opacity(
          opacity: sliderPosition,
          child: _buildImagePanel(context, rightDataset, 'Overlay Layer'),
        ),
        Positioned(
          bottom: 20,
          left: 20,
          right: 20,
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Overlay Opacity',
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  Slider(
                    value: sliderPosition,
                    onChanged: onSliderChanged,
                    min: 0.0,
                    max: 1.0,
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSwipeView(BuildContext context) {
    return Stack(
      children: [
        _buildImagePanel(context, leftDataset, 'Before'),
        ClipRect(
          child: Align(
            alignment: Alignment.centerLeft,
            widthFactor: sliderPosition,
            child: _buildImagePanel(context, rightDataset, 'After'),
          ),
        ),
        Positioned(
          left: MediaQuery.of(context).size.width * sliderPosition - 2,
          top: 0,
          bottom: 80,
          child: Container(
            width: 4,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.3),
                  blurRadius: 4,
                  spreadRadius: 1,
                ),
              ],
            ),
          ),
        ),
        Positioned(
          bottom: 20,
          left: 20,
          right: 20,
          child: Card(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Slider(
                value: sliderPosition,
                onChanged: onSliderChanged,
                min: 0.0,
                max: 1.0,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDifferenceView(BuildContext context) {
    return Stack(
      children: [
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFF1E293B),
                Color(0xFF0F172A),
              ],
            ),
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 200,
                  height: 200,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    gradient: const LinearGradient(
                      colors: [Colors.red, Colors.yellow, Colors.green],
                      stops: [0.0, 0.5, 1.0],
                    ),
                  ),
                  child: const Center(
                    child: Text(
                      'Change\nDetection\nHeatmap',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'Difference Analysis',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Red: High change, Yellow: Medium change, Green: No change',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.white.withValues(alpha: 0.8),
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
        Positioned(
          top: 20,
          right: 20,
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Statistics',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  _buildStatItem('Changed Pixels', '23.4%'),
                  _buildStatItem('Correlation', '0.78'),
                  _buildStatItem('RMSE', '0.12'),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildImagePanel(BuildContext context, String dataset, String label) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            _getDatasetColor(dataset).withValues(alpha: 0.8),
            _getDatasetColor(dataset).withValues(alpha: 0.4),
          ],
        ),
      ),
      child: Stack(
        children: [
          const Center(
            child: Icon(
              Icons.satellite_alt,
              size: 48,
              color: Colors.white54,
            ),
          ),
          Positioned(
            top: 16,
            left: 16,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.7),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 16,
            left: 16,
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.7),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _getDatasetTitle(dataset),
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _getDatasetDate(dataset),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Text(
            '$label: ',
            style: const TextStyle(fontSize: 12),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Color _getDatasetColor(String dataset) {
    switch (dataset) {
      case 'before':
        return const Color(0xFF059669);
      case 'during':
        return const Color(0xFFf59e0b);
      case 'after':
        return const Color(0xFFdc2626);
      case 'recovery':
        return const Color(0xFF0891b2);
      default:
        return const Color(0xFF6b7280);
    }
  }


  String _getDatasetTitle(String dataset) {
    switch (dataset) {
      case 'before':
        return 'Winter Baseline';
      case 'during':
        return 'Spring Period';
      case 'after':
        return 'Summer Low';
      case 'recovery':
        return 'Current Status';
      default:
        return 'Unknown';
    }
  }

  String _getDatasetDate(String dataset) {
    switch (dataset) {
      case 'before':
        return 'Jan 15, 2024';
      case 'during':
        return 'Apr 20, 2024';
      case 'after':
        return 'Jul 10, 2024';
      case 'recovery':
        return 'Oct 5, 2024';
      default:
        return 'Unknown';
    }
  }
}