import 'package:flutter/material.dart';
import 'screens/login_screen.dart';

void main() {
  runApp(const QueuelessQueueApp());
}

class QueuelessQueueApp extends StatelessWidget {
  const QueuelessQueueApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "Queueless Queue",
      theme: ThemeData(
        primarySwatch: Colors.indigo,
      ),
      home: const LoginScreen(),
    );
  }
}