import 'package:latlong2/latlong.dart';

/// Represents a ship detected via AIS (Automatic Identification System)
class AisShip {
  final String mmsi;           // Maritime Mobile Service Identity
  final String? shipName;
  final LatLng position;
  final double? speed;         // Speed in knots
  final double? course;        // Course over ground (degrees)
  final String shipType;
  final DateTime timestamp;
  final double? heading;       // degrees
  final String? destination;
  final String? callSign;
  final int? imo;             // International Maritime Organization number
  final String? status;       // Navigation status (underway, anchored, etc.)
  final double? length;       // meters
  final double? width;        // meters
  final String? flag;         // Country flag
  final bool isSuspicious;    // Flag for suspicious activity

  const AisShip({
    required this.mmsi,
    this.shipName,
    required this.position,
    this.speed,
    this.course,
    required this.shipType,
    required this.timestamp,
    this.heading,
    this.destination,
    this.callSign,
    this.imo,
    this.status,
    this.length,
    this.width,
    this.flag,
    this.isSuspicious = false,
  });

  factory AisShip.fromJson(Map<String, dynamic> json) {
    return AisShip(
      mmsi: json['mmsi']?.toString() ?? '',
      shipName: json['name']?.toString(),
      position: LatLng(
        _parseDouble(json['latitude']),
        _parseDouble(json['longitude']),
      ),
      speed: json['speedKnots'] != null ? _parseDouble(json['speedKnots']) : null,
      course: json['cog'] != null ? _parseDouble(json['cog']) : null,
      shipType: json['shipType']?.toString() ?? 'Unknown',
      timestamp: json['timestamp'] != null
          ? DateTime.parse(json['timestamp'])
          : DateTime.now(),
      heading: json['heading'] != null ? _parseDouble(json['heading']) : null,
      destination: json['destination']?.toString(),
      callSign: json['callsign']?.toString(),
      imo: json['imo'] != null ? int.tryParse(json['imo'].toString()) : null,
      status: json['status']?.toString(),
      length: json['length'] != null ? _parseDouble(json['length']) : null,
      width: json['width'] != null ? _parseDouble(json['width']) : null,
      flag: json['flag']?.toString(),
      isSuspicious: json['isSuspicious'] == true,
    );
  }

  static double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }

  Map<String, dynamic> toJson() {
    return {
      'mmsi': mmsi,
      'name': shipName,
      'latitude': position.latitude,
      'longitude': position.longitude,
      'speedKnots': speed,
      'cog': course,
      'shipType': shipType,
      'timestamp': timestamp.toIso8601String(),
      'heading': heading,
      'destination': destination,
      'callsign': callSign,
      'imo': imo,
      'status': status,
      'length': length,
      'width': width,
      'flag': flag,
      'isSuspicious': isSuspicious,
    };
  }

  String get displayName => shipName ?? 'Unknown Vessel';

  String get displayType => shipType;
}

/// Filter options for AIS data queries
class AisFilter {
  final List<String>? shipTypes;     // Filter by ship type
  final double? minSpeedKnots;       // Minimum speed
  final double? maxSpeedKnots;       // Maximum speed
  final DateTime? startTime;         // Time range start
  final DateTime? endTime;           // Time range end

  const AisFilter({
    this.shipTypes,
    this.minSpeedKnots,
    this.maxSpeedKnots,
    this.startTime,
    this.endTime,
  });

  bool matches(AisShip ship) {
    // Filter by ship type
    if (shipTypes != null && shipTypes!.isNotEmpty) {
      if (!shipTypes!.contains(ship.shipType)) {
        return false;
      }
    }

    // Filter by speed
    if (ship.speed != null) {
      if (minSpeedKnots != null && ship.speed! < minSpeedKnots!) {
        return false;
      }
      if (maxSpeedKnots != null && ship.speed! > maxSpeedKnots!) {
        return false;
      }
    }

    // Filter by time range
    if (startTime != null && ship.timestamp.isBefore(startTime!)) {
      return false;
    }
    if (endTime != null && ship.timestamp.isAfter(endTime!)) {
      return false;
    }

    return true;
  }
}
