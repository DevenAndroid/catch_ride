import 'package:catch_ride/constant/app_colors.dart';
import 'package:catch_ride/constant/app_text_sizes.dart';
import 'package:catch_ride/controllers/vendor/groom/grooming_details_controller.dart';
import 'package:catch_ride/widgets/common_button.dart';
import 'package:catch_ride/widgets/common_text.dart';
import 'package:catch_ride/widgets/common_textfield.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:catch_ride/utils/price_formatter.dart';

class GroomingServiceAndRates extends GetView<GroomingDetailsController> {
  const GroomingServiceAndRates({super.key});

  @override
  Widget build(BuildContext context) {
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
          'Services & Rates',
          fontSize: AppTextSizes.size18,
          fontWeight: FontWeight.bold,
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            _buildCoreGroomingCard(),
            const SizedBox(height: 20),
            _buildAdditionalServicesCard(context),
            const SizedBox(height: 40),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomButtons(),
    );
  }

  Widget _buildCoreGroomingCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
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
          const CommonText('Core Grooming Services', fontSize: AppTextSizes.size18, fontWeight: FontWeight.bold),
          const SizedBox(height: 4),
          const CommonText('Select the services you offer and set your pricing', fontSize: AppTextSizes.size14, color: AppColors.textSecondary),
          const SizedBox(height: 24),
          
          // Grooming & Turnout Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(2),
                decoration: BoxDecoration(
                  color: const Color(0xFF001149),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Icon(Icons.check, size: 14, color: Colors.white),
              ),
              const SizedBox(width: 12),
              const CommonText('Grooming & Turnout', fontSize: AppTextSizes.size16, fontWeight: FontWeight.bold),
              const Spacer(),
              const Icon(Icons.edit_outlined, size: 20, color: AppColors.linkBlue),
            ],
          ),
          
          const SizedBox(height: 20),
          
          // Rates Grid
          Row(
            children: [
              Expanded(child: _buildRateBox('\$ ${controller.dailyRateController.text.isEmpty ? "0" : controller.dailyRateController.text}', 'Per day')),
              const SizedBox(width: 12),
              Expanded(child: _buildRateBox('\$ ${controller.weeklyRateController.text.isEmpty ? "0" : controller.weeklyRateController.text}', 'Per week (${controller.weeklyRateDays.value}d)')),
              const SizedBox(width: 12),
              Expanded(child: _buildRateBox('\$ ${controller.monthlyRateController.text.isEmpty ? "0" : controller.monthlyRateController.text}', 'Per month')),
            ],
          ),
          
          const SizedBox(height: 24),
          
          // Sub-skills list
          Obx(() => Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: controller.selectedGroomingServices.map((skill) => Padding(
              padding: const EdgeInsets.only(bottom: 12, left: 32),
              child: CommonText(skill, fontSize: AppTextSizes.size14, color: AppColors.textPrimary),
            )).toList(),
          )),
          
          const SizedBox(height: 12),
          
          // Add More button
          Padding(
            padding: const EdgeInsets.only(left: 32),
            child: GestureDetector(
              onTap: () => _showAddSkillBottomSheet(),
              child: const CommonText(
                '+ ADD MORE',
                color: AppColors.linkBlue,
                fontWeight: FontWeight.bold,
                fontSize: AppTextSizes.size14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRateBox(String price, String period) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Column(
        children: [
          CommonText(price, fontSize: AppTextSizes.size16, fontWeight: FontWeight.bold, color: const Color(0xFFB91C1C)),
          const SizedBox(height: 4),
          CommonText(period, fontSize: AppTextSizes.size12, color: AppColors.textSecondary),
        ],
      ),
    );
  }

  Widget _buildAdditionalServicesCard(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
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
          const CommonText('Additional Services', fontSize: AppTextSizes.size18, fontWeight: FontWeight.bold),
          const SizedBox(height: 4),
          const CommonText('Optional services offered in addition to your standard work', fontSize: AppTextSizes.size14, color: AppColors.textSecondary),
          const SizedBox(height: 20),
          Obx(() => Column(
            children: controller.additionalServices.map((service) => _buildAdditionalServiceItem(service)).toList(),
          )),
          const SizedBox(height: 12),
          GestureDetector(
            onTap: () => _showAddAdditionalServiceBottomSheet(context),
            child: Row(
              children: const [
                Icon(Icons.add, size: 18, color: AppColors.linkBlue),
                SizedBox(width: 4),
                CommonText(
                  'Add Service',
                  color: AppColors.linkBlue,
                  fontWeight: FontWeight.bold,
                  fontSize: AppTextSizes.size14,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAdditionalServiceItem(Map<String, dynamic> service) {
    final RxBool isSelected = service['isSelected'];
    final TextEditingController priceCtrl = service['price'];

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Obx(() => Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isSelected.value ? const Color(0xFF001149) : AppColors.borderLight,
                width: isSelected.value ? 1.5 : 1,
              ),
            ),
            child: Row(
              children: [
                GestureDetector(
                  onTap: () => isSelected.value = !isSelected.value,
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: isSelected.value ? const Color(0xFF001149) : Colors.white,
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(
                        color: isSelected.value ? const Color(0xFF001149) : AppColors.borderMedium,
                        width: 1.5,
                      ),
                    ),
                    child: Icon(
                      Icons.check,
                      size: 14,
                      color: isSelected.value ? Colors.white : Colors.transparent,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CommonText(
                        service['name'],
                        fontSize: AppTextSizes.size14,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                      const CommonText(
                        'Per horse',
                        fontSize: AppTextSizes.size12,
                        color: AppColors.textSecondary,
                      ),
                    ],
                  ),
                ),
                Container(
                  width: 90,
                  height: 44,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF9FAFB),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.borderLight),
                  ),
                  child: Row(
                    children: [
                      const CommonText('\$ ', fontSize: AppTextSizes.size14, color: AppColors.textSecondary),
                      Expanded(
                        child: TextField(
                          controller: priceCtrl,
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          inputFormatters: [PriceInputFormatter()],
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                            hintText: '0',
                            isDense: true,
                            contentPadding: EdgeInsets.zero,
                          ),
                          style: const TextStyle(
                            fontSize: AppTextSizes.size14,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          )),
    );
  }

  Widget _buildBottomButtons() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
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
                side: BorderSide(color: AppColors.borderMedium),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const CommonText('Cancel', fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Obx(() => CommonButton(
                  text: 'Save',
                  isLoading: controller.isSubmitting.value,
                  onPressed: () => controller.submit(),
                  backgroundColor: const Color(0xFF00083B),
                )),
          ),
        ],
      ),
    );
  }

  void _showAddSkillBottomSheet() {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const CommonText('Add Skill', fontSize: AppTextSizes.size22, fontWeight: FontWeight.bold),
            const SizedBox(height: 24),
            const CommonText('Skill Name', fontSize: AppTextSizes.size14, fontWeight: FontWeight.w600),
            const SizedBox(height: 8),
            CommonTextField(
              label: '',
              hintText: 'Enter your skill',
              controller: controller.addServiceInputController,
            ),
            const SizedBox(height: 32),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Get.back(),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const CommonText('Cancel'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: CommonButton(
                    text: 'Save',
                    onPressed: () {
                      if (controller.addServiceInputController.text.isNotEmpty) {
                        controller.addGroomingService(controller.addServiceInputController.text);
                        Get.back();
                      }
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showAddAdditionalServiceBottomSheet(BuildContext context) {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const CommonText('Add Additional Service', fontSize: AppTextSizes.size22, fontWeight: FontWeight.bold),
            const SizedBox(height: 24),
            const CommonText('Service Name', fontSize: AppTextSizes.size14, fontWeight: FontWeight.w600),
            const SizedBox(height: 8),
            CommonTextField(
              label: '',
              hintText: 'Enter your service',
              controller: controller.addServiceInputController,
            ),
            const SizedBox(height: 20),
            const CommonText('Price', fontSize: AppTextSizes.size14, fontWeight: FontWeight.w600),
            const SizedBox(height: 8),
            CommonTextField(
              label: '',
              hintText: 'Enter price (e.g. 40)',
              controller: controller.addServicePriceInputController,
              prefixIcon: const Padding(
                padding: EdgeInsets.all(14),
                child: CommonText('\$ ', fontSize: AppTextSizes.size14),
              ),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [PriceInputFormatter()],
            ),
            const SizedBox(height: 32),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Get.back(),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const CommonText('Cancel'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: CommonButton(
                    text: 'Save',
                    onPressed: () {
                      if (controller.addServiceInputController.text.isNotEmpty) {
                        controller.addAdditionalService(
                          controller.addServiceInputController.text,
                          controller.addServicePriceInputController.text,
                        );
                        Get.back();
                      }
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
