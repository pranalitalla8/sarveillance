import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../widgets/layer_control_panel.dart';
import '../widgets/measurement_tools.dart';
import '../widgets/spill_detail_popup.dart';
import '../widgets/environmental_heatmap.dart';
import '../models/map_region.dart';
import '../models/oil_spill_data.dart';
import '../services/sar_data_service.dart';
import 'time_series_screen.dart';
import 'data_management_screen.dart';
import 'statistics_dashboard_screen.dart';

class AnalyzeScreen extends StatefulWidget {
  const AnalyzeScreen({super.key});

  @override
  State<AnalyzeScreen> createState() => _AnalyzeScreenState();
}

class _AnalyzeScreenState extends State<AnalyzeScreen> {
  bool _showLayerPanel = false;
  bool _showMeasurementTools = false;
  bool _showShipLayer = true;
  bool _highlightShipCorrelation = true;

  // Environmental heatmap layers
  String? _activeHeatmap; // 'temperature', 'wind', 'precipitation', etc.
  double _heatmapOpacity = 0.6;

  String _selectedTool = 'none';
  List<OilSpillData> _oilSpillData = [];
  List<OilSpillData> _allData = [];
  bool _isLoading = true;
  double _currentZoom = 9.0;
  static const int MAX_MARKERS = 2000; // Limit for performance
  final SARDataService _sarDataService = SARDataService();
  final MapController _mapController = MapController();

  @override
  void initState() {
    super.initState();
    _loadSARData();
  }

  Future<void> _loadSARData() async {
    print('_loadSARData() called');
    try {
      print('Calling _sarDataService.loadSARData()...');
      final data = await _sarDataService.loadSARData();
      print('Received data: ${data.length} points');
      setState(() {
        _allData = data;
        _oilSpillData = _sampleData(data);
        _isLoading = false;
      });
      print('Loaded ${data.length} total points, displaying ${_oilSpillData.length}');
    } catch (e, stackTrace) {
      print('Error loading SAR data: $e');
      print('Stack trace: $stackTrace');
      setState(() {
        _isLoading = false;
      });
    }
  }

  List<OilSpillData> _sampleData(List<OilSpillData> data) {
    if (data.length <= MAX_MARKERS) {
      return data;
    }

    // Prioritize ship-related oil spills and sample the rest
    final shipRelated = data.where((d) => d.isOilCandidate && d.isShipRelated).toList();
    final oil = data.where((d) => d.isOilCandidate && !d.isShipRelated).toList();
    final water = data.where((d) => !d.isOilCandidate).toList();

    print('Sampling: ${shipRelated.length} ship-related, ${oil.length} oil, ${water.length} water');

    // Always show all ship-related points
    final result = <OilSpillData>[...shipRelated];
    final remaining = MAX_MARKERS - shipRelated.length;

    if (remaining <= 0) return result;

    // Sample oil and water proportionally
    final oilToShow = (remaining * 0.7).toInt();
    final waterToShow = remaining - oilToShow;

    // Evenly sample oil points
    final oilStep = oil.length / oilToShow;
    for (int i = 0; i < oilToShow && i * oilStep < oil.length; i++) {
      result.add(oil[(i * oilStep).toInt()]);
    }

    // Evenly sample water points
    final waterStep = water.length / waterToShow;
    for (int i = 0; i < waterToShow && i * waterStep < water.length; i++) {
      result.add(water[(i * waterStep).toInt()]);
    }

    return result;
  }

  void _showSpillDetails(OilSpillData spillData) {
    showDialog(
      context: context,
      builder: (context) => SpillDetailPopup(spillData: spillData),
    );
  }

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
            icon: const Icon(Icons.storage),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const DataManagementScreen(),
                ),
              );
            },
            tooltip: 'Data Sources',
          ),
        ],
      ),
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: const LatLng(37.8, -76.1), // Chesapeake Bay
              initialZoom: 9.0,
              minZoom: 2.0,
              maxZoom: 18.0,
              // Lock rotation and tilt
              interactionOptions: const InteractionOptions(
                flags: InteractiveFlag.all & ~InteractiveFlag.rotate,
              ),
              // Constrain panning to world bounds
              cameraConstraint: CameraConstraint.contain(
                bounds: LatLngBounds(
                  const LatLng(-90, -180),
                  const LatLng(90, 180),
                ),
              ),
              onTap: (tapPosition, point) {
                // Find nearest marker when map is tapped
                _findAndShowNearestSpill(point);
              },
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.nasa.sar_app',
              ),
              // Environmental heatmap layer (rendered before markers)
              if (_activeHeatmap != null && !_isLoading && _allData.isNotEmpty)
                EnvironmentalHeatmap(
                  data: _allData,
                  heatmapType: _activeHeatmap!,
                  opacity: _heatmapOpacity,
                ),
              if (!_isLoading && _oilSpillData.isNotEmpty)
                CircleLayer(
                  circles: _oilSpillData.map((point) {
                    Color markerColor;
                    double radius;

                    // Prioritize ship-related coloring first
                    if (_highlightShipCorrelation && point.isOilCandidate && point.isShipRelated) {
                      // Orange for ship-related oil spills (potential illegal dumping)
                      markerColor = Colors.orange.withOpacity(0.95);
                      radius = 10;
                    } else if (point.isOilCandidate) {
                      // Red for oil candidates
                      markerColor = Colors.red.withOpacity(0.7);
                      radius = 8;
                    } else {
                      // Blue for water
                      markerColor = Colors.blue.withOpacity(0.5);
                      radius = 5;
                    }

                    return CircleMarker(
                      point: LatLng(point.latitude, point.longitude),
                      color: markerColor,
                      borderColor: Colors.white.withOpacity(0.5),
                      borderStrokeWidth: 2,
                      radius: radius,
                    );
                  }).toList(),
                ),
            ],
          ),
          if (_isLoading)
            Center(
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const CircularProgressIndicator(),
                      const SizedBox(height: 16),
                      Text(
                        'Loading SAR Data...',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Please wait...',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          if (_showLayerPanel)
            Positioned(
              right: 16,
              top: 16,
              bottom: 80,
              width: 300,
              child: LayerControlPanel(
                onClose: () => setState(() => _showLayerPanel = false),
                showShipLayer: _showShipLayer,
                highlightShipCorrelation: _highlightShipCorrelation,
                onShipLayerChanged: (value) {
                  setState(() => _showShipLayer = value);
                },
                onShipCorrelationChanged: (value) {
                  setState(() => _highlightShipCorrelation = value);
                },
                activeHeatmap: _activeHeatmap,
                heatmapOpacity: _heatmapOpacity,
                onHeatmapChanged: (value) {
                  setState(() => _activeHeatmap = value);
                },
                onHeatmapOpacityChanged: (value) {
                  setState(() => _heatmapOpacity = value);
                },
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

  void _findAndShowNearestSpill(LatLng tappedPoint) {
    if (_oilSpillData.isEmpty) return;

    // Find the nearest spill within a reasonable distance
    OilSpillData? nearestSpill;
    double minDistance = double.infinity;
    const double maxDistanceKm = 0.5; // 500 meters

    for (final spill in _oilSpillData) {
      final spillPoint = LatLng(spill.latitude, spill.longitude);
      final distance = const Distance().as(LengthUnit.Kilometer, tappedPoint, spillPoint);

      if (distance < minDistance && distance < maxDistanceKm) {
        minDistance = distance;
        nearestSpill = spill;
      }
    }

    if (nearestSpill != null) {
      _showSpillDetails(nearestSpill);
    }
  }

  Widget _buildCompactInfoPanel() {
    final oilPoints = _oilSpillData.where((p) => p.isOilCandidate).length;
    final waterPoints = _oilSpillData.where((p) => !p.isOilCandidate).length;
    final shipRelated = _oilSpillData.where((p) => p.isShipRelated).length;
    final stats = _sarDataService.getStatistics();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Chesapeake Bay SAR Analysis',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.circle, size: 8, color: Colors.red),
                const SizedBox(width: 4),
                Text('Oil: $oilPoints', style: Theme.of(context).textTheme.bodySmall),
                const SizedBox(width: 12),
                const Icon(Icons.circle, size: 8, color: Colors.blue),
                const SizedBox(width: 4),
                Text('Water: $waterPoints', style: Theme.of(context).textTheme.bodySmall),
              ],
            ),
            if (shipRelated > 0) ...[
              const SizedBox(height: 4),
              Row(
                children: [
                  const Icon(Icons.circle, size: 8, color: Colors.orange),
                  const SizedBox(width: 4),
                  Text('Ship Related: $shipRelated',
                      style: Theme.of(context).textTheme.bodySmall),
                ],
              ),
            ],
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(Icons.calendar_today, size: 12),
                const SizedBox(width: 4),
                Text(
                  'Dates: ${stats['unique_dates']}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(width: 8),
                const Icon(Icons.satellite, size: 12),
                const SizedBox(width: 4),
                Text(
                  'Showing: ${_oilSpillData.length} / ${_allData.length}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Tap a marker for details',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontStyle: FontStyle.italic,
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                  ),
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
          heroTag: "filter",
          mini: true,
          onPressed: () => _showFilterOptions(),
          tooltip: 'Filter Data',
          child: const Icon(Icons.filter_list),
        ),
        const SizedBox(height: 8),
        FloatingActionButton(
          heroTag: "stats",
          mini: true,
          onPressed: () => _showStatistics(),
          tooltip: 'Statistics',
          child: const Icon(Icons.analytics),
        ),
        const SizedBox(height: 8),
        FloatingActionButton(
          heroTag: "refresh",
          mini: true,
          onPressed: () => _loadSARData(),
          tooltip: 'Refresh Data',
          child: const Icon(Icons.refresh),
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

  void _showFilterOptions() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Filter Options',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.water_drop, color: Colors.red),
              title: const Text('Show Oil Candidates Only'),
              onTap: () {
                Navigator.pop(context);
                setState(() {
                  _oilSpillData = _sarDataService.getOilCandidates();
                });
              },
            ),
            ListTile(
              leading: const Icon(Icons.water, color: Colors.blue),
              title: const Text('Show Water Points Only'),
              onTap: () {
                Navigator.pop(context);
                setState(() {
                  _oilSpillData = _sarDataService.getWaterPoints();
                });
              },
            ),
            if (_sarDataService.getShipRelatedPoints().isNotEmpty)
              ListTile(
                leading: const Icon(Icons.directions_boat, color: Colors.orange),
                title: const Text('Show Ship-Related Only'),
                onTap: () {
                  Navigator.pop(context);
                  setState(() {
                    _oilSpillData = _sarDataService.getShipRelatedPoints();
                  });
                },
              ),
            ListTile(
              leading: const Icon(Icons.refresh),
              title: const Text('Show All Data'),
              onTap: () {
                Navigator.pop(context);
                _loadSARData();
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showStatistics() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => StatisticsDashboardScreen(data: _allData),
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

  Widget _buildStatRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Theme.of(context).colorScheme.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ),
          Text(
            value,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary,
                ),
          ),
        ],
      ),
    );
  }
}
