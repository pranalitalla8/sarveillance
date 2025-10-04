import 'dart:math';
import 'package:latlong2/latlong.dart';

/// Represents a selectable region on the map
class MapRegion {
  final String id;
  final String name;
  final LatLng center;
  final List<LatLng> bounds; // Polygon bounds
  final double radiusKm; // For circular regions
  final RegionType type;
  final bool hasData;
  final DateTime? lastDataUpdate;
  final Map<String, dynamic> metadata;

  const MapRegion({
    required this.id,
    required this.name,
    required this.center,
    required this.bounds,
    this.radiusKm = 10.0,
    this.type = RegionType.circular,
    this.hasData = false,
    this.lastDataUpdate,
    this.metadata = const {},
  });

  MapRegion copyWith({
    String? id,
    String? name,
    LatLng? center,
    List<LatLng>? bounds,
    double? radiusKm,
    RegionType? type,
    bool? hasData,
    DateTime? lastDataUpdate,
    Map<String, dynamic>? metadata,
  }) {
    return MapRegion(
      id: id ?? this.id,
      name: name ?? this.name,
      center: center ?? this.center,
      bounds: bounds ?? this.bounds,
      radiusKm: radiusKm ?? this.radiusKm,
      type: type ?? this.type,
      hasData: hasData ?? this.hasData,
      lastDataUpdate: lastDataUpdate ?? this.lastDataUpdate,
      metadata: metadata ?? this.metadata,
    );
  }

  /// Create a circular region from a center point
  factory MapRegion.circular({
    required String id,
    required String name,
    required LatLng center,
    double radiusKm = 10.0,
  }) {
    // Generate approximate square bounds for the circle
    final latOffset = radiusKm / 111.0; // 1 degree lat ≈ 111 km
    final lonOffset = radiusKm / (111.0 * cos(center.latitude * pi / 180.0));
    
    final bounds = [
      LatLng(center.latitude + latOffset, center.longitude - lonOffset),
      LatLng(center.latitude + latOffset, center.longitude + lonOffset),
      LatLng(center.latitude - latOffset, center.longitude + lonOffset),
      LatLng(center.latitude - latOffset, center.longitude - lonOffset),
    ];

    return MapRegion(
      id: id,
      name: name,
      center: center,
      bounds: bounds,
      radiusKm: radiusKm,
      type: RegionType.circular,
    );
  }

  /// Create a rectangular region
  factory MapRegion.rectangle({
    required String id,
    required String name,
    required LatLng northWest,
    required LatLng southEast,
  }) {
    final bounds = [
      northWest,
      LatLng(northWest.latitude, southEast.longitude),
      southEast,
      LatLng(southEast.latitude, northWest.longitude),
    ];

    final center = LatLng(
      (northWest.latitude + southEast.latitude) / 2,
      (northWest.longitude + southEast.longitude) / 2,
    );

    return MapRegion(
      id: id,
      name: name,
      center: center,
      bounds: bounds,
      type: RegionType.rectangular,
    );
  }

  /// Create a custom polygon region
  factory MapRegion.polygon({
    required String id,
    required String name,
    required List<LatLng> bounds,
  }) {
    // Calculate center as average of all points
    double sumLat = 0;
    double sumLon = 0;
    for (final point in bounds) {
      sumLat += point.latitude;
      sumLon += point.longitude;
    }
    final center = LatLng(
      sumLat / bounds.length,
      sumLon / bounds.length,
    );

    return MapRegion(
      id: id,
      name: name,
      center: center,
      bounds: bounds,
      type: RegionType.polygon,
    );
  }
}

enum RegionType {
  circular,
  rectangular,
  polygon,
}

/// Data loaded for a specific region
class RegionData {
  final String regionId;
  final DateTime timestamp;
  final SarDataInfo? sarData;
  final OilSpillInfo? oilSpills;
  final ShipTrafficInfo? shipTraffic;
  final WaterQualityInfo? waterQuality;
  final LoadingStatus status;
  final String? errorMessage;

  const RegionData({
    required this.regionId,
    required this.timestamp,
    this.sarData,
    this.oilSpills,
    this.shipTraffic,
    this.waterQuality,
    this.status = LoadingStatus.idle,
    this.errorMessage,
  });

  RegionData copyWith({
    String? regionId,
    DateTime? timestamp,
    SarDataInfo? sarData,
    OilSpillInfo? oilSpills,
    ShipTrafficInfo? shipTraffic,
    WaterQualityInfo? waterQuality,
    LoadingStatus? status,
    String? errorMessage,
  }) {
    return RegionData(
      regionId: regionId ?? this.regionId,
      timestamp: timestamp ?? this.timestamp,
      sarData: sarData ?? this.sarData,
      oilSpills: oilSpills ?? this.oilSpills,
      shipTraffic: shipTraffic ?? this.shipTraffic,
      waterQuality: waterQuality ?? this.waterQuality,
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  bool get hasAnyData => 
    sarData != null || 
    oilSpills != null || 
    shipTraffic != null || 
    waterQuality != null;
}

enum LoadingStatus {
  idle,
  loading,
  loaded,
  error,
}

/// SAR data information for a region
class SarDataInfo {
  final String satellite; // Sentinel-1, NISAR, etc.
  final String frequency; // C-band, L-band, X-band
  final String polarization;
  final DateTime acquisitionDate;
  final int pixelCount;
  final String coverage; // percentage
  final String resolution; // in meters
  
  const SarDataInfo({
    required this.satellite,
    required this.frequency,
    required this.polarization,
    required this.acquisitionDate,
    required this.pixelCount,
    required this.coverage,
    required this.resolution,
  });
}

/// Oil spill detection information
class OilSpillInfo {
  final int spillCount;
  final double totalAreaKm2;
  final List<OilSpillDetection> detections;
  final String confidenceLevel;

  const OilSpillInfo({
    required this.spillCount,
    required this.totalAreaKm2,
    required this.detections,
    required this.confidenceLevel,
  });
}

class OilSpillDetection {
  final LatLng location;
  final double areaKm2;
  final String severity; // low, medium, high
  final DateTime detectedAt;

  const OilSpillDetection({
    required this.location,
    required this.areaKm2,
    required this.severity,
    required this.detectedAt,
  });
}

/// Ship traffic information
class ShipTrafficInfo {
  final int shipCount;
  final int suspiciousShips;
  final Map<String, int> shipTypes;
  final double averageSpeed;

  const ShipTrafficInfo({
    required this.shipCount,
    required this.suspiciousShips,
    required this.shipTypes,
    required this.averageSpeed,
  });
}

/// Water quality information
class WaterQualityInfo {
  final double? chlorophyllLevel;
  final double? turbidity;
  final double? temperature;
  final String qualityRating; // excellent, good, fair, poor

  const WaterQualityInfo({
    this.chlorophyllLevel,
    this.turbidity,
    this.temperature,
    required this.qualityRating,
  });
}

