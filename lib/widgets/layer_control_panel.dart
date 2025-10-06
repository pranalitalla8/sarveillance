import 'package:flutter/material.dart';

class LayerControlPanel extends StatefulWidget {
  final VoidCallback onClose;
  final bool showShipLayer;
  final bool highlightShipCorrelation;
  final ValueChanged<bool> onShipLayerChanged;
  final ValueChanged<bool> onShipCorrelationChanged;
  final String? activeHeatmap;
  final double heatmapOpacity;
  final ValueChanged<String?> onHeatmapChanged;
  final ValueChanged<double> onHeatmapOpacityChanged;
  // Google Earth Engine layers
  final bool showGEESAR;
  final bool showGEEOilDetection;
  final ValueChanged<bool> onGEESARChanged;
  final ValueChanged<bool> onGEEOilDetectionChanged;
  final double dataPointPercentage;
  final ValueChanged<double> onDataPointPercentageChanged;
  final int totalDataPoints;
  final int displayedDataPoints;

  const LayerControlPanel({
    super.key,
    required this.onClose,
    required this.showShipLayer,
    required this.highlightShipCorrelation,
    required this.onShipLayerChanged,
    required this.onShipCorrelationChanged,
    required this.activeHeatmap,
    required this.heatmapOpacity,
    required this.onHeatmapChanged,
    required this.onHeatmapOpacityChanged,
    required this.showGEESAR,
    required this.showGEEOilDetection,
    required this.onGEESARChanged,
    required this.onGEEOilDetectionChanged,
    required this.dataPointPercentage,
    required this.onDataPointPercentageChanged,
    required this.totalDataPoints,
    required this.displayedDataPoints,
  });

  @override
  State<LayerControlPanel> createState() => _LayerControlPanelState();
}

class _LayerControlPanelState extends State<LayerControlPanel> {
  late TextEditingController _dataPointController;

  @override
  void initState() {
    super.initState();
    _dataPointController = TextEditingController(
      text: (widget.dataPointPercentage * 100).toInt().toString(),
    );
  }

  @override
  void didUpdateWidget(LayerControlPanel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.dataPointPercentage != widget.dataPointPercentage) {
      _dataPointController.text = (widget.dataPointPercentage * 100).toInt().toString();
    }
  }

  @override
  void dispose() {
    _dataPointController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Theme.of(context).colorScheme.primaryContainer,
                  Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.7),
                ],
              ),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    Icons.layers,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'Layer Controls',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: widget.onClose,
                  iconSize: 24,
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.white.withValues(alpha: 0.2),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _buildShipTrackingSection(),
                const Divider(height: 32),
                _buildGEESection(),
                const Divider(height: 32),
                _buildDataPointFilterSection(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildShipTrackingSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.directions_boat, size: 20),
            const SizedBox(width: 8),
            Text(
              'Ship Tracking',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              children: [
                SwitchListTile(
                  value: widget.showShipLayer,
                  onChanged: widget.onShipLayerChanged,
                  title: const Text('Show Ship Data'),
                  subtitle: const Text('Display AIS ship markers'),
                  contentPadding: EdgeInsets.zero,
                  dense: true,
                ),
                const Divider(),
                SwitchListTile(
                  value: widget.highlightShipCorrelation,
                  onChanged: widget.showShipLayer ? widget.onShipCorrelationChanged : null,
                  title: const Text('Highlight Ship Correlation'),
                  subtitle: const Text('Show oil spills near ships in orange'),
                  contentPadding: EdgeInsets.zero,
                  dense: true,
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        size: 16,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Orange markers indicate potential illegal dumping',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildGEESection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.satellite_alt, size: 20),
            const SizedBox(width: 8),
            Text(
              'Google Earth Engine',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              children: [
                SwitchListTile(
                  value: widget.showGEESAR,
                  onChanged: widget.onGEESARChanged,
                  title: const Text('SAR Imagery'),
                  subtitle: const Text('Sentinel-1 backscatter'),
                  contentPadding: EdgeInsets.zero,
                  dense: true,
                ),
                const Divider(),
                SwitchListTile(
                  value: widget.showGEEOilDetection,
                  onChanged: widget.onGEEOilDetectionChanged,
                  title: const Text('Oil Detection Layer'),
                  subtitle: const Text('JRC Water-Masked (VV < -22 dB)'),
                  contentPadding: EdgeInsets.zero,
                  dense: true,
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        size: 16,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Requires backend server running',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDataPointFilterSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.filter_list, size: 20),
            const SizedBox(width: 8),
            Text(
              'Data Point Filter',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Showing ${widget.displayedDataPoints} of ${widget.totalDataPoints} points',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _dataPointController,
                        decoration: InputDecoration(
                          labelText: 'Percentage',
                          hintText: 'Enter 10-100',
                          suffixText: '%',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 12,
                          ),
                        ),
                        keyboardType: TextInputType.number,
                        onSubmitted: (value) {
                          final percentage = int.tryParse(value);
                          if (percentage != null && percentage >= 10 && percentage <= 100) {
                            widget.onDataPointPercentageChanged(percentage / 100.0);
                          } else {
                            // Reset to current value if invalid
                            _dataPointController.text = (widget.dataPointPercentage * 100).toInt().toString();
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Please enter a value between 10 and 100'),
                                duration: Duration(seconds: 2),
                              ),
                            );
                          }
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: () {
                        final percentage = int.tryParse(_dataPointController.text);
                        if (percentage != null && percentage >= 10 && percentage <= 100) {
                          widget.onDataPointPercentageChanged(percentage / 100.0);
                        } else {
                          _dataPointController.text = (widget.dataPointPercentage * 100).toInt().toString();
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Please enter a value between 10 and 100'),
                              duration: Duration(seconds: 2),
                            ),
                          );
                        }
                      },
                      child: const Text('Apply'),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        size: 16,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Reduce data points for better performance (10-100%)',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

}