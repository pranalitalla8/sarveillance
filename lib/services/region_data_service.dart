import 'dart:math';
import 'package:latlong2/latlong.dart';
import '../models/map_region.dart';

/// Service for loading data for selected map regions
class RegionDataService {
  // Singleton pattern
  static final RegionDataService _instance = RegionDataService._internal();
  factory RegionDataService() => _instance;
  RegionDataService._internal();

  final _random = Random();

  /// Load data for a selected region
  /// In production, this would call NASA APIs, SAR data services, etc.
  Future<RegionData> loadRegionData(MapRegion region) async {
    // Simulate API call delay
    await Future.delayed(const Duration(seconds: 2));

    // Simulate random data loading
    final hasOilSpills = _random.nextBool();
    final hasSuspiciousShips = _random.nextInt(10) > 7;

    return RegionData(
      regionId: region.id,
      timestamp: DateTime.now(),
      sarData: _generateMockSarData(region),
      oilSpills: hasOilSpills ? _generateMockOilSpillData(region) : null,
      shipTraffic: _generateMockShipTrafficData(region, hasSuspiciousShips),
      waterQuality: _generateMockWaterQualityData(),
      status: LoadingStatus.loaded,
    );
  }

  /// Generate mock SAR data
  SarDataInfo _generateMockSarData(MapRegion region) {
    final satellites = ['Sentinel-1A', 'Sentinel-1B', 'NISAR', 'RADARSAT-2'];
    final frequencies = ['C-band', 'L-band', 'X-band'];
    final polarizations = ['VV', 'VH', 'HH', 'HV'];

    return SarDataInfo(
      satellite: satellites[_random.nextInt(satellites.length)],
      frequency: frequencies[_random.nextInt(frequencies.length)],
      polarization: polarizations[_random.nextInt(polarizations.length)],
      acquisitionDate: DateTime.now().subtract(
        Duration(days: _random.nextInt(7)),
      ),
      pixelCount: 50000 + _random.nextInt(150000),
      coverage: '${85 + _random.nextInt(15)}%',
      resolution: '${5 + _random.nextInt(15)}m',
    );
  }

  /// Generate mock oil spill data
  OilSpillInfo _generateMockOilSpillData(MapRegion region) {
    final spillCount = 1 + _random.nextInt(3);
    final detections = List.generate(
      spillCount,
      (index) => OilSpillDetection(
        location: _randomPointNear(region.center),
        areaKm2: 0.5 + _random.nextDouble() * 2.5,
        severity: ['low', 'medium', 'high'][_random.nextInt(3)],
        detectedAt: DateTime.now().subtract(
          Duration(hours: _random.nextInt(48)),
        ),
      ),
    );

    final totalArea = detections.fold<double>(
      0.0,
      (sum, detection) => sum + detection.areaKm2,
    );

    return OilSpillInfo(
      spillCount: spillCount,
      totalAreaKm2: totalArea,
      detections: detections,
      confidenceLevel: ['High', 'Medium', 'Very High'][_random.nextInt(3)],
    );
  }

  /// Generate mock ship traffic data
  ShipTrafficInfo _generateMockShipTrafficData(
    MapRegion region,
    bool hasSuspicious,
  ) {
    final shipCount = 5 + _random.nextInt(20);
    final suspiciousCount = hasSuspicious ? 1 + _random.nextInt(3) : 0;

    return ShipTrafficInfo(
      shipCount: shipCount,
      suspiciousShips: suspiciousCount,
      shipTypes: {
        'Cargo': 2 + _random.nextInt(5),
        'Fishing': 1 + _random.nextInt(4),
        'Tanker': _random.nextInt(3),
        'Passenger': _random.nextInt(2),
      },
      averageSpeed: 5.0 + _random.nextDouble() * 10.0,
    );
  }

  /// Generate mock water quality data
  WaterQualityInfo _generateMockWaterQualityData() {
    final ratings = ['excellent', 'good', 'fair', 'poor'];
    
    return WaterQualityInfo(
      chlorophyllLevel: 2.0 + _random.nextDouble() * 8.0,
      turbidity: 10.0 + _random.nextDouble() * 30.0,
      temperature: 15.0 + _random.nextDouble() * 10.0,
      qualityRating: ratings[_random.nextInt(ratings.length)],
    );
  }

  /// Generate a random point near a center location
  LatLng _randomPointNear(LatLng center) {
    final latOffset = (_random.nextDouble() - 0.5) * 0.1;
    final lonOffset = (_random.nextDouble() - 0.5) * 0.1;
    
    return LatLng(
      center.latitude + latOffset,
      center.longitude + lonOffset,
    );
  }

  /// Get pre-defined regions of interest in the Chesapeake Bay area
  List<MapRegion> getPredefinedRegions() {
    return [
      MapRegion.circular(
        id: 'chesapeake_north',
        name: 'Northern Chesapeake Bay',
        center: const LatLng(39.2, -76.2),
        radiusKm: 15.0,
      ),
      MapRegion.circular(
        id: 'chesapeake_central',
        name: 'Central Chesapeake Bay',
        center: const LatLng(38.5, -76.3),
        radiusKm: 20.0,
      ),
      MapRegion.circular(
        id: 'chesapeake_south',
        name: 'Southern Chesapeake Bay',
        center: const LatLng(37.2, -76.0),
        radiusKm: 15.0,
      ),
      MapRegion.circular(
        id: 'baltimore_harbor',
        name: 'Baltimore Harbor',
        center: const LatLng(39.2847, -76.6205),
        radiusKm: 8.0,
      ),
      MapRegion.circular(
        id: 'potomac_river',
        name: 'Potomac River',
        center: const LatLng(38.9047, -77.0647),
        radiusKm: 10.0,
      ),
    ];
  }
}

