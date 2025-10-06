# SARveillance - Oil Spill Detection for Chesapeake Bay

A Flutter mobile application for detecting and monitoring oil spills in the Chesapeake Bay using Synthetic Aperture Radar (SAR) satellite imagery from Sentinel-1, built for the NASA Space Apps Challenge 2024.

## Overview

SARveillance makes satellite-based oil spill detection accessible to environmental agencies, researchers, and citizen scientists. The app analyzes historical SAR data (2015-2024) integrated with environmental data from NASA POWER API and ship tracking from AIS systems to identify and correlate oil pollution events in the Chesapeake Bay region.

## Key Features

### Oil Spill Detection
- 15,267 historical oil detection points analyzed using VV polarization < -22 dB threshold
- JRC Global Surface Water masking for accurate water surface identification
- Google Earth Engine integration for SAR imagery visualization
- Dual-polarization (VV+VH) C-band radar analysis

### Interactive Analysis
- **Analyze Screen**: Interactive map with toggleable layers (SAR imagery, oil detection overlays, ship tracking, environmental heatmaps)
- **Layer Controls**: Custom panel for blending multiple data sources with transparency adjustment
- **Data Point Filtering**: Filter detections by date, location, and percentage of dataset
- **Ship Correlation**: View AIS ship proximity data for each oil detection
- **Weather Integration**: NASA POWER data showing temperature, wind, precipitation, and solar radiation

### Comprehensive Statistics
- **Statistics Dashboard**: 23 data visualization charts including:
  - Temporal trends and seasonal patterns
  - Weather correlation analysis (temperature, wind speed, precipitation)
  - Ship proximity and type analysis
  - Machine learning severity predictions
  - Spatial distribution heatmaps
  - K-means clustering of weather patterns (3 distinct types)

### Educational Content
- **Story Mode**: Alice in Wonderland-themed narrative explaining oil pollution
  - 5 interactive chapters with animations
  - Themed visualizations and metaphors
  - Timeline of environmental changes
  - Solution demonstrations
- **Discover Page**: Educational content about SAR technology and oil detection methods
- **Explore Page**: Browse study areas and analysis topics with detailed metadata

### Data Management
- Download all data sources
- Google Earth Engine setup guide
- View and copy GEE scripts
- Data source documentation

## Technical Stack

### Frontend (Mobile App)
- **Framework**: Flutter 3.9+ (Dart)
- **Maps**: Google Maps Flutter, Flutter Map
- **Visualization**: FL Chart for statistics
- **Data Processing**: CSV parsing, GeoJSON handling
- **State Management**: Provider
- **UI**: Material 3 design with custom theming

### Backend
- **Framework**: FastAPI (Python)
- **Satellite Data**: Google Earth Engine API
- **Authentication**: Earth Engine service account
- **Deployment**: Docker-ready with uvicorn

### Data Sources
- **SAR Imagery**: Sentinel-1 C-band (2015-2024, 548 acquisition dates)
- **Weather Data**: NASA POWER API (temperature, wind, precipitation, solar radiation)
- **Ship Tracking**: AIS (Automatic Identification System) data
- **Water Masking**: JRC Global Surface Water dataset

## Project Structure

```
sarveillance/
├── lib/
│   ├── main.dart                          # App entry point
│   ├── screens/
│   │   ├── main_screen.dart              # Bottom navigation
│   │   ├── analyze_screen.dart           # Interactive map with layers
│   │   ├── story_screen.dart             # Alice in Wonderland narrative
│   │   ├── statistics_dashboard_screen.dart  # 23 charts and analytics
│   │   ├── explore_screen.dart           # Study areas browser
│   │   ├── discover_screen.dart          # Educational content
│   │   └── data_management_screen.dart   # Data sources and setup
│   ├── widgets/
│   │   ├── layer_control_panel.dart      # Map layer controls
│   │   ├── spill_detail_popup.dart       # Oil detection details
│   │   ├── story_chapter_widget.dart     # Story mode components
│   │   ├── interactive_timeline.dart     # Timeline visualization
│   │   ├── solution_demo.dart            # Solution presentations
│   │   └── educational_card.dart         # Learning content cards
│   ├── services/
│   │   ├── sar_data_service.dart         # CSV data loading
│   │   ├── gee_tile_service.dart         # Google Earth Engine tiles
│   │   └── data_source_service.dart      # Data management
│   ├── models/
│   │   ├── oil_spill_data.dart           # Oil detection data model
│   │   ├── story_models.dart             # Story/narrative models
│   │   └── study_area.dart               # Study area metadata
│   └── data/
│       ├── mock_data.dart                # Study area definitions
│       └── story_data.dart               # Alice narrative content
├── assets/
│   ├── data/
│   │   └── merged_complete_data.csv      # 15,267 oil detections with metadata
│   ├── charts/                           # 23 visualization charts
│   └── images/                           # SAR imagery samples
└── sar-data/                             # Data processing notebooks
    ├── SARveilliance.ipynb
    ├── Laila_SAR_analysis.ipynb
    └── python_scripts_data/
        ├── cleaned_data/                 # Processed CSV datasets
        └── automatd_data_extraction_python_scripts/

nasa-sar-backend/
├── main.py                               # FastAPI server
├── gee_service.py                        # Earth Engine integration
├── requirements.txt
└── Dockerfile
```

## Getting Started

### Prerequisites
- Flutter SDK 3.9.0 or higher
- Dart SDK
- Android Studio / Xcode for mobile deployment
- Python 3.8+ (for backend)
- Google Earth Engine account (for tile serving)

### Installation

1. Clone the repository:
```bash
git clone <repository-url>
cd sarveillance
```

2. Install Flutter dependencies:
```bash
flutter pub get
```

3. Set up the backend (optional, for GEE tiles):
```bash
cd ../nasa-sar-backend
pip install -r requirements.txt
# Add your Earth Engine credentials to .env
python -m uvicorn main:app --reload --host 0.0.0.0 --port 8000
```

4. Run the app:
```bash
cd ../sarveillance
flutter run
```

### Key Dependencies

#### Flutter App
- `google_maps_flutter: ^2.9.0` - Interactive mapping
- `fl_chart: ^0.69.0` - Statistical visualizations
- `csv: ^6.0.0` - Data parsing
- `http: ^1.1.0` - Backend communication
- `provider: ^6.1.1` - State management
- `google_fonts: ^6.1.0` - Typography
- `share_plus: ^10.1.2` - Data sharing

#### Python Backend
- `fastapi==0.104.1` - REST API framework
- `earthengine-api==0.1.384` - Google Earth Engine
- `uvicorn==0.24.0` - ASGI server
- `python-dotenv==1.0.0` - Environment configuration

## Data Analysis Methodology

### Oil Detection Algorithm
1. **Sentinel-1 SAR Data**: C-band dual-polarization (VV+VH)
2. **Water Masking**: JRC Global Surface Water dataset
3. **Threshold Detection**: VV backscatter < -22 dB
4. **Temporal Coverage**: 548 acquisition dates (2015-2024)
5. **Geographic Focus**: Chesapeake Bay region (37°N-40°N, 75°W-77°W)

### Data Integration
- **Weather Correlation**: NASA POWER meteorological data merged by date and location
- **Ship Tracking**: AIS data processed to identify vessels within 5km of detections
- **Machine Learning**: K-means clustering revealing 3 distinct weather pattern types
- **Spatial Analysis**: Hotspot identification and trend analysis

### Dataset Statistics
- Total detections: 15,267
- Date range: March 2015 - October 2024
- Satellite passes: 548
- Weather parameters: 8 (temperature, wind, precipitation, etc.)
- Ship correlation: Distance, type, speed, and count

## Features in Detail

### Story Mode (Alice in Wonderland Theme)
Five interactive chapters that transform scientific data into an engaging narrative:

1. **Down the Rabbit Hole**: Introduction to oil pollution problem
2. **A World That Was**: Historical baseline before human impact
3. **The Mad Hatter's Tea Party**: Timeline of human-caused pollution
4. **Through the Looking Glass**: Multi-frequency SAR analysis
5. **The Queen's Decree**: Proposed solutions and technology

Each chapter includes:
- Animated transitions and themed backgrounds
- Interactive elements (timelines, technology cards, impact previews)
- Alice in Wonderland metaphors connecting to SAR concepts
- Progress tracking and discovery system

### Analysis Tools
- **Multi-layer Visualization**: Toggle between SAR, oil detection, ship tracking, and weather
- **Temporal Filtering**: View data from specific date ranges
- **Ship Correlation**: Identify vessels near oil detections
- **Weather Patterns**: See environmental conditions during detections
- **Hotspot Mapping**: Identify high-frequency detection areas
- **Data Export**: Share findings and statistics

### Educational Components
- SAR technology fundamentals
- Oil detection methodology
- Interferometry and polarimetry concepts
- Environmental impact analysis
- Real-world application examples

## Impact and Benefits

### Environmental Monitoring
- Rapid identification of oil pollution events
- Historical pattern analysis for trend identification
- Ship correlation for potential source identification
- Weather impact assessment on detection rates

### Accessibility
- Mobile-first design for field use
- Offline capability after initial data load
- No specialized SAR analysis expertise required
- Free access to processed satellite data

### Research Applications
- 9+ years of historical pollution data
- Multi-source data integration (SAR + weather + ships)
- Statistical analysis tools
- Exportable datasets and visualizations

## Development Notes

### AI Assistance
This project utilized AI coding assistants (Claude via Cursor IDE) for approximately 80-85% of code generation, including UI components, state management, data visualization integration, and bug fixes. All core intellectual contributions (project concept, scientific methodology, data curation, architecture, and design decisions) were entirely human-created.

### Data Processing
- Initial SAR analysis performed in Jupyter notebooks
- CSV data merged from three sources (SAR, NASA POWER, AIS)
- K-means clustering applied to weather patterns
- Coordinate system normalization across datasets

### Future Enhancements
- Real-time oil detection alerts
- User-submitted pollution reports
- Expanded geographic coverage
- Advanced machine learning models
- Community validation system
- API for external integrations

## Contributing

Created for NASA Space Apps Challenge 2024. For contributions or questions:
1. Fork the repository
2. Create a feature branch
3. Submit a pull request with detailed description

## Image Sources & Attribution

### Explore Page Study Area Cards
All images used on the Explore page study area cards are sourced from **Unsplash** under the Unsplash License:

- **Oil Spills Category**: Ocean/water images
  - Source: [Unsplash](https://unsplash.com)
  - Photographers: Various Unsplash contributors
  - URLs: `https://images.unsplash.com/photo-1530587191325-3db32d826c18`

- **Ship Traffic Category**: Maritime/cargo ship images
  - Source: [Unsplash](https://unsplash.com)
  - Photographers: Various Unsplash contributors
  - URLs: `https://images.unsplash.com/photo-1464037866556-6812c9d1c72e`

- **High-Risk Zone Category**: Industrial port/harbor images
  - Source: [Unsplash](https://unsplash.com)
  - Photographers: Various Unsplash contributors
  - URLs: `https://images.unsplash.com/photo-1605731414355-485f5e5c6d4f`

- **Environmental Category**: Nature/coastal landscape images
  - Source: [Unsplash](https://unsplash.com)
  - Photographers: Various Unsplash contributors
  - URLs: `https://images.unsplash.com/photo-1470071459604-3b5ec3a7fe05`

- **Temporal Analysis Category**: Earth from space/satellite images
  - Source: [Unsplash](https://unsplash.com)
  - Photographers: Various Unsplash contributors
  - URLs: `https://images.unsplash.com/photo-1451187580459-43490279c0fa`

- **Machine Learning Category**: Technology/AI visualization images
  - Source: [Unsplash](https://unsplash.com)
  - Photographers: Various Unsplash contributors
  - URLs: `https://images.unsplash.com/photo-1535378917042-10a22c95931a`

### Unsplash License
All Unsplash photos are free to use for commercial and non-commercial purposes with no permission needed. Attribution is appreciated but not required. Learn more at [Unsplash License](https://unsplash.com/license).

### Other Visual Assets
- **App Icons & UI Elements**: Custom-designed Flutter Material 3 icons and widgets
- **Statistical Charts**: Generated from SAR analysis data stored in `assets/charts/`
- **NASA Branding**: No NASA logos, flags, or mission identifiers are used in this project per NASA Space Apps Challenge guidelines

## License

Created for NASA Space Apps Challenge 2024.

## Acknowledgments

- NASA for Sentinel-1 SAR data access
- Google Earth Engine for satellite imagery processing
- NASA POWER API for meteorological data
- NOAA for AIS ship tracking data
- JRC for Global Surface Water dataset
- Flutter and Dart communities

## Contact

Project created for NASA Space Apps Challenge 2024 - Chesapeake Bay Oil Spill Detection
