import 'package:catch_ride/constant/app_colors.dart';
import 'package:catch_ride/constant/app_text_sizes.dart';
import '../../../../controllers/vendor/shipping/shipping_details_controller.dart';
import 'package:catch_ride/widgets/common_button.dart';
import 'package:catch_ride/widgets/common_text.dart';
import 'package:catch_ride/widgets/common_textfield.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ServicePriceView extends StatelessWidget {
  const ServicePriceView({super.key});

  @override
  Widget build(BuildContext context) {
    // Renamed controller class to ShippingProfileController
    final ShippingDetailsController controller = Get.put(ShippingDetailsController());
    
    // Explicitly marking as edit mode so the controller knows to go back on success
    controller.editModeEnabled.value = true;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black, size: 20),
          onPressed: () => Get.back(),
        ),
        title: const CommonText(
          'Pricing',
          fontSize: AppTextSizes.size18,
          fontWeight: FontWeight.bold,
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.borderLight),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const CommonText(
                    'Set your shipping rates',
                    fontSize: AppTextSizes.size14,
                    color: AppColors.textSecondary,
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Obx(() => Checkbox(
                        value: controller.inquiryPrice.value,
                        onChanged: (val) => controller.inquiryPrice.value = val ?? false,
                        activeColor: const Color(0xFF001149),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                      )),
                      const CommonText(
                        'Inquire for Price',
                        fontSize: AppTextSizes.size14,
                        fontWeight: FontWeight.w500,
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  
                  // Base Rate
                  const CommonText(
                    'Base Rate',
                    fontSize: AppTextSizes.size14,
                    fontWeight: FontWeight.bold,
                  ),
                  const SizedBox(height: 8),
                  _buildPriceField(
                    controller: controller.baseRateController,
                    hint: 'Enter Price',
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Fully Loaded Rate
                  const CommonText(
                    'Fully Loaded Rate',
                    fontSize: AppTextSizes.size14,
                    fontWeight: FontWeight.bold,
                  ),
                  const SizedBox(height: 8),
                  _buildPriceField(
                    controller: controller.loadedRateController,
                    hint: 'Enter Price',
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: AppColors.borderLight)),
        ),
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () => Get.back(),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  side: const BorderSide(color: AppColors.borderLight),
                ),
                child: const CommonText(
                  'Cancel',
                  fontSize: AppTextSizes.size16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Obx(() => CommonButton(
                text: 'Save',
                isLoading: controller.isSubmitting.value,
                onPressed: () => controller.submitDetails(),
                backgroundColor: const Color(0xFF001149),
              )),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPriceField({
    required TextEditingController controller,
    required String hint,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                hintText: hint,
                hintStyle: const TextStyle(color: Colors.grey, fontSize: 14),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            height: 56, // Matching input height
            decoration: const BoxDecoration(
              border: Border(left: BorderSide(color: AppColors.borderLight)),
            ),
            alignment: Alignment.center,
            child: const CommonText(
              '/ per mile',
              fontSize: AppTextSizes.size14,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
