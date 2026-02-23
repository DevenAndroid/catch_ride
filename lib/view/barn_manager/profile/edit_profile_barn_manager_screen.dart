import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:catch_ride/utils/app_colors.dart';
import 'package:catch_ride/utils/app_text_styles.dart';
import 'package:catch_ride/widgets/custom_button.dart';
import 'package:catch_ride/widgets/custom_text_field.dart';
import 'package:catch_ride/controllers/user_role_controller.dart';

class EditProfileBarnManagerController extends GetxController {
  final roleController = Get.find<UserRoleController>();

  // Trainer data (Read-Only for Barn Manager)
  late final String trainerName;
  late final String trainerLocation;
  late final String trainerBarnName;

  @override
  void onInit() {
    super.onInit();
    trainerName = 'Emily Johnson'; // In real app, fetch from Trainer model
    trainerLocation = 'Wellington, FL'; // In real app, fetch from Trainer model
    trainerBarnName =
        'Sunshine Equestrian'; // In real app, fetch from Trainer model
  }

  void saveProfile() {
    Get.back();
    Get.snackbar(
      'Success',
      'Profile updated successfully',
      backgroundColor: AppColors.successGreen,
      colorText: Colors.white,
    );
  }

  @override
  void onClose() {
    super.onClose();
  }
}

class EditProfileBarnManagerScreen extends StatelessWidget {
  const EditProfileBarnManagerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(EditProfileBarnManagerController());

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Edit Profile'),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          TextButton(
            onPressed: controller.saveProfile,
            child: const Text(
              'Save',
              style: TextStyle(
                color: AppColors.deepNavy,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Cover Photo Support
            _buildCoverPhotoSection(),
            const SizedBox(height: 24),

            // Profile Image
            Center(
              child: Stack(
                children: [
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.grey200,
                      image: const DecorationImage(
                        image: NetworkImage('https://via.placeholder.com/150'),
                        fit: BoxFit.cover,
                      ),
                      border: Border.all(color: Colors.white, width: 4),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
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
                        size: 20,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            const SizedBox(height: 32),
            Row(
              children: [
                Text(
                  'Trainer Information',
                  style: AppTextStyles.headlineMedium,
                ),
                const SizedBox(width: 8),
                const Icon(
                  Icons.lock_outline,
                  size: 16,
                  color: AppColors.grey400,
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              'Fetched automatically from your associated Trainer.',
              style: AppTextStyles.bodySmall.copyWith(color: AppColors.grey500),
            ),
            const SizedBox(height: 16),
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
              controller: TextEditingController(
                text: controller.trainerLocation,
              ),
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

            const SizedBox(height: 48),
            CustomButton(
              text: 'Save Changes',
              onPressed: controller.saveProfile,
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildCoverPhotoSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Cover Photo', style: AppTextStyles.labelLarge),
        const SizedBox(height: 12),
        Stack(
          children: [
            Container(
              height: 150,
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                image: const DecorationImage(
                  image: NetworkImage(
                    'https://images.unsplash.com/photo-1553284965-83fd3e82fa5a?auto=format&fit=crop&q=80&w=800',
                  ),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            Positioned(
              right: 12,
              bottom: 12,
              child: ElevatedButton.icon(
                onPressed: () =>
                    Get.snackbar('Photo', 'Select new cover photo'),
                icon: const Icon(Icons.camera_alt, size: 16),
                label: const Text('Change'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: AppColors.deepNavy,
                  elevation: 2,
                  minimumSize: const Size(80, 36), // Restrict layout width
                  maximumSize: const Size(120, 36),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
