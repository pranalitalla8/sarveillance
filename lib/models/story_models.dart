enum StoryInteractionType {
  introduction,
  beforeAfter,
  humanImpact,
  multiFrequency,
  personalInsight,
  futureProjection,
  solution,
}

class StoryChapter {
  final String id;
  final String title;
  final String subtitle;
  final String description;
  final StoryInteractionType interactionType;
  final List<SarDataLayer> sarLayers;
  final PersonalNarrative? personalStory;
  final List<InteractiveElement> interactions;
  final FuturePredictions? predictions;
  final SolutionComponents? solution;
  final AliceThemeData? aliceTheme;

  const StoryChapter({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.description,
    required this.interactionType,
    this.sarLayers = const [],
    this.personalStory,
    this.interactions = const [],
    this.predictions,
    this.solution,
    this.aliceTheme,
  });
}

class SarDataLayer {
  final String id;
  final String frequency; // C-band, L-band, X-band
  final String polarization; // VV, VH, HH, HV
  final DateTime acquisitionDate;
  final String location;
  final List<double> coordinates; // [lat, lon]
  final List<DetectionResult> detections;
  final ColorMapping visualization;
  final Map<String, dynamic> metadata;

  const SarDataLayer({
    required this.id,
    required this.frequency,
    required this.polarization,
    required this.acquisitionDate,
    required this.location,
    required this.coordinates,
    this.detections = const [],
    required this.visualization,
    this.metadata = const {},
  });
}

class DetectionResult {
  final String type; // oil_spill, illegal_ship, sea_ice, vegetation
  final String confidence; // high, medium, low
  final List<double> boundingBox; // [minLat, minLon, maxLat, maxLon]
  final Map<String, dynamic> properties;
  final String description;

  const DetectionResult({
    required this.type,
    required this.confidence,
    required this.boundingBox,
    this.properties = const {},
    required this.description,
  });
}

class ColorMapping {
  final String colorScheme; // viridis, plasma, inferno, custom
  final double minValue;
  final double maxValue;
  final String units; // dB, linear, normalized
  final Map<String, int> customColors; // For specific features

  const ColorMapping({
    required this.colorScheme,
    required this.minValue,
    required this.maxValue,
    required this.units,
    this.customColors = const {},
  });
}

class PersonalNarrative {
  final String authorName;
  final String authorContext;
  final List<LocalStory> stories;
  final List<FamiliarLocation> dmvSpots;
  final Map<String, String> personalConnections;

  const PersonalNarrative({
    required this.authorName,
    required this.authorContext,
    required this.stories,
    required this.dmvSpots,
    this.personalConnections = const {},
  });
}

class LocalStory {
  final String title;
  final String description;
  final String location;
  final List<double> coordinates;
  final DateTime? date;
  final String category; // childhood_memory, environmental_change, community_impact
  final List<String> imageUrls;

  const LocalStory({
    required this.title,
    required this.description,
    required this.location,
    required this.coordinates,
    this.date,
    required this.category,
    this.imageUrls = const [],
  });
}

class FamiliarLocation {
  final String name;
  final String description;
  final List<double> coordinates;
  final String category; // sailing, fishing, swimming, studying
  final String personalStory;
  final List<EnvironmentalChange> observedChanges;

  const FamiliarLocation({
    required this.name,
    required this.description,
    required this.coordinates,
    required this.category,
    required this.personalStory,
    this.observedChanges = const [],
  });
}

class EnvironmentalChange {
  final String type; // water_quality, ice_patterns, shipping_traffic
  final String timeframe; // childhood_to_now, past_5_years, recent
  final String description;
  final String impact; // positive, negative, neutral
  final String sarEvidence; // How SAR data shows this change

  const EnvironmentalChange({
    required this.type,
    required this.timeframe,
    required this.description,
    required this.impact,
    required this.sarEvidence,
  });
}

class InteractiveElement {
  final String id;
  final String type; // tap_reveal, slider, timeline, game, riddle
  final String title;
  final String description;
  final Map<String, dynamic> config;
  final List<String> unlockConditions;

  const InteractiveElement({
    required this.id,
    required this.type,
    required this.title,
    required this.description,
    this.config = const {},
    this.unlockConditions = const [],
  });
}

class FuturePredictions {
  final List<String> timeHorizons; // 2025, 2030, 2040
  final List<PredictionScenario> scenarios;
  final String methodology;
  final List<String> uncertainties;

  const FuturePredictions({
    required this.timeHorizons,
    required this.scenarios,
    required this.methodology,
    this.uncertainties = const [],
  });
}

class PredictionScenario {
  final String id;
  final String name; // current_trend, intervention, worst_case, best_case
  final String description;
  final Map<String, double> predictedValues;
  final List<SarDataLayer> projectedSarData;
  final String likelihood; // high, medium, low

  const PredictionScenario({
    required this.id,
    required this.name,
    required this.description,
    required this.predictedValues,
    this.projectedSarData = const [],
    required this.likelihood,
  });
}

class SolutionComponents {
  final List<Technology> technologies;
  final List<Impact> expectedImpacts;
  final String implementation;
  final List<String> stakeholders;
  final String timeline;

  const SolutionComponents({
    required this.technologies,
    required this.expectedImpacts,
    required this.implementation,
    this.stakeholders = const [],
    required this.timeline,
  });
}

class Technology {
  final String name;
  final String description;
  final String category; // monitoring, detection, response, prevention
  final String maturityLevel; // prototype, pilot, operational
  final List<String> capabilities;

  const Technology({
    required this.name,
    required this.description,
    required this.category,
    required this.maturityLevel,
    this.capabilities = const [],
  });
}

class Impact {
  final String category; // environmental, economic, social
  final String description;
  final String magnitude; // high, medium, low
  final String timeframe; // immediate, short_term, long_term
  final List<String> beneficiaries;

  const Impact({
    required this.category,
    required this.description,
    required this.magnitude,
    required this.timeframe,
    this.beneficiaries = const [],
  });
}

class AliceThemeData {
  final String chapterQuote; // Alice in Wonderland quote for the chapter
  final String characterReference; // Which character this chapter relates to
  final String wonderlandMetaphor; // How this relates to Wonderland
  final List<String> visualMotifs; // rabbit_hole, playing_cards, tea_party, etc.
  final Map<String, String> sarToWonderlandMappings; // "Different frequencies" = "Different colors"

  const AliceThemeData({
    required this.chapterQuote,
    required this.characterReference,
    required this.wonderlandMetaphor,
    this.visualMotifs = const [],
    this.sarToWonderlandMappings = const {},
  });
}

// Story progress tracking
class StoryProgress {
  final Map<String, bool> chaptersCompleted;
  final Map<String, List<String>> interactionsCompleted;
  final List<String> discoveries;
  final Map<String, DateTime> chapterStartTimes;
  final Map<String, Duration> timeSpentPerChapter;

  const StoryProgress({
    this.chaptersCompleted = const {},
    this.interactionsCompleted = const {},
    this.discoveries = const [],
    this.chapterStartTimes = const {},
    this.timeSpentPerChapter = const {},
  });

  double get overallProgress {
    if (chaptersCompleted.isEmpty) return 0.0;
    final completed = chaptersCompleted.values.where((v) => v).length;
    return completed / chaptersCompleted.length;
  }
}

// DMV Area specific data
class DmvAreaContext {
  static const List<FamiliarLocation> localSpots = [
    FamiliarLocation(
      name: 'Annapolis Harbor',
      description: 'Historic sailing town and Naval Academy home',
      coordinates: [38.9719, -76.5019],
      category: 'sailing',
      personalStory: 'Where I learned to sail on weekends, watching the midshipmen practice',
      observedChanges: [
        EnvironmentalChange(
          type: 'shipping_traffic',
          timeframe: 'past_5_years',
          description: 'Increased commercial traffic affecting recreational sailing',
          impact: 'negative',
          sarEvidence: 'C-band SAR shows increased ship wakes and congestion patterns',
        ),
      ],
    ),
    FamiliarLocation(
      name: 'Baltimore Inner Harbor',
      description: 'Major port and urban waterfront',
      coordinates: [39.2847, -76.6205],
      category: 'studying',
      personalStory: 'Field trips here for marine biology classes, studying urban water impacts',
      observedChanges: [
        EnvironmentalChange(
          type: 'water_quality',
          timeframe: 'childhood_to_now',
          description: 'Visible improvement in water clarity but occasional oil sheens',
          impact: 'mixed',
          sarEvidence: 'Multi-polarization SAR reveals subsurface pollution patterns',
        ),
      ],
    ),
    FamiliarLocation(
      name: 'Potomac River (Georgetown)',
      description: 'Historic river and recreational waterway',
      coordinates: [38.9047, -77.0647],
      category: 'fishing',
      personalStory: 'Family fishing trips and ice skating in rare winter freezes',
      observedChanges: [
        EnvironmentalChange(
          type: 'ice_patterns',
          timeframe: 'past_5_years',
          description: 'Less frequent winter ice formation, shorter ice seasons',
          impact: 'negative',
          sarEvidence: 'L-band SAR time series shows changing freeze-thaw cycles',
        ),
      ],
    ),
  ];

  static const List<LocalStory> impactStories = [
    LocalStory(
      title: 'The Oil Sheen Discovery',
      description: 'Finding an unexplained oil sheen near Fort McHenry during a kayak trip in 2022, leading to questions about industrial discharge monitoring',
      location: 'Fort McHenry National Monument',
      coordinates: [39.2636, -76.5797],
      date: null,
      category: 'environmental_change',
    ),
    LocalStory(
      title: 'Night Fishing Mysteries',
      description: 'Unusual ship activity during night fishing on the Patuxent River - ships without proper lighting, potential illegal dumping',
      location: 'Patuxent River',
      coordinates: [38.5742, -76.6907],
      category: 'community_impact',
    ),
    LocalStory(
      title: 'The Changing Seasons',
      description: 'Growing up, the Potomac would freeze solid enough for ice skating. Now, even in the coldest winters, safe ice rarely forms',
      location: 'Potomac River',
      coordinates: [38.9047, -77.0647],
      category: 'childhood_memory',
    ),
  ];
}