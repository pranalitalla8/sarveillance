import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../widgets/layer_control_panel.dart';
import '../widgets/measurement_tools.dart';
import '../widgets/sar_viewer.dart';
import '../widgets/region_info_panel.dart';
import '../models/map_region.dart';
import '../services/region_data_service.dart';
import 'time_series_screen.dart';

class AnalyzeScreen extends StatefulWidget {
  const AnalyzeScreen({super.key});

  @override
  State<AnalyzeScreen> createState() => _AnalyzeScreenState();
}

class _AnalyzeScreenState extends State<AnalyzeScreen> {
  bool _showLayerPanel = false;
  bool _showMeasurementTools = false;
  String _selectedTool = 'none';
  
  // Region selection
  MapRegion? _selectedRegion;
  RegionData? _regionData;
  final _regionService = RegionDataService();
  bool _isLoadingData = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('SAR Analysis'),
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
            icon: Icon(
              _showLayerPanel ? Icons.layers : Icons.layers_outlined,
              color: _showLayerPanel ? Theme.of(context).colorScheme.primary : null,
            ),
            onPressed: () {
              setState(() {
                _showLayerPanel = !_showLayerPanel;
                if (_showLayerPanel) _showMeasurementTools = false;
              });
            },
            tooltip: 'Layer Controls',
          ),
          IconButton(
            icon: Icon(
              _showMeasurementTools ? Icons.straighten : Icons.straighten_outlined,
              color: _showMeasurementTools ? Theme.of(context).colorScheme.primary : null,
            ),
            onPressed: () {
              setState(() {
                _showMeasurementTools = !_showMeasurementTools;
                if (_showMeasurementTools) _showLayerPanel = false;
              });
            },
            tooltip: 'Measurement Tools',
          ),
          IconButton(
            icon: const Icon(Icons.show_chart),
            onPressed: () => _navigateToTimeSeries(),
            tooltip: 'Time Series Analysis',
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => _showSettings(),
            tooltip: 'Settings',
          ),
        ],
      ),
      body: Stack(
        children: [
          FlutterMap(
            options: MapOptions(
              initialCenter: const LatLng(37.8, -76.1), // Chesapeake Bay
              initialZoom: 9.0,
              onTap: (tapPosition, point) => _handleMapTap(point),
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.nasa.sar_app',
              ),
              // Show selected region overlay
              if (_selectedRegion != null) ...[
                CircleLayer(
                  circles: [
                    CircleMarker(
                      point: _selectedRegion!.center,
                      color: Colors.blue.withValues(alpha: 0.2),
                      borderColor: Colors.blue,
                      borderStrokeWidth: 2,
                      radius: _selectedRegion!.radiusKm * 1000, // Convert to meters for display
                      useRadiusInMeter: true,
                    ),
                  ],
                ),
                MarkerLayer(
                  markers: [
                    Marker(
                      point: _selectedRegion!.center,
                      width: 40,
                      height: 40,
                      child: const Icon(
                        Icons.place,
                        color: Colors.blue,
                        size: 40,
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
          if (_showLayerPanel)
            Positioned(
              right: 16,
              top: 16,
              bottom: 80,
              width: 300,
              child: LayerControlPanel(
                onClose: () => setState(() => _showLayerPanel = false),
              ),
            ),
          if (_showMeasurementTools)
            Positioned(
              right: 16,
              top: 16,
              bottom: 80,
              width: 250,
              child: MeasurementTools(
                selectedTool: _selectedTool,
                onToolChanged: (tool) => setState(() => _selectedTool = tool),
                onClose: () => setState(() => _showMeasurementTools = false),
              ),
            ),
          // Region info panel
          if (_selectedRegion != null)
            Positioned(
              left: 16,
              top: 16,
              bottom: 80,
              child: RegionInfoPanel(
                region: _selectedRegion!,
                data: _regionData,
                onClose: _clearSelection,
                onLoadData: _loadRegionData,
              ),
            ),
          // Compact info panel (only show when no region selected)
          if (_selectedRegion == null)
            Positioned(
              left: 16,
              bottom: 16,
              child: _buildCompactInfoPanel(),
            ),
          Positioned(
            right: 16,
            bottom: 16,
            child: _buildCompactActions(),
          ),
        ],
      ),
    );
  }

  Widget _buildCompactInfoPanel() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Hurricane Ian Impact',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 2),
            Row(
              children: [
                const Icon(Icons.satellite, size: 12),
                const SizedBox(width: 4),
                Text(
                  'Sentinel-1 • 2 days ago',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCompactActions() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        FloatingActionButton(
          heroTag: "analyze",
          mini: true,
          onPressed: () => _showAnalysisOptions(),
          tooltip: 'Analyze',
          child: const Icon(Icons.analytics),
        ),
        const SizedBox(height: 8),
        FloatingActionButton(
          heroTag: "change",
          mini: true,
          onPressed: () => _performAnalysis('Change Detection'),
          tooltip: 'Change Detection',
          child: const Icon(Icons.timeline),
        ),
        const SizedBox(height: 8),
        FloatingActionButton(
          heroTag: "interferometry",
          mini: true,
          onPressed: () => _performAnalysis('Interferometry'),
          tooltip: 'Interferometry',
          child: const Icon(Icons.speed),
        ),
      ],
    );
  }

  void _navigateToTimeSeries() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const TimeSeriesScreen(),
      ),
    );
  }

  void _showSettings() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Analysis Settings',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            const ListTile(
              leading: Icon(Icons.palette),
              title: Text('Color Map'),
              subtitle: Text('Viridis'),
              trailing: Icon(Icons.chevron_right),
            ),
            const ListTile(
              leading: Icon(Icons.tune),
              title: Text('Contrast'),
              subtitle: Text('Auto'),
              trailing: Icon(Icons.chevron_right),
            ),
            const ListTile(
              leading: Icon(Icons.grid_on),
              title: Text('Grid Overlay'),
              trailing: Switch(value: true, onChanged: null),
            ),
          ],
        ),
      ),
    );
  }

  void _showAnalysisOptions() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Analysis Tools',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.timeline),
              title: const Text('Change Detection'),
              subtitle: const Text('Compare temporal datasets'),
              onTap: () => _performAnalysis('Change Detection'),
            ),
            ListTile(
              leading: const Icon(Icons.speed),
              title: const Text('Interferometry'),
              subtitle: const Text('Measure ground deformation'),
              onTap: () => _performAnalysis('Interferometry'),
            ),
            ListTile(
              leading: const Icon(Icons.category),
              title: const Text('Classification'),
              subtitle: const Text('Classify land cover types'),
              onTap: () => _performAnalysis('Classification'),
            ),
          ],
        ),
      ),
    );
  }

  void _performAnalysis(String analysisType) {
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Starting $analysisType analysis...'),
        behavior: SnackBarBehavior.floating,
        action: SnackBarAction(
          label: 'View Progress',
          onPressed: () {},
        ),
      ),
    );
  }

  // Region selection handlers
  void _handleMapTap(LatLng point) {
    setState(() {
      // Create a new region at the tapped location
      _selectedRegion = MapRegion.circular(
        id: 'custom_${DateTime.now().millisecondsSinceEpoch}',
        name: 'Selected Region',
        center: point,
        radiusKm: 10.0,
      );
      // Clear previous data
      _regionData = null;
    });

    // Show instruction
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Region selected! Click "Load Data" to fetch SAR data.'),
        duration: Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _clearSelection() {
    setState(() {
      _selectedRegion = null;
      _regionData = null;
      _isLoadingData = false;
    });
  }

  Future<void> _loadRegionData() async {
    if (_selectedRegion == null || _isLoadingData) return;

    setState(() {
      _isLoadingData = true;
      _regionData = RegionData(
        regionId: _selectedRegion!.id,
        timestamp: DateTime.now(),
        status: LoadingStatus.loading,
      );
    });

    try {
      final data = await _regionService.loadRegionData(_selectedRegion!);
      
      if (mounted) {
        setState(() {
          _regionData = data;
          _isLoadingData = false;
        });

        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Data loaded! ${data.oilSpills != null ? "⚠️ Oil spills detected" : "✓ No issues detected"}',
            ),
            duration: const Duration(seconds: 3),
            behavior: SnackBarBehavior.floating,
            backgroundColor: data.oilSpills != null ? Colors.orange : Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _regionData = RegionData(
            regionId: _selectedRegion!.id,
            timestamp: DateTime.now(),
            status: LoadingStatus.error,
            errorMessage: e.toString(),
          );
          _isLoadingData = false;
        });
      }
    }
  }
}