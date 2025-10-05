import 'dart:math';
import '../models/time_series_data.dart';

class TimeSeriesService {
  final Random _random = Random(42); // Fixed seed for consistent data

  /// Generate time series data for 548 dates (approximately 18 months)
  OilDetectionTimeSeries generateTimeSeriesData({
    int dataPoints = 548,
  }) {
    final endDate = DateTime.now();
    final startDate = endDate.subtract(Duration(days: dataPoints - 1));
    
    final dataPointsList = _generateDataPoints(startDate, endDate, dataPoints);
    final trendAnalysis = _analyzeTrend(dataPointsList);
    final seasonalAnalysis = _analyzeSeasonalPatterns(dataPointsList);
    final weatherCorrelations = _calculateWeatherCorrelations(dataPointsList);

    return OilDetectionTimeSeries(
      dataPoints: dataPointsList,
      startDate: startDate,
      endDate: endDate,
      trendAnalysis: trendAnalysis,
      seasonalAnalysis: seasonalAnalysis,
      weatherCorrelations: weatherCorrelations,
    );
  }

  List<OilDetectionDataPoint> _generateDataPoints(
    DateTime startDate,
    DateTime endDate,
    int count,
  ) {
    final points = <OilDetectionDataPoint>[];
    
    for (int i = 0; i < count; i++) {
      final date = startDate.add(Duration(days: i));
      final dayOfYear = _getDayOfYear(date);
      final month = date.month;
      
      // Base detection rate with seasonal variation
      double baseRate = 5.0;
      
      // Seasonal effects (higher in winter months, lower in summer)
      final seasonalFactor = 1.0 + 0.3 * sin((dayOfYear / 365.0) * 2 * pi - pi / 2);
      
      // Long-term trend (slight increase over time)
      final trendFactor = 1.0 + (i / count) * 0.4;
      
      // Weekly pattern (lower on weekends due to reporting)
      final dayOfWeek = date.weekday;
      final weekendFactor = (dayOfWeek == 6 || dayOfWeek == 7) ? 0.7 : 1.0;
      
      // Random variation
      final randomFactor = 0.8 + _random.nextDouble() * 0.4;
      
      // Calculate detection count
      final detectionCount = (baseRate * seasonalFactor * trendFactor * 
                             weekendFactor * randomFactor).round();
      
      // Calculate area based on detection count
      final totalArea = detectionCount * (0.5 + _random.nextDouble() * 2.0);
      
      // Confidence varies
      final confidence = 0.7 + _random.nextDouble() * 0.25;
      
      // Generate weather data
      final weather = _generateWeatherData(date, month);
      
      points.add(OilDetectionDataPoint(
        date: date,
        detectionCount: detectionCount,
        totalAreaKm2: totalArea,
        averageConfidence: confidence,
        weather: weather,
      ));
    }
    
    return points;
  }

  WeatherData _generateWeatherData(DateTime date, int month) {
    // Simulate realistic weather patterns
    final seasonalTemp = 15 + 10 * sin((month / 12.0) * 2 * pi - pi / 2);
    final temperature = seasonalTemp + (_random.nextDouble() - 0.5) * 5;
    
    // Wind speed tends to be higher in winter
    final baseWindSpeed = 15 + 10 * cos((month / 12.0) * 2 * pi);
    final windSpeed = baseWindSpeed + (_random.nextDouble() - 0.5) * 10;
    
    // Wave height correlates with wind speed
    final waveHeight = (windSpeed / 20.0) * (1 + _random.nextDouble() * 0.5);
    
    // Precipitation varies seasonally
    final precipitation = _random.nextDouble() < 0.3 
        ? _random.nextDouble() * 20 
        : 0.0;
    
    // Humidity
    final humidity = 60 + _random.nextDouble() * 30;
    
    // Pressure
    final pressure = 1010 + (_random.nextDouble() - 0.5) * 30;
    
    return WeatherData(
      windSpeed: windSpeed.clamp(0, 100),
      waveHeight: waveHeight.clamp(0, 10),
      temperature: temperature,
      precipitation: precipitation,
      humidity: humidity,
      pressure: pressure,
    );
  }

  TrendAnalysis _analyzeTrend(List<OilDetectionDataPoint> dataPoints) {
    // Calculate linear regression for trend
    final n = dataPoints.length;
    double sumX = 0, sumY = 0, sumXY = 0, sumX2 = 0;
    
    for (int i = 0; i < n; i++) {
      final x = i.toDouble();
      final y = dataPoints[i].detectionCount.toDouble();
      sumX += x;
      sumY += y;
      sumXY += x * y;
      sumX2 += x * x;
    }
    
    final slope = (n * sumXY - sumX * sumY) / (n * sumX2 - sumX * sumX);
    
    // Calculate change rate as percentage
    final firstQuarter = dataPoints.take(n ~/ 4)
        .fold(0, (sum, p) => sum + p.detectionCount) / (n ~/ 4);
    final lastQuarter = dataPoints.skip(3 * n ~/ 4)
        .fold(0, (sum, p) => sum + p.detectionCount) / (n ~/ 4);
    
    final changeRate = ((lastQuarter - firstQuarter) / firstQuarter) * 100;
    
    // Determine trend direction
    TrendDirection direction;
    if (changeRate > 5) {
      direction = TrendDirection.increasing;
    } else if (changeRate < -5) {
      direction = TrendDirection.decreasing;
    } else {
      direction = TrendDirection.stable;
    }
    
    // Create trend segments (quarterly)
    final segments = <TrendSegment>[];
    final segmentSize = n ~/ 4;
    
    for (int i = 0; i < 4; i++) {
      final startIdx = i * segmentSize;
      final endIdx = min((i + 1) * segmentSize, n);
      final segmentPoints = dataPoints.sublist(startIdx, endIdx);
      
      final avgFirst = segmentPoints.take(10)
          .fold(0, (sum, p) => sum + p.detectionCount) / 10;
      final avgLast = segmentPoints.skip(segmentPoints.length - 10)
          .fold(0, (sum, p) => sum + p.detectionCount) / 10;
      
      final segmentSlope = avgLast - avgFirst;
      
      segments.add(TrendSegment(
        startDate: segmentPoints.first.date,
        endDate: segmentPoints.last.date,
        direction: segmentSlope > 0.5 
            ? TrendDirection.increasing 
            : segmentSlope < -0.5 
                ? TrendDirection.decreasing 
                : TrendDirection.stable,
        slope: segmentSlope,
      ));
    }
    
    return TrendAnalysis(
      direction: direction,
      changeRate: changeRate,
      confidence: 0.85,
      segments: segments,
    );
  }

  SeasonalAnalysis _analyzeSeasonalPatterns(List<OilDetectionDataPoint> dataPoints) {
    // Calculate monthly averages
    final monthlyData = <int, List<int>>{};
    
    for (final point in dataPoints) {
      final month = point.date.month;
      monthlyData.putIfAbsent(month, () => []).add(point.detectionCount);
    }
    
    final monthlyAverages = monthlyData.map((month, detections) {
      final avg = detections.reduce((a, b) => a + b) / detections.length;
      return MapEntry(month, avg);
    });
    
    // Calculate seasonal patterns
    final seasonalPatterns = <Season, SeasonalPattern>{};
    
    // Spring (Mar, Apr, May)
    final springMonths = [3, 4, 5];
    final springAvg = _calculateSeasonalAverage(monthlyAverages, springMonths);
    seasonalPatterns[Season.spring] = SeasonalPattern(
      season: Season.spring,
      averageDetections: springAvg,
      peakDetections: _getPeakForMonths(dataPoints, springMonths),
      characteristics: [
        'Moderate detection rates',
        'Increasing shipping activity',
        'Variable weather patterns',
      ],
    );
    
    // Summer (Jun, Jul, Aug)
    final summerMonths = [6, 7, 8];
    final summerAvg = _calculateSeasonalAverage(monthlyAverages, summerMonths);
    seasonalPatterns[Season.summer] = SeasonalPattern(
      season: Season.summer,
      averageDetections: summerAvg,
      peakDetections: _getPeakForMonths(dataPoints, summerMonths),
      characteristics: [
        'Lower detection rates',
        'Calmer sea conditions',
        'Peak tourism season',
      ],
    );
    
    // Fall (Sep, Oct, Nov)
    final fallMonths = [9, 10, 11];
    final fallAvg = _calculateSeasonalAverage(monthlyAverages, fallMonths);
    seasonalPatterns[Season.fall] = SeasonalPattern(
      season: Season.fall,
      averageDetections: fallAvg,
      peakDetections: _getPeakForMonths(dataPoints, fallMonths),
      characteristics: [
        'Increasing detection rates',
        'More frequent storms',
        'Decreased visibility',
      ],
    );
    
    // Winter (Dec, Jan, Feb)
    final winterMonths = [12, 1, 2];
    final winterAvg = _calculateSeasonalAverage(monthlyAverages, winterMonths);
    seasonalPatterns[Season.winter] = SeasonalPattern(
      season: Season.winter,
      averageDetections: winterAvg,
      peakDetections: _getPeakForMonths(dataPoints, winterMonths),
      characteristics: [
        'Highest detection rates',
        'Rough sea conditions',
        'Reduced monitoring capacity',
      ],
    );
    
    // Determine dominant pattern
    final peakSeason = seasonalPatterns.entries
        .reduce((a, b) => a.value.averageDetections > b.value.averageDetections ? a : b)
        .key;
    
    return SeasonalAnalysis(
      patterns: seasonalPatterns,
      monthlyAverages: monthlyAverages,
      dominantPattern: 'Clear seasonal variation with peak in ${_seasonName(peakSeason)}',
    );
  }

  double _calculateSeasonalAverage(Map<int, double> monthlyAverages, List<int> months) {
    final values = months
        .where((m) => monthlyAverages.containsKey(m))
        .map((m) => monthlyAverages[m]!)
        .toList();
    
    return values.isEmpty ? 0 : values.reduce((a, b) => a + b) / values.length;
  }

  double _getPeakForMonths(List<OilDetectionDataPoint> dataPoints, List<int> months) {
    return dataPoints
        .where((p) => months.contains(p.date.month))
        .fold(0, (max, p) => p.detectionCount > max ? p.detectionCount : max)
        .toDouble();
  }

  String _seasonName(Season season) {
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

  List<WeatherCorrelation> _calculateWeatherCorrelations(
    List<OilDetectionDataPoint> dataPoints,
  ) {
    final correlations = <WeatherCorrelation>[];
    
    // Filter points with weather data
    final pointsWithWeather = dataPoints.where((p) => p.weather != null).toList();
    
    if (pointsWithWeather.isEmpty) return correlations;
    
    for (final param in WeatherParameter.values) {
      final correlation = _calculateCorrelation(
        pointsWithWeather.map((p) => p.detectionCount.toDouble()).toList(),
        pointsWithWeather.map((p) => p.weather!.getParameter(param)).toList(),
      );
      
      final strength = _getCorrelationStrength(correlation.abs());
      final interpretation = _interpretCorrelation(param, correlation, strength);
      
      correlations.add(WeatherCorrelation(
        parameter: param,
        correlationCoefficient: correlation,
        strength: strength,
        interpretation: interpretation,
      ));
    }
    
    // Sort by absolute correlation strength
    correlations.sort((a, b) => 
      b.correlationCoefficient.abs().compareTo(a.correlationCoefficient.abs()));
    
    return correlations;
  }

  double _calculateCorrelation(List<double> x, List<double> y) {
    if (x.length != y.length || x.isEmpty) return 0.0;
    
    final n = x.length;
    final meanX = x.reduce((a, b) => a + b) / n;
    final meanY = y.reduce((a, b) => a + b) / n;
    
    double numerator = 0;
    double denomX = 0;
    double denomY = 0;
    
    for (int i = 0; i < n; i++) {
      final diffX = x[i] - meanX;
      final diffY = y[i] - meanY;
      numerator += diffX * diffY;
      denomX += diffX * diffX;
      denomY += diffY * diffY;
    }
    
    if (denomX == 0 || denomY == 0) return 0.0;
    
    return numerator / sqrt(denomX * denomY);
  }

  CorrelationStrength _getCorrelationStrength(double absCorr) {
    if (absCorr >= 0.8) return CorrelationStrength.veryStrong;
    if (absCorr >= 0.6) return CorrelationStrength.strong;
    if (absCorr >= 0.4) return CorrelationStrength.moderate;
    if (absCorr >= 0.2) return CorrelationStrength.weak;
    if (absCorr >= 0.1) return CorrelationStrength.veryWeak;
    return CorrelationStrength.none;
  }

  String _interpretCorrelation(
    WeatherParameter param,
    double correlation,
    CorrelationStrength strength,
  ) {
    final absCorr = correlation.abs();
    final direction = correlation > 0 ? 'increases' : 'decreases';
    
    if (strength == CorrelationStrength.none || strength == CorrelationStrength.veryWeak) {
      return 'No significant correlation with oil spill detections';
    }
    
    return 'Oil spill detections ${direction} with higher ${param.displayName.toLowerCase()}. '
           '${_strengthDescription(strength)} correlation (${(absCorr * 100).toStringAsFixed(0)}%)';
  }

  String _strengthDescription(CorrelationStrength strength) {
    switch (strength) {
      case CorrelationStrength.veryStrong:
        return 'Very strong';
      case CorrelationStrength.strong:
        return 'Strong';
      case CorrelationStrength.moderate:
        return 'Moderate';
      case CorrelationStrength.weak:
        return 'Weak';
      case CorrelationStrength.veryWeak:
        return 'Very weak';
      case CorrelationStrength.none:
        return 'No';
    }
  }

  int _getDayOfYear(DateTime date) {
    final startOfYear = DateTime(date.year, 1, 1);
    return date.difference(startOfYear).inDays + 1;
  }
}

