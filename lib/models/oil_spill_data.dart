class OilSpillData {
  // Identification
  final String systemIndex;

  // Location
  final double longitude;
  final double latitude;
  final DateTime date;

  // SAR Data (Sentinel-1)
  final double VV;           // Vertical-Vertical polarization (dB)
  final double VH;           // Vertical-Horizontal polarization (dB)
  final double VH_VV_ratio;  // Ratio for material classification
  final double angle;        // Incidence angle (degrees)

  // Orbit metadata
  final int orbit_direction;  // 0 = ascending, 1 = descending
  final String orbit_type;    // "ASC" or "DESC"

  // Classification
  final int oil_candidate;    // 0 = water, 1 = oil

  // Environmental (ERA5)
  final double temperature_2m;                  // Kelvin
  final double dewpoint_temperature_2m;         // Kelvin
  final double surface_pressure;                // Pascal
  final double total_precipitation;             // meters
  final double surface_net_solar_radiation;     // J/m²
  final double u_component_of_wind_10m;         // m/s
  final double v_component_of_wind_10m;         // m/s
  final double wind_speed_10m;                  // m/s
  final double wind_direction_degrees;          // degrees

  // GeoJSON (optional, for reference)
  final String? geoJson;

  // AIS (Ship tracking) - OPTIONAL, will be null until teammates run AIS script
  final String? vessel_flag;      // 'ship_related' or 'no_ship_detected'
  final int? num_ships;
  final String? ship_types;

  const OilSpillData({
    required this.systemIndex,
    required this.longitude,
    required this.latitude,
    required this.date,
    required this.VV,
    required this.VH,
    required this.VH_VV_ratio,
    required this.angle,
    required this.orbit_direction,
    required this.orbit_type,
    required this.oil_candidate,
    required this.temperature_2m,
    required this.dewpoint_temperature_2m,
    required this.surface_pressure,
    required this.total_precipitation,
    required this.surface_net_solar_radiation,
    required this.u_component_of_wind_10m,
    required this.v_component_of_wind_10m,
    required this.wind_speed_10m,
    required this.wind_direction_degrees,
    this.geoJson,
    this.vessel_flag,
    this.num_ships,
    this.ship_types,
  });

  factory OilSpillData.fromCsv(Map<String, dynamic> row) {
    return OilSpillData(
      systemIndex: row['system:index']?.toString() ?? '',
      longitude: _parseDouble(row['longitude']),
      latitude: _parseDouble(row['latitude']),
      date: DateTime.parse(row['date'] ?? '2015-01-01'),
      VV: _parseDouble(row['VV']),
      VH: _parseDouble(row['VH']),
      VH_VV_ratio: _parseDouble(row['VH_VV_ratio']),
      angle: _parseDouble(row['angle']),
      orbit_direction: _parseInt(row['orbit_direction']),
      orbit_type: row['orbit_type']?.toString() ?? 'ASC',
      oil_candidate: _parseInt(row['oil_candidate']),
      temperature_2m: _parseDouble(row['temperature_2m']),
      dewpoint_temperature_2m: _parseDouble(row['dewpoint_temperature_2m']),
      surface_pressure: _parseDouble(row['surface_pressure']),
      total_precipitation: _parseDouble(row['total_precipitation']),
      surface_net_solar_radiation: _parseDouble(row['surface_net_solar_radiation']),
      u_component_of_wind_10m: _parseDouble(row['u_component_of_wind_10m']),
      v_component_of_wind_10m: _parseDouble(row['v_component_of_wind_10m']),
      wind_speed_10m: _parseDouble(row['wind_speed_10m']),
      wind_direction_degrees: _parseDouble(row['wind_direction_degrees']),
      geoJson: row['.geo']?.toString(),
      vessel_flag: row['vessel_flag']?.toString(),
      num_ships: row['num_ships'] != null ? _parseInt(row['num_ships']) : null,
      ship_types: row['ship_types']?.toString(),
    );
  }

  static double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }

  static int _parseInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }

  // Helper methods
  bool get isOilCandidate => oil_candidate == 1;

  double get temperatureCelsius => temperature_2m - 273.15;

  double get dewpointCelsius => dewpoint_temperature_2m - 273.15;

  String get latitudeFormatted => '${latitude.toStringAsFixed(2)}°${latitude >= 0 ? 'N' : 'S'}';

  String get longitudeFormatted => '${longitude.abs().toStringAsFixed(2)}°${longitude >= 0 ? 'E' : 'W'}';

  bool get hasShipData => vessel_flag != null;

  bool get isShipRelated => vessel_flag == 'ship_related';
}
