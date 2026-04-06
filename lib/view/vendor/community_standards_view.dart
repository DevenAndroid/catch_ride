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
        centerTitle: false,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new,
            color: AppColors.textPrimary,
            size: 20,
          ),
          onPressed: () => Get.back(),
        ),
        title: const CommonText(
          'Community Standards',
          fontSize: AppTextSizes.size18,
          fontWeight: FontWeight.bold,
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
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildCenteredSection('Be Reliable', 'Show up on time, prepared, and consistent'),
                  const SizedBox(height: 32),
                  _buildCenteredSection('Be Professional', 'Clear communication, respectful, easy to work with'),
                  const SizedBox(height: 32),
                  _buildCenteredSection('Be Honest', 'Represent skills, experience, and services accurately'),
                  const SizedBox(height: 32),
                  _buildCenteredSection('Deliver Quality', 'Work should meet a professional show standard'),
                  const SizedBox(height: 32),
                  _buildCenteredSection('Communicate Clearly', 'Confirm details, pricing, and expectations upfront'),
                  const SizedBox(height: 32),
                  _buildCenteredSection('Operate with Clarity', 'Key terms, pricing, and expectations should be confirmed in writing'),
                  const SizedBox(height: 100),
                  const CommonText(
                    'This is a private network of professionals. Access is maintained by upholding these standards',
                    fontSize: 14,
                    color: AppColors.textSecondary,
                    textAlign: TextAlign.center,
                    fontStyle: FontStyle.italic,
                  ),
                ],
              ),
            ),
          ),

          // Bottom Button
          Padding(
            padding: const EdgeInsets.all(20.0),
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
