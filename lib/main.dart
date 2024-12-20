import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:app/Welcome_screen.dart'; // Import the WelcomeScreen

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase with options for mobile
  await Firebase.initializeApp(
    options: const FirebaseOptions(
      apiKey: "AIzaSyBy4njaj1TdTAQ6Itgyj_-mnZZs1yT2DXM",
      authDomain: "YOUR_AUTH_DOMAIN",
      projectId: "authentication-e106e",
      storageBucket: "authentication-e106e.appspot.com",
      messagingSenderId: "YOUR_MESSAGING_SENDER_ID",
      appId: "YOUR_APP_ID",
      measurementId: "YOUR_MEASUREMENT_ID",
    ),
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'My App',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const WelcomeScreen(),
    );
  }
}
