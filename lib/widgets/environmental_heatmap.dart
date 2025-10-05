import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../models/oil_spill_data.dart';

class EnvironmentalHeatmap extends StatelessWidget {
  final List<OilSpillData> data;
  final String heatmapType; // 'temperature', 'wind', 'precipitation', etc.
  final double opacity;

  const EnvironmentalHeatmap({
    super.key,
    required this.data,
    required this.heatmapType,
    this.opacity = 0.6,
  });

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) return const SizedBox.shrink();

    return CircleLayer(
      circles: data.map((point) {
        final value = _getValue(point);
        final color = _getColorForValue(value, heatmapType);

        return CircleMarker(
          point: LatLng(point.latitude, point.longitude),
          color: color.withOpacity(opacity),
          borderColor: Colors.transparent,
          borderStrokeWidth: 0,
          radius: 15, // Larger for heatmap effect
        );
      }).toList(),
    );
  }

  double _getValue(OilSpillData point) {
    switch (heatmapType) {
      case 'temperature':
        return point.temperatureCelsius;
      case 'wind':
        return point.wind_speed_10m;
      case 'precipitation':
        return point.total_precipitation * 1000; // Convert to mm
      case 'pressure':
        return point.surface_pressure / 100; // Convert to hPa
      case 'dewpoint':
        return point.dewpointCelsius;
      case 'solar':
        return point.surface_net_solar_radiation / 1000000; // Normalize
      default:
        return 0;
    }
  }

  Color _getColorForValue(double value, String type) {
    double normalized;

    switch (type) {
      case 'temperature':
        // Temperature range: 0°C to 40°C
        normalized = ((value.clamp(0, 40)) / 40);
        return _interpolateColor(
          Colors.blue,
          Colors.red,
          normalized,
        );

      case 'wind':
        // Wind speed range: 0 to 20 m/s
        normalized = (value.clamp(0, 20) / 20);
        return _interpolateColor(
          Colors.green.shade100,
          Colors.purple.shade900,
          normalized,
        );

      case 'precipitation':
        // Precipitation range: 0 to 10 mm
        normalized = (value.clamp(0, 10) / 10);
        return _interpolateColor(
          Colors.yellow.shade100,
          Colors.blue.shade900,
          normalized,
        );

      case 'pressure':
        // Pressure range: 980 to 1040 hPa
        normalized = ((value.clamp(980, 1040) - 980) / 60);
        return _interpolateColor(
          Colors.orange.shade200,
          Colors.indigo.shade900,
          normalized,
        );

      case 'dewpoint':
        // Dewpoint range: -10°C to 30°C
        normalized = ((value.clamp(-10, 30) + 10) / 40);
        return _interpolateColor(
          Colors.cyan.shade100,
          Colors.teal.shade900,
          normalized,
        );

      case 'solar':
        // Solar radiation (normalized)
        normalized = value.clamp(0, 10) / 10;
        return _interpolateColor(
          Colors.grey.shade800,
          Colors.yellow.shade400,
          normalized,
        );

      default:
        return Colors.grey;
    }
  }

  Color _interpolateColor(Color start, Color end, double t) {
    return Color.fromRGBO(
      (start.red + (end.red - start.red) * t).round(),
      (start.green + (end.green - start.green) * t).round(),
      (start.blue + (end.blue - start.blue) * t).round(),
      1.0,
    );
  }
}
