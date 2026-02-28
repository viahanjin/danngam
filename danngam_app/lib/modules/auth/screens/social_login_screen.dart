import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../models/user_model.dart';
import '../../../shared/utils/logger.dart';

/// Social Login Screen - Google, Kakao, Apple
class SocialLoginScreen extends StatefulWidget {
  const SocialLoginScreen({super.key});

  @override
  State<SocialLoginScreen> createState() => _SocialLoginScreenState();
}

class _SocialLoginScreenState extends State<SocialLoginScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Logo & Title
              Column(
                children: [
                  const SizedBox(height: 40),
                  const Text(
                    '단감',
                    style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  const Text('농기계 공유 플랫폼'),
                  const SizedBox(height: 32),
                  const Text('소셜 계정으로 로그인하세요'),
                ],
              ),

              // Buttons
              Consumer<AuthProvider>(
                builder: (context, authProvider, _) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Google
                      SizedBox(
                        height: 56,
                        child: ElevatedButton(
                          onPressed: authProvider.isLoading ? null : _signInWithGoogle,
                          child: authProvider.isLoading
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                )
                              : const Text('Google로 로그인'),
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Kakao
                      SizedBox(
                        height: 56,
                        child: ElevatedButton(
                          onPressed: authProvider.isLoading ? null : _signInWithKakao,
                          child: authProvider.isLoading
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                )
                              : const Text('Kakao로 로그인'),
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Apple
                      SizedBox(
                        height: 56,
                        child: ElevatedButton(
                          onPressed: authProvider.isLoading ? null : _signInWithApple,
                          child: authProvider.isLoading
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                )
                              : const Text('Apple로 로그인'),
                        ),
                      ),
                    ],
                  );
                },
              ),

              // Error & Demo Login
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Consumer<AuthProvider>(
                    builder: (context, authProvider, _) {
                      if (authProvider.error != null && authProvider.error!.isNotEmpty) {
                        return Container(
                          padding: const EdgeInsets.all(12),
                          color: Colors.red[100],
                          child: Text(authProvider.error ?? ''),
                        );
                      }
                      return const SizedBox.shrink();
                    },
                  ),
                  const SizedBox(height: 16),

                  // Demo Login Buttons (for testing without real API keys)
                  const Text(
                    '테스트용 데모 로그인 (앱 키 설정 전):',
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => _demoLogin('google'),
                          child: const Text('Google Demo'),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => _demoLogin('kakao'),
                          child: const Text('Kakao Demo'),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => _demoLogin('apple'),
                          child: const Text('Apple Demo'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _signInWithGoogle() async {
    try {
      final authProvider = context.read<AuthProvider>();
      final success = await authProvider.signInWithGoogle();

      if (!mounted) return;

      if (success) {
        AppLogger.info('Google Sign-In successful', tag: 'SocialLoginScreen');
        Navigator.of(context).pushReplacementNamed('/main');
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Google 로그인 실패')),
        );
      }
    } catch (e) {
      AppLogger.error('Google Sign-In error: $e', tag: 'SocialLoginScreen');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Google 로그인 실패. 앱 키 설정이 필요합니다.')),
        );
      }
    }
  }

  Future<void> _signInWithKakao() async {
    try {
      final authProvider = context.read<AuthProvider>();
      final success = await authProvider.signInWithKakao();

      if (!mounted) return;

      if (success) {
        AppLogger.info('Kakao Sign-In successful', tag: 'SocialLoginScreen');
        Navigator.of(context).pushReplacementNamed('/main');
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Kakao 로그인 실패')),
        );
      }
    } catch (e) {
      AppLogger.error('Kakao Sign-In error: $e', tag: 'SocialLoginScreen');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Kakao 로그인 실패. 앱 키 설정이 필요합니다.')),
        );
      }
    }
  }

  Future<void> _signInWithApple() async {
    try {
      final authProvider = context.read<AuthProvider>();
      final success = await authProvider.signInWithApple();

      if (!mounted) return;

      if (success) {
        AppLogger.info('Apple Sign-In successful', tag: 'SocialLoginScreen');
        Navigator.of(context).pushReplacementNamed('/main');
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Apple 로그인 실패')),
        );
      }
    } catch (e) {
      AppLogger.error('Apple Sign-In error: $e', tag: 'SocialLoginScreen');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Apple 로그인은 iOS 실기기에서만 가능합니다.')),
        );
      }
    }
  }

  /// 테스트용 Demo 로그인
  void _demoLogin(String provider) {
    final authProvider = context.read<AuthProvider>();

    // Mock user data
    final mockUser = UserModel(
      id: 'demo_user_${provider}',
      name: 'Test User ($provider)',
      email: 'test@${provider}.com',
      phone: '010-1234-5678',
      profileImageUrl: null,
      rating: 4.5,
      reviewCount: 10,
      loginProvider: provider,
      accessToken: 'mock_token_${DateTime.now().millisecondsSinceEpoch}',
    );

    authProvider.setUser(mockUser);
    Navigator.of(context).pushReplacementNamed('/main');
  }
}
