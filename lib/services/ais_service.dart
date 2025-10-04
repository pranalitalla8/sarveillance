import 'package:latlong2/latlong.dart';
import '../models/ais_ship.dart';

/// Service for fetching and managing AIS ship tracking data
class AisService {
  // Singleton pattern
  static final AisService _instance = AisService._internal();
  factory AisService() => _instance;
  AisService._internal();

  /// Fetch AIS data for a given area
  /// In production, this would call a real AIS API like MarineTraffic, VesselFinder, or NASA's own data
  Future<List<AisShip>> fetchShipsInArea({
    required LatLng center,
    required double radiusKm,
    AisFilter? filter,
  }) async {
    // Simulate API delay
    await Future.delayed(const Duration(milliseconds: 500));

    // Generate mock AIS data for Chesapeake Bay area
    final ships = _generateMockAisData(center);

    // Apply filter if provided
    if (filter != null) {
      return ships.where((ship) => filter.matches(ship)).toList();
    }

    return ships;
  }

  /// Generate mock AIS data for demonstration
  /// In production, replace with actual API calls
  List<AisShip> _generateMockAisData(LatLng center) {
    final now = DateTime.now();
    
    return [
      // Cargo ships
      AisShip(
        mmsi: '367123456',
        shipName: 'ATLANTIC TRADER',
        shipType: 'cargo',
        position: LatLng(37.85, -76.15),
        speed: 12.5,
        course: 45.0,
        heading: 47.0,
        status: 'underway',
        timestamp: now.subtract(const Duration(minutes: 5)),
        length: 185.0,
        width: 28.0,
        destination: 'BALTIMORE',
        callSign: 'WDF5678',
        flag: 'USA',
        isSuspicious: false,
      ),
      AisShip(
        mmsi: '235987654',
        shipName: 'CHESAPEAKE EXPRESS',
        shipType: 'cargo',
        position: LatLng(37.75, -76.05),
        speed: 8.2,
        course: 180.0,
        heading: 182.0,
        status: 'underway',
        timestamp: now.subtract(const Duration(minutes: 3)),
        length: 120.0,
        width: 20.0,
        destination: 'NORFOLK',
        callSign: 'GBZK',
        flag: 'UK',
        isSuspicious: false,
      ),
      
      // Tanker (suspicious)
      AisShip(
        mmsi: '477234567',
        shipName: 'OCEAN PHANTOM',
        shipType: 'tanker',
        position: LatLng(37.70, -76.20),
        speed: 2.1,
        course: 90.0,
        heading: 85.0,
        status: 'underway',
        timestamp: now.subtract(const Duration(minutes: 45)),
        length: 145.0,
        width: 22.0,
        destination: 'UNKNOWN',
        callSign: 'VRTY9',
        flag: 'HK',
        isSuspicious: true, // Suspicious: slow speed, unknown destination
      ),
      
      // Fishing vessels
      AisShip(
        mmsi: '368456789',
        shipName: 'MARY ANN',
        shipType: 'fishing',
        position: LatLng(37.82, -76.08),
        speed: 3.5,
        course: 270.0,
        heading: 268.0,
        status: 'underway',
        timestamp: now.subtract(const Duration(minutes: 8)),
        length: 25.0,
        width: 8.0,
        callSign: 'WDL2345',
        flag: 'USA',
        isSuspicious: false,
      ),
      AisShip(
        mmsi: '368567890',
        shipName: 'BLUE CRAB',
        shipType: 'fishing',
        position: LatLng(37.88, -76.12),
        speed: 0.2,
        course: null,
        heading: 135.0,
        status: 'anchored',
        timestamp: now.subtract(const Duration(minutes: 20)),
        length: 18.0,
        width: 6.0,
        callSign: 'WDL3456',
        flag: 'USA',
        isSuspicious: false,
      ),
      
      // Passenger vessel
      AisShip(
        mmsi: '366789012',
        shipName: 'BAY QUEEN',
        shipType: 'passenger',
        position: LatLng(37.78, -76.18),
        speed: 15.8,
        course: 315.0,
        heading: 315.0,
        status: 'underway',
        timestamp: now.subtract(const Duration(minutes: 2)),
        length: 65.0,
        width: 12.0,
        destination: 'ANNAPOLIS',
        callSign: 'WDE4567',
        flag: 'USA',
        isSuspicious: false,
      ),
      
      // Suspicious fishing vessel (no AIS for extended period)
      AisShip(
        mmsi: '412345678',
        shipName: 'GHOST NET',
        shipType: 'fishing',
        position: LatLng(37.65, -76.25),
        speed: 4.5,
        course: 180.0,
        heading: 180.0,
        status: 'underway',
        timestamp: now.subtract(const Duration(hours: 3)), // Stale data
        length: 30.0,
        width: 10.0,
        callSign: 'VRT456',
        flag: 'Unknown',
        isSuspicious: true, // Suspicious: intermittent AIS signal
      ),
      
      // Tug boat
      AisShip(
        mmsi: '367890123',
        shipName: 'CHESAPEAKE TUG',
        shipType: 'tug',
        position: LatLng(37.72, -76.10),
        speed: 6.0,
        course: 45.0,
        heading: 45.0,
        status: 'underway',
        timestamp: now.subtract(const Duration(minutes: 1)),
        length: 28.0,
        width: 9.0,
        callSign: 'WDF6789',
        flag: 'USA',
        isSuspicious: false,
      ),
      
      // Another suspicious vessel (AIS turned off in protected area)
      AisShip(
        mmsi: '412999888',
        shipName: 'DARK STAR',
        shipType: 'cargo',
        position: LatLng(37.90, -76.05),
        speed: 0.5,
        course: null,
        heading: 180.0,
        status: 'not_under_command',
        timestamp: now.subtract(const Duration(minutes: 90)),
        length: 95.0,
        width: 18.0,
        destination: 'UNKNOWN',
        flag: 'Panama',
        isSuspicious: true, // Suspicious: AIS gaps, restricted area
      ),
    ];
  }

  /// Get available ship types for filtering
  List<String> getAvailableShipTypes() {
    return [
      'cargo',
      'tanker',
      'fishing',
      'passenger',
      'military',
      'tug',
      'sailing',
      'other',
    ];
  }

  /// Get ship count by type
  Map<String, int> getShipTypeDistribution(List<AisShip> ships) {
    final distribution = <String, int>{};
    for (final ship in ships) {
      distribution[ship.shipType] = (distribution[ship.shipType] ?? 0) + 1;
    }
    return distribution;
  }

  /// Get suspicious ships
  List<AisShip> getSuspiciousShips(List<AisShip> ships) {
    return ships.where((ship) => ship.isSuspicious).toList();
  }
}

