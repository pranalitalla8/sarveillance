/// Models for time series analysis of oil detections

class OilDetectionTimeSeries {
  final List<OilDetectionDataPoint> dataPoints;
  final DateTime startDate;
  final DateTime endDate;
  final TrendAnalysis trendAnalysis;
  final SeasonalAnalysis seasonalAnalysis;
  final List<WeatherCorrelation> weatherCorrelations;

  OilDetectionTimeSeries({
    required this.dataPoints,
    required this.startDate,
    required this.endDate,
    required this.trendAnalysis,
    required this.seasonalAnalysis,
    required this.weatherCorrelations,
  });

  int get totalDetections => dataPoints.fold(0, (sum, point) => sum + point.detectionCount);
  
  double get averageDetectionsPerDay => totalDetections / dataPoints.length;
  
  int get maxDetections => dataPoints.fold(0, (max, point) => point.detectionCount > max ? point.detectionCount : max);
}

class OilDetectionDataPoint {
  final DateTime date;
  final int detectionCount;
  final double totalAreaKm2;
  final double averageConfidence;
  final WeatherData? weather;

  OilDetectionDataPoint({
    required this.date,
    required this.detectionCount,
    required this.totalAreaKm2,
    required this.averageConfidence,
    this.weather,
  });
}

class TrendAnalysis {
  final TrendDirection direction;
  final double changeRate; // Percentage change over period
  final double confidence; // Statistical confidence
  final List<TrendSegment> segments;

  TrendAnalysis({
    required this.direction,
    required this.changeRate,
    required this.confidence,
    required this.segments,
  });

  String get description {
    if (direction == TrendDirection.increasing) {
      return 'Oil spills increasing by ${changeRate.toStringAsFixed(1)}% over period';
    } else if (direction == TrendDirection.decreasing) {
      return 'Oil spills decreasing by ${changeRate.abs().toStringAsFixed(1)}% over period';
    } else {
      return 'Oil spills remain stable';
    }
  }
}

enum TrendDirection {
  increasing,
  decreasing,
  stable,
}

class TrendSegment {
  final DateTime startDate;
  final DateTime endDate;
  final TrendDirection direction;
  final double slope;

  TrendSegment({
    required this.startDate,
    required this.endDate,
    required this.direction,
    required this.slope,
  });
}

class SeasonalAnalysis {
  final Map<Season, SeasonalPattern> patterns;
  final Map<int, double> monthlyAverages; // Month number (1-12) to average detections
  final String dominantPattern;

  SeasonalAnalysis({
    required this.patterns,
    required this.monthlyAverages,
    required this.dominantPattern,
  });

  Season getPeakSeason() {
    var maxDetections = 0.0;
    var peakSeason = Season.spring;
    
    patterns.forEach((season, pattern) {
      if (pattern.averageDetections > maxDetections) {
        maxDetections = pattern.averageDetections;
        peakSeason = season;
      }
    });
    
    return peakSeason;
  }
}

class SeasonalPattern {
  final Season season;
  final double averageDetections;
  final double peakDetections;
  final List<String> characteristics;

  SeasonalPattern({
    required this.season,
    required this.averageDetections,
    required this.peakDetections,
    required this.characteristics,
  });
}

enum Season {
  spring,
  summer,
  fall,
  winter,
}

class WeatherCorrelation {
  final WeatherParameter parameter;
  final double correlationCoefficient; // -1 to 1
  final CorrelationStrength strength;
  final String interpretation;

  WeatherCorrelation({
    required this.parameter,
    required this.correlationCoefficient,
    required this.strength,
    required this.interpretation,
  });
}

enum WeatherParameter {
  windSpeed,
  waveHeight,
  temperature,
  precipitation,
  humidity,
  pressure,
}

enum CorrelationStrength {
  veryStrong,
  strong,
  moderate,
  weak,
  veryWeak,
  none,
}

extension WeatherParameterExtension on WeatherParameter {
  String get displayName {
    switch (this) {
      case WeatherParameter.windSpeed:
        return 'Wind Speed';
      case WeatherParameter.waveHeight:
        return 'Wave Height';
      case WeatherParameter.temperature:
        return 'Temperature';
      case WeatherParameter.precipitation:
        return 'Precipitation';
      case WeatherParameter.humidity:
        return 'Humidity';
      case WeatherParameter.pressure:
        return 'Pressure';
    }
  }

  String get unit {
    switch (this) {
      case WeatherParameter.windSpeed:
        return 'km/h';
      case WeatherParameter.waveHeight:
        return 'm';
      case WeatherParameter.temperature:
        return '°C';
      case WeatherParameter.precipitation:
        return 'mm';
      case WeatherParameter.humidity:
        return '%';
      case WeatherParameter.pressure:
        return 'hPa';
    }
  }
}

class WeatherData {
  final double windSpeed;
  final double waveHeight;
  final double temperature;
  final double precipitation;
  final double humidity;
  final double pressure;

  WeatherData({
    required this.windSpeed,
    required this.waveHeight,
    required this.temperature,
    required this.precipitation,
    required this.humidity,
    required this.pressure,
  });

  double getParameter(WeatherParameter param) {
    switch (param) {
      case WeatherParameter.windSpeed:
        return windSpeed;
      case WeatherParameter.waveHeight:
        return waveHeight;
      case WeatherParameter.temperature:
        return temperature;
      case WeatherParameter.precipitation:
        return precipitation;
      case WeatherParameter.humidity:
        return humidity;
      case WeatherParameter.pressure:
        return pressure;
    }
  }
}

