/// Model for Chesapeake Bay shapefile data
class ChesapeakeBayData {
  final String name;
  final String type;
  final Map<String, dynamic> properties;
  final List<List<List<double>>> coordinates;
  final double? areaKm2;

  ChesapeakeBayData({
    required this.name,
    required this.type,
    required this.properties,
    required this.coordinates,
    this.areaKm2,
  });

  factory ChesapeakeBayData.fromJson(Map<String, dynamic> json) {
    return ChesapeakeBayData(
      name: json['name'] ?? '',
      type: json['type'] ?? '',
      properties: json['properties'] ?? {},
      coordinates: List<List<List<double>>>.from(
        json['geometry']?['coordinates'] ?? [],
      ),
      areaKm2: json['properties']?['area_km2']?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'type': type,
      'properties': properties,
      'geometry': {
        'coordinates': coordinates,
      },
      'area_km2': areaKm2,
    };
  }
}

/// Model for fish habitat zones
class FishHabitatZone {
  final String name;
  final String species;
  final String season;
  final double areaKm2;
  final List<List<List<double>>> coordinates;
  final String habitatType;

  FishHabitatZone({
    required this.name,
    required this.species,
    required this.season,
    required this.areaKm2,
    required this.coordinates,
    required this.habitatType,
  });

  factory FishHabitatZone.fromJson(Map<String, dynamic> json) {
    return FishHabitatZone(
      name: json['name'] ?? '',
      species: json['species'] ?? '',
      season: json['season'] ?? '',
      areaKm2: json['area_km2']?.toDouble() ?? 0.0,
      coordinates: List<List<List<double>>>.from(
        json['geometry']?['coordinates'] ?? [],
      ),
      habitatType: json['habitat_type'] ?? 'unknown',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'species': species,
      'season': season,
      'area_km2': areaKm2,
      'geometry': {
        'coordinates': coordinates,
      },
      'habitat_type': habitatType,
    };
  }
}

/// Model for submerged aquatic vegetation zones
class SAVZone {
  final String name;
  final String species;
  final String density;
  final double areaKm2;
  final List<List<List<double>>> coordinates;
  final String vegetationType;

  SAVZone({
    required this.name,
    required this.species,
    required this.density,
    required this.areaKm2,
    required this.coordinates,
    required this.vegetationType,
  });

  factory SAVZone.fromJson(Map<String, dynamic> json) {
    return SAVZone(
      name: json['name'] ?? '',
      species: json['species'] ?? '',
      density: json['density'] ?? '',
      areaKm2: json['area_km2']?.toDouble() ?? 0.0,
      coordinates: List<List<List<double>>>.from(
        json['geometry']?['coordinates'] ?? [],
      ),
      vegetationType: json['vegetation_type'] ?? 'unknown',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'species': species,
      'density': density,
      'area_km2': areaKm2,
      'geometry': {
        'coordinates': coordinates,
      },
      'vegetation_type': vegetationType,
    };
  }
}

/// Model for SAR data from Earth Engine
class SARData {
  final String id;
  final String satellite;
  final DateTime date;
  final String polarization;
  final double resolution;
  final String filePath;
  final Map<String, dynamic> metadata;
  final String dataType; // 'annual', 'monthly', 'summer'

  SARData({
    required this.id,
    required this.satellite,
    required this.date,
    required this.polarization,
    required this.resolution,
    required this.filePath,
    required this.metadata,
    required this.dataType,
  });

  factory SARData.fromJson(Map<String, dynamic> json) {
    return SARData(
      id: json['id'] ?? '',
      satellite: json['satellite'] ?? 'Sentinel-1',
      date: DateTime.parse(json['date'] ?? DateTime.now().toIso8601String()),
      polarization: json['polarization'] ?? 'VV/VH',
      resolution: json['resolution']?.toDouble() ?? 10.0,
      filePath: json['file_path'] ?? '',
      metadata: json['metadata'] ?? {},
      dataType: json['data_type'] ?? 'annual',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'satellite': satellite,
      'date': date.toIso8601String(),
      'polarization': polarization,
      'resolution': resolution,
      'file_path': filePath,
      'metadata': metadata,
      'data_type': dataType,
    };
  }
}

/// Model for oil spill detection dataset
class OilSpillDataset {
  final String id;
  final String source; // 'zenodo' or 'm4d'
  final String imagePath;
  final String? maskPath;
  final String? annotationPath;
  final Map<String, dynamic> metadata;
  final bool hasOilSpill;
  final double? confidence;

  OilSpillDataset({
    required this.id,
    required this.source,
    required this.imagePath,
    this.maskPath,
    this.annotationPath,
    required this.metadata,
    required this.hasOilSpill,
    this.confidence,
  });

  factory OilSpillDataset.fromJson(Map<String, dynamic> json) {
    return OilSpillDataset(
      id: json['id'] ?? '',
      source: json['source'] ?? '',
      imagePath: json['image_path'] ?? '',
      maskPath: json['mask_path'],
      annotationPath: json['annotation_path'],
      metadata: json['metadata'] ?? {},
      hasOilSpill: json['has_oil_spill'] ?? false,
      confidence: json['confidence']?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'source': source,
      'image_path': imagePath,
      'mask_path': maskPath,
      'annotation_path': annotationPath,
      'metadata': metadata,
      'has_oil_spill': hasOilSpill,
      'confidence': confidence,
    };
  }
}

/// Model for data source configuration
class DataSourceConfig {
  final String name;
  final String type;
  final String source;
  final String format;
  final String description;
  final bool isAvailable;
  final String? localPath;
  final Map<String, dynamic> metadata;

  DataSourceConfig({
    required this.name,
    required this.type,
    required this.source,
    required this.format,
    required this.description,
    required this.isAvailable,
    this.localPath,
    required this.metadata,
  });

  factory DataSourceConfig.fromJson(Map<String, dynamic> json) {
    return DataSourceConfig(
      name: json['name'] ?? '',
      type: json['type'] ?? '',
      source: json['source'] ?? '',
      format: json['format'] ?? '',
      description: json['description'] ?? '',
      isAvailable: json['is_available'] ?? false,
      localPath: json['local_path'],
      metadata: json['metadata'] ?? {},
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'type': type,
      'source': source,
      'format': format,
      'description': description,
      'is_available': isAvailable,
      'local_path': localPath,
      'metadata': metadata,
    };
  }
}
