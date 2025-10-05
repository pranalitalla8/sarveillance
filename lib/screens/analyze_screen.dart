import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../widgets/layer_control_panel.dart';
import '../widgets/measurement_tools.dart';
import '../widgets/sar_viewer.dart';
import '../services/sar_data_service.dart';
import '../models/oil_spill_data.dart';

class AnalyzeScreen extends StatefulWidget {
  const AnalyzeScreen({super.key});

  @override
  State<AnalyzeScreen> createState() => _AnalyzeScreenState();
}

class _AnalyzeScreenState extends State<AnalyzeScreen> {
  bool _showLayerPanel = false;
  bool _showMeasurementTools = false;
  String _selectedTool = 'none';
  List<OilSpillData> _oilSpillData = [];
  bool _isLoading = true;
  final SARDataService _sarDataService = SARDataService();

  @override
  void initState() {
    super.initState();
    _loadSARData();
  }

  Future<void> _loadSARData() async {
    try {
      final data = await _sarDataService.loadSARData();
      setState(() {
        _oilSpillData = data;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading SAR data: $e');
      setState(() {
        _isLoading = false;
      });
    }
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
              initialCenter: LatLng(37.8, -76.1), // Chesapeake Bay
              initialZoom: 9.0,
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.nasa.sar_app',
              ),
              if (!_isLoading && _oilSpillData.isNotEmpty)
                CircleLayer(
                  circles: _oilSpillData.map((point) {
                    Color markerColor;
                    double radius;

                    // Color based on SAR value (higher = more likely oil spill)
                    if (point.sar >= 0.7) {
                      markerColor = Colors.red.withOpacity(0.7);
                      radius = 8;
                    } else if (point.sar >= 0.4) {
                      markerColor = Colors.orange.withOpacity(0.6);
                      radius = 6;
                    } else {
                      markerColor = Colors.yellow.withOpacity(0.5);
                      radius = 4;
                    }

                    return CircleMarker(
                      point: LatLng(point.latitude, point.longitude),
                      color: markerColor,
                      borderColor: Colors.white.withOpacity(0.3),
                      borderStrokeWidth: 1,
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

  Widget _buildCompactInfoPanel() {
    final highRiskPoints = _oilSpillData.where((p) => p.sar >= 0.7).length;
    final mediumRiskPoints = _oilSpillData.where((p) => p.sar >= 0.4 && p.sar < 0.7).length;
    final lowRiskPoints = _oilSpillData.where((p) => p.sar < 0.4).length;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(8),
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
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(Icons.circle, size: 8, color: Colors.red),
                const SizedBox(width: 4),
                Text('High: $highRiskPoints', style: Theme.of(context).textTheme.bodySmall),
                const SizedBox(width: 8),
                const Icon(Icons.circle, size: 8, color: Colors.orange),
                const SizedBox(width: 4),
                Text('Med: $mediumRiskPoints', style: Theme.of(context).textTheme.bodySmall),
                const SizedBox(width: 8),
                const Icon(Icons.circle, size: 8, color: Colors.yellow),
                const SizedBox(width: 4),
                Text('Low: $lowRiskPoints', style: Theme.of(context).textTheme.bodySmall),
              ],
            ),
            const SizedBox(height: 2),
            Row(
              children: [
                const Icon(Icons.satellite, size: 12),
                const SizedBox(width: 4),
                Text(
                  'Total points: ${_oilSpillData.length}',
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
}