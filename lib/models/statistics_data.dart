import 'package:latlong2/latlong.dart';

/// Statistics dashboard data models

class OilSpillStatistics {
  final int totalOilCandidates;
  final int totalWaterPoints;
  final int shipRelatedSpills;
  final double averageConfidence;
  final Map<String, int> yearlyBreakdown;
  final Map<String, int> monthlyBreakdown;
  final List<HotspotArea> hotspots;
  final ShipCorrelationStats shipStats;
  final WeatherCorrelationStats weatherStats;
  final List<TrendDataPoint> trendData;

  OilSpillStatistics({
    required this.totalOilCandidates,
    required this.totalWaterPoints,
    required this.shipRelatedSpills,
    required this.averageConfidence,
    required this.yearlyBreakdown,
    required this.monthlyBreakdown,
    required this.hotspots,
    required this.shipStats,
    required this.weatherStats,
    required this.trendData,
  });

  double get shipCorrelationPercentage => 
      totalOilCandidates > 0 ? (shipRelatedSpills / totalOilCandidates) * 100 : 0;

  int get totalDataPoints => totalOilCandidates + totalWaterPoints;
}

class HotspotArea {
  final String name;
  final LatLng center;
  final int spillCount;
  final double radiusKm;
  final String riskLevel; // low, medium, high, critical
  final List<String> characteristics;

  HotspotArea({
    required this.name,
    required this.center,
    required this.spillCount,
    required this.radiusKm,
    required this.riskLevel,
    required this.characteristics,
  });

  String get riskDescription {
    switch (riskLevel.toLowerCase()) {
      case 'critical':
        return 'Critical - Immediate attention required';
      case 'high':
        return 'High Risk - Frequent spills detected';
      case 'medium':
        return 'Medium Risk - Monitor closely';
      case 'low':
        return 'Low Risk - Occasional spills';
      default:
        return 'Unknown risk level';
    }
  }
}

class ShipCorrelationStats {
  final int totalShipRelatedSpills;
  final int totalShipsDetected;
  final double correlationStrength; // 0-1
  final Map<String, int> spillsByShipType;
  final List<String> topViolationAreas;
  final double averageDistanceToShip; // km

  ShipCorrelationStats({
    required this.totalShipRelatedSpills,
    required this.totalShipsDetected,
    required this.correlationStrength,
    required this.spillsByShipType,
    required this.topViolationAreas,
    required this.averageDistanceToShip,
  });

  String get correlationStrengthDescription {
    if (correlationStrength >= 0.8) return 'Very Strong';
    if (correlationStrength >= 0.6) return 'Strong';
    if (correlationStrength >= 0.4) return 'Moderate';
    if (correlationStrength >= 0.2) return 'Weak';
    return 'Very Weak';
  }
}

class WeatherCorrelationStats {
  final Map<String, double> parameterCorrelations;
  final String dominantFactor;
  final List<WeatherPattern> patterns;

  WeatherCorrelationStats({
    required this.parameterCorrelations,
    required this.dominantFactor,
    required this.patterns,
  });

  double getCorrelation(String parameter) {
    return parameterCorrelations[parameter] ?? 0.0;
  }
}

class WeatherPattern {
  final String name;
  final String description;
  final double frequency; // 0-1
  final int spillsAssociated;

  WeatherPattern({
    required this.name,
    required this.description,
    required this.frequency,
    required this.spillsAssociated,
  });
}

class TrendDataPoint {
  final DateTime date;
  final int spillCount;
  final int shipCount;

  TrendDataPoint({
    required this.date,
    required this.spillCount,
    required this.shipCount,
  });
}

enum RiskLevel {
  low,
  medium,
  high,
  critical,
}

extension RiskLevelExtension on RiskLevel {
  String get displayName {
    switch (this) {
      case RiskLevel.low:
        return 'Low';
      case RiskLevel.medium:
        return 'Medium';
      case RiskLevel.high:
        return 'High';
      case RiskLevel.critical:
        return 'Critical';
    }
  }
}

