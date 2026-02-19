import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:catch_ride/utils/app_colors.dart';
import 'package:catch_ride/utils/app_text_styles.dart';
import 'package:catch_ride/widgets/custom_button.dart';
import 'package:catch_ride/widgets/custom_text_field.dart';
import 'package:catch_ride/view/trainer/onboarding/application_submit_trainer_screen.dart';

class TrainerApplicationController extends GetxController {
  final websiteController = TextEditingController();
  final facebookController = TextEditingController(); // Required
  final instagramController = TextEditingController();
  final usefController = TextEditingController(); // Required
  final ushjaController = TextEditingController(); // Required

  void submitApplication() {
    // if (facebookController.text.isEmpty ||
    //     usefController.text.isEmpty ||
    //     ushjaController.text.isEmpty) {
    //   Get.snackbar(
    //     'Missing Information',
    //     'Facebook URL and Federation Information (USEF & USHJA) are required.',
    //     backgroundColor: AppColors.softRed,
    //     colorText: Colors.white,
    //   );
    //   return;
    // }

    // Navigate to Application Submitted Screen
    Get.offAll(() => const ApplicationSubmitTrainerScreen());
  }

  @override
  void onClose() {
    websiteController.dispose();
    facebookController.dispose();
    instagramController.dispose();
    usefController.dispose();
    ushjaController.dispose();
    super.onClose();
  }
}

class TrainerApplicationScreen extends StatelessWidget {
  const TrainerApplicationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(TrainerApplicationController());

    return Scaffold(
      appBar: AppBar(
        title: const Text('Trainer Application'),
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
              'Please provide your professional details for verification.',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.grey600,
              ),
            ),
            const SizedBox(height: 32),

            // Website (Optional)
            CustomTextField(
              label: 'Website URL (Optional)',
              hint: 'https://www.example.com',
              controller: controller.websiteController,
            ),
            const SizedBox(height: 16),

            // Facebook (Required)
            CustomTextField(
              label: 'Facebook URL *',
              hint: 'https://facebook.com/yourprofile',
              controller: controller.facebookController,
            ),
            const SizedBox(height: 16),

            // Instagram (Optional)
            CustomTextField(
              label: 'Instagram URL (Optional)',
              hint: 'https://instagram.com/yourhandle',
              controller: controller.instagramController,
            ),
            const SizedBox(height: 16),

            // USHJA (Required)
            CustomTextField(
              label: 'Federation Information *',
              hint: 'Enter your federation number',
              controller: controller.ushjaController,
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
