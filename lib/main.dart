import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'screens/auth_wrapper.dart';
import 'utils/app_colors.dart';

// Note: After running 'flutterfire configure', uncomment the line below
// import 'firebase_options.dart';

void main() async {
  // Set system UI overlay style
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase
  // After running 'flutterfire configure', update this line to:
  // await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await Firebase.initializeApp();
  
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );
  
  runApp(const QueuelessQueueApp());
}

/// Main application widget
class QueuelessQueueApp extends StatelessWidget {
  const QueuelessQueueApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Queueless Queue',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: AppColors.primary,
        scaffoldBackgroundColor: AppColors.background,
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.primary,
          brightness: Brightness.light,
        ),
      ),
      home: const AuthWrapper(), // Changed from LoginScreen to AuthWrapper
    );
  }
}
