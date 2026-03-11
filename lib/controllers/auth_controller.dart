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

import '../models/user_model.dart';
import '../services/socket_service.dart';
import '../controllers/profile_controller.dart';
import '../view/barn_manager/barn_manager_application_submitted_view.dart';
import '../view/barn_manager/barn_manager_create_profile_view.dart';
import '../view/create_account_view.dart';
import '../view/trainer/trainer_complete_profile_view.dart';
import '../view/trainer/trainer_profile_setup_view.dart';

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
  final Rxn<UserModel> currentUser = Rxn<UserModel>();

  @override
  void onInit() {
    super.onInit();
    _loadUserFromStorage();
  }

  Future<void> _loadUserFromStorage() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? email = prefs.getString('userEmail');
    final String? role = prefs.getString('role');
    final String? token = prefs.getString('token');

    // Minimal user object for initial load, can be refreshed by a profile API call
    if (email != null && role != null) {
      if (token != null) _apiService.setToken(token);

      currentUser.value = UserModel(
        firstName: '',
        // We don't store first/last name in prefs currently
        lastName: '',
        email: email,
        role: role,
        id: box.read('userId'),
        isProfileCompleted: prefs.getBool('isProfileCompleted') ?? false,
        isProfileSetup: prefs.getBool('isProfileSetup') ?? false,
        isProfileApprove: prefs.getBool('isProfileApprove') ?? false,
      );

      // Auto-authenticate socket if possible
      Get.find<SocketService>().authenticate(box.read('userId') ?? '', email, role);
    }
  }

  // ─── CHECK AUTH STATUS (Splash Logic) ───────────────────────────────────────
  Future<void> checkAuthStatus() async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final String? token = prefs.getString('token');
      final String? role = prefs.getString('role');
      final bool isFirstLaunch = box.read('isFirstLaunch') ?? true;

      if (token == null || token.isEmpty) {
        // Not logged in
        if (isFirstLaunch) {
          box.write('isFirstLaunch', false);
          Get.offAll(() => const CreateAccountView());
        } else {
          Get.offAll(() => const LoginView());
        }
        return;
      }

      // 1. Initial navigation from stored values while we wait for fresh data
      _apiService.setToken(token);
      final bool storedSetup = prefs.getBool('isProfileSetup') ?? false;
      final bool storedApprove = prefs.getBool('isProfileApprove') ?? false;
      final bool storedCompleted = prefs.getBool('isProfileCompleted') ?? false;

      // 2. Refresh profile from backend to get the latest status (especially admin approval)
      final response = await _apiService.getRequest(AppUrls.profile);
      if (response.statusCode == 200) {
        final data = response.body['data'];
        final bool setup = data['isProfileSetup'] ?? false;
        final bool approve = data['isProfileApprove'] ?? false;
        final bool completed = data['isProfileCompleted'] ?? false;
        final String refreshedRole = data['role'] ?? role ?? '';

        _logger.i('Startup Refresh: role=$refreshedRole setup=$setup approve=$approve completed=$completed');

        // Update storage with fresh data
        await prefs.setBool('isProfileSetup', setup);
        await prefs.setBool('isProfileApprove', approve);
        await prefs.setBool('isProfileCompleted', completed);
        await prefs.setString('role', refreshedRole);

        currentUser.value = UserModel.fromJson(data);
        _navigateBasedOnRole(refreshedRole, completed, setup, approve);
      } else {
        // If API fails (e.g., token expired), logout the user
        if (response.statusCode == 401) {
          await logout(sessionExpired: true);
        } else {
          // Fallback to stored values if API is temporarily unavailable
          _navigateBasedOnRole(role ?? '', storedCompleted, storedSetup, storedApprove);
        }
      }
    } catch (e) {
      _logger.e('Error checking auth status: $e');
      Get.offAll(() => const LoginView());
    }
  }

  // ─── LOGIN ───────────────────────────────────────────────────────────────────
  Future<void> login() async {
    if (emailController.text.isEmpty || passwordController.text.isEmpty) {
      Get.snackbar(
        'Error',
        'Please fill in all fields',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
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
        final bool isProfileCompleted = user['isProfileCompleted'] ?? false;
        final bool isProfileSetup = user['isProfileSetup'] ?? false;
        final bool isProfileApprove = user['isProfileApprove'] ?? false;

        _logger.i('Login: role=$role completed=$isProfileCompleted setup=$isProfileSetup approve=$isProfileApprove');

        final SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', token);
        await prefs.setString('role', role);
        await prefs.setString('userEmail', user['email']);
        await prefs.setBool('isProfileCompleted', isProfileCompleted);
        await prefs.setBool('isProfileSetup', isProfileSetup);
        await prefs.setBool('isProfileApprove', isProfileApprove);
        box.write('userId', user['_id'] ?? user['id']);

        currentUser.value = UserModel.fromJson(user);

        _apiService.setToken(token);

        Get.find<SocketService>().authenticate(user['_id'] ?? user['id'], user['email'], user['role']);

        _navigateBasedOnRole(role, isProfileCompleted, isProfileSetup, isProfileApprove);
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
        Get.snackbar(
          'Login Failed',
          message,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      _logger.e('Login error: $e');
      Get.snackbar(
        'Error',
        'An unexpected error occurred',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
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
        Get.snackbar(
          'Account Exists',
          'This email is already registered. Please log in.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.orange,
          colorText: Colors.white,
          duration: const Duration(seconds: 4),
        );
      } else {
        String message = response.body?['message'] ?? 'Registration failed';
        Get.snackbar('Error', message, snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.red, colorText: Colors.white);
      }
    } catch (e) {
      _logger.e('Registration error: $e');
      Get.snackbar(
        'Error',
        'An unexpected error occurred',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // ─── VERIFY EMAIL (Step 2: confirm OTP) ──────────────────────────────────────
  Future<void> verifyEmail(String email, String otp) async {
    try {
      isLoading.value = true;

      final response = await _apiService.postRequest(AppUrls.verifyEmail, {'email': email, 'otp': otp});

      if (response.statusCode == 200) {
        final responseData = response.body['data'];
        final token = responseData['token'];
        final user = responseData['user'];
        final String role = user['role'] ?? '';
        final bool isProfileCompleted = user['isProfileCompleted'] ?? false;
        final bool isProfileSetup = user['isProfileSetup'] ?? false;
        final bool isProfileApprove = user['isProfileApprove'] ?? false;

        _logger.i('Email verified! User: ${user['email']}, Completed: $isProfileCompleted');

        Get.snackbar(
          'Success',
          'Email verified successfully. Please log in to continue.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );

        // Redirect to Login as per requirement (user must login after verification)
        Get.offAll(() => const LoginView());
      } else {
        String message = response.body?['message'] ?? 'Verification failed';
        Get.snackbar(
          'Invalid OTP',
          message,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      _logger.e('Verify email error: $e');
      Get.snackbar(
        'Error',
        'An unexpected error occurred',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
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
        Get.snackbar(
          'OTP Sent',
          'A new OTP has been sent to your email.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      } else {
        String message = response.body?['message'] ?? 'Failed to resend OTP';
        Get.snackbar('Error', message, snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.red, colorText: Colors.white);
      }
    } catch (e) {
      _logger.e('Resend OTP error: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // ─── ROLE-BASED NAVIGATION (after LOGIN) ─────────────────────────────────────
  // Priority (highest first):
  // 1. isProfileCompleted = true  → Trainer filled TrainerCompleteProfileView → Dashboard
  // 2. isProfileApprove   = true  → Admin approved → TrainerCompleteProfileView
  // 3. isProfileSetup     = true  → Trainer submitted application → ApplicationSubmittedView
  // 4. all false                  → New user → SelectRoleView
  void _navigateBasedOnRole(String role, bool isProfileCompleted, bool isProfileSetup, bool isProfileApprove) {
    if (isProfileCompleted) {
      if (role == 'trainer') {
        Get.offAll(() => const TrainerBottomNav());
      } else if (role == 'barn_manager') {
        Get.offAll(() => const BarnManagerBottomNav());
      } else if (role == 'service_provider') {
        Get.offAll(() => const TrainerBottomNav(initialIndex: 0));
      } else {
        Get.offAll(() => const SelectRoleView());
      }
      return;
    }

    if (isProfileApprove) {
      // Admin approved — ensure ProfileController is available before navigating
      if (!Get.isRegistered<ProfileController>()) {
        Get.put(ProfileController());
      }
      Get.offAll(() => const TrainerCompleteProfileView());
      return;
    }

    if (isProfileSetup) {
      // Application submitted, waiting for admin review
      if (role == 'barn_manager') {
        if (isProfileCompleted) {
          Get.offAll(() => const BarnManagerCreateProfileView());
        } else {
          Get.offAll(() => const BarnManagerBottomNav());
        }

        return;
      }
    }

    // New account — no role chosen yet
    Get.offAll(() => const SelectRoleView());
  }

  // ─── COMPLETE TRAINER PROFILE (TrainerProfileSetupView — professional application) ──────────────────────────
  Future<void> completeTrainerProfile(Map<String, dynamic> profileData) async {
    try {
      isLoading.value = true;
      final response = await _apiService.putRequest(AppUrls.completeProfile, profileData);

      if (response.statusCode == 200) {
        _logger.i('Trainer application submitted. Waiting for admin approval.');
        // NOTE: isProfileSetup is NOT set here — admin sets it upon approval.
        // Just navigate directly to the submitted screen.
        navigateAfterRoleSet();
      } else {
        String message = response.body?['message'] ?? 'Failed to submit application';
        Get.snackbar('Error', message, snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.red, colorText: Colors.white);
      }
    } catch (e) {
      _logger.e('Complete profile error: $e');
      Get.snackbar(
        'Error',
        'An unexpected error occurred',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // ─── COMPLETE BARN MANAGER PROFILE (BarnManagerCreateProfileView) ─────────────
  Future<void> completeBarnManagerProfile(Map<String, dynamic> profileData) async {
    try {
      isLoading.value = true;
      final response = await _apiService.putRequest(AppUrls.completeProfile, profileData);

      if (response.statusCode == 200) {
        _logger.i('Barn Manager application submitted.');
        Get.offAll(() => const BarnManagerApplicationSubmittedView());
      } else {
        String message = response.body?['message'] ?? 'Failed to submit application';
        Get.snackbar('Error', message, snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.red, colorText: Colors.white);
      }
    } catch (e) {
      _logger.e('Complete profile error: $e');
      Get.snackbar(
        'Error',
        'An unexpected error occurred',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // ─── NAVIGATION AFTER REGISTRATION (after role set) ──────────────────────────
  void navigateAfterRoleSet() {
    if (selectedRole.value == 'barn_manager') {
      Get.offAll(() => const BarnManagerApplicationSubmittedView());
    } else {
      Get.offAll(() => const TrainerApplicationSubmittedView());
    }
  }

  // ─── LOGOUT ──────────────────────────────────────────────────────────────────
  Future<void> logout({bool sessionExpired = false}) async {
    try {
      _logger.i('Logging out user...');

      // Notify backend if it's a manual logout
      if (!sessionExpired) {
        try {
          // Attempt but don't block by failure
          await _apiService.postRequest(AppUrls.logout, {});
        } catch (e) {
          _logger.w('Failed to notify backend of logout: $e');
        }
      }

      // Clear all SharedPreferences (token, role, email, profileStatus, etc.)
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.clear();

      // Reset API state
      _apiService.clearToken();

      // Navigate to Login and wipe route history
      Get.offAll(() => const LoginView());

      if (sessionExpired) {
        Get.snackbar(
          'Session Expired',
          'Your session has expired. Please log in again.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.orange,
          colorText: Colors.white,
          duration: const Duration(seconds: 4),
        );
      } else {
        Get.snackbar(
          'Logged Out',
          'You have been successfully logged out.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.blue,
          colorText: Colors.white,
        );
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
