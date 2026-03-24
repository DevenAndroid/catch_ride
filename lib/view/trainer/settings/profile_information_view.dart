import 'package:catch_ride/constant/app_colors.dart';
import 'package:catch_ride/widgets/common_text.dart';
import 'package:catch_ride/controllers/profile_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ProfileInformationView extends StatelessWidget {
  const ProfileInformationView({super.key});

  @override
  Widget build(BuildContext context) {
    final ProfileController profileController = Get.find<ProfileController>();

    return Scaffold(
      backgroundColor: AppColors.background,
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
          'Personal Information',
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: AppColors.textPrimary,
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.border.withValues(alpha: 0.3)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Obx(() {
            // Format joined date
            String joinedDate = profileController.joinedDate;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CommonText(
                  'Joined in $joinedDate',
                  fontSize: 14,
                  color: AppColors.textSecondary,
                ),
                const SizedBox(height: 6),
                CommonText(
                  profileController.fullName.isNotEmpty
                      ? profileController.fullName
                      : 'User Name',
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
                const SizedBox(height: 24),

                const CommonText(
                  'Email Address',
                  fontSize: 14,
                  color: AppColors.textSecondary,
                ),
                const SizedBox(height: 6),
                CommonText(
                  profileController.email.isNotEmpty
                      ? profileController.email
                      : 'lisa@example.com',
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
                const SizedBox(height: 24),

                const CommonText(
                  'Phone Number',
                  fontSize: 14,
                  color: AppColors.textSecondary,
                ),
                const SizedBox(height: 6),
                CommonText(
                  profileController.phone.isNotEmpty
                      ? profileController.phone
                      : '+1 6587 4385 244',
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ],
            );
          }),
        ),
      ),
    );
  }
}
