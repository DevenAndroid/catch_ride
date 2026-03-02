import 'package:catch_ride/constant/app_urls.dart';
import 'package:catch_ride/services/api_service.dart';
import 'package:catch_ride/view/login_view.dart';
import 'package:catch_ride/view/otp_verification_view.dart';
import 'package:catch_ride/view/select_role_view.dart';
import 'package:catch_ride/view/trainer/trainer_application_submitted_view.dart';
import 'package:catch_ride/view/trainer/trainer_bottom_nav.dart';
import 'package:catch_ride/view/barn_manager/barn_manager_bottom_nav.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:logger/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthController extends GetxController {
  final ApiService _apiService = Get.find<ApiService>();
  final Logger _logger = Logger();
  final box = GetStorage();

  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  // Registration State
  final RxString selectedRole = 'trainer'.obs;
  final RxString registrationEmail = ''.obs;
  final RxString registrationPassword = ''.obs;

  final RxBool isLoading = false.obs;

  // ─── LOGIN ───────────────────────────────────────────────────────────────────
  Future<void> login() async {
    if (emailController.text.isEmpty || passwordController.text.isEmpty) {
      Get.snackbar('Error', 'Please fill in all fields',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white);
      return;
    }

    try {
      isLoading.value = true;

      final response = await _apiService.postRequest(AppUrls.login, {
        'email': emailController.text.trim(),
        'password': passwordController.text,
      });

      if (response.statusCode == 200) {
        final responseData = response.body['data'];
        final token = responseData['token'];
        final user = responseData['user'];
        final String role = user['role'] ?? '';

        _logger.i('Login success! User: ${user['email']}, Role: $role');

        final SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', token);
        await prefs.setString('role', role);
        await prefs.setString('userEmail', user['email']);

        _apiService.setToken(token);
        _navigateBasedOnRole(role);
      } else if (response.statusCode == 403) {
        // Email not verified — send them to OTP screen
        final email = emailController.text.trim();
        registrationEmail.value = email;
        Get.snackbar(
          'Verification Required',
          'A new OTP has been sent to your email.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.orange,
          colorText: Colors.white,
        );
        Get.to(() => OtpVerificationView(email: email));
      } else {
        String message = response.body?['message'] ?? 'Login failed';
        Get.snackbar('Login Failed', message,
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.red,
            colorText: Colors.white);
      }
    } catch (e) {
      _logger.e('Login error: $e');
      Get.snackbar('Error', 'An unexpected error occurred',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white);
    } finally {
      isLoading.value = false;
    }
  }

  // ─── REGISTER (Step 1: send OTP) ─────────────────────────────────────────────
  Future<void> register(Map<String, dynamic> userData) async {
    try {
      isLoading.value = true;

      if (!userData.containsKey('email')) userData['email'] = registrationEmail.value;
      if (!userData.containsKey('password')) userData['password'] = registrationPassword.value;
      if (!userData.containsKey('role')) userData['role'] = 'user';

      final response = await _apiService.postRequest(AppUrls.register, userData);

      if (response.statusCode == 201 || response.statusCode == 200) {
        _logger.i('OTP sent. Navigating to OTP screen.');
        final email = userData['email'];
        Get.to(() => OtpVerificationView(email: email));
      } else if (response.statusCode == 409) {
        // Email already verified — tell user to log in
        Get.snackbar('Account Exists', 'This email is already registered. Please log in.',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.orange,
            colorText: Colors.white,
            duration: const Duration(seconds: 4));
      } else {
        String message = response.body?['message'] ?? 'Registration failed';
        Get.snackbar('Error', message,
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.red,
            colorText: Colors.white);
      }
    } catch (e) {
      _logger.e('Registration error: $e');
      Get.snackbar('Error', 'An unexpected error occurred',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white);
    } finally {
      isLoading.value = false;
    }
  }

  // ─── VERIFY EMAIL (Step 2: confirm OTP) ──────────────────────────────────────
  Future<void> verifyEmail(String email, String otp) async {
    try {
      isLoading.value = true;

      final response = await _apiService.postRequest(AppUrls.verifyEmail, {
        'email': email,
        'otp': otp,
      });

      if (response.statusCode == 200) {
        final responseData = response.body['data'];
        final token = responseData['token'];
        final user = responseData['user'];
        final String role = user['role'] ?? '';

        _logger.i('Email verified! User: ${user['email']}');

        final SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', token);
        await prefs.setString('role', role);
        await prefs.setString('userEmail', user['email']);

        _apiService.setToken(token);

        Get.snackbar('Success', 'Email verified! Please select your role.',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.green,
            colorText: Colors.white);

        // After verification → role selection
        Get.offAll(() => const SelectRoleView());
      } else {
        String message = response.body?['message'] ?? 'Verification failed';
        Get.snackbar('Invalid OTP', message,
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.red,
            colorText: Colors.white);
      }
    } catch (e) {
      _logger.e('Verify email error: $e');
      Get.snackbar('Error', 'An unexpected error occurred',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white);
    } finally {
      isLoading.value = false;
    }
  }

  // ─── RESEND OTP ───────────────────────────────────────────────────────────────
  Future<void> resendOtp(String email) async {
    try {
      isLoading.value = true;
      final response = await _apiService.postRequest(AppUrls.resendOtp, {'email': email});

      if (response.statusCode == 200) {
        Get.snackbar('OTP Sent', 'A new OTP has been sent to your email.',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.green,
            colorText: Colors.white);
      } else {
        String message = response.body?['message'] ?? 'Failed to resend OTP';
        Get.snackbar('Error', message,
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.red,
            colorText: Colors.white);
      }
    } catch (e) {
      _logger.e('Resend OTP error: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // ─── ROLE-BASED NAVIGATION (after LOGIN) ─────────────────────────────────────
  void _navigateBasedOnRole(String role) {
    if (role == 'trainer') {
      Get.offAll(() => const TrainerBottomNav());
    } else if (role == 'barn_manager') {
      Get.offAll(() => const BarnManagerBottomNav());
    } else if (role == 'service_provider') {
      Get.offAll(() => const TrainerBottomNav(initialIndex: 0));
    } else {
      // New account — hasn't picked a role yet
      Get.offAll(() => const SelectRoleView());
    }
  }

  // ─── NAVIGATION AFTER REGISTRATION (after role set) ──────────────────────────
  void navigateAfterRoleSet() {
    Get.offAll(() => const TrainerApplicationSubmittedView());
  }

  // ─── LOGOUT ──────────────────────────────────────────────────────────────────
  Future<void> logout({bool sessionExpired = false}) async {
    try {
      _logger.i('Logging out user...');
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.remove('token');
      await prefs.remove('role');
      await prefs.remove('userEmail');
      _apiService.clearToken();
      Get.offAll(() => const LoginView());

      if (sessionExpired) {
        Get.snackbar('Session Expired', 'Your session has expired. Please log in again.',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.orange,
            colorText: Colors.white,
            duration: const Duration(seconds: 4));
      } else {
        Get.snackbar('Logged Out', 'You have been successfully logged out.',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.blue,
            colorText: Colors.white);
      }
    } catch (e) {
      _logger.e('Error during logout: $e');
      Get.offAll(() => const LoginView());
    }
  }

  @override
  void onClose() {
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.onClose();
  }
}


