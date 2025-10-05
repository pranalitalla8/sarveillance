import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:csv/csv.dart';
import '../models/oil_spill_data.dart';

class SARDataService {
  static final SARDataService _instance = SARDataService._internal();
  factory SARDataService() => _instance;
  SARDataService._internal();

  List<OilSpillData>? _cachedData;

  /// Load SAR data from CSV asset
  Future<List<OilSpillData>> loadSARData() async {
    if (_cachedData != null) {
      return _cachedData!;
    }

    try {
      // Load CSV from assets (merged dataset with water points, AIS + NASA POWER data)
      print('Loading complete SAR dataset with water points, AIS ship tracking, and NASA POWER weather data...');
      final String csvString = await rootBundle.loadString('assets/data/merged_complete_data.csv');
      print('CSV loaded, length: ${csvString.length} characters');

      // Parse CSV with proper field delimiter and text delimiter handling
      final List<List<dynamic>> rows = const CsvToListConverter(
        fieldDelimiter: ',',
        textDelimiter: '"',
        eol: '\n',
      ).convert(csvString);
      print('Parsed ${rows.length} rows from CSV');

      if (rows.isEmpty) {
        print('CSV file is empty');
        return [];
      }

      // First row is header
      final List<String> headers = rows[0].map((e) => e.toString()).toList();
      print('Headers: ${headers.join(", ")}'.substring(0, 200));

      // Convert remaining rows to OilSpillData objects
      _cachedData = [];
      for (int i = 1; i < rows.length; i++) {
        try {
          // Create a map from headers and row values
          final Map<String, dynamic> rowMap = {};
          for (int j = 0; j < headers.length && j < rows[i].length; j++) {
            rowMap[headers[j]] = rows[i][j];
          }

          final oilSpillData = OilSpillData.fromCsv(rowMap);
          _cachedData!.add(oilSpillData);
        } catch (e, stackTrace) {
          print('Error parsing row $i: $e');
          print('Stack trace: $stackTrace');
          if (i < 5) {
            print('Row data: ${rows[i]}');
          }
          // Skip this row and continue
        }
      }

      // Count ship-related points for debugging
      final shipRelatedCount = _cachedData!.where((p) => p.isShipRelated).length;
      print('Loaded ${_cachedData!.length} oil spill data points');
      print('Ship-related points: $shipRelatedCount');
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

  /// Get only oil candidate points
  List<OilSpillData> getOilCandidates({List<OilSpillData>? data}) {
    final dataToFilter = data ?? _cachedData ?? [];
    return dataToFilter.where((point) => point.oil_candidate == 1).toList();
  }

  /// Get only water points
  List<OilSpillData> getWaterPoints({List<OilSpillData>? data}) {
    final dataToFilter = data ?? _cachedData ?? [];
    return dataToFilter.where((point) => point.oil_candidate == 0).toList();
  }

  /// Filter by date range
  List<OilSpillData> getDataByDateRange({
    required DateTime startDate,
    required DateTime endDate,
    List<OilSpillData>? data,
  }) {
    final dataToFilter = data ?? _cachedData ?? [];
    return dataToFilter.where((point) {
      return point.date.isAfter(startDate.subtract(const Duration(days: 1))) &&
          point.date.isBefore(endDate.add(const Duration(days: 1)));
    }).toList();
  }

  /// Get points with ship correlation (if AIS data is available)
  List<OilSpillData> getShipRelatedPoints({List<OilSpillData>? data}) {
    final dataToFilter = data ?? _cachedData ?? [];
    return dataToFilter.where((point) => point.isShipRelated).toList();
  }

  /// Get high-risk points (oil candidates near ships)
  List<OilSpillData> getHighRiskPoints({List<OilSpillData>? data}) {
    final dataToFilter = data ?? _cachedData ?? [];
    return dataToFilter.where((point) =>
      point.isOilCandidate && point.isShipRelated
    ).toList();
  }

  /// Get unique dates in the dataset
  List<DateTime> getUniqueDates() {
    if (_cachedData == null) return [];
    final dates = _cachedData!.map((point) => point.date).toSet().toList();
    dates.sort();
    return dates;
  }

  /// Get data for a specific date
  List<OilSpillData> getDataForDate(DateTime date) {
    if (_cachedData == null) return [];
    return _cachedData!.where((point) {
      return point.date.year == date.year &&
          point.date.month == date.month &&
          point.date.day == date.day;
    }).toList();
  }

  /// Get statistics
  Map<String, dynamic> getStatistics({List<OilSpillData>? data}) {
    final dataToAnalyze = data ?? _cachedData ?? [];

    if (dataToAnalyze.isEmpty) {
      return {
        'total': 0,
        'oil_candidates': 0,
        'water_points': 0,
        'ship_related': 0,
        'high_risk': 0,
      };
    }

    return {
      'total': dataToAnalyze.length,
      'oil_candidates': dataToAnalyze.where((p) => p.isOilCandidate).length,
      'water_points': dataToAnalyze.where((p) => !p.isOilCandidate).length,
      'ship_related': dataToAnalyze.where((p) => p.isShipRelated).length,
      'high_risk': dataToAnalyze.where((p) => p.isOilCandidate && p.isShipRelated).length,
      'unique_dates': dataToAnalyze.map((p) => p.date).toSet().length,
    };
  }

  /// Clear cached data
  void clearCache() {
    _cachedData = null;
  }
}
