import '../models/study_area.dart';

class MockData {
  static final List<StudyArea> studyAreas = [
    StudyArea(
      id: '1',
      title: 'Chesapeake Bay Overview',
      description: 'Comprehensive SAR monitoring of oil spill incidents across the entire Chesapeake Bay region with 548 days of detection data.',
      category: 'Oil Spills',
      location: 'Chesapeake Bay, MD/VA',
      imageUrl: '',
      lastUpdated: DateTime.now().subtract(const Duration(hours: 2)),
      metadata: {
        'oil_detections': '2,847',
        'area_km2': 11600,
        'satellite': 'Sentinel-1',
        'confidence': '85%',
      },
    ),
    StudyArea(
      id: '2',
      title: 'Shipping Lane Monitoring',
      description: 'High-traffic shipping routes in Chesapeake Bay with correlation analysis between vessel activity and oil spill incidents.',
      category: 'Ship Traffic',
      location: 'Main Shipping Channel',
      imageUrl: '',
      lastUpdated: DateTime.now().subtract(const Duration(hours: 6)),
      metadata: {
        'ship_related': '1,245',
        'area_km2': 850,
        'satellite': 'Sentinel-1',
        'correlation': '68%',
      },
    ),
    StudyArea(
      id: '3',
      title: 'Norfolk Port Vicinity',
      description: 'Concentrated monitoring of oil spill activity near Norfolk Port and surrounding waters with AIS ship tracking integration.',
      category: 'High-Risk Zone',
      location: 'Norfolk, VA',
      imageUrl: '',
      lastUpdated: DateTime.now().subtract(const Duration(hours: 12)),
      metadata: {
        'hotspot_rank': '#1',
        'area_km2': 425,
        'satellite': 'Sentinel-1',
        'risk_level': 'Critical',
      },
    ),
    StudyArea(
      id: '4',
      title: 'Baltimore Harbor Zone',
      description: 'Industrial port area monitoring with focus on commercial vessel operations and potential pollution sources.',
      category: 'High-Risk Zone',
      location: 'Baltimore, MD',
      imageUrl: '',
      lastUpdated: DateTime.now().subtract(const Duration(hours: 8)),
      metadata: {
        'hotspot_rank': '#2',
        'area_km2': 380,
        'satellite': 'Sentinel-1',
        'risk_level': 'High',
      },
    ),
    StudyArea(
      id: '5',
      title: 'Eastern Shore Coastline',
      description: 'Oil spill detection along the Eastern Shore with emphasis on environmental impact and coastal water quality assessment.',
      category: 'Environmental',
      location: 'Eastern Shore, MD/VA',
      imageUrl: '',
      lastUpdated: DateTime.now().subtract(const Duration(days: 1)),
      metadata: {
        'detections': '567',
        'area_km2': 3200,
        'satellite': 'Sentinel-1',
        'water_quality': 'Fair',
      },
    ),
    StudyArea(
      id: '6',
      title: 'Potomac River Confluence',
      description: 'Multi-temporal analysis of oil spill patterns where the Potomac River meets Chesapeake Bay, including tidal influence studies.',
      category: 'Oil Spills',
      location: 'Potomac River Delta',
      imageUrl: '',
      lastUpdated: DateTime.now().subtract(const Duration(days: 2)),
      metadata: {
        'detections': '423',
        'area_km2': 890,
        'satellite': 'Sentinel-1',
        'tidal_impact': 'High',
      },
    ),
    StudyArea(
      id: '7',
      title: 'Seasonal Pattern Analysis',
      description: 'Year-round monitoring revealing seasonal variations in oil spill frequency, with peak activity during winter months.',
      category: 'Temporal Analysis',
      location: 'Chesapeake Bay Region',
      imageUrl: '',
      lastUpdated: DateTime.now().subtract(const Duration(hours: 4)),
      metadata: {
        'peak_season': 'Winter',
        'area_km2': 11600,
        'satellite': 'Sentinel-1',
        'trend': 'Increasing',
      },
    ),
    StudyArea(
      id: '8',
      title: 'Weather Correlation Study',
      description: 'Analyzing the relationship between weather conditions (wind, waves, temperature) and oil spill detection rates.',
      category: 'Temporal Analysis',
      location: 'Chesapeake Bay Region',
      imageUrl: '',
      lastUpdated: DateTime.now().subtract(const Duration(hours: 10)),
      metadata: {
        'wind_correlation': '65%',
        'area_km2': 11600,
        'satellite': 'Sentinel-1',
        'dominant_factor': 'Wind Speed',
      },
    ),
  ];

  static List<StudyArea> getAreasByCategory(String category) {
    return studyAreas.where((area) => area.category == category).toList();
  }

  static List<String> get categories {
    return studyAreas.map((area) => area.category).toSet().toList();
  }
}