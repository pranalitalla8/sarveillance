class StudyArea {
  final String id;
  final String title;
  final String description;
  final String category;
  final String location;
  final String imageUrl;
  final DateTime lastUpdated;
  final Map<String, dynamic> metadata;

  const StudyArea({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.location,
    required this.imageUrl,
    required this.lastUpdated,
    this.metadata = const {},
  });
}

enum StudyAreaCategory {
  disasters('Disasters', 'Natural disasters and emergencies'),
  climate('Climate', 'Climate change monitoring'),
  urban('Urban', 'Urban development and infrastructure'),
  naturalFeatures('Natural Features', 'Geological and environmental features');

  const StudyAreaCategory(this.displayName, this.description);
  final String displayName;
  final String description;
}