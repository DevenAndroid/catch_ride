import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:catch_ride/utils/app_colors.dart';
import 'package:catch_ride/utils/app_text_styles.dart';
import 'package:catch_ride/widgets/custom_button.dart';
import 'package:catch_ride/widgets/custom_text_field.dart';

class ProfileCompleteTrainerController extends GetxController {
  final barnNameController = TextEditingController();
  final location1Controller = TextEditingController();
  final location2Controller = TextEditingController(); // Optional
  final yearsController = TextEditingController(); // Optional
  final bioController = TextEditingController();

  // Horse Shows & Circuits (Multi-select)
  final horseShows = [
    'Winter Equestrian Festival (WEF)',
    'HITS Ocala',
    'World Equestrian Center (WEC)',
    'Tryon International',
    'Desert International Horse Park',
    'Kentucky Horse Park',
    'Hampton Classic',
    'Devon',
  ];
  final selectedHorseShows = <String>[].obs;

  // Program Tags (Multi-select)
  final programTags = [
    'Big Equitation',
    'High Performance Hunter (3\'6"+)',
    'High Performance Jumper (1.20m+)',
    'Young Developing Hunter',
    'Young Developing Jumper',
    'Schoolmaster',
    'Prospect',
    'Division Pony',
    'Beginner Friendly',
  ];
  final selectedProgramTags = <String>[].obs;

  void toggleHorseShow(String show) {
    if (selectedHorseShows.contains(show)) {
      selectedHorseShows.remove(show);
    } else {
      selectedHorseShows.add(show);
    }
  }

  void toggleProgramTag(String tag) {
    if (selectedProgramTags.contains(tag)) {
      selectedProgramTags.remove(tag);
    } else {
      selectedProgramTags.add(tag);
    }
  }

  void submitProfile() {
    if (barnNameController.text.isEmpty ||
        location1Controller.text.isEmpty ||
        selectedHorseShows.isEmpty ||
        selectedProgramTags.isEmpty) {
      Get.snackbar(
        'Missing Information',
        'Please fill in all required fields.',
        backgroundColor: AppColors.softRed,
        colorText: Colors.white,
      );
      return;
    }

    // Process submission logic here (API call)
    Get.snackbar(
      'Success',
      'Profile information updated successfully!',
      backgroundColor: AppColors.successGreen,
      colorText: Colors.white,
    );
    // Proceed to next screen (e.g., Dashboard or Explore)
    // Get.offAllNamed('/trainer/main');
  }

  @override
  void onClose() {
    barnNameController.dispose();
    location1Controller.dispose();
    location2Controller.dispose();
    yearsController.dispose();
    bioController.dispose();
    super.onClose();
  }
}

class ProfileCompleteTrainerScreen extends StatelessWidget {
  const ProfileCompleteTrainerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ProfileCompleteTrainerController());

    return Scaffold(
      appBar: AppBar(
        title: const Text('Complete Profile'),
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: AppColors.deepNavy,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Profile Picture Section
            Center(
              child: Stack(
                children: [
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.grey200,
                      border: Border.all(color: AppColors.deepNavy, width: 2),
                    ),
                    child: const Icon(
                      Icons.person,
                      size: 60,
                      color: AppColors.grey400,
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: const BoxDecoration(
                        color: AppColors.deepNavy,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.camera_alt,
                        color: Colors.white,
                        size: 18,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Basic Info
            CustomTextField(
              label: 'Barn Name *',
              hint: 'e.g. Wellington Stables',
              controller: controller.barnNameController,
            ),
            const SizedBox(height: 16),
            CustomTextField(
              label: 'Location I (Required) *',
              hint: 'Primary Base (City, State)',
              controller: controller.location1Controller,
            ),
            const SizedBox(height: 16),
            CustomTextField(
              label: 'Location II (Optional)',
              hint: 'Secondary Base',
              controller: controller.location2Controller,
            ),
            const SizedBox(height: 16),
            CustomTextField(
              label: 'Years in Industry (Optional)',
              hint: 'e.g. 15',
              controller: controller.yearsController,
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            CustomTextField(
              label: 'Bio / Experience (Optional)',
              hint: 'Tell us about your background...',
              controller: controller.bioController,
              minLines: 4, // Prevents cut-off
              maxLines: 50,
            ),

            const SizedBox(height: 24),
            Text('Horse Shows & Circuits *', style: AppTextStyles.labelLarge),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.grey300),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Obx(
                () => Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: controller.horseShows.map((show) {
                    final isSelected = controller.selectedHorseShows.contains(
                      show,
                    );
                    return FilterChip(
                      label: Text(show),
                      selected: isSelected,
                      onSelected: (_) => controller.toggleHorseShow(show),
                      selectedColor: AppColors.deepNavy,
                      labelStyle: TextStyle(
                        color: isSelected
                            ? Colors.white
                            : AppColors.textPrimary,
                        fontWeight: isSelected
                            ? FontWeight.bold
                            : FontWeight.normal,
                      ),
                      backgroundColor: Colors.white,
                      side: BorderSide(
                        color: isSelected
                            ? AppColors.deepNavy
                            : AppColors.grey300,
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),

            const SizedBox(height: 24),
            Text('Program Tags *', style: AppTextStyles.labelLarge),
            const SizedBox(height: 4),
            Text(
              'Select all that apply to help with connections.',
              style: AppTextStyles.bodySmall.copyWith(color: AppColors.grey600),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.grey300),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Obx(
                () => Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: controller.programTags.map((tag) {
                    final isSelected = controller.selectedProgramTags.contains(
                      tag,
                    );
                    return FilterChip(
                      label: Text(tag),
                      selected: isSelected,
                      onSelected: (_) => controller.toggleProgramTag(tag),
                      selectedColor: AppColors.deepNavy,
                      labelStyle: TextStyle(
                        color: isSelected
                            ? Colors.white
                            : AppColors.textPrimary,
                        fontWeight: isSelected
                            ? FontWeight.bold
                            : FontWeight.normal,
                      ),
                      backgroundColor: Colors.white,
                      side: BorderSide(
                        color: isSelected
                            ? AppColors.deepNavy
                            : AppColors.grey300,
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),

            const SizedBox(height: 48),
            CustomButton(
              text: 'Save & Continue',
              onPressed: controller.submitProfile,
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
