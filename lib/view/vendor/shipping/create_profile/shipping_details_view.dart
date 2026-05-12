import 'dart:io';
import 'package:catch_ride/constant/app_colors.dart';
import 'package:catch_ride/constant/app_text_sizes.dart';
import 'package:catch_ride/controllers/vendor/shipping/shipping_details_controller.dart';
import 'package:catch_ride/widgets/common_button.dart';
import 'package:catch_ride/widgets/common_text.dart';
import 'package:catch_ride/widgets/common_textfield.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:catch_ride/utils/price_formatter.dart';
import 'package:url_launcher/url_launcher.dart';

class ShippingDetailsView extends StatelessWidget {
  const ShippingDetailsView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ShippingDetailsController());

    return GestureDetector(
      behavior: HitTestBehavior.opaque, // ensures taps are detected on empty space
      onTap: () {
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: Scaffold(
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

                  // 4. Summary Data (Editable)
                  _buildSummaryItem('Location', controller.locationDisplay.value),
                  const SizedBox(height: 16),
                  _buildEditableExperience(controller),
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

                  // 6b. Stall Type
                  _buildGroupedSection(
                    'Stall Type',
                    description: 'Select the types of stalls available',
                    children: [
                      _buildChipSelection(
                        options: controller.stallOptions,
                        selectedItems: controller.stallTypes,
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
                      Obx(() {
                        if (controller.operationOptions.isEmpty) {
                          return const Center(child: CircularProgressIndicator());
                        }
                        
                        // Set default if not set
                        if (controller.operationType.value.isEmpty && controller.operationOptions.isNotEmpty) {
                          Future.delayed(Duration.zero, () {
                            controller.operationType.value = controller.operationOptions.first;
                          });
                        }

                        return Column(
                          children: controller.operationOptions.map((opt) {
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: _buildRadioOption(opt, opt, controller.operationType),
                            );
                          }).toList(),
                        );
                      }),
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
                              activeColor: AppColors.primary,
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
                        existingFileName: controller.currentCdlFileName,
                        onTap: () => controller.pickFile(controller.cdlFile),
                        onClear: () {
                          controller.currentCdlUrl.value = null;
                          controller.currentCdlFileName.value = null;
                          controller.cdlFile.value = null;
                        },
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
                        existingFileName: controller.currentInsuranceFileName,
                        onTap: () => controller.pickFile(controller.insuranceFile),
                        onClear: () {
                          controller.currentInsuranceUrl.value = null;
                          controller.currentInsuranceFileName.value = null;
                          controller.insuranceFile.value = null;
                        },
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
                        value: controller.cancellationPresetForDropdown,
                        hint: 'Select Cancellation Policy',
                        onTap: () => _showPolicyBottomSheet(context, controller),
                      ),
                      GestureDetector(
                        onTap: () => controller.toggleCustomCancellation(),
                        behavior: HitTestBehavior.opaque,
                        child: Row(
                          children: [
                            Checkbox(
                              value: controller.isCustomCancellation.value,
                              onChanged: (v) =>
                                  controller.setCustomCancellation(v ?? false),
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
                    backgroundColor: AppColors.primaryDark,
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          );
        }),
      ),
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
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      inputFormatters: [PriceInputFormatter()],
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
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.borderLight),
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

  Widget _buildFileUploadTrigger({
    required Rxn<File> target,
    RxnString? existingUrl,
    RxnString? existingFileName,
    required VoidCallback onTap,
    required VoidCallback onClear,
  }) {
    return Obx(() {
      final hasLocalFile = target.value != null;
      final hasRemoteFile =
          existingUrl?.value != null && existingUrl!.value!.isNotEmpty;

      if (hasLocalFile || hasRemoteFile) {
        final fileName = hasLocalFile
            ? target.value!.path.split('/').last
            : (existingFileName?.value ?? 'Document');

        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.primary.withOpacity(0.3)),
            color: AppColors.primary.withOpacity(0.05),
          ),
          child: Row(
            children: [
              const Icon(Icons.description, color: AppColors.primary, size: 28),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CommonText(
                      fileName,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (hasRemoteFile && !hasLocalFile)
                      GestureDetector(
                        onTap: () => _launchURL(existingUrl!.value!),
                        child: const CommonText(
                          'View Document',
                          fontSize: 12,
                          color: Colors.blue,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.cancel, color: Colors.red, size: 20),
                onPressed: onClear,
              ),
            ],
          ),
        );
      }

      return GestureDetector(
        onTap: onTap,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: AppColors.borderLight,
              style: BorderStyle.solid,
            ),
          ),
          child: Column(
            children: [
              const Icon(
                Icons.file_upload_outlined,
                color: AppColors.textSecondary,
                size: 32,
              ),
              const SizedBox(height: 12),
              RichText(
                text: const TextSpan(
                  style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
                  children: [
                    TextSpan(
                      text: 'Click to upload',
                      style: TextStyle(
                        color: Colors.blue,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextSpan(text: ' or drag and drop'),
                  ],
                ),
              ),
              const CommonText(
                'PDF, PNG or JPG (max. 10MB)',
                fontSize: 11,
                color: AppColors.textSecondary,
              ),
            ],
          ),
        ),
      );
    });
  }

  Future<void> _launchURL(String url) async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      Get.snackbar('Error', 'Could not launch URL');
    }
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
          onTap: () {
            controller.setCustomCancellation(false);
            controller.cancellationPolicy.value = opt;
            Navigator.pop(ctx);
          },
        )).toList(),
      ),
    );
  }

  Widget _buildSummaryItem(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CommonText(label, fontSize: 14, color: AppColors.textPrimary),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.borderLight),
          ),
          child: CommonText(value, fontSize: 14, color: AppColors.textPrimary),
        ),
      ],
    );
  }

  Widget _buildEditableExperience(ShippingDetailsController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const CommonText('Years of Experience', fontSize: 14, color: AppColors.textPrimary),
        const SizedBox(height: 8),
        Obx(() => GestureDetector(
          onTap: () => _showPickerBottomSheet(
            title: 'Experience',
            currentValue: controller.experienceDisplay.value,
            options: controller.experienceOptions,
            onSelected: (val) => controller.experienceDisplay.value = val,
          ),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.borderLight),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: CommonText(controller.experienceDisplay.value ?? 'Select years of experience', fontSize: 14, color: controller.experienceDisplay.value == null ? AppColors.textSecondary : AppColors.textPrimary),
                ),
                const Icon(Icons.keyboard_arrow_down, color: AppColors.textSecondary, size: 20),
              ],
            ),
          ),
        )),
      ],
    );
  }

  void _showPickerBottomSheet({required String title, String? currentValue, required List<String> options, required Function(String) onSelected}) {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CommonText(title, fontSize: 20, fontWeight: FontWeight.bold),
            const SizedBox(height: 24),
            ...options.map((opt) {
              final isSelected = opt == currentValue;
              return ListTile(
                title: Center(child: CommonText(opt, color: isSelected ? AppColors.primary : AppColors.textPrimary, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal)),
                onTap: () {
                  onSelected(opt);
                  Get.back();
                },
              );
            }),
          ],
        ),
      ),
    );
  }
}
