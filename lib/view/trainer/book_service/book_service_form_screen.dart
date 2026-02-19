import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:catch_ride/utils/app_colors.dart';
import 'package:catch_ride/utils/app_text_styles.dart';
import 'package:catch_ride/widgets/custom_button.dart';
import 'package:catch_ride/widgets/custom_text_field.dart';

class BookServiceFormController extends GetxController {
  final dateStartController = TextEditingController();
  final dateEndController = TextEditingController();
  final notesController = TextEditingController();
  var selectedService = Rx<String>('');
  final selectedServices = <String>[
    'Grooming',
    'Braiding',
    'Farrier',
  ].obs; // Mock Data

  @override
  void onClose() {
    dateStartController.dispose();
    dateEndController.dispose();
    notesController.dispose();
    super.onClose();
  }
}

class BookServiceFormScreen extends StatelessWidget {
  const BookServiceFormScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(BookServiceFormController());

    return Scaffold(
      appBar: AppBar(title: const Text('Request Booking')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Select Service', style: AppTextStyles.labelLarge),
            const SizedBox(height: 12),
            Obx(
              () => Wrap(
                spacing: 8,
                children: controller.selectedServices.map((service) {
                  return ChoiceChip(
                    label: Text(service),
                    selected: controller.selectedService.value == service,
                    onSelected: (val) {
                      controller.selectedService.value = val ? service : '';
                    },
                    selectedColor: AppColors.mutedGold,
                    backgroundColor: AppColors.grey100,
                    labelStyle: TextStyle(
                      color: controller.selectedService.value == service
                          ? AppColors.deepNavy
                          : AppColors.textPrimary,
                    ),
                  );
                }).toList(),
              ),
            ),

            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: CustomTextField(
                    label: 'Start Date',
                    hint: 'MM/DD/YYYY',
                    controller: controller.dateStartController,
                    suffixIcon: const Icon(Icons.calendar_today, size: 20),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: CustomTextField(
                    label: 'End Date (Opt)',
                    hint: 'MM/DD/YYYY',
                    controller: controller.dateEndController,
                    suffixIcon: const Icon(Icons.calendar_today, size: 20),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),
            Text('Request Details', style: AppTextStyles.labelLarge),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.grey50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.grey200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Wellington Show Grounds',
                        style: AppTextStyles.titleMedium,
                      ),
                      Icon(Icons.edit, size: 16, color: AppColors.grey500),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text('Barn 4, Aisle B', style: AppTextStyles.bodyMedium),
                ],
              ),
            ),

            const SizedBox(height: 24),
            CustomTextField(
              label: 'Notes / Special Instructions',
              hint: 'e.g. Needs Braiding by 7 AM',
              controller: controller.notesController,
              maxLines: 4,
            ),

            const SizedBox(height: 32),
            CustomButton(
              text: 'Send Request',
              onPressed: () {
                // Submit Logic
                Get.back(); // Close form
                Get.back(); // Back to profile
                Get.back(); // Back to search
                Get.snackbar('Success', 'Booking Request Sent!');
              },
            ),
          ],
        ),
      ),
    );
  }
}
