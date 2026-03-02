import 'package:catch_ride/constant/app_strings.dart';
import 'package:catch_ride/widgets/common_text.dart';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:catch_ride/constant/app_colors.dart';
import 'package:catch_ride/view/login_view.dart';
import 'package:catch_ride/view/create_account_view.dart';
import 'package:catch_ride/view/trainer/trainer_bottom_nav.dart';
import 'package:catch_ride/view/barn_manager/barn_manager_bottom_nav.dart';
import 'package:catch_ride/view/select_role_view.dart';
import 'package:logger/logger.dart';
import '../../constant/app_text_sizes.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../services/api_service.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final box = GetStorage();
  final Logger _logger = Logger();

  @override
  void initState() {
    super.initState();
    Timer(const Duration(seconds: 3), () {
      _handleNavigation();
    });
  }

  Future<void> _handleNavigation() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString('token');
    final String? role = prefs.getString('role');
    final bool isFirstLaunch = box.read('isFirstLaunch') ?? true;

    if (token != null && token.isNotEmpty) {
      // User is logged in, redirect based on role
      _logger.i('Auto-logging in user with role: $role');
      
      // SET TOKEN IN API SERVICE
      Get.find<ApiService>().setToken(token);
      
      if (role == 'trainer') {
        Get.offAll(() => const TrainerBottomNav());
      } else if (role == 'barn_manager') {
        Get.offAll(() => const BarnManagerBottomNav());
      } else {
        Get.offAll(() => const SelectRoleView());
      }
    } else {
      // Not logged in
      if (isFirstLaunch) {
        box.write('isFirstLaunch', false);
        Get.offAll(() => const CreateAccountView());
      } else {
        Get.offAll(() => const LoginView());
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SvgPicture.asset('assets/images/logo_white.svg', width: 120),
            const SizedBox(height: 16),
            const CommonText(
              AppStrings.catchRide1,
              fontSize: AppTextSizes.size26,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              letterSpacing: 2.0,
            ),
          ],
        ),
      ),
    );
  }
}
