import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';

import '../../constant/app_colors.dart';
import '../../constant/app_strings.dart';
import '../../constant/app_text_sizes.dart';
import '../../controllers/auth_controller.dart';
import 'community_standards_view.dart';
import '../../widgets/common_button.dart';
import '../../widgets/common_text.dart';

class VendorApplicationSubmitView extends StatelessWidget {
  const VendorApplicationSubmitView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        children: [
                          const SizedBox(height: 40),
                          const SizedBox(height: 40),
                          Center(child: SvgPicture.asset('assets/images/new_logo.svg', height: 80, color: AppColors.primary)),
                          const SizedBox(height: 60),

                          // Success Icon
                          Container(
                            height: 110,
                            width: 110,
                            decoration: BoxDecoration(shape: BoxShape.circle, color: AppColors.secondary.withOpacity(0.3)),
                            child: Center(
                              child: Container(
                                height: 82,
                                width: 82,
                                decoration: const BoxDecoration(shape: BoxShape.circle, color: AppColors.secondary),
                                child: const Icon(Icons.check, size: 44, color: Colors.white),
                              ),
                            ),
                          ),
                          const SizedBox(height: 32),

                          // Title
                          const CommonText(
                            'Application Submitted',
                            fontSize: AppTextSizes.size24,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 12),

                          // Subtitle
                          const CommonText(
                            'Your application is under review',
                            fontSize: AppTextSizes.size18,
                            color: AppColors.textSecondary,
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 24),

                          // Info Box
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                            decoration: BoxDecoration(
                              color: AppColors.infoBoxBg,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: AppColors.secondary.withOpacity(0.3), width: 1),
                            ),
                            child: const CommonText(
                              'You\'ll receive access details once your account has been approved.',
                              fontSize: AppTextSizes.size14,
                              color: AppColors.textSecondary,
                              height: 1.4,
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ],
                      ),

                      Column(
                        children: [
                          const SizedBox(height: 32),
                          const CommonText(
                            'Typical review time is 24-48 hours',
                            fontSize: AppTextSizes.size14,
                            color: AppColors.textSecondary,
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 20),

                          CommonButton(
                            text: 'Back to login',
                            backgroundColor: AppColors.primary,
                            onPressed: (){
                              final AuthController _authController = Get.put(AuthController());

                              _authController.logout();
                            },
                          ),
                          const SizedBox(height: 10),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
