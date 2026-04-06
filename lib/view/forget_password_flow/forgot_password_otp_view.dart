import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../constant/app_colors.dart';
import '../../controllers/auth_controller.dart';
import 'forgot_password_reset_view.dart';

class ForgotPasswordOTPView extends StatefulWidget {
  final String email;
  const ForgotPasswordOTPView({super.key, required this.email});

  @override
  State<ForgotPasswordOTPView> createState() => _ForgotPasswordOTPViewState();
}

class _ForgotPasswordOTPViewState extends State<ForgotPasswordOTPView> {
  final _otpController = TextEditingController();
  final AuthController _authController = Get.find<AuthController>();

  @override
  void dispose() {
    _otpController.dispose();
    super.dispose();
  }

  void _verify() async {
    if (_otpController.text.length != 6) {
      Get.snackbar('Error', 'Please enter a 6-digit code.',
          snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.red, colorText: Colors.white);
      return;
    }
    
    try {
      await _authController.verifyResetOTP(widget.email, _otpController.text.trim());
      Get.to(() => ForgotPasswordResetView(email: widget.email, otp: _otpController.text.trim()));
    } catch (e) {
      // Error handled in controller
    }
  }

  void _resendCode() async {
    try {
      await _authController.requestPasswordReset(widget.email);
    } catch (e) {
      // Error handled in controller
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Verify Code'),
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: AppColors.primary,
      ),
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Check Your Email',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 12),
              RichText(
                text: TextSpan(
                  text: 'We have sent a verification code to ',
                  style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                  children: [
                    TextSpan(
                      text: widget.email,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 48),
              TextField(
                controller: _otpController,
                keyboardType: TextInputType.number,
                maxLength: 6,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, letterSpacing: 10),
                decoration: InputDecoration(
                  hintText: '000000',
                  hintStyle: TextStyle(color: Colors.grey[300], letterSpacing: 10),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  counterText: '',
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.primary, width: 2),
                  ),
                ),
              ),
              const SizedBox(height: 32),
              Obx(() => ElevatedButton(
                onPressed: _authController.isLoading.value ? null : _verify,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _authController.isLoading.value
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Text(
                        'Verify Code',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
              )),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Didn\'t receive a code? ',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                  TextButton(
                    onPressed: _resendCode,
                    child: const Text(
                      'Resend Code',
                      style: TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
