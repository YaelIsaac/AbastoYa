import 'package:flutter/material.dart';

import 'screens/splash_screen.dart';
import 'theme.dart';

void main() {
  runApp(const AbastoYaApp());
}

class AbastoYaApp extends StatelessWidget {
  const AbastoYaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AbastoYa',
      debugShowCheckedModeBanner: false,
      theme: buildTheme(),
      home: const SplashScreen(),
    );
  }
}
