import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:catch_ride/controller/add_horse_controller.dart';
import 'package:catch_ride/utils/app_colors.dart';
import 'package:catch_ride/utils/app_text_styles.dart';
import 'package:catch_ride/widgets/custom_button.dart';
import 'package:catch_ride/widgets/custom_text_field.dart';

class AddHorseScreen extends StatelessWidget {
  const AddHorseScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(AddHorseController());

    return Scaffold(
      appBar: AppBar(title: const Text('Add Your Horse'), centerTitle: true),
      body: Column(
        children: [
          // Steps Indicator
          Obx(() => _buildStepIndicator(controller.currentStep.value)),

          Expanded(
            child: Obx(() {
              switch (controller.currentStep.value) {
                case 0:
                  return _buildStep1(controller);
                case 1:
                  return _buildStep2(controller);
                case 2:
                  return _buildStep3(controller);
                default:
                  return const SizedBox();
              }
            }),
          ),

          // Navigation Buttons
          Padding(
            padding: const EdgeInsets.all(24),
            child: Row(
              children: [
                Expanded(
                  child: Obx(
                    () => controller.currentStep.value > 0
                        ? CustomButton(
                            text: 'Back',
                            isOutlined: true,
                            onPressed: controller.previousStep,
                          )
                        : const SizedBox(),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: CustomButton(
                    text: controller.currentStep.value == 2
                        ? 'Publish'
                        : 'Next',
                    onPressed: controller.nextStep,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepIndicator(int currentStep) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      color: Colors.white,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(3, (index) {
          bool isActive = index <= currentStep;
          return Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: isActive ? AppColors.mutedGold : AppColors.grey200,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    '${index + 1}',
                    style: TextStyle(
                      color: isActive ? AppColors.deepNavy : AppColors.grey500,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              if (index < 2)
                Container(
                  width: 40,
                  height: 2,
                  color: isActive ? AppColors.mutedGold : AppColors.grey200,
                ),
            ],
          );
        }),
      ),
    );
  }

  // Step 1: Media
  Widget _buildStep1(AddHorseController controller) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Media Upload', style: AppTextStyles.headlineMedium),
          const SizedBox(height: 8),
          Text(
            'Upload at least one video (Required) to showcase movement.',
            style: AppTextStyles.bodyMedium,
          ),
          const SizedBox(height: 24),

          GestureDetector(
            onTap: () {
              controller.videoUploaded.value = true;
            },
            child: Container(
              height: 220,
              width: double.infinity,
              decoration: BoxDecoration(
                color: AppColors.grey100,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: AppColors.deepNavy.withOpacity(0.3),
                  style: BorderStyle.solid,
                ),
              ),
              child: Center(
                child: Obx(
                  () => controller.videoUploaded.value
                      ? Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.check_circle,
                              size: 48,
                              color: AppColors.successGreen,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Video Uploaded',
                              style: AppTextStyles.titleMedium,
                            ),
                          ],
                        )
                      : Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.videocam_outlined,
                              size: 48,
                              color: AppColors.deepNavy,
                            ),
                            SizedBox(height: 12),
                            Text(
                              'Tap to upload Video',
                              style: AppTextStyles.titleMedium,
                            ),
                            Text(
                              '(Required)',
                              style: AppTextStyles.labelLarge.copyWith(
                                color: AppColors.softRed,
                                fontSize: 10,
                              ),
                            ),
                          ],
                        ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text('Photos (Optional)', style: AppTextStyles.titleMedium),
          const SizedBox(height: 12),
          Row(
            children: [
              _buildPhotoPlaceholder(),
              const SizedBox(width: 12),
              _buildPhotoPlaceholder(),
              const SizedBox(width: 12),
              _buildPhotoPlaceholder(),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPhotoPlaceholder() {
    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        color: AppColors.grey100,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.grey300),
      ),
      child: Icon(Icons.add_a_photo_outlined, color: AppColors.grey500),
    );
  }

  // Step 2: Horse Details
  Widget _buildStep2(AddHorseController controller) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Horse Details', style: AppTextStyles.headlineMedium),
          const SizedBox(height: 24),

          CustomTextField(
            label: 'Horse Name',
            controller: controller.nameController,
          ),
          const SizedBox(height: 16),

          Row(
            children: [
              Expanded(
                child: CustomTextField(
                  label: 'Age',
                  keyboardType: TextInputType.number,
                  controller: controller.ageController,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: CustomTextField(
                  label: 'Height (hh)',
                  keyboardType: TextInputType.number,
                  controller: controller.heightController,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          CustomTextField(
            label: 'Breed',
            controller: controller.breedController,
          ),
          const SizedBox(height: 16),

          // Discipline Select
          Text('Discipline', style: AppTextStyles.labelLarge),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: ['Hunter', 'Jumper', 'Equitation', 'Dressage'].map((d) {
              return ChoiceChip(
                label: Text(d),
                selected: false, // Wire up to controller if needed
                onSelected: (val) {},
                selectedColor: AppColors.mutedGold,
                backgroundColor: AppColors.grey100,
                labelStyle: TextStyle(color: AppColors.deepNavy),
              );
            }).toList(),
          ),
          const SizedBox(height: 16),

          CustomTextField(
            label: 'Description',
            controller: controller.descriptionController,
            maxLines: 4,
            hint: 'Describe temperament, experience, and suitability...',
          ),
        ],
      ),
    );
  }

  // Step 3: Availability & Pricing
  Widget _buildStep3(AddHorseController controller) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Availability & Pricing', style: AppTextStyles.headlineMedium),
          const SizedBox(height: 24),

          // Listing Type
          Text('Listing Type', style: AppTextStyles.labelLarge),
          const SizedBox(height: 8),
          Row(
            children: [
              _buildTypeChip('Sale', true),
              const SizedBox(width: 8),
              _buildTypeChip('Lease', false),
              const SizedBox(width: 8),
              _buildTypeChip('Trial', false),
            ],
          ),
          const SizedBox(height: 24),

          // Price/Fee input removed
          const SizedBox(height: 24),
          Text('Availability Calendar', style: AppTextStyles.titleMedium),
          Text(
            'Add blocks for locations and dates.',
            style: AppTextStyles.bodyMedium,
          ),
          const SizedBox(height: 12),

          // Add Block Button
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.deepNavy),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.add_circle_outline, color: AppColors.deepNavy),
                SizedBox(width: 8),
                Text(
                  'Add Availability Block',
                  style: AppTextStyles.titleMedium.copyWith(
                    color: AppColors.deepNavy,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),
          // Example Block
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.grey50,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Wellington, FL', style: AppTextStyles.titleMedium),
                    Icon(Icons.edit, size: 18, color: AppColors.grey500),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.date_range, size: 16, color: AppColors.grey600),
                    SizedBox(width: 4),
                    Text('Dec 1 - Apr 15', style: AppTextStyles.bodyMedium),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTypeChip(String label, bool isSelected) {
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (val) {},
      selectedColor: AppColors.mutedGold,
      checkmarkColor: AppColors.deepNavy,
      labelStyle: TextStyle(
        color: isSelected ? AppColors.deepNavy : AppColors.textPrimary,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
    );
  }
}
