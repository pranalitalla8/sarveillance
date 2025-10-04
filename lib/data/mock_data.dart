import '../models/study_area.dart';

class MockData {
  static final List<StudyArea> studyAreas = [
    StudyArea(
      id: '1',
      title: 'Hurricane Ian Impact',
      description: 'SAR analysis of Hurricane Ian\'s impact on Florida coastline and infrastructure damage assessment.',
      category: 'Disasters',
      location: 'Florida, USA',
      imageUrl: '',
      lastUpdated: DateTime.now().subtract(const Duration(days: 2)),
      metadata: {
        'severity': 'High',
        'area_km2': 15000,
        'satellite': 'Sentinel-1',
      },
    ),
    StudyArea(
      id: '2',
      title: 'Amazon Deforestation',
      description: 'Monitoring deforestation patterns in the Amazon rainforest using multi-temporal SAR imagery.',
      category: 'Climate',
      location: 'Amazon Basin, Brazil',
      imageUrl: '',
      lastUpdated: DateTime.now().subtract(const Duration(days: 5)),
      metadata: {
        'deforestation_rate': '12%',
        'area_km2': 25000,
        'satellite': 'ALOS-2',
      },
    ),
    StudyArea(
      id: '3',
      title: 'Tokyo Urban Growth',
      description: 'Urban expansion analysis of Tokyo metropolitan area using long-term SAR data.',
      category: 'Urban',
      location: 'Tokyo, Japan',
      imageUrl: '',
      lastUpdated: DateTime.now().subtract(const Duration(days: 1)),
      metadata: {
        'growth_rate': '8%',
        'area_km2': 8000,
        'satellite': 'TerraSAR-X',
      },
    ),
    StudyArea(
      id: '4',
      title: 'Glacier Retreat Monitoring',
      description: 'Tracking glacier retreat in the Arctic using interferometric SAR analysis.',
      category: 'Climate',
      location: 'Greenland',
      imageUrl: '',
      lastUpdated: DateTime.now().subtract(const Duration(days: 3)),
      metadata: {
        'retreat_rate': '15m/year',
        'area_km2': 5000,
        'satellite': 'Sentinel-1',
      },
    ),
    StudyArea(
      id: '5',
      title: 'Volcanic Activity Detection',
      description: 'Real-time monitoring of volcanic ground deformation using InSAR techniques.',
      category: 'Natural Features',
      location: 'Mount Etna, Italy',
      imageUrl: '',
      lastUpdated: DateTime.now().subtract(const Duration(hours: 6)),
      metadata: {
        'deformation': '5cm uplift',
        'area_km2': 1200,
        'satellite': 'Cosmo-SkyMed',
      },
    ),
    StudyArea(
      id: '6',
      title: 'Earthquake Damage Assessment',
      description: 'Post-earthquake damage assessment using coherence change detection methods.',
      category: 'Disasters',
      location: 'Turkey-Syria Border',
      imageUrl: '',
      lastUpdated: DateTime.now().subtract(const Duration(days: 7)),
      metadata: {
        'magnitude': '7.8',
        'area_km2': 20000,
        'satellite': 'Sentinel-1',
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