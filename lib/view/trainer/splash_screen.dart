import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:catch_ride/constant/app_colors.dart';
import 'package:catch_ride/view/login_view.dart';
import 'package:catch_ride/view/create_account_view.dart';
import 'package:catch_ride/view/trainer/trainer_bottom_nav.dart';
import 'package:catch_ride/view/barn_manager/barn_manager_bottom_nav.dart';
import 'package:catch_ride/view/select_role_view.dart';
import 'package:catch_ride/view/trainer/trainer_profile_setup_view.dart';
import 'package:logger/logger.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../controllers/auth_controller.dart';
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
    _handleNavigation();
  }

  Future<void> _handleNavigation() async {
    // Let AuthController handle the logic of checking token and profile status
    // It will fetch the latest profile and redirect to the correct screen
    await Get.find<AuthController>().checkAuthStatus();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      body: Center(child: SvgPicture.asset('assets/images/new_logo.svg')),
    );
  }
}
