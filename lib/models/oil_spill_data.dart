class OilSpillData {
  final double longitude;
  final double latitude;
  final double sar;
  final double ndvi;
  final double ndci;
  final double wqi;

  const OilSpillData({
    required this.longitude,
    required this.latitude,
    required this.sar,
    required this.ndvi,
    required this.ndci,
    required this.wqi,
  });

  factory OilSpillData.fromJson(Map<String, dynamic> json) {
    return OilSpillData(
      longitude: (json['lng'] as num).toDouble(),
      latitude: (json['lat'] as num).toDouble(),
      sar: (json['sar'] as num).toDouble(),
      ndvi: (json['ndvi'] as num).toDouble(),
      ndci: (json['ndci'] as num).toDouble(),
      wqi: (json['wqi'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'lng': longitude,
      'lat': latitude,
      'sar': sar,
      'ndvi': ndvi,
      'ndci': ndci,
      'wqi': wqi,
    };
  }
}
