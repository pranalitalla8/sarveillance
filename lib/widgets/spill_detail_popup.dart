import 'package:flutter/material.dart';
import '../models/oil_spill_data.dart';

class SpillDetailPopup extends StatelessWidget {
  final OilSpillData spillData;

  const SpillDetailPopup({
    super.key,
    required this.spillData,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 500, maxHeight: 700),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    spillData.isOilCandidate
                        ? Colors.red.shade700
                        : Colors.blue.shade700,
                    spillData.isOilCandidate
                        ? Colors.red.shade900
                        : Colors.blue.shade900,
                  ],
                ),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    spillData.isOilCandidate ? Icons.warning : Icons.water_drop,
                    color: Colors.white,
                    size: 32,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          spillData.isOilCandidate
                              ? '🛢️ Oil Spill Detection'
                              : '💧 Water Point',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '━━━━━━━━━━━━━━━━━━',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.5),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),

            // Content
            Expanded(
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Basic Info
                    _buildSection(
                      icon: Icons.info_outline,
                      title: 'Basic Information',
                      children: [
                        _buildInfoRow('📅 Date', _formatDate(spillData.date)),
                        _buildInfoRow('📍 Location',
                            '${spillData.latitudeFormatted}, ${spillData.longitudeFormatted}'),
                      ],
                    ),

                    const SizedBox(height: 20),

                    // SAR Data
                    _buildSection(
                      icon: Icons.satellite_alt,
                      title: '🛰️ SAR Data (Sentinel-1)',
                      children: [
                        _buildInfoRow('VV', '${spillData.VV.toStringAsFixed(2)} dB'),
                        _buildInfoRow('VH', '${spillData.VH.toStringAsFixed(2)} dB'),
                        _buildInfoRow(
                            'VH/VV Ratio', spillData.VH_VV_ratio.toStringAsFixed(3)),
                        _buildInfoRow('Orbit', spillData.orbit_type),
                        _buildInfoRow('Angle', '${spillData.angle.toStringAsFixed(1)}°'),
                      ],
                    ),

                    const SizedBox(height: 20),

                    // Weather Data
                    _buildSection(
                      icon: Icons.wb_sunny_outlined,
                      title: '🌤️ Weather Conditions',
                      children: [
                        _buildInfoRow('Temperature',
                            '${spillData.temperatureCelsius.toStringAsFixed(1)}°C (${spillData.temperature_2m.toStringAsFixed(1)}K)'),
                        _buildInfoRow('Dewpoint',
                            '${spillData.dewpointCelsius.toStringAsFixed(1)}°C'),
                        _buildInfoRow(
                            'Wind Speed', '${spillData.wind_speed_10m.toStringAsFixed(1)} m/s'),
                        _buildInfoRow('Wind Direction',
                            '${spillData.wind_direction_degrees.toStringAsFixed(0)}°'),
                        _buildInfoRow('Precipitation',
                            '${(spillData.total_precipitation * 1000).toStringAsFixed(2)} mm'),
                        _buildInfoRow('Pressure',
                            '${(spillData.surface_pressure / 100).toStringAsFixed(1)} hPa'),
                      ],
                    ),

                    // NASA POWER Enhanced Weather (if available)
                    if (spillData.hasNasaPowerData) ...[
                      const SizedBox(height: 20),
                      _buildSection(
                        icon: Icons.cloud_outlined,
                        title: '☀️ NASA POWER Weather Data',
                        children: [
                          if (spillData.nasa_power_air_temp_2m != null)
                            _buildInfoRow('Temperature', '${spillData.nasa_power_air_temp_2m!.toStringAsFixed(1)}°C'),
                          if (spillData.nasa_power_max_air_temp_2m != null)
                            _buildInfoRow('Max Temp', '${spillData.nasa_power_max_air_temp_2m!.toStringAsFixed(1)}°C'),
                          if (spillData.nasa_power_min_air_temp_2m != null)
                            _buildInfoRow('Min Temp', '${spillData.nasa_power_min_air_temp_2m!.toStringAsFixed(1)}°C'),
                          if (spillData.nasa_power_wind_speed_2m != null)
                            _buildInfoRow('Wind Speed (2m)', '${spillData.nasa_power_wind_speed_2m!.toStringAsFixed(1)} m/s'),
                          if (spillData.nasa_power_precipitation_mm != null)
                            _buildInfoRow('Precipitation', '${spillData.nasa_power_precipitation_mm!.toStringAsFixed(2)} mm'),
                          if (spillData.nasa_power_solar_radiation != null)
                            _buildInfoRow('Solar Radiation', '${spillData.nasa_power_solar_radiation!.toStringAsFixed(2)} MJ/m²/day'),
                        ],
                      ),
                    ],

                    // Ship Activity (AIS tracking - if available)
                    if (spillData.hasShipData) ...[
                      const SizedBox(height: 20),
                      _buildSection(
                        icon: Icons.directions_boat,
                        title: '🚢 Ship Tracking (AIS)',
                        children: [
                          _buildInfoRow('Ships Detected', '${spillData.num_ships_near_point ?? 0}'),
                          if (spillData.closest_ship_distance_km != null)
                            _buildInfoRow('Closest Ship', '${spillData.closest_ship_distance_km!.toStringAsFixed(2)} km'),
                          if (spillData.avg_ship_speed != null)
                            _buildInfoRow('Avg Ship Speed', '${spillData.avg_ship_speed!.toStringAsFixed(1)} knots'),
                          if (spillData.isShipRelated)
                            _buildInfoRow('Status', '⚠️ Ship-Related (<5km)'),
                        ],
                      ),
                    ],

                    const SizedBox(height: 20),

                    // Classification
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: spillData.isOilCandidate
                            ? Colors.red.withOpacity(0.1)
                            : Colors.blue.withOpacity(0.1),
                        border: Border.all(
                          color: spillData.isOilCandidate
                              ? Colors.red.withOpacity(0.3)
                              : Colors.blue.withOpacity(0.3),
                          width: 2,
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            spillData.isOilCandidate
                                ? Icons.warning_amber
                                : Icons.check_circle_outline,
                            color: spillData.isOilCandidate
                                ? Colors.red.shade700
                                : Colors.blue.shade700,
                            size: 32,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '⚠️ Classification',
                                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                        fontWeight: FontWeight.bold,
                                      ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  spillData.isOilCandidate
                                      ? 'OIL CANDIDATE'
                                      : 'WATER',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: spillData.isOilCandidate
                                        ? Colors.red.shade700
                                        : Colors.blue.shade700,
                                  ),
                                ),
                                if (spillData.isOilCandidate && spillData.isShipRelated)
                                  Padding(
                                    padding: const EdgeInsets.only(top: 8),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: Colors.orange.shade700,
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: const Text(
                                        '⚠️ SHIP CORRELATION DETECTED',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Footer Actions
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainer,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(16),
                  bottomRight: Radius.circular(16),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton.icon(
                    onPressed: () {
                      // TODO: Export this detection data
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Export feature coming soon')),
                      );
                    },
                    icon: const Icon(Icons.share),
                    label: const Text('Share'),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Close'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection({
    required IconData icon,
    required String title,
    required List<Widget> children,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 20),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ...children,
      ],
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(
              '• $label:',
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
}
