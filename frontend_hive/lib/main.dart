import 'package:flutter/material.dart';
import 'views/login.dart'; // Imports all screens through the index file

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'AfyaHive',
      theme: ThemeData(useMaterial3: true, fontFamily: 'Poppins'),
      home: const LoginScreen(),
    );
  }
}
