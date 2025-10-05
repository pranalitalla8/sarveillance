import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/time_series_data.dart';

class TrendAnalysisCard extends StatelessWidget {
  final TrendAnalysis trendAnalysis;

  const TrendAnalysisCard({
    super.key,
    required this.trendAnalysis,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  _getTrendIcon(),
                  color: _getTrendColor(),
                  size: 32,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Overall Trend',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      Text(
                        trendAnalysis.description,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 16),
            Text(
              'Trend Confidence: ${(trendAnalysis.confidence * 100).toStringAsFixed(0)}%',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            LinearProgressIndicator(
              value: trendAnalysis.confidence,
              backgroundColor: Colors.grey[300],
              valueColor: AlwaysStoppedAnimation<Color>(_getTrendColor()),
            ),
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 16),
            Text(
              'Quarterly Breakdown',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            ...trendAnalysis.segments.asMap().entries.map((entry) {
              final index = entry.key;
              final segment = entry.value;
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _buildSegmentRow(context, 'Q${index + 1}', segment),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildSegmentRow(BuildContext context, String label, TrendSegment segment) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _getSegmentColor(segment.direction).withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: _getSegmentColor(segment.direction).withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: _getSegmentColor(segment.direction),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      _getDirectionIcon(segment.direction),
                      size: 16,
                      color: _getSegmentColor(segment.direction),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      _getDirectionText(segment.direction),
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: _getSegmentColor(segment.direction),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  '${DateFormat('MMM d').format(segment.startDate)} - ${DateFormat('MMM d').format(segment.endDate)}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${segment.slope >= 0 ? '+' : ''}${segment.slope.toStringAsFixed(2)}',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: _getSegmentColor(segment.direction),
                ),
              ),
              Text(
                'slope',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        ],
      ),
    );
  }

  IconData _getTrendIcon() {
    switch (trendAnalysis.direction) {
      case TrendDirection.increasing:
        return Icons.trending_up;
      case TrendDirection.decreasing:
        return Icons.trending_down;
      case TrendDirection.stable:
        return Icons.trending_flat;
    }
  }

  IconData _getDirectionIcon(TrendDirection direction) {
    switch (direction) {
      case TrendDirection.increasing:
        return Icons.arrow_upward;
      case TrendDirection.decreasing:
        return Icons.arrow_downward;
      case TrendDirection.stable:
        return Icons.remove;
    }
  }

  Color _getTrendColor() {
    switch (trendAnalysis.direction) {
      case TrendDirection.increasing:
        return Colors.red;
      case TrendDirection.decreasing:
        return Colors.green;
      case TrendDirection.stable:
        return Colors.blue;
    }
  }

  Color _getSegmentColor(TrendDirection direction) {
    switch (direction) {
      case TrendDirection.increasing:
        return Colors.red;
      case TrendDirection.decreasing:
        return Colors.green;
      case TrendDirection.stable:
        return Colors.grey;
    }
  }

  String _getDirectionText(TrendDirection direction) {
    switch (direction) {
      case TrendDirection.increasing:
        return 'Increasing';
      case TrendDirection.decreasing:
        return 'Decreasing';
      case TrendDirection.stable:
        return 'Stable';
    }
  }
}

