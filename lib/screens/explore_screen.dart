import 'package:flutter/material.dart';
import '../data/mock_data.dart';
import '../models/study_area.dart';
import '../widgets/study_area_card.dart';
import '../widgets/category_filter.dart';

// Test comment added
class ExploreScreen extends StatefulWidget {
  const ExploreScreen({super.key});

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  String selectedCategory = 'All';
  List<StudyArea> filteredAreas = MockData.studyAreas;

  void _filterByCategory(String category) {
    setState(() {
      selectedCategory = category;
      if (category == 'All') {
        filteredAreas = MockData.studyAreas;
      } else {
        filteredAreas = MockData.getAreasByCategory(category);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Explore Oil Spill Data'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Theme.of(context).colorScheme.primaryContainer,
                Theme.of(context).colorScheme.surface,
              ],
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Chesapeake Bay Studies',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: 8),
                Text(
                  'Explore oil spill monitoring areas across Chesapeake Bay',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                  ),
                ),
                const SizedBox(height: 16),
                CategoryFilter(
                  selectedCategory: selectedCategory,
                  onCategorySelected: _filterByCategory,
                ),
              ],
            ),
          ),
          Expanded(
            child: filteredAreas.isEmpty
                ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.search_off,
                              size: 64,
                              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No study areas found',
                              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Try selecting a different category',
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
                              ),
                            ),
                          ],
                        ),
                      )
                    : GridView.builder(
                        padding: const EdgeInsets.all(16),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                          childAspectRatio: 0.6,
                        ),
                        itemCount: filteredAreas.length,
                        itemBuilder: (context, index) {
                          return StudyAreaCard(
                            studyArea: filteredAreas[index],
                            onTap: () => _navigateToAnalyze(filteredAreas[index]),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }

  void _navigateToAnalyze(StudyArea area) {
    showDialog(
      context: context,
      builder: (context) => _StudyAreaDetailDialog(studyArea: area),
    );
  }
}

class _StudyAreaDetailDialog extends StatelessWidget {
  final StudyArea studyArea;

  const _StudyAreaDetailDialog({required this.studyArea});

  @override
  Widget build(BuildContext context) {
    final charts = _getRelevantCharts(studyArea.category);
    
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 600, maxHeight: 700),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Theme.of(context).colorScheme.primaryContainer,
                    Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.7),
                  ],
                ),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          studyArea.title,
                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.close),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(
                        Icons.location_on,
                        size: 16,
                        color: Theme.of(context).colorScheme.onPrimaryContainer.withValues(alpha: 0.7),
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          studyArea.location,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Theme.of(context).colorScheme.onPrimaryContainer.withValues(alpha: 0.7),
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Flexible(
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.primary,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            studyArea.category,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            
            // Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Overview section
                    Text(
                      'Overview',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      studyArea.description,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 24),
                    
                    // Key metrics
                    Text(
                      'Key Metrics',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildMetricsGrid(context),
                    const SizedBox(height: 24),
                    
                    // Statistical charts
                    if (charts.isNotEmpty) ...[
                      Text(
                        'Statistical Analysis',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      ...charts.map((chart) => _buildChartCard(context, chart)),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricsGrid(BuildContext context) {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: studyArea.metadata.entries.map((entry) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainer,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _formatMetricLabel(entry.key),
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                entry.value.toString(),
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildChartCard(BuildContext context, Map<String, String> chart) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Image.asset(
            chart['path']!,
            width: double.infinity,
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) {
              return Container(
                height: 200,
                color: Theme.of(context).colorScheme.surfaceContainer,
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.broken_image,
                        size: 48,
                        color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.3),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Chart: ${chart['title']}',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  chart['title']!,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (chart['description'] != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    chart['description']!,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatMetricLabel(String key) {
    return key
        .replaceAll('_', ' ')
        .split(' ')
        .map((word) => word[0].toUpperCase() + word.substring(1))
        .join(' ');
  }

  List<Map<String, String>> _getRelevantCharts(String category) {
    // Map study area categories to relevant charts
    final allCharts = <Map<String, String>>[];
    
    switch (category) {
      case 'Oil Spills':
        allCharts.addAll([
          {
            'title': 'Oil Detection Points Over Time',
            'path': 'assets/charts/OilDetectionPointsColoredByDate.webp',
            'description': 'Temporal distribution of oil spill detections across Chesapeake Bay',
          },
          {
            'title': 'VH vs VV Backscatter by Oil Candidate',
            'path': 'assets/charts/VHvsVVByOilCandidate.webp',
            'description': 'SAR polarization analysis distinguishing oil from water',
          },
          {
            'title': 'VH/VV Ratio Distribution',
            'path': 'assets/charts/DistributionOfVHVVRatio&VHVVRatioByOilCandidate.webp',
            'description': 'Statistical distribution of the VH/VV ratio for oil detection',
          },
        ]);
        break;
      
      case 'Ship Traffic':
        allCharts.addAll([
          {
            'title': 'VH/VV Ratio by Weekday',
            'path': 'assets/charts/VHVVRatioByWeekdayOilvsNon-Oil.webp',
            'description': 'Temporal patterns showing ship-related oil incidents by day of week',
          },
          {
            'title': 'Wind Speed vs VH/VV Ratio',
            'path': 'assets/charts/WindSpeedvsVHVVRatioOilCandidateHighlight.webp',
            'description': 'Correlation between wind conditions and oil detection in shipping lanes',
          },
        ]);
        break;
      
      case 'High-Risk Zone':
        allCharts.addAll([
          {
            'title': 'Oil Detection Points',
            'path': 'assets/charts/OilDetectionPointsColoredByDate.webp',
            'description': 'Hotspot analysis showing concentration of oil spill incidents',
          },
          {
            'title': 'Feature Correlation Heatmap',
            'path': 'assets/charts/FeatureCorrelationHeatmap.webp',
            'description': 'Correlation analysis of factors contributing to high-risk areas',
          },
        ]);
        break;
      
      case 'Environmental':
        allCharts.addAll([
          {
            'title': 'NASA POWER Temperature vs Oil Presence',
            'path': 'assets/charts/NASAPowerAirTemp2mvsOilPresence.webp',
            'description': 'Environmental temperature impact on oil spill detection',
          },
          {
            'title': 'NASA POWER Solar Radiation',
            'path': 'assets/charts/NASAPowerSolarRadiationMJm2dayvsOilPresence.webp',
            'description': 'Solar radiation correlation with oil presence',
          },
          {
            'title': 'Backscatter Distribution',
            'path': 'assets/charts/DistributionOfVHBackscatter&DistributionOfVVBackscatter.webp',
            'description': 'SAR backscatter characteristics in coastal environments',
          },
        ]);
        break;
      
      case 'Temporal Analysis':
        allCharts.addAll([
          {
            'title': 'Clustered Weather Patterns',
            'path': 'assets/charts/ClusteredWeatherPatternsTempvsPrecip.webp',
            'description': 'K-means clustering of weather conditions affecting oil detection',
          },
          {
            'title': 'Daily Mean SAR & Wind Speed',
            'path': 'assets/charts/DailyMeanSAR&WindSpeed.webp',
            'description': 'Temporal trends in SAR signatures and meteorological conditions',
          },
          {
            'title': 'NASA POWER Wind Speed Analysis',
            'path': 'assets/charts/NASAPowerWindSpeed2mmpersvsOilPresence.webp',
            'description': 'Wind speed correlation with oil spill detection rates',
          },
          {
            'title': 'Precipitation vs Oil Presence',
            'path': 'assets/charts/NASAPowerPrecipiationMMvsOilPresence.webp',
            'description': 'Rainfall impact on oil spill visibility and detection',
          },
        ]);
        break;
      
      default:
        // Show general overview charts
        allCharts.addAll([
          {
            'title': 'Feature Correlation Heatmap',
            'path': 'assets/charts/FeatureCorrelationHeatmap.webp',
            'description': 'Comprehensive correlation analysis of all SAR and environmental features',
          },
          {
            'title': 'Oil Candidate Behavior PCA',
            'path': 'assets/charts/OilCandidateBehaviorPCAProjection.webp',
            'description': 'Principal Component Analysis revealing oil detection patterns',
          },
        ]);
    }
    
    return allCharts;
  }
}