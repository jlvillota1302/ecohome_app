import 'package:flutter/material.dart';
import 'screens/login_screen.dart';

import 'package:flutter/material.dart';
import 'screens/login_screen.dart';

void main() {
  runApp(const EcoHomeApp());
}

class EcoHomeApp extends StatelessWidget {
  const EcoHomeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'EcoHome App',
      debugShowCheckedModeBanner: false,
      home: const LoginScreen(),
    );
  }
}