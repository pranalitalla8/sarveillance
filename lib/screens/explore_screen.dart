import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../data/mock_data.dart';
import '../models/study_area.dart';
import '../widgets/study_area_card.dart';
import '../widgets/category_filter.dart';

class ExploreScreen extends StatefulWidget {
  const ExploreScreen({super.key});

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  String selectedCategory = 'All';
  List<StudyArea> filteredAreas = MockData.studyAreas;
  bool showMapView = true;

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
        title: const Text('Explore SAR Data'),
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
        actions: [
          IconButton(
            icon: Icon(showMapView ? Icons.grid_view : Icons.map),
            onPressed: () {
              setState(() {
                showMapView = !showMapView;
              });
            },
            tooltip: showMapView ? 'Show Grid View' : 'Show Map View',
          ),
        ],
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
                  'Study Areas',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: 8),
                Text(
                  'Explore SAR data from around the world',
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
            child: showMapView
                ? FlutterMap(
                    options: MapOptions(
                      initialCenter: LatLng(37.8, -76.1), // Chesapeake Bay
                      initialZoom: 9.0,
                    ),
                    children: [
                      TileLayer(
                        urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                        userAgentPackageName: 'com.nasa.sar_app',
                      ),
                    ],
                  )
                : filteredAreas.isEmpty
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
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddAreaDialog(),
        icon: const Icon(Icons.add),
        label: const Text('Add Area'),
      ),
    );
  }

  void _navigateToAnalyze(StudyArea area) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Opening ${area.title} for analysis'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showAddAreaDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Study Area'),
        content: const Text('This feature would allow you to add new study areas from satellite data sources.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}