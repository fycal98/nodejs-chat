import 'package:flutter/material.dart';
import 'Home.dart';
import 'Login.dart';

void main() {
  // Dart client

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: LoginScreen(),
    );
  }
}
