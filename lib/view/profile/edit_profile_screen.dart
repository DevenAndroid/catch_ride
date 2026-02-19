import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:catch_ride/utils/app_colors.dart';
import 'package:catch_ride/utils/app_text_styles.dart';
import 'package:catch_ride/widgets/custom_button.dart';
import 'package:catch_ride/widgets/custom_text_field.dart';

class EditProfileController extends GetxController {
  final nameController = TextEditingController(text: 'John Smith');
  final stableNameController = TextEditingController(
    text: 'Wellington Stables',
  );
  final phoneController = TextEditingController(text: '(555) 123-4567');
  final locationController = TextEditingController(text: 'Wellington, FL');
  final bioController = TextEditingController(
    text:
        'Professional trainer with 15 years of experience in Hunter/Jumper circuit.',
  );
  final usefIdController = TextEditingController(text: '12345');

  // Discipline Selection
  final disciplines = <String>[
    'Hunter',
    'Jumper',
    'Equitation',
    'Dressage',
    'Eventing',
  ];
  final selectedDisciplines = <String>['Hunter', 'Jumper'].obs;

  void toggleDiscipline(String discipline) {
    if (selectedDisciplines.contains(discipline)) {
      selectedDisciplines.remove(discipline);
    } else {
      selectedDisciplines.add(discipline);
    }
  }

  void saveProfile() {
    // Validate and Save Logic
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
    nameController.dispose();
    stableNameController.dispose();
    phoneController.dispose();
    locationController.dispose();
    bioController.dispose();
    usefIdController.dispose();
    super.onClose();
  }
}

class EditProfileScreen extends StatelessWidget {
  const EditProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(EditProfileController());

    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
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

            Text('Personal Information', style: AppTextStyles.headlineMedium),
            const SizedBox(height: 16),
            CustomTextField(
              label: 'Full Name',
              hint: 'Enter your full name',
              controller: controller.nameController,
            ),
            const SizedBox(height: 16),
            CustomTextField(
              label: 'Phone Number',
              hint: '(555) 000-0000',
              controller: controller.phoneController,
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 16),
            // Email is usually read-only
            const CustomTextField(
              label: 'Email',
              hint: 'john.smith@example.com',
              readOnly: true,
            ),

            const SizedBox(height: 32),
            Text('Professional Details', style: AppTextStyles.headlineMedium),
            const SizedBox(height: 16),
            CustomTextField(
              label: 'Stable / Business Name',
              hint: 'e.g. Wellington Stables',
              controller: controller.stableNameController,
            ),
            const SizedBox(height: 16),
            CustomTextField(
              label: 'Location (City, State)',
              hint: 'e.g. Wellington, FL',
              controller: controller.locationController,
            ),
            const SizedBox(height: 16),
            CustomTextField(
              label: 'USEF / FEI ID',
              hint: 'Membership ID',
              controller: controller.usefIdController,
            ),
            const SizedBox(height: 16),
            CustomTextField(
              label: 'Bio / About',
              hint: 'Tell us about your experience...',
              controller: controller.bioController,
              maxLines: 4,
            ),

            const SizedBox(height: 24),
            Text('Disciplines', style: AppTextStyles.labelLarge),
            const SizedBox(height: 12),
            Obx(
              () => Wrap(
                spacing: 8,
                runSpacing: 8,
                children: controller.disciplines.map((discipline) {
                  final isSelected = controller.selectedDisciplines.contains(
                    discipline,
                  );
                  return FilterChip(
                    label: Text(discipline),
                    selected: isSelected,
                    onSelected: (_) => controller.toggleDiscipline(discipline),
                    selectedColor: AppColors.deepNavy,
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.white : AppColors.textPrimary,
                    ),
                    checkmarkColor: Colors.white,
                  );
                }).toList(),
              ),
            ),

            const SizedBox(height: 48),
            CustomButton(
              text: 'Save Changes',
              onPressed: controller.saveProfile,
            ),
          ],
        ),
      ),
    );
  }
}
