import 'package:catch_ride/constant/app_colors.dart';
import 'package:catch_ride/constant/app_text_sizes.dart';
import 'package:catch_ride/controllers/auth_controller.dart';
import 'package:catch_ride/view/vendor/complete_profile_view.dart';
import 'package:catch_ride/widgets/common_button.dart';
import 'package:catch_ride/widgets/common_text.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CommunityStandardsView extends StatelessWidget {
  const CommunityStandardsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        automaticallyImplyLeading: false,
        title: const CommonText(
          'Community Standards',
          fontSize: AppTextSizes.size20,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(color: AppColors.border, height: 1.0),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 40.0, vertical: 40.0),
              child: Column(
                children: [
                  _buildCenteredSection('Show Up Reliably', 'Be on time, prepared, and consistent'),
                  const SizedBox(height: 32),
                  _buildCenteredSection('Communicate Professionally', 'Clear, respectful, and easy to work with'),
                  const SizedBox(height: 32),
                  _buildCenteredSection('Represent Your Work Honestly', 'Skills, experience, and services should be accurate and current'),
                  const SizedBox(height: 32),
                  _buildCenteredSection('Deliver Professional-Level Quality', 'Work should meet the standard expected at rated shows'),
                  const SizedBox(height: 32),
                  _buildCenteredSection('Confirm Details Upfront', 'Pricing, scope, and expectations should be agreed upon in advance'),


                ],
              ),
            ),
          ),
          const SizedBox(height: 60),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6.0),
            child: CommonText(
              'This is a private network of professionals. Access is maintained by upholding these standards',
              fontSize: 14,
              color: AppColors.textSecondary,
              textAlign: TextAlign.center,
              fontStyle: FontStyle.italic,
            ),
          ),
          const SizedBox(height: 60),
          // Bottom Button
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 30),
            child: CommonButton(
              text: 'Agree & Continue',
              backgroundColor: AppColors.primary,
              onPressed: () {
                Get.offAll(() => const CompleteProfileView());
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCenteredSection(String title, String content) {
    return Column(
      children: [
        CommonText(
          title,
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: AppColors.textPrimary,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        CommonText(
          content,
          fontSize: 14,
          color: AppColors.textSecondary,
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
