import 'package:flutter/material.dart';
import '../models/time_series_data.dart';

class WeatherCorrelationCard extends StatelessWidget {
  final List<WeatherCorrelation> correlations;

  const WeatherCorrelationCard({
    super.key,
    required this.correlations,
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
                  Icons.cloud,
                  color: Theme.of(context).colorScheme.primary,
                  size: 32,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Weather Correlations',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      Text(
                        'Impact of weather on oil spill detections',
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
              'Correlation Strength',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            ...correlations.map((correlation) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _buildCorrelationRow(context, correlation),
              );
            }),
            const SizedBox(height: 8),
            _buildCorrelationLegend(context),
          ],
        ),
      ),
    );
  }

  Widget _buildCorrelationRow(BuildContext context, WeatherCorrelation correlation) {
    final absCorr = correlation.correlationCoefficient.abs();
    final isPositive = correlation.correlationCoefficient > 0;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _getStrengthColor(correlation.strength).withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: _getStrengthColor(correlation.strength).withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                _getWeatherIcon(correlation.parameter),
                color: _getStrengthColor(correlation.strength),
                size: 24,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  correlation.parameter.displayName,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Icon(
                isPositive ? Icons.arrow_upward : Icons.arrow_downward,
                size: 16,
                color: isPositive ? Colors.red : Colors.green,
              ),
              const SizedBox(width: 4),
              Text(
                '${(absCorr * 100).toStringAsFixed(0)}%',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: _getStrengthColor(correlation.strength),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: absCorr,
            backgroundColor: Colors.grey[300],
            valueColor: AlwaysStoppedAnimation<Color>(
              _getStrengthColor(correlation.strength),
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: _getStrengthColor(correlation.strength).withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              _getStrengthLabel(correlation.strength),
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: _getStrengthColor(correlation.strength),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            correlation.interpretation,
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }

  Widget _buildCorrelationLegend(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Understanding Correlation',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          _buildLegendItem(
            context,
            Icons.arrow_upward,
            Colors.red,
            'Positive correlation: detections increase with parameter',
          ),
          const SizedBox(height: 4),
          _buildLegendItem(
            context,
            Icons.arrow_downward,
            Colors.green,
            'Negative correlation: detections decrease with parameter',
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem(BuildContext context, IconData icon, Color color, String text) {
    return Row(
      children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ),
      ],
    );
  }

  IconData _getWeatherIcon(WeatherParameter parameter) {
    switch (parameter) {
      case WeatherParameter.windSpeed:
        return Icons.air;
      case WeatherParameter.waveHeight:
        return Icons.waves;
      case WeatherParameter.temperature:
        return Icons.thermostat;
      case WeatherParameter.precipitation:
        return Icons.water_drop;
      case WeatherParameter.humidity:
        return Icons.opacity;
      case WeatherParameter.pressure:
        return Icons.compress;
    }
  }

  Color _getStrengthColor(CorrelationStrength strength) {
    switch (strength) {
      case CorrelationStrength.veryStrong:
        return Colors.green[700]!;
      case CorrelationStrength.strong:
        return Colors.green;
      case CorrelationStrength.moderate:
        return Colors.orange;
      case CorrelationStrength.weak:
        return Colors.red[300]!;
      case CorrelationStrength.veryWeak:
        return Colors.red[200]!;
      case CorrelationStrength.none:
        return Colors.grey;
    }
  }

  String _getStrengthLabel(CorrelationStrength strength) {
    switch (strength) {
      case CorrelationStrength.veryStrong:
        return 'VERY STRONG';
      case CorrelationStrength.strong:
        return 'STRONG';
      case CorrelationStrength.moderate:
        return 'MODERATE';
      case CorrelationStrength.weak:
        return 'WEAK';
      case CorrelationStrength.veryWeak:
        return 'VERY WEAK';
      case CorrelationStrength.none:
        return 'NONE';
    }
  }
}

