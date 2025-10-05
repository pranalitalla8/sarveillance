import 'package:flutter/material.dart';
import '../models/map_region.dart';

/// Widget to display information about a selected region
class RegionInfoPanel extends StatelessWidget {
  final MapRegion region;
  final RegionData? data;
  final VoidCallback onClose;
  final VoidCallback? onLoadData;

  const RegionInfoPanel({
    super.key,
    required this.region,
    this.data,
    required this.onClose,
    this.onLoadData,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 8,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 350),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(context),
            const Divider(height: 1),
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: _buildContent(context),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Theme.of(context).colorScheme.primaryContainer,
            Theme.of(context).colorScheme.surface,
          ],
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.location_on,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  region.name,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '${region.center.latitude.toStringAsFixed(4)}, ${region.center.longitude.toStringAsFixed(4)}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: onClose,
            tooltip: 'Close',
          ),
        ],
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    if (data == null) {
      return _buildLoadDataPrompt(context);
    }

    switch (data!.status) {
      case LoadingStatus.loading:
        return _buildLoadingState(context);
      case LoadingStatus.error:
        return _buildErrorState(context);
      case LoadingStatus.loaded:
        return _buildDataContent(context);
      case LoadingStatus.idle:
        return _buildLoadDataPrompt(context);
    }
  }

  Widget _buildLoadDataPrompt(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.cloud_download,
            size: 64,
            color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'Load SAR Data',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Text(
            'Click below to load data for this region',
            style: Theme.of(context).textTheme.bodySmall,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: onLoadData,
            icon: const Icon(Icons.download),
            label: const Text('Load Data'),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 16),
          Text('Loading region data...'),
        ],
      ),
    );
  }

  Widget _buildErrorState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: Theme.of(context).colorScheme.error,
          ),
          const SizedBox(height: 16),
          Text(
            'Error Loading Data',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Text(
            data?.errorMessage ?? 'An unknown error occurred',
            style: Theme.of(context).textTheme.bodySmall,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: onLoadData,
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildDataContent(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (data!.sarData != null) _buildSarDataSection(context),
        if (data!.oilSpills != null) ...[
          const SizedBox(height: 16),
          _buildOilSpillSection(context),
        ],
        if (data!.shipTraffic != null) ...[
          const SizedBox(height: 16),
          _buildShipTrafficSection(context),
        ],
        if (data!.waterQuality != null) ...[
          const SizedBox(height: 16),
          _buildWaterQualitySection(context),
        ],
        const SizedBox(height: 16),
        _buildTimestamp(context),
      ],
    );
  }

  Widget _buildSarDataSection(BuildContext context) {
    final sarData = data!.sarData!;
    return _buildSection(
      context: context,
      icon: Icons.satellite,
      title: 'SAR Data',
      children: [
        _buildInfoRow('Satellite', sarData.satellite),
        _buildInfoRow('Frequency', sarData.frequency),
        _buildInfoRow('Polarization', sarData.polarization),
        _buildInfoRow('Resolution', sarData.resolution),
        _buildInfoRow('Coverage', sarData.coverage),
        _buildInfoRow(
          'Acquired',
          _formatDate(sarData.acquisitionDate),
        ),
      ],
    );
  }

  Widget _buildOilSpillSection(BuildContext context) {
    final oilSpills = data!.oilSpills!;
    return _buildSection(
      context: context,
      icon: Icons.warning,
      title: 'Oil Spills Detected',
      color: Colors.orange,
      children: [
        _buildInfoRow('Spill Count', '${oilSpills.spillCount}'),
        _buildInfoRow(
          'Total Area',
          '${oilSpills.totalAreaKm2.toStringAsFixed(2)} km²',
        ),
        _buildInfoRow('Confidence', oilSpills.confidenceLevel),
        const SizedBox(height: 8),
        ...oilSpills.detections.map((detection) => Padding(
          padding: const EdgeInsets.only(bottom: 4),
          child: Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: _getSeverityColor(detection.severity),
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  '${detection.severity.toUpperCase()}: ${detection.areaKm2.toStringAsFixed(2)} km²',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
            ],
          ),
        )),
      ],
    );
  }

  Widget _buildShipTrafficSection(BuildContext context) {
    final shipTraffic = data!.shipTraffic!;
    return _buildSection(
      context: context,
      icon: Icons.directions_boat,
      title: 'Ship Traffic',
      color: shipTraffic.suspiciousShips > 0 ? Colors.red : Colors.blue,
      children: [
        _buildInfoRow('Total Ships', '${shipTraffic.shipCount}'),
        if (shipTraffic.suspiciousShips > 0)
          _buildInfoRow(
            'Suspicious',
            '${shipTraffic.suspiciousShips}',
            valueColor: Colors.red,
          ),
        _buildInfoRow(
          'Avg Speed',
          '${shipTraffic.averageSpeed.toStringAsFixed(1)} kn',
        ),
        const SizedBox(height: 8),
        Text(
          'Ship Types:',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        ...shipTraffic.shipTypes.entries.map((entry) => Padding(
          padding: const EdgeInsets.only(left: 16, bottom: 2),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                entry.key,
                style: Theme.of(context).textTheme.bodySmall,
              ),
              Text(
                '${entry.value}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        )),
      ],
    );
  }

  Widget _buildWaterQualitySection(BuildContext context) {
    final waterQuality = data!.waterQuality!;
    return _buildSection(
      context: context,
      icon: Icons.water,
      title: 'Water Quality',
      color: _getQualityColor(waterQuality.qualityRating),
      children: [
        _buildInfoRow('Rating', waterQuality.qualityRating.toUpperCase()),
        if (waterQuality.chlorophyllLevel != null)
          _buildInfoRow(
            'Chlorophyll',
            '${waterQuality.chlorophyllLevel!.toStringAsFixed(1)} µg/L',
          ),
        if (waterQuality.turbidity != null)
          _buildInfoRow(
            'Turbidity',
            '${waterQuality.turbidity!.toStringAsFixed(1)} NTU',
          ),
        if (waterQuality.temperature != null)
          _buildInfoRow(
            'Temperature',
            '${waterQuality.temperature!.toStringAsFixed(1)}°C',
          ),
      ],
    );
  }

  Widget _buildSection({
    required BuildContext context,
    required IconData icon,
    required String title,
    required List<Widget> children,
    Color? color,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: (color ?? Theme.of(context).colorScheme.primary)
            .withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 20, color: color),
              const SizedBox(width: 8),
              Text(
                title,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ...children,
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, {Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: valueColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimestamp(BuildContext context) {
    return Center(
      child: Text(
        'Updated: ${_formatDate(data!.timestamp)}',
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
          color: Colors.grey,
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inMinutes < 1) return 'Just now';
    if (difference.inHours < 1) return '${difference.inMinutes}m ago';
    if (difference.inDays < 1) return '${difference.inHours}h ago';
    if (difference.inDays < 7) return '${difference.inDays}d ago';
    
    return '${date.day}/${date.month}/${date.year}';
  }

  Color _getSeverityColor(String severity) {
    switch (severity.toLowerCase()) {
      case 'high':
        return Colors.red;
      case 'medium':
        return Colors.orange;
      case 'low':
        return Colors.yellow;
      default:
        return Colors.grey;
    }
  }

  Color _getQualityColor(String rating) {
    switch (rating.toLowerCase()) {
      case 'excellent':
        return Colors.green;
      case 'good':
        return Colors.lightGreen;
      case 'fair':
        return Colors.orange;
      case 'poor':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}

