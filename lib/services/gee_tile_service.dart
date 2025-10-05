import 'dart:convert';
import 'package:http/http.dart' as http;

class GEETileService {
  // TODO: Update this URL when deploying backend to production
  // For local development with backend running on same machine:
  static const String baseUrl = 'http://localhost:8000';

  // For deployed backend, use your Cloud Run URL:
  // static const String baseUrl = 'https://sar-backend-xxx-uc.a.run.app';

  /// Get Sentinel-1 SAR imagery tile URL from Earth Engine
  ///
  /// Returns a tile URL that can be used with flutter_map's TileLayer
  Future<String?> getSARTiles({
    required String startDate,
    required String endDate,
    String bounds = '-76.5,37.5,-75.5,39.5', // Chesapeake Bay default
  }) async {
    try {
      final uri = Uri.parse('$baseUrl/tiles/sar').replace(queryParameters: {
        'start_date': startDate,
        'end_date': endDate,
        'bounds': bounds,
      });

      print('Fetching SAR tiles from: $uri');
      final response = await http.get(uri).timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          throw Exception('GEE tile request timed out after 30 seconds');
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final tileUrl = data['tile_url'] as String?;
        print('✓ SAR tile URL received: ${tileUrl?.substring(0, 100)}...');
        return tileUrl;
      } else {
        print('✗ SAR tiles error: ${response.statusCode} - ${response.body}');
        return null;
      }
    } catch (e) {
      print('✗ Error fetching SAR tiles: $e');
      return null;
    }
  }

  /// Get oil spill detection overlay tile URL
  ///
  /// Uses VV backscatter threshold (< -22 dB) to detect potential oil
  Future<String?> getOilDetectionTiles({
    required String startDate,
    required String endDate,
    String bounds = '-76.5,37.5,-75.5,39.5',
  }) async {
    try {
      final uri = Uri.parse('$baseUrl/tiles/oil-detection').replace(queryParameters: {
        'start_date': startDate,
        'end_date': endDate,
        'bounds': bounds,
      });

      print('Fetching oil detection tiles from: $uri');
      final response = await http.get(uri).timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          throw Exception('GEE oil detection request timed out');
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final tileUrl = data['tile_url'] as String?;
        print('✓ Oil detection tile URL received');
        return tileUrl;
      } else {
        print('✗ Oil detection tiles error: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('✗ Error fetching oil detection tiles: $e');
      return null;
    }
  }

  /// Get list of available SAR acquisition dates for the region
  Future<List<String>> getAvailableDates({
    String bounds = '-76.5,37.5,-75.5,39.5',
  }) async {
    try {
      final uri = Uri.parse('$baseUrl/dates/available').replace(queryParameters: {
        'bounds': bounds,
      });

      print('Fetching available dates from: $uri');
      final response = await http.get(uri).timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          throw Exception('GEE dates request timed out');
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final dates = List<String>.from(data['dates'] ?? []);
        print('✓ Received ${dates.length} available dates');
        return dates;
      } else {
        print('✗ Available dates error: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      print('✗ Error fetching available dates: $e');
      return [];
    }
  }

  /// Check if the GEE backend is running and healthy
  Future<bool> checkBackendHealth() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/health'),
      ).timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final isHealthy = data['status'] == 'healthy';
        final geeInit = data['gee_initialized'] == true;
        print('✓ Backend health: ${isHealthy ? "OK" : "ERROR"}');
        print('✓ GEE initialized: ${geeInit ? "YES" : "NO"}');
        return isHealthy && geeInit;
      }
      return false;
    } catch (e) {
      print('✗ Backend health check failed: $e');
      print('  Make sure backend is running at: $baseUrl');
      return false;
    }
  }
}
