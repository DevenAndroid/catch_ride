import 'dart:async';
import 'package:catch_ride/constant/app_colors.dart';
import 'package:catch_ride/constant/app_text_sizes.dart';
import 'package:catch_ride/controllers/auth_controller.dart';
import 'package:catch_ride/widgets/common_button.dart';
import 'package:catch_ride/widgets/common_text.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class OtpVerificationView extends StatefulWidget {
  final String email;
  const OtpVerificationView({super.key, required this.email});

  @override
  State<OtpVerificationView> createState() => _OtpVerificationViewState();
}

class _OtpVerificationViewState extends State<OtpVerificationView> {
  final AuthController _authController = Get.find<AuthController>();
  final List<TextEditingController> _controllers = List.generate(
    6,
    (_) => TextEditingController(),
  );
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());

  int _secondsRemaining = 60;
  Timer? _timer;
  bool _canResend = false;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    setState(() {
      _secondsRemaining = 60;
      _canResend = false;
    });
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsRemaining <= 1) {
        timer.cancel();
        setState(() => _canResend = true);
      } else {
        setState(() => _secondsRemaining--);
      }
    });
  }

  String get _otp => _controllers.map((c) => c.text).join();

  void _onOtpChanged(String value, int index) {
    if (value.length == 1 && index < 5) {
      _focusNodes[index + 1].requestFocus();
    } else if (value.isEmpty && index > 0) {
      _focusNodes[index - 1].requestFocus();
    }
    // Auto-submit when all 6 digits are filled
    if (_otp.length == 6) {
      _authController.verifyEmail(widget.email, _otp);
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    for (var c in _controllers) {
      c.dispose();
    }
    for (var f in _focusNodes) {
      f.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new,
            color: AppColors.textPrimary,
            size: 20,
          ),
          onPressed: () => Get.back(),
        ),
        title: const CommonText(
          'Verify Email',
          fontSize: AppTextSizes.size18,
          fontWeight: FontWeight.bold,
          color: AppColors.textPrimary,
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(color: AppColors.border, height: 1.0),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 32),

              // Icon
              Container(
                height: 80,
                width: 80,
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.mark_email_unread_outlined,
                  size: 40,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 24),

              const CommonText(
                'Check your email',
                fontSize: AppTextSizes.size22,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
              const SizedBox(height: 8),
              CommonText(
                'We\'ve sent a 6-digit code to\n${widget.email}',
                fontSize: AppTextSizes.size14,
                color: AppColors.textSecondary,
                textAlign: TextAlign.center,
                height: 1.5,
              ),
              const SizedBox(height: 40),

              // OTP boxes
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(6, (index) {
                  return Container(
                    margin: const EdgeInsets.symmetric(horizontal: 6),
                    width: 48,
                    height: 56,
                    clipBehavior: Clip.antiAlias,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: _focusNodes[index].hasFocus
                            ? AppColors.primary
                            : AppColors.border,
                        width: 1.5,
                      ),
                    ),
                    alignment: Alignment.center,
                    child: TextField(
                      controller: _controllers[index],
                      focusNode: _focusNodes[index],
                      textAlign: TextAlign.center,
                      keyboardType: TextInputType.number,
                      showCursor: false, // Keeps UI cleaner
                      maxLength: 1,
                      onTap: () {
                        setState(() {});
                      },
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                        height: 1.0, // Force centered text
                      ),
                      decoration: const InputDecoration(
                        counterText: '',
                        border: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        errorBorder: InputBorder.none,
                        disabledBorder: InputBorder.none,
                        isCollapsed:
                            true, // Crucial for removing internal padding
                        filled: false,
                        contentPadding: EdgeInsets.zero,
                      ),
                      onChanged: (val) {
                        _onOtpChanged(val, index);
                        setState(() {});
                      },
                    ),
                  );
                }),
              ),
              const SizedBox(height: 32),

              // Resend timer
              _canResend
                  ? GestureDetector(
                      onTap: () {
                        _authController.resendOtp(widget.email);
                        _startTimer();
                      },
                      child: const CommonText(
                        'Resend Code',
                        fontSize: AppTextSizes.size14,
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    )
                  : CommonText(
                      'Resend code in ${_secondsRemaining}s',
                      fontSize: AppTextSizes.size14,
                      color: AppColors.textSecondary,
                    ),
              const SizedBox(height: 40),

              // Verify button
              Obx(
                () => CommonButton(
                  text: 'Verify',
                  isLoading: _authController.isLoading.value,
                  onPressed: () {
                    if (_otp.length < 6) {
                      Get.snackbar(
                        'Error',
                        'Please enter the full 6-digit code',
                        snackPosition: SnackPosition.BOTTOM,
                        backgroundColor: Colors.red,
                        colorText: Colors.white,
                      );
                      return;
                    }
                    _authController.verifyEmail(widget.email, _otp);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
