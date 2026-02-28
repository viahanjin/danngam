import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../config/app_colors.dart';
import '../../../shared/constants/app_dimensions.dart';
import '../../../shared/constants/app_strings.dart';
import '../../../shared/extensions/build_context_ext.dart';
import '../../../shared/utils/validators.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/app_text_field.dart';
import '../providers/auth_provider.dart';

/// Login Screen - Phone number and OTP verification
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  late TextEditingController _phoneController;
  late TextEditingController _otpController;

  bool _otpSent = false;
  bool _isLoading = false;
  String? _phoneError;
  String? _otpError;

  @override
  void initState() {
    super.initState();
    _phoneController = TextEditingController();
    _otpController = TextEditingController();
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _otpController.dispose();
    super.dispose();
  }

  void _validatePhoneNumber() {
    setState(() {
      _phoneError = Validators.validatePhoneNumber(_phoneController.text);
    });
  }

  void _validateOtp() {
    setState(() {
      _otpError = Validators.validateOtp(_otpController.text);
    });
  }

  Future<void> _sendOtp() async {
    _validatePhoneNumber();
    if (_phoneError != null) return;

    setState(() => _isLoading = true);

    try {
      final authProvider = context.read<AuthProvider>();
      final success = await authProvider.sendOtp(_phoneController.text);

      if (mounted) {
        setState(() => _isLoading = false);
        if (success) {
          setState(() => _otpSent = true);
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('OTP 발송되었습니다. 테스트 코드: 123456')),
            );
          }
        } else {
          final authProvider = context.read<AuthProvider>();
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(authProvider.error ?? 'OTP 발송 실패')),
            );
          }
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('오류: $e')),
        );
      }
    }
  }

  Future<void> _login() async {
    _validatePhoneNumber();
    _validateOtp();

    if (_phoneError != null || _otpError != null) return;

    setState(() => _isLoading = true);

    try {
      final authProvider = context.read<AuthProvider>();
      final success = await authProvider.verifyOtp(
        _phoneController.text,
        _otpController.text,
      );

      if (!mounted) return;
      setState(() => _isLoading = false);

      if (success) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('로그인 성공!')),
          );
          // 딜레이를 약간 두고 네비게이션
          await Future.delayed(const Duration(milliseconds: 500));
          if (mounted) {
            Navigator.of(context).pushReplacementNamed('/main');
          }
        }
      } else {
        final authProvider = context.read<AuthProvider>();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(authProvider.error ?? '인증 실패')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('오류: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('로그인'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '단감에 로그인',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text('농기계 공유 플랫폼에 로그인하세요'),
              const SizedBox(height: 32),

              // Phone Number Field
              TextField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(
                  labelText: '전화번호',
                  hintText: '01012345678',
                  errorText: _phoneError,
                  border: const OutlineInputBorder(),
                ),
                onChanged: (_) {
                  if (_phoneError != null) _validatePhoneNumber();
                },
              ),
              const SizedBox(height: 16),

              // Send OTP Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading || _phoneController.text.isEmpty
                      ? null
                      : _sendOtp,
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('OTP 전송'),
                ),
              ),

              // OTP Section
              if (_otpSent) ...[
                const SizedBox(height: 32),
                const Text(
                  'OTP 인증',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  '${_phoneController.text}로 인증번호를 보냈습니다.',
                  style: const TextStyle(color: Colors.grey),
                ),
                const SizedBox(height: 16),

                // OTP Field
                TextField(
                  controller: _otpController,
                  keyboardType: TextInputType.number,
                  maxLength: 6,
                  decoration: InputDecoration(
                    labelText: 'OTP (테스트: 123456)',
                    hintText: '000000',
                    errorText: _otpError,
                    border: const OutlineInputBorder(),
                    counterText: '',
                  ),
                  onChanged: (_) {
                    if (_otpError != null) _validateOtp();
                  },
                ),
                const SizedBox(height: 16),

                // Login Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed:
                        _isLoading || _otpController.text.isEmpty ? null : _login,
                    child: _isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('인증 완료'),
                  ),
                ),
                const SizedBox(height: 16),

                // Resend OTP Button
                Center(
                  child: TextButton(
                    onPressed: _isLoading ? null : _sendOtp,
                    child: const Text('OTP 재전송'),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
