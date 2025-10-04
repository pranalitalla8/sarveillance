import 'package:flutter/material.dart';
import 'story_screen.dart';
import 'explore_screen.dart';
import 'analyze_screen.dart';
import 'compare_screen.dart';
import 'discover_screen.dart';
import 'profile_screen.dart';
import 'data_management_screen.dart';
 
class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const StoryScreen(),
    const ExploreScreen(),
    const AnalyzeScreen(),
    const CompareScreen(),
    const DiscoverScreen(),
  ];

  void _navigateToDataManagement() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const DataManagementScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Theme.of(context).colorScheme.surface,
              Theme.of(context).colorScheme.primaryContainer,
              Theme.of(context).colorScheme.surface,
            ],
            stops: const [0.0, 0.5, 1.0],
          ),
        ),
        child: _screens[_currentIndex],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToDataManagement,
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        child: const Icon(Icons.cloud_download),
        tooltip: 'Data Sources',
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.startTop,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.3),
              blurRadius: 20,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          type: BottomNavigationBarType.fixed,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.auto_stories),
              activeIcon: Icon(Icons.auto_stories),
              label: 'Story',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.explore),
              activeIcon: Icon(Icons.explore),
              label: 'Explore',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.analytics),
              activeIcon: Icon(Icons.analytics),
              label: 'Analyze',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.compare),
              activeIcon: Icon(Icons.compare),
              label: 'Compare',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.school),
              activeIcon: Icon(Icons.school),
              label: 'Discover',
            ),
          ],
        ),
      ),
    );
  }
}