import 'dart:io';
import 'package:catch_ride/constant/app_colors.dart';
import 'package:catch_ride/constant/app_text_sizes.dart';
import 'package:catch_ride/controllers/vendor/shipping/shipping_details_controller.dart';
import 'package:catch_ride/widgets/common_button.dart';
import 'package:catch_ride/widgets/common_text.dart';
import 'package:catch_ride/widgets/common_textfield.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ShippingDetailsView extends StatelessWidget {
  const ShippingDetailsView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ShippingDetailsController());

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.cardColor,
        elevation: 0,
        centerTitle: false,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: AppColors.textPrimary, size: 20),
          onPressed: () => Get.back(),
        ),
        title: const CommonText(
          'Shipping Details',
          fontSize: AppTextSizes.size18,
          fontWeight: FontWeight.bold,
          color: AppColors.textPrimary,
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(color: AppColors.border, height: 1.0),
        ),
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        return SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. Pricing
                _buildGroupedSection(
                  'Pricing',
                  description: 'Set your shipping rates',
                  children: [
                    GestureDetector(
                      onTap: () => controller.inquiryPrice.toggle(),
                      behavior: HitTestBehavior.opaque,
                      child: Row(
                        children: [
                          Checkbox(
                            visualDensity: VisualDensity(horizontal: -4),
                            value: controller.inquiryPrice.value, 
                            onChanged: (val) => controller.inquiryPrice.value = val ?? false,
                            activeColor: AppColors.primary,
                          ),
                          const CommonText('Inquire for Price', fontSize: 14, color: AppColors.textPrimary),
                        ],
                      ),
                    ),
                    if (!controller.inquiryPrice.value) ...[
                      const SizedBox(height: 12),
                      _buildRateField('Base Rate', controller.baseRateController),
                      const SizedBox(height: 16),
                      _buildRateField('Fully Loaded Rate', controller.loadedRateController),
                    ],
                  ],
                ),
                const SizedBox(height: 24),

                // 2. Services Offered
                _buildGroupedSection(
                  'Services Offered',
                  children: [
                    _buildChipSelection(
                      options: controller.serviceOptions,
                      selectedItems: controller.selectedServices,
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // 3. Equipment Summary
                _buildGroupedSection(
                  'Equipment Summary',
                  children: [
                    CommonTextField(
                      label: '',
                      controller: controller.equipmentSummaryController,
                      hintText: 'Briefly describe your equipment and setup (truck, trailer, capacity, etc.)',
                      maxLines: 3,
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // 4. Read-only Data
                _buildReadOnlyField('Location', controller.locationDisplay.value),
                const SizedBox(height: 16),
                _buildReadOnlyField('Years of Experience', controller.experienceDisplay.value),
                const SizedBox(height: 16),
                _buildReadOnlyField('USDOT Number', controller.usdotDisplay.value, isRequired: true),
                const SizedBox(height: 24),

                // 5. Travel Scope
                _buildGroupedSection(
                  'Travel Scope',
                  description: 'Select how you typically operate',
                  children: [
                    _buildChipSelection(
                      options: controller.travelOptions,
                      selectedItems: controller.travelScope,
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // 6. Rig Types
                _buildGroupedSection(
                  'Rig Types',
                  children: [
                    _buildChipSelection(
                      options: controller.rigOptions,
                      selectedItems: controller.rigTypes,
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // 7. Regions Covered
                _buildGroupedSection(
                  'Regions Covered',
                  description: 'Select the regions you regularly service',
                  children: [
                    _buildChipSelection(
                      options: controller.regionOptions,
                      selectedItems: controller.regionsCovered,
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // 8. Operation Type
                _buildGroupedSection(
                  'Operation Type',
                  children: [
                    _buildRadioOption('Independent / Small Operation', 'Independent Small Operation', controller.operationType),
                    const SizedBox(height: 12),
                    _buildRadioOption('Established Shipping Company', 'Established Shipping Company', controller.operationType),
                  ],
                ),
                const SizedBox(height: 24),

                // 9. Driver Credentials
                _buildGroupedSection(
                  'Driver Credentials',
                  children: [
                    GestureDetector(
                      onTap: () => controller.hasCDL.toggle(),
                      behavior: HitTestBehavior.opaque,
                      child: Row(
                        children: [
                          Checkbox(
                            value: controller.hasCDL.value,
                            onChanged: (val) => controller.hasCDL.value = val ?? false,
                            activeColor: const Color(0xFF001149),
                          ),
                          const Expanded(child: CommonText('I have a valid CDL (if required for my rig size)', fontSize: 13)),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    const CommonText('Upload CDL (optional)', fontSize: 14),
                    const SizedBox(height: 8),
                    _buildFileUploadTrigger(
                      target: controller.cdlFile,
                      existingUrl: controller.currentCdlUrl,
                      onTap: () => controller.pickFile(controller.cdlFile),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // 10. Insurance
                _buildGroupedSection(
                  'Insurance',
                  description: 'Active commercial insurance is required. Documentation may be reviewed as part of the approval process.',
                  children: [
                    const CommonText('Upload Document', fontSize: 14),
                    const SizedBox(height: 8),
                    _buildFileUploadTrigger(
                      target: controller.insuranceFile,
                      existingUrl: controller.currentInsuranceUrl,
                      onTap: () => controller.pickFile(controller.insuranceFile),
                    ),
                    const SizedBox(height: 16),
                    CommonTextField(
                      label: 'Expiration date',
                      isRequired: true,
                      controller: controller.insuranceExpiryController,
                      hintText: 'Select Date...',
                      readOnly: true,
                      onTap: () => controller.selectDate(context),
                      prefixIcon: const Icon(Icons.calendar_today_outlined, size: 18),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // 11. Cancellation Policy
                _buildGroupedSection(
                  'Cancellation Policy',
                  description: 'Set your cancellation preference for bookings',
                  children: [
                    _buildDropdownTrigger(
                      value: controller.cancellationPolicy.value,
                      hint: 'Select Cancellation Policy', 
                      onTap: () => _showPolicyBottomSheet(context, controller),
                    ),
                    GestureDetector(
                      onTap: () => controller.isCustomCancellation.toggle(),
                      behavior: HitTestBehavior.opaque,
                      child: Row(
                        children: [
                          Checkbox(
                            value: controller.isCustomCancellation.value, 
                            onChanged: (v) => controller.isCustomCancellation.value = v ?? false, 
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                          ),
                          const CommonText('Custom', fontSize: 14),
                        ],
                      ),
                    ),
                    if (controller.isCustomCancellation.value) ...[
                      const SizedBox(height: 12),
                      CommonTextField(
                        label: '',
                        controller: controller.customCancellationController,
                        hintText: 'Describe your custom cancellation policy...',
                        maxLines: 4,
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 24),

                // 12. Additional Notes
                _buildGroupedSection(
                  'Additional Notes (optional)',
                  description: 'Share any specific preferences, needs, or details that would help us better match you with the right horses, programs, or service providers.',
                  children: [
                    CommonTextField(
                      label: '',
                      controller: controller.additionalNotesController,
                      hintText: 'Write here...',
                      maxLines: 4,
                    ),
                  ],
                ),
                const SizedBox(height: 40),

                // 13. Continue Button
                CommonButton(
                  text: 'Continue',
                  isLoading: controller.isSubmitting.value,
                  onPressed: controller.submitDetails,
                  height: 56,
                  backgroundColor: const Color(0xFF001149),
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        );
      }),
    );
  }

  // ── Helpers ────────────────────────────────────────────────────────────────

  Widget _buildGroupedSection(String title, {String? description, required List<Widget> children}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CommonText(title, fontSize: 16, fontWeight: FontWeight.bold),
          if (description != null) ...[
            const SizedBox(height: 4),
            CommonText(description, fontSize: 12, color: AppColors.textSecondary),
          ],
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }

  Widget _buildRateField(String label, TextEditingController ctrl) {
    return CommonTextField(
      label: label,
      controller: ctrl,
      hintText: 'Enter Price',
      keyboardType: TextInputType.number,
      suffixIcon: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            height: 24,
            width: 1,
            color: AppColors.borderLight,
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 12),
            child: CommonText('/ per mile', color: AppColors.textSecondary, fontSize: 12),
          ),
        ],
      ),
    );
  }


  Widget _buildChipSelection({required List<String> options, required RxList<String> selectedItems}) {
    return Obx(() => Wrap(
      spacing: 8,
      runSpacing: 8,
      children: options.map((opt) {
        final isSelected = selectedItems.contains(opt);
        return GestureDetector(
          onTap: () => isSelected ? selectedItems.remove(opt) : selectedItems.add(opt),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: isSelected ? AppColors.tabBackground : Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: isSelected ? AppColors.primary : AppColors.borderLight),
            ),
            child: CommonText(opt, fontSize: 12, color: isSelected ? AppColors.primary : AppColors.textPrimary),
          ),
        );
      }).toList(),
    ));
  }

  Widget _buildReadOnlyField(String label, String value, {bool isRequired = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            CommonText(label, fontSize: 14, color: AppColors.textPrimary),
            if (isRequired) const CommonText(' *', color: Colors.red),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          decoration: BoxDecoration(
            color: const Color(0xFFF3F4F6),
            borderRadius: BorderRadius.circular(12),
          ),
          child: CommonText(value, fontSize: 14, color: AppColors.textPrimary),
        ),
      ],
    );
  }

  Widget _buildRadioOption(String title, String value, RxString groupValue) {
    return Obx(() {
      final isSelected = groupValue.value == value;
      return GestureDetector(
        onTap: () => groupValue.value = value,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? AppColors.primary : AppColors.borderLight,
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: CommonText(
                  title,
                  fontSize: 16,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  color: isSelected ? AppColors.textPrimary : AppColors.textSecondary,
                ),
              ),
              Icon(
                isSelected ? Icons.radio_button_checked : Icons.radio_button_off,
                color: isSelected ? AppColors.primary : AppColors.borderMedium,
                size: 24,
              ),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildFileUploadTrigger({required Rxn<File> target, RxnString? existingUrl, required VoidCallback onTap}) {
    return Obx(() {
      final hasLocalFile = target.value != null;
      final hasRemoteFile = existingUrl?.value != null && existingUrl!.value!.isNotEmpty;

      return GestureDetector(
        onTap: onTap,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.borderLight, style: BorderStyle.solid),
          ),
          child: Column(
            children: [
              if (hasLocalFile) ...[
                const Icon(Icons.description, color: AppColors.primary, size: 32),
                const SizedBox(height: 8),
                CommonText(target.value!.path.split('/').last, fontSize: 12, overflow: TextOverflow.ellipsis),
              ] else if (hasRemoteFile) ...[
                const Icon(Icons.check_circle, color: Colors.green, size: 32),
                const SizedBox(height: 8),
                const CommonText('Document Uploaded', fontSize: 13, fontWeight: FontWeight.bold),
              ] else ...[
                const Icon(Icons.file_upload_outlined, color: AppColors.textSecondary, size: 32),
                const SizedBox(height: 12),
                RichText(
                  text: const TextSpan(
                    style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
                    children: [
                      TextSpan(text: 'Click to upload', style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold)),
                      TextSpan(text: ' or drag and drop'),
                    ],
                  ),
                ),
                const CommonText('PDF, PNG or JPG (max. 400x400px)', fontSize: 11, color: AppColors.textSecondary),
              ],
            ],
          ),
        ),
      );
    });
  }

  Widget _buildDropdownTrigger({String? value, required String hint, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.borderLight),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            CommonText(value ?? hint, fontSize: 14, color: value != null ? AppColors.textPrimary : AppColors.textSecondary),
            const Icon(Icons.keyboard_arrow_down, color: AppColors.textSecondary),
          ],
        ),
      ),
    );
  }

  void _showPolicyBottomSheet(BuildContext context, ShippingDetailsController controller) {
    showModalBottomSheet(
      context: context,
      builder: (ctx) => Column(
        mainAxisSize: MainAxisSize.min,
        children: controller.cancellationOptions.map((opt) => ListTile(
          title: CommonText(opt),
          onTap: () { controller.cancellationPolicy.value = opt; Navigator.pop(ctx); },
        )).toList(),
      ),
    );
  }
}
