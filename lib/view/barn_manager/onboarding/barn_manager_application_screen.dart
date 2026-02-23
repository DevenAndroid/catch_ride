import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:catch_ride/utils/app_colors.dart';
import 'package:catch_ride/utils/app_text_styles.dart';
import 'package:catch_ride/widgets/custom_button.dart';
import 'package:catch_ride/widgets/custom_text_field.dart';
import 'package:catch_ride/view/barn_manager/onboarding/barn_manager_application_submit_screen.dart';

class BarnManagerApplicationController extends GetxController {
  var profilePhoto = Rx<String?>(null);
  var coverPhoto = Rx<String?>(null);

  final trainerName = 'Emily Johnson';
  final location = 'Wellington, FL';
  final trainerBarnName = 'Sunshine Equestrian';
  final usefController = TextEditingController(); // Optional

  void pickProfilePhoto() {
    profilePhoto.value = 'profile_picked';
  }

  void pickCoverPhoto() {
    coverPhoto.value = 'cover_picked';
  }

  void submitApplication() {
    // if (profilePhoto.value == null) {
    //   Get.snackbar(
    //     'Required',
    //     'Profile photo is required.',
    //     backgroundColor: AppColors.softRed,
    //     colorText: Colors.white,
    //   );
    //   return;
    // }
    Get.offAll(() => const BarnManagerApplicationSubmitScreen());
  }

  @override
  void onClose() {
    usefController.dispose();
    super.onClose();
  }
}

class BarnManagerApplicationScreen extends StatelessWidget {
  const BarnManagerApplicationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(BarnManagerApplicationController());

    return Scaffold(
      appBar: AppBar(
        title: const Text('Barn Manager Application'),
        backgroundColor: Colors.white,
        foregroundColor: AppColors.deepNavy,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Application Process', style: AppTextStyles.headlineMedium),
            const SizedBox(height: 8),
            Text(
              'Your trainer and location information is pulled automatically from your associated trainer\'s profile.',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.grey600,
              ),
            ),
            const SizedBox(height: 32),

            CustomTextField(
              label: 'Trainer Name',
              hint: '',
              controller: TextEditingController(text: controller.trainerName),
              readOnly: true,
            ),
            const SizedBox(height: 16),
            CustomTextField(
              label: 'Location',
              hint: '',
              controller: TextEditingController(text: controller.location),
              readOnly: true,
            ),
            const SizedBox(height: 16),
            CustomTextField(
              label: 'Barn Name',
              hint: '',
              controller: TextEditingController(
                text: controller.trainerBarnName,
              ),
              readOnly: true,
            ),
            const SizedBox(height: 32),

            Text('Federation Information', style: AppTextStyles.titleMedium),
            const SizedBox(height: 12),
            CustomTextField(
              label: 'USEF Number (Optional)',
              hint: 'Enter your federation number',
              controller: controller.usefController,
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 32),

            // Profile Photo (REQUIRED)
            Text(
              'Profile Photo *',
              style: AppTextStyles.labelLarge.copyWith(
                color: AppColors.deepNavy,
              ),
            ),
            const SizedBox(height: 8),
            Obx(
              () => GestureDetector(
                onTap: controller.pickProfilePhoto,
                child: Container(
                  height: 120,
                  width: 120,
                  decoration: BoxDecoration(
                    color: AppColors.grey100,
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.grey300),
                  ),
                  child: controller.profilePhoto.value == null
                      ? const Center(
                          child: Icon(
                            Icons.add_a_photo,
                            color: AppColors.grey400,
                            size: 32,
                          ),
                        )
                      : const Center(
                          child: Icon(
                            Icons.check_circle,
                            color: AppColors.successGreen,
                            size: 48,
                          ),
                        ),
                ),
              ),
            ),
            const SizedBox(height: 32),

            // Cover Photo (Optional)
            Text(
              'Cover Photo (Optional)',
              style: AppTextStyles.labelLarge.copyWith(
                color: AppColors.deepNavy,
              ),
            ),
            const SizedBox(height: 8),
            Obx(
              () => GestureDetector(
                onTap: controller.pickCoverPhoto,
                child: Container(
                  height: 160,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: AppColors.grey100,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.grey300),
                  ),
                  child: controller.coverPhoto.value == null
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.wallpaper,
                                color: AppColors.grey400,
                                size: 32,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Tap to upload cover photo',
                                style: AppTextStyles.bodySmall.copyWith(
                                  color: AppColors.grey500,
                                ),
                              ),
                            ],
                          ),
                        )
                      : const Center(
                          child: Icon(
                            Icons.check_circle,
                            color: AppColors.successGreen,
                            size: 48,
                          ),
                        ),
                ),
              ),
            ),
            const SizedBox(height: 48),
            CustomButton(
              text: 'Submit Application',
              onPressed: controller.submitApplication,
            ),
          ],
        ),
      ),
    );
  }
}
