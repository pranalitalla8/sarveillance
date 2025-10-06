import 'dart:async';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import '../widgets/layer_control_panel.dart';
import '../widgets/spill_detail_popup.dart';
import '../models/oil_spill_data.dart';
import '../services/sar_data_service.dart';
import '../services/gee_tile_service.dart';
import 'data_management_screen.dart';
import 'statistics_dashboard_screen.dart';

class AnalyzeScreenGoogle extends StatefulWidget {
  const AnalyzeScreenGoogle({super.key});

  @override
  State<AnalyzeScreenGoogle> createState() => _AnalyzeScreenGoogleState();
}

class _AnalyzeScreenGoogleState extends State<AnalyzeScreenGoogle> {
  bool _showLayerPanel = false;
  bool _showShipLayer = true;
  bool _highlightShipCorrelation = true;

  // Environmental heatmap layers
  String? _activeHeatmap;
  double _heatmapOpacity = 0.6;

  // Data point filtering
  double _dataPointPercentage = 1.0; // 100% by default

  // Google Earth Engine tile layers
  bool _showGEESAR = true;
  bool _showGEEOilDetection = true;
  String? _geeSARTileUrl;
  String? _geeOilTileUrl;
  String _geeStartDate = '2024-01-01';
  String _geeEndDate = '2024-12-31';
  final GEETileService _geeService = GEETileService();

  List<OilSpillData> _oilSpillData = [];
  List<OilSpillData> _allData = [];
  bool _isLoading = true;
  static const int maxMarkers = 2000;
  final SARDataService _sarDataService = SARDataService();

  GoogleMapController? _mapController;
  Set<Marker> _markers = {};
  Set<TileOverlay> _tileOverlays = {};

  static const CameraPosition _initialPosition = CameraPosition(
    target: LatLng(39.1858, -76.0997), // Chesapeake Bay
    zoom: 9.0,
  );

  @override
  void initState() {
    super.initState();
    _loadSARData();
    _loadGEETiles();
  }

  Future<void> _loadGEETiles() async {
    print('Loading GEE tiles...');
    try {
      // Load SAR imagery
      final sarTileUrl = await _geeService.getSARTiles(
        startDate: _geeStartDate,
        endDate: _geeEndDate,
      );
      print('SAR tiles loaded: $sarTileUrl');

      // Load teammate's oil detection (JRC Water Mask method - more accurate)
      final oilTileUrl = await _geeService.getTeammateOilDetectionTiles(
        startDate: _geeStartDate,
        endDate: _geeEndDate,
      );
      print('Oil detection tiles loaded: $oilTileUrl');

      setState(() {
        _geeSARTileUrl = sarTileUrl;
        _geeOilTileUrl = oilTileUrl;
      });

      _updateTileOverlays();

      // Preload tiles for initial view (zoom levels 8-11 for Chesapeake Bay)
      if (oilTileUrl != null) {
        _preloadTiles(oilTileUrl);
      }
    } catch (e) {
      print('Error loading GEE tiles: $e');
    }
  }

  Future<void> _preloadTiles(String urlTemplate) async {
    print('Preloading tiles for faster display...');

    // Preload tiles for zoom levels 8-11 covering Chesapeake Bay
    // Center: 39.1858, -76.0997, zoom 9
    final tilesToPreload = [
      // Zoom 8 (4 tiles cover the area)
      {'z': 8, 'x': 74, 'y': 95},
      {'z': 8, 'x': 75, 'y': 95},
      {'z': 8, 'x': 74, 'y': 96},
      {'z': 8, 'x': 75, 'y': 96},
      // Zoom 9 (9 tiles cover the area)
      {'z': 9, 'x': 148, 'y': 190},
      {'z': 9, 'x': 149, 'y': 190},
      {'z': 9, 'x': 150, 'y': 190},
      {'z': 9, 'x': 148, 'y': 191},
      {'z': 9, 'x': 149, 'y': 191},
      {'z': 9, 'x': 150, 'y': 191},
      {'z': 9, 'x': 148, 'y': 192},
      {'z': 9, 'x': 149, 'y': 192},
      {'z': 9, 'x': 150, 'y': 192},
      // Zoom 10 (16 tiles cover core area)
      {'z': 10, 'x': 296, 'y': 380},
      {'z': 10, 'x': 297, 'y': 380},
      {'z': 10, 'x': 298, 'y': 380},
      {'z': 10, 'x': 299, 'y': 380},
      {'z': 10, 'x': 296, 'y': 381},
      {'z': 10, 'x': 297, 'y': 381},
      {'z': 10, 'x': 298, 'y': 381},
      {'z': 10, 'x': 299, 'y': 381},
      {'z': 10, 'x': 296, 'y': 382},
      {'z': 10, 'x': 297, 'y': 382},
      {'z': 10, 'x': 298, 'y': 382},
      {'z': 10, 'x': 299, 'y': 382},
      {'z': 10, 'x': 296, 'y': 383},
      {'z': 10, 'x': 297, 'y': 383},
      {'z': 10, 'x': 298, 'y': 383},
      {'z': 10, 'x': 299, 'y': 383},
    ];

    int loaded = 0;
    for (final tile in tilesToPreload) {
      try {
        final url = urlTemplate
            .replaceAll('{x}', tile['x'].toString())
            .replaceAll('{y}', tile['y'].toString())
            .replaceAll('{z}', tile['z'].toString());

        final response = await http.get(Uri.parse(url));
        if (response.statusCode == 200) {
          _CustomTileProvider._tileCache[url] = response.bodyBytes;
          loaded++;
        }
      } catch (e) {
        // Continue loading other tiles even if one fails
      }
    }

    print('✓ Preloaded $loaded tiles into cache');
  }

  void _updateTileOverlays() {
    final overlays = <TileOverlay>{};

    if (_showGEESAR && _geeSARTileUrl != null) {
      overlays.add(
        TileOverlay(
          tileOverlayId: const TileOverlayId('sar_tiles'),
          tileProvider: _CustomTileProvider(_geeSARTileUrl!),
          transparency: 0.3,
        ),
      );
    }

    if (_showGEEOilDetection && _geeOilTileUrl != null) {
      overlays.add(
        TileOverlay(
          tileOverlayId: const TileOverlayId('oil_tiles'),
          tileProvider: _CustomTileProvider(_geeOilTileUrl!),
          transparency: 0.0,
        ),
      );
    }

    setState(() {
      _tileOverlays = overlays;
    });
  }

  Future<void> _loadSARData() async {
    print('Loading SAR data...');
    setState(() => _isLoading = true);

    try {
      final data = await _sarDataService.loadSARData();

      setState(() {
        _allData = data;
        // Sample data if too many points for performance
        if (_allData.length > maxMarkers) {
          _oilSpillData = (_allData.toList()..shuffle()).take(maxMarkers).toList();
        } else {
          _oilSpillData = _allData;
        }
        _isLoading = false;
      });

      _updateMarkers();
      print('SAR data loaded: ${_oilSpillData.length} points');
    } catch (e) {
      print('Error loading SAR data: $e');
      setState(() => _isLoading = false);
    }
  }

  void _updateMarkers() {
    final markers = <Marker>{};

    for (int i = 0; i < _oilSpillData.length; i++) {
      final point = _oilSpillData[i];
      final markerId = MarkerId('marker_$i');

      Color markerColor;
      BitmapDescriptor icon;
      double alpha;
      String title;

      // Prioritize ship-related oil detections
      if (point.isShipRelated && point.isOilCandidate) {
        // Ship-related oil (always visible, bright orange)
        markerColor = Colors.orange;
        icon = BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueOrange);
        alpha = 1.0; // Fully opaque for maximum visibility
        title = 'Ship-Related Oil';
      } else if (point.isOilCandidate) {
        // Regular oil detection
        markerColor = Colors.red;
        icon = BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed);
        alpha = 0.8;
        title = 'Oil Detection';
      } else {
        // Water points (always show)
        markerColor = Colors.blue;
        icon = BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue);
        alpha = 0.5;
        title = 'Water';
      }

      markers.add(
        Marker(
          markerId: markerId,
          position: LatLng(point.latitude, point.longitude),
          icon: icon,
          alpha: alpha,
          infoWindow: InfoWindow(
            title: title,
            snippet: 'VV: ${point.VV.toStringAsFixed(1)} dB, ${point.date.toString().substring(0, 10)}',
          ),
          onTap: () => _showSpillDetail(point),
        ),
      );
    }

    setState(() {
      _markers = markers;
    });
  }

  void _applyDataPointFilter() {
    final targetCount = (_allData.length * _dataPointPercentage).round();
    setState(() {
      _oilSpillData = _allData.take(targetCount.clamp(0, maxMarkers)).toList();
    });
    _updateMarkers();
  }

  void _showSpillDetail(OilSpillData spill) {
    showDialog(
      context: context,
      builder: (context) => SpillDetailPopup(spillData: spill),
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
              });
            },
            tooltip: 'Layer Controls',
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
          GoogleMap(
            mapType: MapType.satellite,
            initialCameraPosition: _initialPosition,
            markers: _markers,
            tileOverlays: _tileOverlays,
            onMapCreated: (GoogleMapController controller) {
              _mapController = controller;
            },
            myLocationButtonEnabled: false,
            zoomControlsEnabled: false,
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
          // Chesapeake Bay SAR Analysis Card
          if (!_isLoading)
            Positioned(
              left: 8,
              bottom: 16,
              child: Card(
                color: Colors.black.withValues(alpha: 0.85),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Chesapeake Bay SAR Analysis',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 12,
                            height: 12,
                            decoration: const BoxDecoration(
                              color: Colors.red,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'Oil: ${_allData.where((d) => d.isOilCandidate).length}',
                            style: const TextStyle(color: Colors.white, fontSize: 13),
                          ),
                          const SizedBox(width: 16),
                          Container(
                            width: 12,
                            height: 12,
                            decoration: const BoxDecoration(
                              color: Colors.blue,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'Water: ${_allData.where((d) => !d.isOilCandidate).length}',
                            style: const TextStyle(color: Colors.white, fontSize: 13),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 12,
                            height: 12,
                            decoration: const BoxDecoration(
                              color: Colors.orange,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'Ship Related: ${_allData.where((d) => d.isShipRelated).length}',
                            style: const TextStyle(color: Colors.white, fontSize: 13),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.calendar_today, color: Colors.white70, size: 12),
                          const SizedBox(width: 6),
                          Text(
                            'Dates: 541',
                            style: const TextStyle(color: Colors.white70, fontSize: 12),
                          ),
                          const SizedBox(width: 12),
                          const Icon(Icons.visibility, color: Colors.white70, size: 12),
                          const SizedBox(width: 6),
                          Text(
                            'Showing: ${_oilSpillData.length} / ${_allData.length}',
                            style: const TextStyle(color: Colors.white70, fontSize: 12),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        'Tap a marker for details',
                        style: TextStyle(color: Colors.white60, fontSize: 11, fontStyle: FontStyle.italic),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          // Layer Control Panel Modal Overlay (on top of everything)
          if (_showLayerPanel)
            Positioned.fill(
              child: GestureDetector(
                onTap: () => setState(() => _showLayerPanel = false),
                child: Container(
                  color: Colors.black.withValues(alpha: 0.5),
                  child: Center(
                    child: GestureDetector(
                      onTap: () {}, // Prevent closing when tapping the panel itself
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 60),
                        constraints: const BoxConstraints(maxWidth: 400),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.3),
                              blurRadius: 20,
                              spreadRadius: 5,
                            ),
                          ],
                        ),
                        child: LayerControlPanel(
                          onClose: () => setState(() => _showLayerPanel = false),
                          showShipLayer: _showShipLayer,
                          highlightShipCorrelation: _highlightShipCorrelation,
                          onShipLayerChanged: (value) {
                            setState(() {
                              _showShipLayer = value;
                              _updateMarkers();
                            });
                          },
                          onShipCorrelationChanged: (value) {
                            setState(() {
                              _highlightShipCorrelation = value;
                              _updateMarkers();
                            });
                          },
                          showGEESAR: _showGEESAR,
                          showGEEOilDetection: _showGEEOilDetection,
                          onGEESARChanged: (value) {
                            setState(() {
                              _showGEESAR = value;
                              _updateTileOverlays();
                            });
                          },
                          onGEEOilDetectionChanged: (value) {
                            setState(() {
                              _showGEEOilDetection = value;
                              _updateTileOverlays();
                            });
                          },
                          activeHeatmap: _activeHeatmap,
                          onHeatmapChanged: (value) {
                            setState(() {
                              _activeHeatmap = value;
                            });
                          },
                          heatmapOpacity: _heatmapOpacity,
                          onHeatmapOpacityChanged: (value) {
                            setState(() {
                              _heatmapOpacity = value;
                            });
                          },
                          dataPointPercentage: _dataPointPercentage,
                          onDataPointPercentageChanged: (value) {
                            setState(() {
                              _dataPointPercentage = value;
                              _applyDataPointFilter();
                            });
                          },
                          totalDataPoints: _allData.length,
                          displayedDataPoints: _oilSpillData.length,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            heroTag: "visibility",
            mini: true,
            backgroundColor: _showGEEOilDetection ? Colors.red : null,
            onPressed: () {
              setState(() {
                _showGEEOilDetection = !_showGEEOilDetection;
                _updateTileOverlays();
              });
            },
            tooltip: _showGEEOilDetection ? 'Hide Oil Overlay' : 'Show Oil Overlay',
            child: Icon(_showGEEOilDetection ? Icons.visibility : Icons.visibility_off),
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
      ),
    );
  }

  void _showStatistics() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => StatisticsDashboardScreen(data: _allData),
      ),
    );
  }

}

// Custom tile provider for Google Earth Engine tiles with caching
class _CustomTileProvider implements TileProvider {
  final String urlTemplate;
  static final Map<String, Uint8List> _tileCache = {};

  _CustomTileProvider(this.urlTemplate);

  @override
  Future<Tile> getTile(int x, int y, int? zoom) async {
    if (zoom == null) {
      return TileProvider.noTile;
    }

    final url = urlTemplate
        .replaceAll('{x}', x.toString())
        .replaceAll('{y}', y.toString())
        .replaceAll('{z}', zoom.toString());

    // Check cache first for instant loading
    if (_tileCache.containsKey(url)) {
      return Tile(256, 256, _tileCache[url]!);
    }

    try {
      // Fetch the tile image from Earth Engine
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final Uint8List tileData = response.bodyBytes;

        // Cache the tile (limit cache size to prevent memory issues)
        if (_tileCache.length < 500) {
          _tileCache[url] = tileData;
        }

        return Tile(256, 256, tileData);
      } else {
        return TileProvider.noTile;
      }
    } catch (e) {
      print('Error loading tile: $e');
      return TileProvider.noTile;
    }
  }
}
