import 'package:flutter/material.dart';
import '../models/time_series_data.dart';

class SeasonalPatternCard extends StatelessWidget {
  final SeasonalAnalysis seasonalAnalysis;

  const SeasonalPatternCard({
    super.key,
    required this.seasonalAnalysis,
  });

  @override
  Widget build(BuildContext context) {
    final peakSeason = seasonalAnalysis.getPeakSeason();

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
                  Icons.calendar_today,
                  color: Theme.of(context).colorScheme.primary,
                  size: 32,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Seasonal Patterns',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      Text(
                        seasonalAnalysis.dominantPattern,
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
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: _getSeasonColor(peakSeason).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: _getSeasonColor(peakSeason).withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    _getSeasonIcon(peakSeason),
                    color: _getSeasonColor(peakSeason),
                    size: 32,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Peak Season',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                        Text(
                          _getSeasonName(peakSeason),
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: _getSeasonColor(peakSeason),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    '${seasonalAnalysis.patterns[peakSeason]!.averageDetections.toStringAsFixed(1)} avg',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: _getSeasonColor(peakSeason),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 16),
            Text(
              'Seasonal Details',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            ...Season.values.map((season) {
              final pattern = seasonalAnalysis.patterns[season]!;
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _buildSeasonRow(context, season, pattern),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildSeasonRow(BuildContext context, Season season, SeasonalPattern pattern) {
    return ExpansionTile(
      leading: Icon(
        _getSeasonIcon(season),
        color: _getSeasonColor(season),
      ),
      title: Text(_getSeasonName(season)),
      subtitle: Text('Average: ${pattern.averageDetections.toStringAsFixed(1)} detections/day'),
      trailing: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: _getSeasonColor(season).withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          '${pattern.peakDetections.toInt()} peak',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: _getSeasonColor(season),
          ),
        ),
      ),
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Characteristics:',
                style: Theme.of(context).textTheme.titleSmall,
              ),
              const SizedBox(height: 8),
              ...pattern.characteristics.map((char) => Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Row(
                  children: [
                    Icon(
                      Icons.fiber_manual_record,
                      size: 8,
                      color: _getSeasonColor(season),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        char,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ),
                  ],
                ),
              )),
            ],
          ),
        ),
      ],
    );
  }

  String _getSeasonName(Season season) {
    switch (season) {
      case Season.spring:
        return 'Spring';
      case Season.summer:
        return 'Summer';
      case Season.fall:
        return 'Fall';
      case Season.winter:
        return 'Winter';
    }
  }

  IconData _getSeasonIcon(Season season) {
    switch (season) {
      case Season.spring:
        return Icons.local_florist;
      case Season.summer:
        return Icons.wb_sunny;
      case Season.fall:
        return Icons.nature;
      case Season.winter:
        return Icons.ac_unit;
    }
  }

  Color _getSeasonColor(Season season) {
    switch (season) {
      case Season.spring:
        return Colors.green;
      case Season.summer:
        return Colors.orange;
      case Season.fall:
        return Colors.brown;
      case Season.winter:
        return Colors.blue;
    }
  }
}

