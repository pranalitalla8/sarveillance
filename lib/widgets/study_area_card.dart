import 'package:flutter/material.dart';
import '../models/study_area.dart';

class StudyAreaCard extends StatelessWidget {
  final StudyArea studyArea;
  final VoidCallback? onTap;

  const StudyAreaCard({
    super.key,
    required this.studyArea,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 2,
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: _getCategoryColor(studyArea.category),
                ),
                child: Stack(
                  children: [
                    // Background image
                    Positioned.fill(
                      child: _getCategoryImageUrl(studyArea.category).isNotEmpty
                          ? Image.network(
                              _getCategoryImageUrl(studyArea.category),
                              fit: BoxFit.cover,
                              loadingBuilder: (context, child, loadingProgress) {
                                if (loadingProgress == null) return child;
                                return Container(
                                  color: _getCategoryColor(studyArea.category),
                                  child: Center(
                                    child: CircularProgressIndicator(
                                      value: loadingProgress.expectedTotalBytes != null
                                          ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                                          : null,
                                      color: Colors.white,
                                    ),
                                  ),
                                );
                              },
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                      colors: [
                                        _getCategoryColor(studyArea.category),
                                        _getCategoryColor(studyArea.category).withValues(alpha: 0.7),
                                      ],
                                    ),
                                  ),
                                  child: Center(
                                    child: Icon(
                                      _getCategoryIcon(studyArea.category),
                                      size: 48,
                                      color: Colors.white.withValues(alpha: 0.3),
                                    ),
                                  ),
                                );
                              },
                            )
                          : Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    _getCategoryColor(studyArea.category),
                                    _getCategoryColor(studyArea.category).withValues(alpha: 0.7),
                                  ],
                                ),
                              ),
                              child: Center(
                                child: Icon(
                                  _getCategoryIcon(studyArea.category),
                                  size: 48,
                                  color: Colors.white.withValues(alpha: 0.3),
                                ),
                              ),
                            ),
                    ),
                    // Gradient overlay for better text visibility
                    Positioned.fill(
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.black.withValues(alpha: 0.3),
                              Colors.black.withValues(alpha: 0.5),
                            ],
                          ),
                        ),
                      ),
                    ),
                    // Category badge
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: _getCategoryColor(studyArea.category),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.5),
                            width: 1,
                          ),
                        ),
                        child: Text(
                          studyArea.category,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      studyArea.title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      studyArea.location,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.8),
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const Spacer(),
                    Row(
                      children: [
                        Icon(
                          Icons.access_time,
                          size: 12,
                          color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            _formatDate(studyArea.lastUpdated),
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getCategoryImageUrl(String category) {
    switch (category.toLowerCase()) {
      case 'oil spills':
        return 'https://images.unsplash.com/photo-1530587191325-3db32d826c18?w=800&q=80'; // Ocean water
      case 'ship traffic':
        return 'https://images.unsplash.com/photo-1464037866556-6812c9d1c72e?w=800&q=80'; // Cargo ship
      case 'high-risk zone':
        return 'https://images.unsplash.com/photo-1605731414355-485f5e5c6d4f?w=800&q=80'; // Industrial port
      case 'environmental':
        return 'https://images.unsplash.com/photo-1470071459604-3b5ec3a7fe05?w=800&q=80'; // Nature/landscape
      case 'temporal analysis':
        return 'https://images.unsplash.com/photo-1451187580459-43490279c0fa?w=800&q=80'; // Earth from space
      case 'machine learning':
        return 'https://images.unsplash.com/photo-1535378917042-10a22c95931a?w=800&q=80'; // Code/tech
      default:
        return '';
    }
  }

  Color _getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'oil spills':
        return const Color(0xFF8B4513); // Brown for oil
      case 'ship traffic':
        return const Color(0xFF1E40AF); // Navy blue for ships
      case 'high-risk zone':
        return const Color(0xFFDC2626); // Red for high risk
      case 'environmental':
        return const Color(0xFF059669); // Green for environment
      case 'temporal analysis':
        return const Color(0xFF7C3AED); // Purple for data/analysis
      case 'machine learning':
        return const Color(0xFFEF4444); // Bright red for ML
      case 'disasters':
        return const Color(0xFFDC2626);
      case 'climate':
        return const Color(0xFF059669);
      case 'urban':
        return const Color(0xFF7C3AED);
      case 'natural features':
        return const Color(0xFF0891B2);
      default:
        return const Color(0xFF6B7280);
    }
  }

  IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'oil spills':
        return Icons.water_drop;
      case 'ship traffic':
        return Icons.directions_boat;
      case 'high-risk zone':
        return Icons.warning;
      case 'environmental':
        return Icons.eco;
      case 'temporal analysis':
        return Icons.show_chart;
      case 'machine learning':
        return Icons.psychology;
      case 'disasters':
        return Icons.warning;
      case 'climate':
        return Icons.eco;
      case 'urban':
        return Icons.location_city;
      case 'natural features':
        return Icons.landscape;
      default:
        return Icons.map;
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else {
      return '${difference.inMinutes}m ago';
    }
  }
}