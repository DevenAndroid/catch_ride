import 'dart:convert';
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
      Get.find<SocketService>().authenticate(
        box.read('userId') ?? '',
        email,
        role,
      );
    }
  }

  // ─── CHECK AUTH STATUS (Splash Logic) ───────────────────────────────────────
  Future<void> checkAuthStatus() async {
    final DateTime startTime = DateTime.now();

    // Helper to ensure minimum splash time
    Future<void> ensureMinTime() async {
      final elapsed = DateTime.now().difference(startTime);
      if (elapsed < const Duration(seconds: 3)) {
        await Future.delayed(const Duration(seconds: 3) - elapsed);
      }
    }

    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final String? token = prefs.getString('token');
      final bool isFirstLaunch = box.read('isFirstLaunch') ?? true;

      if (token == null || token.isEmpty) {
        await ensureMinTime();
        if (isFirstLaunch) {
          box.write('isFirstLaunch', false);
          Get.offAll(() => const CreateAccountView());
        } else {
          Get.offAll(() => const LoginView());
        }
        return;
      }

      // 1. Authenticate API Service
      _apiService.setToken(token);

      // 2. Fetch FRESH profile data directly from API
      debugPrint('Fetching fresh profile data for redirection...');
      final response = await _apiService.getRequest(AppUrls.profile);

      // 3. Ensure we've shown the splash for at least 3 seconds
      await ensureMinTime();

      if (response.statusCode == 200) {
        final data = response.body['data'];
        final String refreshedRole = data['role'] ?? '';
        final bool setup = data['isProfileSetup'] ?? false;
        final bool approve = data['isProfileApprove'] ?? false;
        final bool completed = data['isProfileCompleted'] ?? false;

        debugPrint(
          'API Success: role=$refreshedRole setup=$setup approve=$approve completed=$completed',
        );

        // Sync fresh data to local model
        currentUser.value = UserModel.fromJson(data);

        // Update storage only for session persistence, not for flow logic
        await prefs.setString('role', refreshedRole);
        await prefs.setBool('isProfileSetup', setup);
        await prefs.setBool('isProfileApprove', approve);
        await prefs.setBool('isProfileCompleted', completed);
        await prefs.setString('status', data['status'] ?? 'active');

        // ALWAYS Navigate based on the FRESH API response
        _navigateBasedOnRole(
          refreshedRole,
          completed,
          setup,
          approve,
          data['status'] ?? 'active',
        );
      } else {
        // If API fails (e.g., token expired/invalid), force logout
        debugPrint('Profile API failed with status: ${response.statusCode}');
        await logout(sessionExpired: true);
      }
    } catch (e) {
      debugPrint('Error during auth check: $e');
      await ensureMinTime();
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

        debugPrint(
          'Login: role=$role completed=$isProfileCompleted setup=$isProfileSetup approve=$isProfileApprove',
        );

        final SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', token);
        await prefs.setString('role', role);
        await prefs.setString('userEmail', user['email']);
        await prefs.setBool('isProfileCompleted', isProfileCompleted);
        await prefs.setBool('isProfileSetup', isProfileSetup);
        await prefs.setBool('isProfileApprove', isProfileApprove);
        await prefs.setString('status', user['status'] ?? 'active');
        box.write('userId', user['_id'] ?? user['id']);

        currentUser.value = UserModel.fromJson(user);

        _apiService.setToken(token);

        Get.find<SocketService>().authenticate(
          user['_id'] ?? user['id'],
          user['email'],
          user['role'],
        );

        _navigateBasedOnRole(
          role,
          isProfileCompleted,
          isProfileSetup,
          isProfileApprove,
          user['status'] ?? 'active',
        );
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
        String message = 'Login failed';
        if (response.body != null) {
          if (response.body is Map) {
            message = response.body['message'] ?? 'Login failed';
          } else if (response.body is String) {
            try {
              final decoded = jsonDecode(response.body);
              message = decoded['message'] ?? response.body;
            } catch (_) {
              message = response.body;
            }
          }
        } else if (response.statusText != null &&
            response.statusText!.isNotEmpty) {
          message = response.statusText!;
        }

        Get.snackbar(
          'Login Failed',
          message,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      debugPrint('Login error: $e');
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

      if (!userData.containsKey('email'))
        userData['email'] = emailController.text.trim();
      if (!userData.containsKey('password'))
        userData['password'] = passwordController.text;
      if (!userData.containsKey('role')) userData['role'] = 'user';

      final response = await _apiService.postRequest(
        AppUrls.register,
        userData,
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        debugPrint('OTP sent. Navigating to OTP screen.');
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
        Get.snackbar(
          'Error',
          message,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      debugPrint('Registration error: $e');
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

      final response = await _apiService.postRequest(AppUrls.verifyEmail, {
        'email': email,
        'otp': otp,
      });

      if (response.statusCode == 200) {
        final responseData = response.body['data'];
        final token = responseData['token'];
        final user = responseData['user'];
        final String role = user['role'] ?? '';
        final bool isProfileCompleted = user['isProfileCompleted'] ?? false;
        final bool isProfileSetup = user['isProfileSetup'] ?? false;
        final bool isProfileApprove = user['isProfileApprove'] ?? false;

        debugPrint(
          'Email verified! User: ${user['email']}, Completed: $isProfileCompleted',
        );

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
      debugPrint('Verify email error: $e');
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
      final response = await _apiService.postRequest(AppUrls.resendOtp, {
        'email': email,
      });

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
        Get.snackbar(
          'Error',
          message,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      debugPrint('Resend OTP error: $e');
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
  void _navigateBasedOnRole(
    String role,
    bool isProfileCompleted,
    bool isProfileSetup,
    bool isProfileApprove,
    String status,
  ) {
    debugPrint(
      'Navigating: role=$role, completed=$isProfileCompleted, setup=$isProfileSetup, approve=$isProfileApprove, status=$status',
    );

    if (role == 'trainer' ||
        role == 'barn_manager' ||
        role == 'service_provider') {
      // Check if active and approved for dashboard access
      if (isProfileCompleted) {
        if (status.toLowerCase() == 'active' && isProfileApprove) {
          if (role == 'trainer') {
            Get.offAll(() => const TrainerBottomNav());
          } else if (role == 'barn_manager') {
            Get.offAll(() => const BarnManagerBottomNav());
          } else {
            Get.offAll(() => const TrainerBottomNav(initialIndex: 0));
          }
        } else {
          // Profile exists but not active/approved
          logout(sessionExpired: false);
          Get.snackbar(
            'Access Denied',
            'Your account is ${status.toLowerCase()} or awaiting secondary approval. Please contact support.',
            snackPosition: SnackPosition.TOP,
            backgroundColor: Colors.orange,
            colorText: Colors.white,
            duration: const Duration(seconds: 5),
          );
        }
        return;
      }

      // If not completed, handle application flow
      if (role == 'trainer') {
        if (isProfileApprove) {
          if (!Get.isRegistered<ProfileController>())
            Get.put(ProfileController());
          Get.offAll(() => const TrainerCompleteProfileView());
        } else if (isProfileSetup) {
          Get.offAll(() => const TrainerApplicationSubmittedView());
        } else {
          Get.offAll(() => const SelectRoleView());
        }
      } else if (role == 'barn_manager') {
        if (isProfileApprove) {
          Get.offAll(() => const BarnManagerBottomNav());
        } else if (isProfileSetup) {
          Get.offAll(() => const BarnManagerApplicationSubmittedView());
        } else {
          Get.offAll(() => const BarnManagerCreateProfileView());
        }
      } else {
        Get.offAll(() => const SelectRoleView());
      }
    } else {
      // No valid role or super_admin
      Get.offAll(() => const SelectRoleView());
    }
  }

  // ─── COMPLETE TRAINER PROFILE (TrainerProfileSetupView — professional application) ──────────────────────────
  Future<void> completeTrainerProfile(Map<String, dynamic> profileData) async {
    try {
      isLoading.value = true;
      final response = await _apiService.putRequest(
        AppUrls.completeProfile,
        profileData,
      );

      if (response.statusCode == 200) {
        debugPrint(
          'Trainer application submitted. Waiting for admin approval.',
        );
        // NOTE: isProfileSetup is NOT set here — admin sets it upon approval.
        // Just navigate directly to the submitted screen.
        navigateAfterRoleSet();
      } else {
        String message =
            response.body?['message'] ?? 'Failed to submit application';
        Get.snackbar(
          'Error',
          message,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      debugPrint('Complete profile error: $e');
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
  Future<void> completeBarnManagerProfile(
    Map<String, dynamic> profileData,
  ) async {
    try {
      isLoading.value = true;
      final response = await _apiService.putRequest(
        AppUrls.completeProfile,
        profileData,
      );

      if (response.statusCode == 200) {
        debugPrint('Barn Manager application submitted.');
        Get.offAll(() => const BarnManagerApplicationSubmittedView());
      } else {
        String message =
            response.body?['message'] ?? 'Failed to submit application';
        Get.snackbar(
          'Error',
          message,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      debugPrint('Complete profile error: $e');
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
      debugPrint('Logging out user...');

      // Notify backend if it's a manual logout
      if (!sessionExpired) {
        try {
          // Attempt but don't block by failure
          await _apiService.postRequest(AppUrls.logout, {});
        } catch (e) {
          debugPrint('Failed to notify backend of logout: $e');
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
      debugPrint('Error during logout: $e');
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
