import 'package:flutter/material.dart';
import 'package:fraud_detector/screens/fraud_detection_screen.dart';

void main() {
  runApp(const FraudDetectorApp());
}

class FraudDetectorApp extends StatelessWidget {
  const FraudDetectorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Fraud Detector',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
      ),
      home: const FraudDetectionScreen(),
    );
  }
}


