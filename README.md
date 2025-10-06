# NASA SAR Data Visualization App

A Flutter application for visualizing and analyzing Synthetic Aperture Radar (SAR) data from NASA satellites, built for the NASA Space Apps Challenge.

## Features

### Functionality
- **Explore Tab**: Browse study areas with categorized SAR datasets (Disasters, Climate, Urban, Natural Features)
- **Analyze Tab**: Interactive SAR data viewer with layer controls, measurement tools, and analysis capabilities
- **Compare Tab**: Side-by-side comparison of temporal datasets with multiple viewing modes (overlay, swipe, difference)
- **Discover Tab**: Educational content about SAR technology and Earth observation
- **Profile Tab**: User settings, saved analyses, and account management

### Design Features
- Modern NASA-themed dark design with space gradients
- Material 3 design principles
- NASA blue accent color (#0B3D91)
- Responsive layout with proper spacing and elevation
- Subtle animations and transitions

### Technical Features
- Flutter Material 3 theming
- Custom reusable widgets
- Mock data for demonstration
- Interactive visualizations
- Bottom navigation with 5 tabs
- Floating action buttons for key actions

## Screenshots

The app includes:
- Grid-based study area cards with preview images
- Interactive SAR data viewer with zoom and pan
- Layer control panels for data visualization
- Measurement tools for distance, area, and angle calculations
- Timeline sliders for temporal comparisons
- Educational content cards with learning paths
- Comprehensive user profile and settings

## Project Structure

```
lib/
├── main.dart                 # App entry point
├── screens/                  # Main screen widgets
│   ├── main_screen.dart     # Bottom navigation container
│   ├── explore_screen.dart  # Study areas browser
│   ├── analyze_screen.dart  # SAR data viewer
│   ├── compare_screen.dart  # Temporal comparison
│   ├── discover_screen.dart # Educational content
│   └── profile_screen.dart  # User settings
├── widgets/                  # Reusable components
│   ├── study_area_card.dart
│   ├── category_filter.dart
│   ├── sar_viewer.dart
│   ├── layer_control_panel.dart
│   ├── measurement_tools.dart
│   ├── comparison_viewer.dart
│   ├── timeline_slider.dart
│   ├── educational_card.dart
│   └── learning_path.dart
├── theme/                    # App theming
│   └── app_theme.dart
├── models/                   # Data models
│   └── study_area.dart
└── data/                     # Mock data
    └── mock_data.dart
```

## Getting Started

### Prerequisites
- Flutter SDK (3.0.0 or higher)
- Dart SDK
- Android Studio / VS Code with Flutter extensions

### Installation

1. Clone the repository:
```bash
git clone <repository-url>
cd nasa_sar_app
```

2. Install dependencies:
```bash
flutter pub get
```

3. Run the app:
```bash
flutter run
```

### Dependencies
- `flutter`: Flutter SDK
- `google_fonts`: Custom typography
- `cupertino_icons`: iOS-style icons

## Key Components

### Study Areas
Mock SAR datasets covering:
- Hurricane damage assessment
- Deforestation monitoring
- Urban growth analysis
- Glacier retreat tracking
- Volcanic activity detection
- Earthquake damage assessment

### Analysis Tools
- Interactive SAR data visualization
- Layer management (backscatter, coherence, amplitude, phase)
- Measurement tools (distance, area, angle, profile)
- Change detection algorithms
- Interferometry capabilities

### Educational Content
- SAR technology fundamentals
- Interferometry principles
- Polarimetry concepts
- Change detection methods
- Real-world applications

## Future Enhancements

This initial UI implementation provides the foundation for:
- Real SAR data integration
- Advanced analysis algorithms
- Cloud-based processing
- Collaborative features
- Export capabilities
- Offline functionality

## Contributing

This project was created for the NASA Space Apps Challenge. For contributions:
1. Fork the repository
2. Create a feature branch
3. Submit a pull request

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

Created for NASA Space Apps Challenge 2025.
