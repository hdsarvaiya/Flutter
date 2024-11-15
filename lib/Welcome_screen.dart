import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:app/dashboard.dart';
import 'package:app/login.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  _WelcomeScreenState createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> with TickerProviderStateMixin {
  late AnimationController _horizontalController;
  late AnimationController _verticalController;
  late Animation<Offset> _iconSlideAnimation;
  late Animation<Offset> _textSlideAnimation;
  late Animation<Offset> _verticalAnimation;

  @override
  void initState() {
    super.initState();

    // Initialize animations
    _horizontalController = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    );

    _iconSlideAnimation = Tween<Offset>(
      begin: const Offset(2.0, 0.0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _horizontalController,
      curve: Curves.easeInOut,
    ));

    _textSlideAnimation = Tween<Offset>(
      begin: const Offset(-2.0, 0.0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _horizontalController,
      curve: Curves.easeInOut,
    ));

    _verticalController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);

    _verticalAnimation = Tween<Offset>(
      begin: const Offset(0.0, -0.1),
      end: const Offset(0.0, 0.1),
    ).animate(CurvedAnimation(
      parent: _verticalController,
      curve: Curves.easeInOut,
    ));

    // Start animations and then check authentication state
    _horizontalController.forward().then((_) {
      _verticalController.forward();
      _checkAuthenticationStatus();
    });
  }

  void _checkAuthenticationStatus() async {
    final user = FirebaseAuth.instance.currentUser;

    // Delay before navigating to give time for animations
    await Future.delayed(const Duration(seconds: 2));

    if (user != null) {
      // User is logged in, navigate to Dashboard
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const DashboardScreen()),
      );
    } else {
      // User is not logged in, navigate to Login
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginPage()),
      );
    }
  }

  @override
  void dispose() {
    _horizontalController.dispose();
    _verticalController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SlideTransition(
              position: _iconSlideAnimation,
              child: SlideTransition(
                position: _verticalAnimation,
                child: const Icon(
                  Icons.local_offer,
                  size: 100.0,
                  color: Colors.brown,
                ),
              ),
            ),
            const SizedBox(height: 20),
            SlideTransition(
              position: _textSlideAnimation,
              child: Text(
                'Cattle Tagging',
                style: TextStyle(
                  fontSize: 36.0,
                  fontWeight: FontWeight.bold,
                  color: Colors.brown[700],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
