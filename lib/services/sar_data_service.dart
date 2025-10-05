import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/oil_spill_data.dart';

class SARDataService {
  static final SARDataService _instance = SARDataService._internal();
  factory SARDataService() => _instance;
  SARDataService._internal();

  List<OilSpillData>? _cachedData;

  /// Load SAR data from assets
  Future<List<OilSpillData>> loadSARData() async {
    if (_cachedData != null) {
      return _cachedData!;
    }

    try {
      final String jsonString = await rootBundle.loadString('assets/data/flutter_sar_data.json');
      final Map<String, dynamic> jsonData = json.decode(jsonString);

      final List<dynamic> dataPoints = jsonData['data_points'] as List;
      _cachedData = dataPoints.map((point) => OilSpillData.fromJson(point)).toList();

      return _cachedData!;
    } catch (e) {
      print('Error loading SAR data: $e');
      return [];
    }
  }

  /// Get data points within a specific area
  List<OilSpillData> getDataInBounds({
    required double minLat,
    required double maxLat,
    required double minLng,
    required double maxLng,
    List<OilSpillData>? data,
  }) {
    final dataToFilter = data ?? _cachedData ?? [];
    return dataToFilter.where((point) {
      return point.latitude >= minLat &&
          point.latitude <= maxLat &&
          point.longitude >= minLng &&
          point.longitude <= maxLng;
    }).toList();
  }

  /// Get high-risk oil spill points (high SAR values)
  List<OilSpillData> getHighRiskPoints({
    required List<OilSpillData> data,
    double threshold = 0.7,
  }) {
    return data.where((point) => point.sar >= threshold).toList();
  }

  /// Clear cached data
  void clearCache() {
    _cachedData = null;
  }
}
