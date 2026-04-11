import 'package:catch_ride/constant/app_colors.dart';
import 'package:catch_ride/constant/app_text_sizes.dart';
import 'package:catch_ride/controllers/auth_controller.dart';
import 'package:catch_ride/view/vendor/complete_profile_view.dart';
import 'package:catch_ride/widgets/common_button.dart';
import 'package:catch_ride/widgets/common_text.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'trainer_complete_profile_view.dart';

class TrainerCommunityStandardsView extends StatelessWidget {
  const TrainerCommunityStandardsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        // leading: IconButton(
        //   icon: const Icon(
        //     Icons.arrow_back_ios_new,
        //     color: AppColors.textPrimary,
        //     size: 20,
        //   ),
        //   onPressed: () {
        //     Get.back();
        //   },
        // ),
        title: const CommonText(
          'Community Standards',
          fontSize: AppTextSizes.size18,
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
              padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 40.0),
              child: Column(
                children: [
                  _buildCenteredSection('Communicate Professionally', 'Clear, respectful, business-first communication\nat all times'),
                  const SizedBox(height: 32),
                  _buildCenteredSection('Accurately Represent Horses & Availability', 'All listings and program details should reflect\ncurrent, honest information'),
                  const SizedBox(height: 32),
                  _buildCenteredSection('Prioritize Horse Welfare', 'Decisions should reflect responsible, welfare-first\nhorsemanship'),
                  const SizedBox(height: 32),
                  _buildCenteredSection('Honor Commitments', 'Respect agreed terms, communicate changes,\nand follow through reliably'),
                  const SizedBox(height: 32),
                  _buildCenteredSection('Operate with Clarity', 'Key details—including pricing and expectations—\nshould be confirmed in writing'),
                ],
              ),
            ),
          ),
          
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40.0),
            child: const CommonText(
              'This is a private network of professionals, built on trust,\nconsistency, and high standards.',
              fontSize: 12,
              color: AppColors.textSecondary,
              textAlign: TextAlign.center,
              fontStyle: FontStyle.italic,
            ),
          ),
          const SizedBox(height: 24),
          // Bottom Button
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 30),
            child: CommonButton(
              text: 'Agree & Continue',
              backgroundColor: AppColors.primary,
              onPressed: () {
                Get.offAll(() => const TrainerCompleteProfileView());
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
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: AppColors.textPrimary,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 6),
        CommonText(
          content,
          fontSize: 14,
          color: AppColors.textSecondary,
          textAlign: TextAlign.center,
          height: 1.4,
        ),
      ],
    );
  }
}
