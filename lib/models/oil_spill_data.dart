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

  // AIS (Ship tracking) - from combined AIS data
  final int? num_ships_near_point;          // Number of ships detected near this point
  final double? closest_ship_distance_km;   // Distance to closest ship in km
  final double? avg_ship_speed;             // Average speed of nearby ships

  // NASA POWER weather data (enhanced)
  final double? nasa_power_air_temp_2m;           // °C
  final double? nasa_power_max_air_temp_2m;       // °C
  final double? nasa_power_min_air_temp_2m;       // °C
  final double? nasa_power_wind_speed_2m;         // m/s
  final double? nasa_power_precipitation_mm;      // mm
  final double? nasa_power_solar_radiation;       // MJ/m²/day

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
    this.num_ships_near_point,
    this.closest_ship_distance_km,
    this.avg_ship_speed,
    this.nasa_power_air_temp_2m,
    this.nasa_power_max_air_temp_2m,
    this.nasa_power_min_air_temp_2m,
    this.nasa_power_wind_speed_2m,
    this.nasa_power_precipitation_mm,
    this.nasa_power_solar_radiation,
  });

  factory OilSpillData.fromCsv(Map<String, dynamic> row) {
    // Helper to get value case-insensitively
    dynamic getValue(String key) {
      return row[key] ?? row[key.toLowerCase()] ?? row[key.toUpperCase()];
    }

    // Debug: Print NASA POWER values for first row
    if (row['system:index']?.toString().contains('0_1_33') == true) {
      print('DEBUG NASA POWER DATA for first row:');
      print('  nasa_power_air_temp_2m: ${getValue('nasa_power_air_temp_2m')}');
      print('  nasa_power_max_air_temp_2m: ${getValue('nasa_power_max_air_temp_2m')}');
      print('  nasa_power_min_air_temp_2m: ${getValue('nasa_power_min_air_temp_2m')}');
      print('  All keys: ${row.keys.where((k) => k.contains('nasa')).toList()}');
    }

    return OilSpillData(
      systemIndex: getValue('system:index')?.toString() ?? '',
      longitude: _parseDouble(getValue('longitude')),
      latitude: _parseDouble(getValue('latitude')),
      date: _parseDate(getValue('date')),
      VV: _parseDouble(getValue('vv')),
      VH: _parseDouble(getValue('vh')),
      VH_VV_ratio: _parseDouble(getValue('vh_vv_ratio')),
      angle: _parseDouble(getValue('angle')),
      orbit_direction: _parseInt(getValue('orbit_direction')),
      orbit_type: getValue('orbit_type')?.toString() ?? 'ASC',
      oil_candidate: _parseInt(getValue('oil_candidate')),
      temperature_2m: _parseDouble(getValue('temperature_2m')),
      dewpoint_temperature_2m: _parseDouble(getValue('dewpoint_temperature_2m')),
      surface_pressure: _parseDouble(getValue('surface_pressure')),
      total_precipitation: _parseDouble(getValue('total_precipitation')),
      surface_net_solar_radiation: _parseDouble(getValue('surface_net_solar_radiation')),
      u_component_of_wind_10m: _parseDouble(getValue('u_component_of_wind_10m')),
      v_component_of_wind_10m: _parseDouble(getValue('v_component_of_wind_10m')),
      wind_speed_10m: _parseDouble(getValue('wind_speed_10m')),
      wind_direction_degrees: _parseDouble(getValue('wind_direction_degrees')),
      geoJson: getValue('.geo')?.toString(),
      num_ships_near_point: getValue('num_ships_near_point') != null ? _parseInt(getValue('num_ships_near_point')) : null,
      closest_ship_distance_km: getValue('closest_ship_distance_km') != null ? _parseDouble(getValue('closest_ship_distance_km')) : null,
      avg_ship_speed: getValue('avg_ship_speed') != null ? _parseDouble(getValue('avg_ship_speed')) : null,
      nasa_power_air_temp_2m: getValue('nasa_power_air_temp_2m') != null ? _parseDouble(getValue('nasa_power_air_temp_2m')) : null,
      nasa_power_max_air_temp_2m: getValue('nasa_power_max_air_temp_2m') != null ? _parseDouble(getValue('nasa_power_max_air_temp_2m')) : null,
      nasa_power_min_air_temp_2m: getValue('nasa_power_min_air_temp_2m') != null ? _parseDouble(getValue('nasa_power_min_air_temp_2m')) : null,
      nasa_power_wind_speed_2m: getValue('nasa_power_wind_speed_2m_m/s') != null ? _parseDouble(getValue('nasa_power_wind_speed_2m_m/s')) : null,
      nasa_power_precipitation_mm: getValue('nasa_power_precipitation_mm') != null ? _parseDouble(getValue('nasa_power_precipitation_mm')) : null,
      nasa_power_solar_radiation: getValue('nasa_power_solar_radiation_MJm2day') != null ? _parseDouble(getValue('nasa_power_solar_radiation_MJm2day')) : null,
    );
  }

  static double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) {
      if (value.isEmpty) return 0.0;
      return double.tryParse(value) ?? 0.0;
    }
    return 0.0;
  }

  static int _parseInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) {
      if (value.isEmpty) return 0;
      return int.tryParse(value) ?? 0;
    }
    return 0;
  }

  static DateTime _parseDate(dynamic value) {
    if (value == null) return DateTime(2015, 1, 1);
    try {
      if (value is DateTime) return value;
      if (value is String) {
        if (value.isEmpty) return DateTime(2015, 1, 1);
        return DateTime.parse(value);
      }
      return DateTime(2015, 1, 1);
    } catch (e) {
      // Handle invalid date formats (like corrupt numeric values in CSV)
      return DateTime(2015, 1, 1);
    }
  }

  // Helper methods
  bool get isOilCandidate => oil_candidate == 1;

  double get temperatureCelsius => temperature_2m - 273.15;

  double get dewpointCelsius => dewpoint_temperature_2m - 273.15;

  String get latitudeFormatted => '${latitude.toStringAsFixed(2)}°${latitude >= 0 ? 'N' : 'S'}';

  String get longitudeFormatted => '${longitude.abs().toStringAsFixed(2)}°${longitude >= 0 ? 'E' : 'W'}';

  bool get hasShipData => num_ships_near_point != null && num_ships_near_point! > 0;

  bool get isShipRelated => hasShipData && (closest_ship_distance_km ?? double.infinity) < 5.0; // Within 5km

  bool get hasNasaPowerData => nasa_power_air_temp_2m != null;
}
