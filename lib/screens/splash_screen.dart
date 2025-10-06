import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'dart:async';
import '../services/sar_data_service.dart';
import '../services/gee_tile_service.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  bool _isLoading = true;
  String _loadingStatus = 'Initializing...';

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.5, curve: Curves.easeIn),
      ),
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.5, curve: Curves.easeOutCubic),
      ),
    );

    _animationController.forward();
    _preloadData();
  }

  Future<void> _preloadData() async {
    try {
      // Start loading SAR data in the background
      setState(() {
        _loadingStatus = 'Loading SAR data...';
      });

      final sarService = SARDataService();
      await sarService.loadSARData();

      setState(() {
        _loadingStatus = 'Preparing Earth Engine tiles...';
      });

      // Initialize GEE tile service (this prepares the backend connection)
      final geeService = GEETileService();
      // Pre-warm the connection by getting SAR tiles for Chesapeake Bay
      await geeService.getSARTiles(
        startDate: '2024-01-01',
        endDate: '2024-12-31',
      );

      setState(() {
        _loadingStatus = 'Ready!';
      });

      // Wait a minimum of 3 seconds total for branding
      await Future.delayed(const Duration(milliseconds: 3000));

      // Navigate to main screen
      if (mounted) {
        Navigator.of(context).pushReplacementNamed('/main');
      }
    } catch (e) {
      print('Splash screen preload error: $e');
      setState(() {
        _loadingStatus = 'Ready!';
        _isLoading = false;
      });

      // Still navigate after showing error briefly
      await Future.delayed(const Duration(seconds: 2));
      if (mounted) {
        Navigator.of(context).pushReplacementNamed('/main');
      }
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF001B3D), // Deep blue
              Color(0xFF003366), // Slightly lighter deep blue
            ],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(flex: 2),

              // Animated logo
              AnimatedBuilder(
                animation: _animationController,
                builder: (context, child) {
                  return FadeTransition(
                    opacity: _fadeAnimation,
                    child: ScaleTransition(
                      scale: _scaleAnimation,
                      child: SvgPicture.asset(
                        'assets/images/sarveillance_logo.svg',
                        width: 250,
                        height: 212,
                      ),
                    ),
                  );
                },
              ),

              const SizedBox(height: 48),

              // Loading indicator
              if (_isLoading) ...[
                const SizedBox(
                  width: 40,
                  height: 40,
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFFFF30F)),
                    strokeWidth: 3,
                  ),
                ),
                const SizedBox(height: 24),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: Text(
                    _loadingStatus,
                    key: ValueKey(_loadingStatus),
                    style: const TextStyle(
                      color: Color(0xFFFFF30F),
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ],

              const Spacer(flex: 3),

              // Bottom tagline
              Padding(
                padding: const EdgeInsets.only(bottom: 48),
                child: Column(
                  children: [
                    Text(
                      'Oil Spill Detection for Chesapeake Bay',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.7),
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    const SizedBox(height: 8),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
