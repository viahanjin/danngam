import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:kakao_flutter_sdk/kakao_flutter_sdk.dart';
import 'config/app_theme.dart';
import 'modules/auth/providers/auth_provider.dart';
import 'modules/auth/screens/splash_screen.dart';
import 'modules/auth/screens/onboarding_screen.dart';
import 'modules/auth/screens/login_screen.dart';
import 'modules/auth/screens/social_login_screen.dart';
import 'modules/auth/services/auth_service.dart';
import 'modules/equipment/screens/main_screen.dart';
import 'shared/utils/api_client.dart';

void main() {
  // Initialize Kakao SDK
  // Replace 'YOUR_KAKAO_APP_KEY' with actual key from Kakao Developer
  KakaoSdk.init(
    nativeAppKey: 'YOUR_KAKAO_NATIVE_APP_KEY',
    javaScriptAppKey: 'YOUR_KAKAO_JS_APP_KEY',
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // API Client
        Provider<ApiClient>(create: (_) => ApiClient()),

        // Auth Service
        ProxyProvider<ApiClient, AuthService>(
          update: (_, apiClient, previous) => AuthService(apiClient: apiClient),
        ),

        // Auth Provider
        ChangeNotifierProxyProvider<AuthService, AuthProvider>(
          create: (context) => AuthProvider(
            authService: context.read<AuthService>(),
          ),
          update: (_, authService, previous) =>
              previous ?? AuthProvider(authService: authService),
        ),
      ],
      child: MaterialApp(
        title: 'Danngam',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.light,
        home: const SplashScreen(),
        routes: {
          '/splash': (context) => const SplashScreen(),
          '/onboarding': (context) => const OnboardingScreen(),
          '/login': (context) => const SocialLoginScreen(),
          '/legacy-login': (context) => const LoginScreen(),
          '/main': (context) => const MainScreen(),
        },
        onGenerateRoute: (settings) {
          if (settings.name == '/') {
            return MaterialPageRoute(builder: (_) => const SplashScreen());
          }
          return null;
        },
      ),
    );
  }
}
