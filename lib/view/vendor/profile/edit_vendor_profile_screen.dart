import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:catch_ride/utils/app_colors.dart';
import 'package:catch_ride/utils/app_text_styles.dart';
import 'package:catch_ride/widgets/custom_button.dart';
import 'package:catch_ride/widgets/custom_text_field.dart';

class EditVendorProfileController extends GetxController {
  final nameController = TextEditingController(text: 'John Smith');
  final businessNameController = TextEditingController(
    text: 'Elite Grooming Services',
  );
  final phoneController = TextEditingController(text: '(555) 123-4567');
  final locationController = TextEditingController(text: 'Wellington, FL');
  final bioController = TextEditingController(
    text:
        'Over 8 years of experience grooming for top Grand Prix jumpers and hunters. '
        'Available for full show days, specialized clipping, and show braiding.',
  );
  final serviceRadiusController = TextEditingController(text: '20');

  // Service types the vendor offers
  final allServiceTypes = <String>[
    'Groom',
    'Clipping',
    'Braiding',
    'Farrier',
    'Bodywork',
    'Shipping',
  ];
  final selectedServiceTypes = <String>['Groom', 'Clipping', 'Braiding'].obs;

  void toggleServiceType(String type) {
    if (selectedServiceTypes.contains(type)) {
      if (selectedServiceTypes.length > 1) {
        selectedServiceTypes.remove(type);
      } else {
        Get.snackbar(
          'Required',
          'You must have at least one service type',
          backgroundColor: AppColors.softRed,
          colorText: Colors.white,
        );
      }
    } else if (selectedServiceTypes.length < 2) {
      selectedServiceTypes.add(type);
    } else {
      Get.snackbar(
        'Limit',
        'Maximum 2 service types allowed',
        backgroundColor: AppColors.softRed,
        colorText: Colors.white,
      );
    }
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
    nameController.dispose();
    businessNameController.dispose();
    phoneController.dispose();
    locationController.dispose();
    bioController.dispose();
    serviceRadiusController.dispose();
    super.onClose();
  }
}

class EditVendorProfileScreen extends StatelessWidget {
  const EditVendorProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(EditVendorProfileController());

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
            // Profile Photo
            Center(
              child: Stack(
                children: [
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.deepNavy,
                      border: Border.all(color: AppColors.mutedGold, width: 3),
                    ),
                    child: Center(
                      child: Text(
                        'JS',
                        style: AppTextStyles.headlineMedium.copyWith(
                          color: AppColors.mutedGold,
                          fontSize: 28,
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: GestureDetector(
                      onTap: () {
                        Get.snackbar('Photo', 'Photo picker would open here');
                      },
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
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Personal Information
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
            const CustomTextField(
              label: 'Email',
              hint: 'john.smith@example.com',
              readOnly: true,
            ),

            const SizedBox(height: 32),

            // Business Details
            Text('Business Details', style: AppTextStyles.headlineMedium),
            const SizedBox(height: 16),
            CustomTextField(
              label: 'Business / Professional Name',
              hint: 'e.g. Elite Grooming Services',
              controller: controller.businessNameController,
            ),
            const SizedBox(height: 16),
            CustomTextField(
              label: 'Home Base (City, State)',
              hint: 'e.g. Wellington, FL',
              controller: controller.locationController,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  flex: 3,
                  child: CustomTextField(
                    label: 'Service Radius (miles)',
                    hint: '20',
                    controller: controller.serviceRadiusController,
                    keyboardType: TextInputType.number,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  flex: 2,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Preview', style: AppTextStyles.labelLarge),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: AppColors.grey100,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.location_on,
                              size: 16,
                              color: AppColors.deepNavy,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '+ 20mi',
                              style: AppTextStyles.bodyMedium.copyWith(
                                color: AppColors.deepNavy,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            CustomTextField(
              label: 'Bio / About You',
              hint: 'Tell clients about your experience and specialties...',
              controller: controller.bioController,
              maxLines: 4,
            ),

            const SizedBox(height: 32),

            // Service Types
            Text('Service Types', style: AppTextStyles.headlineMedium),
            const SizedBox(height: 8),
            Text(
              'Select up to 2 service categories you offer.',
              style: AppTextStyles.bodySmall.copyWith(color: AppColors.grey500),
            ),
            const SizedBox(height: 12),
            Obx(
              () => Wrap(
                spacing: 8,
                runSpacing: 8,
                children: controller.allServiceTypes.map((type) {
                  final isSelected = controller.selectedServiceTypes.contains(
                    type,
                  );
                  return FilterChip(
                    label: Text(type),
                    selected: isSelected,
                    onSelected: (_) => controller.toggleServiceType(type),
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
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
