import 'package:flutter/material.dart';
import '../widgets/comparison_viewer.dart';
import '../widgets/timeline_slider.dart';

class CompareScreen extends StatefulWidget {
  const CompareScreen({super.key});

  @override
  State<CompareScreen> createState() => _CompareScreenState();
}

class _CompareScreenState extends State<CompareScreen> {
  String _comparisonMode = 'side_by_side';
  String _leftDataset = 'before';
  String _rightDataset = 'after';
  double _sliderPosition = 0.5;
  bool _showTimeline = true;

  final List<Map<String, dynamic>> _timelineData = [
    {
      'date': DateTime(2023, 9, 25),
      'label': 'Pre-Hurricane',
      'description': 'Normal conditions before Hurricane Ian',
    },
    {
      'date': DateTime(2023, 9, 28),
      'label': 'During Hurricane',
      'description': 'Hurricane Ian landfall',
    },
    {
      'date': DateTime(2023, 10, 2),
      'label': 'Post-Hurricane',
      'description': 'Immediate aftermath assessment',
    },
    {
      'date': DateTime(2023, 10, 15),
      'label': 'Recovery Phase',
      'description': 'Two weeks after hurricane',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Compare SAR Data'),
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
          PopupMenuButton<String>(
            icon: const Icon(Icons.view_module),
            onSelected: (value) {
              setState(() {
                _comparisonMode = value;
              });
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'side_by_side',
                child: ListTile(
                  leading: Icon(Icons.view_column),
                  title: Text('Side by Side'),
                ),
              ),
              const PopupMenuItem(
                value: 'overlay',
                child: ListTile(
                  leading: Icon(Icons.layers),
                  title: Text('Overlay'),
                ),
              ),
              const PopupMenuItem(
                value: 'swipe',
                child: ListTile(
                  leading: Icon(Icons.swipe),
                  title: Text('Swipe'),
                ),
              ),
              const PopupMenuItem(
                value: 'difference',
                child: ListTile(
                  leading: Icon(Icons.compare),
                  title: Text('Difference'),
                ),
              ),
            ],
          ),
          IconButton(
            icon: Icon(
              _showTimeline ? Icons.timeline : Icons.timeline_outlined,
              color: _showTimeline ? Theme.of(context).colorScheme.primary : null,
            ),
            onPressed: () {
              setState(() {
                _showTimeline = !_showTimeline;
              });
            },
            tooltip: 'Toggle Timeline',
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _buildDatasetSelector(
                    'Left/Before',
                    _leftDataset,
                    (value) => setState(() => _leftDataset = value),
                  ),
                  const SizedBox(height: 16),
                  _buildDatasetSelector(
                    'Right/After',
                    _rightDataset,
                    (value) => setState(() => _rightDataset = value),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 400,
              child: ComparisonViewer(
                mode: _comparisonMode,
                sliderPosition: _sliderPosition,
                onSliderChanged: (value) => setState(() => _sliderPosition = value),
                leftDataset: _leftDataset,
                rightDataset: _rightDataset,
              ),
            ),
            if (_showTimeline)
              Container(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Timeline',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TimelineSlider(
                      data: _timelineData,
                      onSelectionChanged: _onTimelineSelectionChanged,
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 80), // Bottom padding for floating action button
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAnalysisResults(),
        icon: const Icon(Icons.analytics),
        label: const Text('Analyze Changes'),
      ),
    );
  }

  Widget _buildDatasetSelector(String label, String value, Function(String) onChanged) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              initialValue: value,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
              items: const [
                DropdownMenuItem(value: 'before', child: Text('Pre-Hurricane')),
                DropdownMenuItem(value: 'during', child: Text('During Hurricane')),
                DropdownMenuItem(value: 'after', child: Text('Post-Hurricane')),
                DropdownMenuItem(value: 'recovery', child: Text('Recovery Phase')),
              ],
              onChanged: (newValue) {
                if (newValue != null) {
                  onChanged(newValue);
                }
              },
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.calendar_today, size: 14),
                const SizedBox(width: 4),
                Flexible(
                  child: Text(
                    _getDateForDataset(value),
                    style: Theme.of(context).textTheme.bodySmall,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 12),
                const Icon(Icons.satellite, size: 14),
                const SizedBox(width: 4),
                Flexible(
                  child: Text(
                    'Sentinel-1',
                    style: Theme.of(context).textTheme.bodySmall,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _getDateForDataset(String dataset) {
    switch (dataset) {
      case 'before':
        return 'Sep 25, 2023';
      case 'during':
        return 'Sep 28, 2023';
      case 'after':
        return 'Oct 2, 2023';
      case 'recovery':
        return 'Oct 15, 2023';
      default:
        return 'Unknown';
    }
  }

  void _onTimelineSelectionChanged(int leftIndex, int rightIndex) {
    setState(() {
      _leftDataset = _getDatasetFromIndex(leftIndex);
      _rightDataset = _getDatasetFromIndex(rightIndex);
    });
  }

  String _getDatasetFromIndex(int index) {
    switch (index) {
      case 0:
        return 'before';
      case 1:
        return 'during';
      case 2:
        return 'after';
      case 3:
        return 'recovery';
      default:
        return 'before';
    }
  }

  void _showAnalysisResults() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Change Analysis Results',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            _buildAnalysisMetric('Area Changed', '15.2 km²', Icons.crop_free),
            const SizedBox(height: 8),
            _buildAnalysisMetric('Damage Detected', '1,247 structures', Icons.warning),
            const SizedBox(height: 8),
            _buildAnalysisMetric('Coherence Loss', '68% average', Icons.scatter_plot),
            const SizedBox(height: 8),
            _buildAnalysisMetric('Flooded Area', '8.9 km²', Icons.water),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Generating detailed report...'),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
              icon: const Icon(Icons.file_download),
              label: const Text('Export Report'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnalysisMetric(String label, String value, IconData icon) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Icon(icon, color: Theme.of(context).colorScheme.primary),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: Theme.of(context).textTheme.bodyLarge,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Text(
              value,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.primary,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}