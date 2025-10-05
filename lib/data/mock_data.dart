import '../models/study_area.dart';

class MockData {
  static final List<StudyArea> studyAreas = [
    StudyArea(
      id: '1',
      title: 'Chesapeake Bay Overview',
      description: 'This comprehensive study utilizes Sentinel-1 SAR satellite imagery spanning 548 acquisition dates from March 2015 to October 2024 to monitor oil spill incidents across the entire Chesapeake Bay region. Using dual-polarization (VV+VH) C-band radar data and the JRC Global Surface Water masking technique with a VV backscatter threshold of -22 dB, we\'ve identified 2,847 potential oil candidates. The analysis integrates NASA POWER meteorological data including air temperature, wind speed, precipitation, and solar radiation to understand environmental factors influencing oil spill detection. This multi-temporal approach reveals seasonal patterns, with peak detection rates occurring during winter months when water surface conditions optimize radar contrast between oil and water.',
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
      description: 'This focused investigation examines high-traffic shipping routes throughout Chesapeake Bay, correlating vessel activity data from the Automatic Identification System (AIS) with SAR-detected oil spill incidents. Analysis of 1,245 ship-related oil candidates reveals a 68% correlation between commercial vessel traffic patterns and oil detection events. The study employs VH/VV ratio analysis to distinguish natural sea surface features from anthropogenic oil slicks, with particular attention to operational discharges and accidental spills along major commercial routes. Temporal analysis shows elevated incident rates during peak shipping hours and weekdays, suggesting a strong link between vessel operations and marine pollution. Integration of AIS daily statistics enables identification of specific vessel types and routes associated with higher pollution risk.',
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
      description: 'Norfolk Port represents the most critical oil spill hotspot in our monitoring network, ranking #1 for incident frequency and environmental risk. This dense concentration of maritime activity combines commercial shipping, naval operations, and industrial port facilities, creating a complex pollution risk profile. SAR analysis integrated with AIS ship tracking reveals persistent oil detection patterns correlating with vessel berthing operations, fuel transfer activities, and departure/arrival procedures. The 425 km² monitoring zone encompasses the immediate port area and adjacent approach channels where vessel density peaks. Advanced feature correlation analysis identifies wind speed, tidal conditions, and vessel traffic density as primary factors influencing detection rates. Machine learning clustering has identified three distinct pollution patterns: operational discharges during port operations, accidental spills during fuel transfer, and wake-related surface disturbances that can mask or enhance oil detection.',
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
      description: 'As the second-highest risk zone in Chesapeake Bay, Baltimore Harbor presents a unique challenge due to its combination of industrial port operations, urban runoff, and confined water geography. The 380 km² study area encompasses the Inner Harbor, Patapsco River approaches, and major industrial terminals handling petroleum products, chemicals, and bulk cargo. SAR monitoring reveals elevated oil detection rates associated with tank farm operations, vessel fueling activities, and storm water discharge events. The harbor\'s semi-enclosed nature creates conditions where spilled oil persists longer than in open water, increasing environmental impact and detection probability. Principal Component Analysis of environmental factors shows that precipitation events, combined with industrial activity cycles, create predictable windows of elevated pollution risk. The integration of Sentinel-1 dual-polarization data with local weather patterns enables identification of both chronic low-level pollution and acute spill events.',
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
      description: 'This extensive 3,200 km² environmental monitoring program along the Eastern Shore focuses on the intersection of oil spill detection, coastal ecosystem health, and water quality assessment. The region\'s shallow waters, extensive marsh systems, and protected coves create unique radar backscatter signatures that require sophisticated analysis to distinguish oil from natural organic material and biogenic slicks. Over 567 oil candidates have been identified, with spatial analysis revealing clusters near recreational boating areas and small craft harbors. The study integrates SAR data with NASA POWER environmental parameters to assess how temperature, solar radiation, and wind patterns affect both oil movement and detection capability. Backscatter distribution analysis (VV and VH polarization) shows distinct signatures for oil in shallow versus deep water, with marsh-adjacent areas presenting particular analytical challenges. Water quality assessment using multi-temporal SAR data reveals areas of persistent surface anomalies that correlate with known pollution sources and require targeted remediation efforts.',
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
      description: 'Where the Potomac River meets Chesapeake Bay, complex hydrodynamic conditions create a challenging environment for oil spill monitoring and a critical area for environmental protection. This 890 km² study area experiences high tidal influence, with strong currents that rapidly transport and disperse surface pollutants while simultaneously creating natural surface patterns that can complicate SAR interpretation. Multi-temporal analysis of 423 oil candidates reveals distinct patterns tied to tidal cycles, with peak detection during slack water periods when oil accumulates rather than dispersing. The confluence zone serves as a natural collection point for pollutants from Washington D.C. metropolitan area runoff, recreational boating activity, and upstream industrial sources. Advanced VH/VV ratio analysis helps distinguish between tidal front features, freshwater-saltwater mixing zones, and actual oil contamination. Integration with NASA POWER data shows that wind-driven surface currents, combined with tidal forcing, create predictable transport pathways that could inform rapid response strategies for spill containment.',
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
      description: 'This comprehensive temporal study analyzes 548 days of SAR acquisitions across nine years to reveal striking seasonal variations in oil spill detection frequency throughout Chesapeake Bay. Statistical analysis demonstrates peak oil candidate identification during winter months (December-February), with detection rates 2.3 times higher than summer baselines. K-means clustering of environmental parameters identifies three distinct seasonal regimes: winter high-detection periods characterized by calm winds and cooler water temperatures that enhance oil-water contrast in SAR imagery; spring/fall transition periods with variable detection influenced by changing weather patterns; and summer low-detection periods where warmer temperatures, increased biological activity, and higher wind speeds reduce detection capability. The study reveals an increasing trend in detection frequency over the monitoring period, though this may reflect improved satellite coverage and algorithmic refinement rather than solely increased pollution. VH/VV ratio analysis by season shows systematic variations in backscatter signatures, requiring season-specific calibration for optimal oil detection accuracy.',
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
      description: 'This advanced meteorological integration study examines the complex relationships between atmospheric and oceanic conditions and SAR-based oil spill detection capability. Using NASA POWER data for air temperature, wind speed (at 2m and 10m height), precipitation, and solar radiation, we\'ve established that wind speed emerges as the dominant environmental factor, showing 65% correlation with detection success. The analysis employs Pearson, Spearman, and Kendall correlation methods to validate relationships across different statistical frameworks. Feature correlation heatmaps reveal that moderate wind speeds (4-8 m/s) optimize detection by creating sufficient surface roughness for radar contrast without excessive wave action that fragments and disperses oil slicks. Temperature effects operate through multiple pathways: affecting oil viscosity, influencing radar penetration, and modulating biological activity that creates confounding surface features. Precipitation shows complex interactions, with light rain potentially enhancing detection through surface film concentration, while heavy precipitation masks signals. Machine learning PCA projection of environmental factors identifies optimal detection windows that could guide satellite tasking and monitoring strategies.',
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