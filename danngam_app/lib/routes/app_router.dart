import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../modules/auth/screens/splash_screen.dart';
import '../modules/auth/screens/onboarding_screen.dart';
import '../modules/auth/screens/login_screen.dart';
import '../modules/equipment/screens/main_screen.dart';

/// App Router Configuration
/// Manages navigation routes
class AppRouter {
  AppRouter._();

  static const String splash = '/';
  static const String onboarding = '/onboarding';
  static const String login = '/login';
  static const String main = '/main';

  /// GoRouter instance
  static GoRouter router({required bool isAuthenticated}) {
    return GoRouter(
      initialLocation: splash,
      routes: [
        // Splash Screen Route
        GoRoute(
          path: splash,
          builder: (context, state) => const SplashScreen(),
        ),

        // Onboarding Screen Route
        GoRoute(
          path: onboarding,
          builder: (context, state) => const OnboardingScreen(),
        ),

        // Login Screen Route
        GoRoute(
          path: login,
          builder: (context, state) => const LoginScreen(),
        ),

        // Main Screen Route
        GoRoute(
          path: main,
          builder: (context, state) => const MainScreen(),
        ),
      ],

      // Redirect logic based on authentication state
      redirect: (context, state) {
        // If user is not authenticated, redirect to splash/login
        if (!isAuthenticated) {
          // Allow access to splash, onboarding, and login routes
          if (state.matchedLocation == splash ||
              state.matchedLocation == onboarding ||
              state.matchedLocation == login) {
            return null;
          }
          // Redirect to splash for all other routes
          return splash;
        }

        // If user is authenticated, prevent access to splash, onboarding, login
        if (state.matchedLocation == splash ||
            state.matchedLocation == onboarding ||
            state.matchedLocation == login) {
          return main;
        }

        return null;
      },

      // Error page
      errorBuilder: (context, state) => Scaffold(
        appBar: AppBar(title: const Text('Error')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Page not found: ${state.matchedLocation}'),
              ElevatedButton(
                onPressed: () => context.go(splash),
                child: const Text('Go to Home'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Alternative: Simple Named Routes (if not using GoRouter)
  static Map<String, WidgetBuilder> createNamedRoutes() {
    return {
      splash: (context) => const SplashScreen(),
      onboarding: (context) => const OnboardingScreen(),
      login: (context) => const LoginScreen(),
      main: (context) => const MainScreen(),
    };
  }
}
