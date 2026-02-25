import 'package:catch_ride/constant/app_strings.dart';
import 'package:catch_ride/widgets/common_text.dart';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:catch_ride/constant/app_colors.dart';
import 'package:catch_ride/view/create_account_view.dart';

import '../../constant/app_text_sizes.dart';
import 'package:get/get.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Timer(const Duration(seconds: 3), () {
      Get.off(() => const CreateAccountView(),
      );
    });
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
