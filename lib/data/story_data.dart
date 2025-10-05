import '../models/story_models.dart';

class StoryData {
  static final List<StoryChapter> chapters = [
    // Chapter 1: Down the Rabbit Hole
    StoryChapter(
      id: 'intro',
      title: 'Down the Rabbit Hole',
      subtitle: 'Welcome to the hidden world beneath Chesapeake Bay',
      description: 'Like Alice tumbling into Wonderland, we\'re about to discover what lies beneath the surface of our familiar Chesapeake Bay. Using Sentinel-1 SAR satellites, we\'ve detected over 9,000 potential oil spills from 2015-2024. Follow the white rabbit into the world of Synthetic Aperture Radar...',
      interactionType: StoryInteractionType.introduction,
      aliceTheme: const AliceThemeData(
        chapterQuote: '"Curiouser and curiouser!" cried Alice',
        characterReference: 'Alice and the White Rabbit',
        wonderlandMetaphor: 'Falling down the rabbit hole represents diving deep into SAR data',
        visualMotifs: ['rabbit_hole', 'falling_cards', 'pocket_watch'],
        sarToWonderlandMappings: {
          'SAR pulses': 'White Rabbit\'s ticking watch',
          'Data exploration': 'Falling down the rabbit hole',
          'Hidden patterns': 'Wonderland\'s secrets',
        },
      ),
      interactions: [
        InteractiveElement(
          id: 'radar_intro',
          type: 'tap_reveal',
          title: 'What is SAR?',
          description: 'Tap to reveal how radar sees our world',
          config: {
            'animation': 'pulse_expand',
            'sound': 'radar_ping',
          },
        ),
        InteractiveElement(
          id: 'dmv_selection',
          type: 'map_explore',
          title: 'Choose Your Adventure',
          description: 'Select a familiar DMV location to begin',
          config: {
            'locations': DmvAreaContext.localSpots,
            'interaction': 'tap_to_select',
          },
        ),
      ],
    ),

    // Chapter 2: The World Before
    StoryChapter(
      id: 'before_pristine',
      title: 'A World That Was',
      subtitle: 'The Chesapeake Bay before the Mad Hatter\'s tea party',
      description: 'Once upon a time, our waters were pristine. Here\'s how the Chesapeake Bay and Potomac River looked before human interference - clear shipping lanes, thriving marine ecosystems, and natural ice patterns.',
      interactionType: StoryInteractionType.beforeAfter,
      aliceTheme: const AliceThemeData(
        chapterQuote: '"It\'s no use going back to yesterday, because I was a different person then."',
        characterReference: 'Alice reflecting on change',
        wonderlandMetaphor: 'The peaceful garden before chaos arrives',
        visualMotifs: ['garden_roses', 'peaceful_meadow', 'clear_streams'],
        sarToWonderlandMappings: {
          'Clean water signatures': 'Crystal clear garden streams',
          'Natural patterns': 'Orderly garden layout',
          'Baseline data': 'The world before Alice arrived',
        },
      ),
      sarLayers: [
        SarDataLayer(
          id: 'chesapeake_2015_baseline',
          frequency: 'C-band',
          polarization: 'VV+VH',
          acquisitionDate: DateTime(2015, 3, 10),
          location: 'Chesapeake Bay',
          coordinates: [39.1858, -76.0997],
          visualization: const ColorMapping(
            colorScheme: 'viridis',
            minValue: -55.0,
            maxValue: -20.0,
            units: 'dB',
          ),
          detections: [
            DetectionResult(
              type: 'baseline_water',
              confidence: 'high',
              boundingBox: [38.5, -77.0, 39.5, -76.0],
              description: 'Early Sentinel-1 baseline - start of 548 detection dates',
              properties: {'vv_mean': '-45 dB', 'vh_mean': '-55 dB', 'detections': '548 dates'},
            ),
          ],
        ),
      ],
      interactions: [
        InteractiveElement(
          id: 'time_slider',
          type: 'timeline',
          title: 'Journey Back in Time',
          description: 'Slide through 548 detection dates from 2015-2024',
          config: {
            'start_year': 2015,
            'end_year': 2024,
            'default_year': 2015,
            'total_dates': 548,
          },
        ),
      ],
    ),

    // Chapter 3: The Mad Hatter's Tea Party
    StoryChapter(
      id: 'human_impact',
      title: 'The Mad Hatter\'s Tea Party',
      subtitle: 'When human activities crashed the party',
      description: 'Just like the chaos at the Mad Hatter\'s table, human activities have transformed our waters. Watch as oil spills, illegal ship dumping, and disrupted shipping patterns emerge in our local DMV waters.',
      interactionType: StoryInteractionType.humanImpact,
      aliceTheme: const AliceThemeData(
        chapterQuote: '"Take more tea," the March Hare said earnestly. "I\'ve had nothing yet," Alice replied. "So I can\'t take more."',
        characterReference: 'Mad Hatter and March Hare',
        wonderlandMetaphor: 'The chaotic tea party represents human disruption of natural systems',
        visualMotifs: ['tea_party', 'broken_dishes', 'spilled_tea'],
        sarToWonderlandMappings: {
          'Oil spills': 'Spilled tea staining the tablecloth',
          'Ship pollution': 'Broken dishes scattered about',
          'Human impact': 'The mad, endless tea party',
        },
      ),
      sarLayers: [
        SarDataLayer(
          id: 'chesapeake_oil_detection',
          frequency: 'C-band',
          polarization: 'VV+VH',
          acquisitionDate: DateTime(2024, 10, 5),
          location: 'Chesapeake Bay',
          coordinates: [39.1858, -76.0997],
          visualization: const ColorMapping(
            colorScheme: 'plasma',
            minValue: -55.0,
            maxValue: -20.0,
            units: 'dB',
          ),
          detections: [
            DetectionResult(
              type: 'oil_spill',
              confidence: 'high',
              boundingBox: [38.5, -77.0, 39.5, -76.0],
              description: 'JRC Water-Masked detection (VV < -22 dB) - 9,382+ detections analyzed',
              properties: {
                'method': 'JRC Global Surface Water masking',
                'threshold': 'VV < -22 dB',
                'total_detections': '9382',
                'date_range': '2015-2024'
              },
            ),
          ],
        ),
      ],
      personalStory: PersonalNarrative(
        authorName: 'Local DMV Resident',
        authorContext: 'Growing up sailing and fishing in these waters',
        stories: DmvAreaContext.impactStories,
        dmvSpots: DmvAreaContext.localSpots,
        personalConnections: {
          'oil_spill': 'I discovered this oil sheen during a kayak trip',
          'illegal_shipping': 'Strange ships during our night fishing trips',
          'changed_patterns': 'The waters of my childhood have changed',
        },
      ),
      interactions: [
        InteractiveElement(
          id: 'impact_timeline',
          type: 'interactive_timeline',
          title: 'Chronicle of Changes',
          description: 'Tap events to see their impact',
          config: {
            'events': [
              {'year': 2015, 'type': 'sentinel1_launch', 'location': 'Global', 'desc': 'Sentinel-1A begins monitoring'},
              {'year': 2019, 'type': 'detection_peak', 'location': 'Chesapeake', 'desc': 'Highest oil detection rates'},
              {'year': 2020, 'type': 'weather_correlation', 'location': 'Bay-wide', 'desc': 'K-means clustering reveals 3 weather patterns'},
              {'year': 2024, 'type': 'nasa_space_apps', 'location': 'DMV', 'desc': 'SARveillance project analyzing 9,382 detections'},
            ],
          },
        ),
      ],
    ),

    // Chapter 4: Through the Looking Glass
    StoryChapter(
      id: 'multi_frequency',
      title: 'Through the Looking Glass',
      subtitle: 'Where each frequency reveals a different world',
      description: 'Alice stepped through the mirror into a world turned upside down. In SAR, each polarization reveals different secrets - VV polarization (avg -45 dB) shows surface roughness, VH polarization (avg -55 dB) reveals volume scattering. The VH/VV ratio distinguishes oil from water!',
      interactionType: StoryInteractionType.multiFrequency,
      aliceTheme: const AliceThemeData(
        chapterQuote: '"It\'s a looking-glass book, of course! And if I hold it up to a glass, the words will all go the right way again."',
        characterReference: 'Alice and the Looking Glass',
        wonderlandMetaphor: 'Different frequencies are like different mirrors showing alternate realities',
        visualMotifs: ['mirror', 'reversed_text', 'chess_board', 'twin_flowers'],
        sarToWonderlandMappings: {
          'VV polarization': 'The surface mirror showing roughness (avg -45 dB)',
          'VH polarization': 'The volume mirror revealing scattering (avg -55 dB)',
          'VH/VV ratio': 'The magic lens that separates oil from water',
          'Backscatter values': 'The backwards numbers that reveal truth through the glass',
        },
      ),
      sarLayers: [
        SarDataLayer(
          id: 'multi_freq_c',
          frequency: 'C-band',
          polarization: 'VV',
          acquisitionDate: DateTime(2023, 9, 1),
          location: 'Chesapeake Bay',
          coordinates: [38.9719, -76.5019],
          visualization: const ColorMapping(
            colorScheme: 'viridis',
            minValue: -25.0,
            maxValue: 5.0,
            units: 'dB',
            customColors: {'oil_spill': 0xFF000080}, // Dark blue for oil
          ),
          detections: [
            DetectionResult(
              type: 'surface_oil',
              confidence: 'high',
              boundingBox: [38.95, -76.52, 38.97, -76.50],
              description: 'Surface oil film visible in C-band',
            ),
          ],
        ),
        SarDataLayer(
          id: 'multi_freq_l',
          frequency: 'L-band',
          polarization: 'HH',
          acquisitionDate: DateTime(2023, 9, 1),
          location: 'Chesapeake Bay',
          coordinates: [38.9719, -76.5019],
          visualization: const ColorMapping(
            colorScheme: 'plasma',
            minValue: -20.0,
            maxValue: 10.0,
            units: 'dB',
            customColors: {'vegetation': 0xFF00FF00}, // Green for vegetation
          ),
          detections: [
            DetectionResult(
              type: 'coastal_vegetation',
              confidence: 'high',
              boundingBox: [38.90, -76.55, 39.00, -76.45],
              description: 'Coastal marsh vegetation visible in L-band',
            ),
          ],
        ),
        SarDataLayer(
          id: 'multi_freq_x',
          frequency: 'X-band',
          polarization: 'VV',
          acquisitionDate: DateTime(2023, 9, 1),
          location: 'Chesapeake Bay',
          coordinates: [38.9719, -76.5019],
          visualization: const ColorMapping(
            colorScheme: 'inferno',
            minValue: -30.0,
            maxValue: 0.0,
            units: 'dB',
            customColors: {'ship': 0xFFFFFFFF}, // White for ships
          ),
          detections: [
            DetectionResult(
              type: 'ship_detail',
              confidence: 'high',
              boundingBox: [38.96, -76.51, 38.965, -76.505],
              description: 'Ship structure details visible in X-band',
            ),
          ],
        ),
      ],
      interactions: [
        InteractiveElement(
          id: 'frequency_mirror',
          type: 'frequency_explorer',
          title: 'The Frequency Mirrors',
          description: 'Tap each mirror to see what it reveals',
          config: {
            'mirrors': ['C-band', 'L-band', 'X-band'],
            'reveal_animation': 'mirror_flip',
            'riddles': {
              'C-band': 'Why does the city look pink and the oil look dark?',
              'L-band': 'How can we see through water to the vegetation below?',
              'X-band': 'What makes ships appear so bright and detailed?',
            },
          },
        ),
      ],
    ),

    // Chapter 5: The Cheshire Cat's Secrets
    StoryChapter(
      id: 'detection_secrets',
      title: 'The Cheshire Cat\'s Grin',
      subtitle: 'What SAR reveals that the eye cannot see',
      description: 'Like the Cheshire Cat appearing and disappearing, oil spills and illegal activities hide in plain sight. But SAR can see their grin even when they\'ve vanished. Each polarization reveals different secrets about what\'s really happening in our DMV waters.',
      interactionType: StoryInteractionType.multiFrequency,
      aliceTheme: const AliceThemeData(
        chapterQuote: '"We\'re all mad here. I\'m mad. You\'re mad."',
        characterReference: 'The Cheshire Cat',
        wonderlandMetaphor: 'The Cat\'s ability to appear and disappear represents how SAR can detect invisible phenomena',
        visualMotifs: ['cat_grin', 'disappearing_act', 'tree_shadows'],
        sarToWonderlandMappings: {
          'Hidden oil spills': 'The Cat\'s invisible body with visible grin',
          'Polarization differences': 'The Cat appearing in different trees',
          'Detection algorithms': 'Learning to see the Cat\'s grin',
        },
      ),
      interactions: [
        InteractiveElement(
          id: 'detection_game',
          type: 'game',
          title: 'Find the Hidden Secrets',
          description: 'Can you spot what the Cheshire Cat sees?',
          config: {
            'game_type': 'spot_the_difference',
            'challenges': [
              'Find the oil spill hidden in calm water',
              'Identify the ship without lights',
              'Spot the unusual ice pattern',
            ],
          },
        ),
      ],
    ),

    // Chapter 6: Alice's Neighborhood
    StoryChapter(
      id: 'personal_dmv',
      title: 'Alice\'s Neighborhood',
      subtitle: 'A personal journey through familiar DMV waters',
      description: 'This isn\'t just data - it\'s our home. Join me on a personal tour of the waters where I grew up, learned to sail, and first noticed changes. From Annapolis Harbor to the Potomac River, these are the places that shaped my understanding of our marine environment.',
      interactionType: StoryInteractionType.personalInsight,
      aliceTheme: const AliceThemeData(
        chapterQuote: '"I knew who I was this morning, but I\'ve changed a few times since then."',
        characterReference: 'Alice\'s journey of self-discovery',
        wonderlandMetaphor: 'Personal growth parallels environmental awareness',
        visualMotifs: ['growing_smaller', 'growing_larger', 'familiar_garden'],
        sarToWonderlandMappings: {
          'Personal stories': 'Alice\'s memories of home',
          'Environmental changes': 'Growing and shrinking in Wonderland',
          'Local knowledge': 'Finding the way home',
        },
      ),
      personalStory: PersonalNarrative(
        authorName: 'Your Local Guide',
        authorContext: 'Born and raised in the DMV area, lifelong water enthusiast',
        stories: DmvAreaContext.impactStories,
        dmvSpots: DmvAreaContext.localSpots,
        personalConnections: {
          'annapolis': 'My sailing instructor taught me to read the water here',
          'baltimore': 'Field trips revealed the complexity of urban waterways',
          'potomac': 'Family traditions shaped by seasonal water patterns',
        },
      ),
      interactions: [
        InteractiveElement(
          id: 'personal_tour',
          type: 'interactive_map',
          title: 'Personal Water Tour',
          description: 'Explore the places that shaped my environmental awareness',
          config: {
            'tour_stops': DmvAreaContext.localSpots,
            'story_integration': true,
            'sar_overlay': true,
          },
        ),
      ],
    ),

    // Chapter 7: The Queen's Decree
    StoryChapter(
      id: 'future_solution',
      title: 'The Queen\'s Decree',
      subtitle: 'Our solution to protect the realm',
      description: 'Every good story needs heroes. The Queen of Hearts may have been mad, but our decree is sensible: protect our marine realm with technology, community action, and smart policy. Here\'s our solution for real-time monitoring and rapid response.',
      interactionType: StoryInteractionType.solution,
      aliceTheme: const AliceThemeData(
        chapterQuote: '"Who in the world am I? Ah, that\'s the great puzzle!"',
        characterReference: 'The Queen of Hearts',
        wonderlandMetaphor: 'Taking charge to create order from chaos',
        visualMotifs: ['royal_decree', 'playing_card_soldiers', 'croquet_game'],
        sarToWonderlandMappings: {
          'Technology solution': 'Organizing the card soldiers',
          'Community action': 'Everyone playing by fair rules',
          'Environmental protection': 'Tending the royal garden properly',
        },
      ),
      solution: const SolutionComponents(
        technologies: [
          Technology(
            name: 'SARveillance Detection System',
            description: 'JRC Water-Masked oil detection using Sentinel-1 SAR (VV < -22 dB threshold)',
            category: 'monitoring',
            maturityLevel: 'operational',
            capabilities: ['Dual-pol VV+VH analysis', 'Google Earth Engine integration', 'NASA POWER weather correlation'],
          ),
          Technology(
            name: 'Flutter Mobile Dashboard',
            description: 'Real-time visualization of 9,382+ oil detections with environmental heatmaps',
            category: 'visualization',
            maturityLevel: 'operational',
            capabilities: ['Interactive maps', 'Statistical analysis', 'Weather pattern clustering'],
          ),
          Technology(
            name: 'Machine Learning Analysis',
            description: 'PCA and K-means clustering of SAR signatures with environmental factors',
            category: 'analysis',
            maturityLevel: 'operational',
            capabilities: ['Feature correlation', 'Pattern recognition', 'Temporal trend analysis'],
          ),
        ],
        expectedImpacts: [
          Impact(
            category: 'environmental',
            description: 'Faster detection and response to oil spills and illegal dumping',
            magnitude: 'high',
            timeframe: 'immediate',
            beneficiaries: ['marine ecosystems', 'water quality', 'recreational users'],
          ),
          Impact(
            category: 'economic',
            description: 'Reduced cleanup costs through early detection',
            magnitude: 'medium',
            timeframe: 'short_term',
            beneficiaries: ['government agencies', 'insurance companies', 'fishing industry'],
          ),
          Impact(
            category: 'social',
            description: 'Increased community engagement in environmental protection',
            magnitude: 'high',
            timeframe: 'long_term',
            beneficiaries: ['local communities', 'educational institutions', 'environmental groups'],
          ),
        ],
        implementation: 'Operational prototype analyzing 548 dates of Chesapeake Bay Sentinel-1 data (2015-2024)',
        stakeholders: ['NASA Space Apps Challenge', 'Google Earth Engine', 'Copernicus Sentinel-1', 'NASA POWER API', 'Chesapeake Bay Foundation'],
        timeline: 'Operational prototype - ready for stakeholder deployment',
      ),
      predictions: const FuturePredictions(
        timeHorizons: ['2025', '2030', '2040'],
        scenarios: [
          PredictionScenario(
            id: 'current_trend',
            name: 'Business as Usual',
            description: 'Current monitoring and response capabilities continue',
            predictedValues: {'oil_incidents': 15.0, 'response_time': 48.0, 'detection_rate': 0.6},
            likelihood: 'high',
          ),
          PredictionScenario(
            id: 'our_solution',
            name: 'SAR Monitoring Implementation',
            description: 'Our proposed solution is fully deployed',
            predictedValues: {'oil_incidents': 8.0, 'response_time': 6.0, 'detection_rate': 0.95},
            likelihood: 'medium',
          ),
          PredictionScenario(
            id: 'worst_case',
            name: 'Degraded Monitoring',
            description: 'Reduced funding leads to less monitoring capability',
            predictedValues: {'oil_incidents': 25.0, 'response_time': 72.0, 'detection_rate': 0.4},
            likelihood: 'low',
          ),
        ],
        methodology: 'Based on historical incident data, SAR detection capabilities, and response time analysis',
        uncertainties: ['funding availability', 'regulatory approval', 'technology adoption rate'],
      ),
      interactions: [
        InteractiveElement(
          id: 'solution_demo',
          type: 'interactive_demo',
          title: 'See Our Solution in Action',
          description: 'Simulate how our monitoring system would work',
          config: {
            'demo_scenario': 'oil_spill_response',
            'interactive_elements': ['detection', 'alert', 'response', 'cleanup'],
          },
        ),
        InteractiveElement(
          id: 'future_scenarios',
          type: 'scenario_comparison',
          title: 'Compare Future Scenarios',
          description: 'See how different approaches lead to different outcomes',
          config: {
            'scenarios': ['current_trend', 'our_solution', 'worst_case'],
            'metrics': ['detection_rate', 'response_time', 'environmental_impact'],
          },
        ),
      ],
    ),
  ];

  static StoryChapter? getChapterById(String id) {
    try {
      return chapters.firstWhere((chapter) => chapter.id == id);
    } catch (e) {
      return null;
    }
  }

  static List<StoryChapter> getChaptersByType(StoryInteractionType type) {
    return chapters.where((chapter) => chapter.interactionType == type).toList();
  }

  static int getChapterIndex(String id) {
    return chapters.indexWhere((chapter) => chapter.id == id);
  }

  static String? getNextChapterId(String currentId) {
    final currentIndex = getChapterIndex(currentId);
    if (currentIndex != -1 && currentIndex < chapters.length - 1) {
      return chapters[currentIndex + 1].id;
    }
    return null;
  }

  static String? getPreviousChapterId(String currentId) {
    final currentIndex = getChapterIndex(currentId);
    if (currentIndex > 0) {
      return chapters[currentIndex - 1].id;
    }
    return null;
  }
}