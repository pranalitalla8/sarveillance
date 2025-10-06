import 'package:flutter/material.dart';
import 'screens/splash_screen.dart';
import 'screens/main_screen.dart';
import 'theme/app_theme.dart';

void main() {
  runApp(const NasaSarApp());
}

class NasaSarApp extends StatelessWidget {
  const NasaSarApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SARveillance',
      theme: AppTheme.darkTheme,
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      routes: {
        '/': (context) => const SplashScreen(),
        '/main': (context) => const MainScreen(),
      },
    );
  }
}
