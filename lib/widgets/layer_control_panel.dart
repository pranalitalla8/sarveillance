import 'package:flutter/material.dart';

class LayerControlPanel extends StatefulWidget {
  final VoidCallback onClose;
  final bool showShipLayer;
  final bool highlightShipCorrelation;
  final ValueChanged<bool> onShipLayerChanged;
  final ValueChanged<bool> onShipCorrelationChanged;

  const LayerControlPanel({
    super.key,
    required this.onClose,
    required this.showShipLayer,
    required this.highlightShipCorrelation,
    required this.onShipLayerChanged,
    required this.onShipCorrelationChanged,
  });

  @override
  State<LayerControlPanel> createState() => _LayerControlPanelState();
}

class _LayerControlPanelState extends State<LayerControlPanel> {
  final Map<String, bool> _layerVisibility = {
    'SAR Backscatter': true,
    'Coherence': false,
    'Amplitude': true,
    'Phase': false,
    'RGB Composite': false,
    'Land Cover': false,
    'Topography': true,
    'Roads': false,
    'Buildings': false,
  };

  final Map<String, double> _layerOpacity = {
    'SAR Backscatter': 1.0,
    'Coherence': 0.8,
    'Amplitude': 1.0,
    'Phase': 0.7,
    'RGB Composite': 0.9,
    'Land Cover': 0.6,
    'Topography': 0.5,
    'Roads': 0.8,
    'Buildings': 0.7,
  };

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primaryContainer,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Row(
              children: [
                const Icon(Icons.layers),
                const SizedBox(width: 8),
                Text(
                  'Layer Controls',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: widget.onClose,
                  iconSize: 20,
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
                _buildLayerSection('SAR Data', [
                  'SAR Backscatter',
                  'Coherence',
                  'Amplitude',
                  'Phase',
                ]),
                const SizedBox(height: 16),
                _buildLayerSection('Visualization', [
                  'RGB Composite',
                  'Land Cover',
                ]),
                const SizedBox(height: 16),
                _buildLayerSection('Reference', [
                  'Topography',
                  'Roads',
                  'Buildings',
                ]),
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
                color: Theme.of(context).colorScheme.primary,
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

  Widget _buildLayerSection(String title, List<String> layers) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
        const SizedBox(height: 8),
        ...layers.map((layer) => _buildLayerControl(layer)),
      ],
    );
  }

  Widget _buildLayerControl(String layerName) {
    final isVisible = _layerVisibility[layerName] ?? false;
    final opacity = _layerOpacity[layerName] ?? 1.0;

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Row(
              children: [
                Switch(
                  value: isVisible,
                  onChanged: (value) {
                    setState(() {
                      _layerVisibility[layerName] = value;
                    });
                  },
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    layerName,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.settings, size: 16),
                  onPressed: () => _showLayerSettings(layerName),
                ),
              ],
            ),
            if (isVisible) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  SizedBox(
                    width: 50,
                    child: Text(
                      'Opacity',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ),
                  Expanded(
                    child: Slider(
                      value: opacity,
                      min: 0.0,
                      max: 1.0,
                      divisions: 10,
                      onChanged: (value) {
                        setState(() {
                          _layerOpacity[layerName] = value;
                        });
                      },
                    ),
                  ),
                  SizedBox(
                    width: 35,
                    child: Text(
                      '${(opacity * 100).toInt()}%',
                      style: Theme.of(context).textTheme.bodySmall,
                      textAlign: TextAlign.end,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _showLayerSettings(String layerName) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('$layerName Settings'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.palette),
              title: const Text('Color Map'),
              subtitle: const Text('Viridis'),
              onTap: () {},
            ),
            ListTile(
              leading: const Icon(Icons.tune),
              title: const Text('Contrast'),
              subtitle: const Text('Auto-adjust'),
              onTap: () {},
            ),
            ListTile(
              leading: const Icon(Icons.filter_alt),
              title: const Text('Filters'),
              subtitle: const Text('None applied'),
              onTap: () {},
            ),
          ],
        ),
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