import 'package:flutter/material.dart';
import '../../../config/app_colors.dart';
import '../../../shared/constants/app_dimensions.dart';
import '../../../shared/extensions/build_context_ext.dart';

/// Splash Screen
/// Shows app logo and name with fade-in animation
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    // Setup animation
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    // Start animation
    _animationController.forward();

    // Navigate to next screen after 2 seconds (as per wireframe)
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        _navigateToNextScreen();
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _navigateToNextScreen() {
    // TODO: Navigate to onboarding or main based on auth state
    Navigator.of(context).pushReplacementNamed('/onboarding');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: ScaleTransition(
            scale: _scaleAnimation,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // App Logo (100x100px)
                Container(
                  width: 100,
                  height: 100,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      '🌾',
                      style: context.displayLarge,
                    ),
                  ),
                ),
                const SizedBox(height: 32),

                // Loading Spinner
                const SizedBox(
                  width: 50,
                  height: 50,
                  child: CircularProgressIndicator(
                    strokeWidth: 3,
                  ),
                ),
                const SizedBox(height: 32),

                // Loading Text
                Text(
                  '로딩 중...',
                  style: context.bodyLarge,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
