import 'package:flutter/material.dart';

class MeasurementTools extends StatefulWidget {
  final String selectedTool;
  final Function(String) onToolChanged;
  final VoidCallback onClose;

  const MeasurementTools({
    super.key,
    required this.selectedTool,
    required this.onToolChanged,
    required this.onClose,
  });

  @override
  State<MeasurementTools> createState() => _MeasurementToolsState();
}

class _MeasurementToolsState extends State<MeasurementTools> {
  final List<Map<String, dynamic>> _measurements = [];

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
                const Icon(Icons.straighten),
                const SizedBox(width: 8),
                Text(
                  'Measurements',
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
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Tools',
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                      const SizedBox(height: 12),
                      _buildToolButton('distance', Icons.straighten, 'Distance'),
                      const SizedBox(height: 8),
                      _buildToolButton('area', Icons.crop_free, 'Area'),
                      const SizedBox(height: 8),
                      _buildToolButton('angle', Icons.rotate_right, 'Angle'),
                      const SizedBox(height: 8),
                      _buildToolButton('profile', Icons.show_chart, 'Profile'),
                    ],
                  ),
                ),
                if (_measurements.isNotEmpty) ...[
                  const Divider(),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          child: Row(
                            children: [
                              Text(
                                'Results',
                                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                              ),
                              const Spacer(),
                              IconButton(
                                icon: const Icon(Icons.clear_all, size: 16),
                                onPressed: _clearMeasurements,
                                tooltip: 'Clear All',
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          child: ListView.builder(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            itemCount: _measurements.length,
                            itemBuilder: (context, index) {
                              return _buildMeasurementResult(_measurements[index], index);
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ] else
                  Expanded(
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.straighten,
                            size: 48,
                            color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.3),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'No measurements yet',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Select a tool to start',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildToolButton(String toolId, IconData icon, String label) {
    final isSelected = widget.selectedTool == toolId;
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: () {
          widget.onToolChanged(isSelected ? 'none' : toolId);
          if (!isSelected) {
            _addMockMeasurement(toolId);
          }
        },
        icon: Icon(icon),
        label: Text(label),
        style: ElevatedButton.styleFrom(
          backgroundColor: isSelected
              ? Theme.of(context).colorScheme.primary
              : Theme.of(context).colorScheme.surfaceContainer,
          foregroundColor: isSelected
              ? Colors.white
              : Theme.of(context).colorScheme.onSurface,
          alignment: Alignment.centerLeft,
        ),
      ),
    );
  }

  Widget _buildMeasurementResult(Map<String, dynamic> measurement, int index) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(_getToolIcon(measurement['type'])),
        title: Text(measurement['label']),
        subtitle: Text(measurement['value']),
        trailing: IconButton(
          icon: const Icon(Icons.delete, size: 16),
          onPressed: () => _removeMeasurement(index),
        ),
      ),
    );
  }

  IconData _getToolIcon(String type) {
    switch (type) {
      case 'distance':
        return Icons.straighten;
      case 'area':
        return Icons.crop_free;
      case 'angle':
        return Icons.rotate_right;
      case 'profile':
        return Icons.show_chart;
      default:
        return Icons.straighten;
    }
  }

  void _addMockMeasurement(String toolId) {
    setState(() {
      switch (toolId) {
        case 'distance':
          _measurements.add({
            'type': 'distance',
            'label': 'Distance ${_measurements.length + 1}',
            'value': '${(1234.5 + _measurements.length * 100).toStringAsFixed(1)} m',
          });
          break;
        case 'area':
          _measurements.add({
            'type': 'area',
            'label': 'Area ${_measurements.length + 1}',
            'value': '${(12.34 + _measurements.length * 2).toStringAsFixed(2)} km²',
          });
          break;
        case 'angle':
          _measurements.add({
            'type': 'angle',
            'label': 'Angle ${_measurements.length + 1}',
            'value': '${(45.6 + _measurements.length * 5).toStringAsFixed(1)}°',
          });
          break;
        case 'profile':
          _measurements.add({
            'type': 'profile',
            'label': 'Profile ${_measurements.length + 1}',
            'value': '${100 + _measurements.length * 10} points',
          });
          break;
      }
    });
  }

  void _removeMeasurement(int index) {
    setState(() {
      _measurements.removeAt(index);
    });
  }

  void _clearMeasurements() {
    setState(() {
      _measurements.clear();
    });
  }
}