import 'dart:io';
import 'package:catch_ride/constant/app_colors.dart';
import 'package:catch_ride/constant/app_text_sizes.dart';
import 'package:catch_ride/controllers/vendor/insurance/vendor_insurance_controller.dart';
import 'package:catch_ride/widgets/common_button.dart';
import 'package:catch_ride/widgets/common_text.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class VendorInsuranceView extends StatefulWidget {
  const VendorInsuranceView({super.key});

  @override
  State<VendorInsuranceView> createState() => _VendorInsuranceViewState();
}

class _VendorInsuranceViewState extends State<VendorInsuranceView> {
  late VendorInsuranceController controller;

  @override
  void initState() {
    super.initState();
    controller = Get.put(VendorInsuranceController());
  }

  @override
  void dispose() {
    Get.delete<VendorInsuranceController>();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
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
            'Insurance Status',
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
          if (controller.isDataLoading.value) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            );
          }

          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildGroupedSection(
                    'Insurance Status',
                    description: 'Insurance may be required for certain services or venues. Documentation may be reviewed as part of approval.',
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ...controller.insuranceOptions.map((opt) {
                            final isSelected = controller.selectedInsurance.value == opt;
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: GestureDetector(
                                onTap: () => controller.selectedInsurance.value = opt,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                                  decoration: BoxDecoration(
                                    color: AppColors.cardColor,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: isSelected ? AppColors.primary : AppColors.borderLight,
                                      width: isSelected ? 1.5 : 1,
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(
                                        isSelected ? Icons.radio_button_checked : Icons.radio_button_off,
                                        color: isSelected ? AppColors.primary : AppColors.borderLight,
                                        size: 20,
                                      ),
                                      const SizedBox(width: 12),
                                      CommonText(opt, fontSize: AppTextSizes.size14, color: AppColors.textPrimary),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          }).toList(),

                          if (controller.selectedInsurance.value == 'Carries Insurance') ...[
                            const SizedBox(height: 16),
                            const CommonText(
                              'Upload Current Insurance Document',
                              fontSize: AppTextSizes.size14,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                            const SizedBox(height: 12),
                            _buildInsuranceFilePicker(controller),
                            const SizedBox(height: 12),
                            _buildInsuranceFileList(controller),
                            const SizedBox(height: 20),
                            _buildSectionHeader('Expiration date', isRequired: true),
                            _buildBottomTrigger(
                              value: controller.insuranceExpiryStr.value,
                              hint: 'Enter expiration date',
                              onTap: () => controller.pickInsuranceExpiry(context),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 40),

                  CommonButton(
                    text: 'Save Changes',
                    isLoading: controller.isSaving.value,
                    onPressed: () => controller.saveInsuranceChanges(),
                    height: 56,
                    backgroundColor: const Color(0xFF001149),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildSectionHeader(String title, {bool isRequired = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        children: [
          CommonText(
            title,
            fontSize: AppTextSizes.size14,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
          if (isRequired)
            const CommonText(
              ' *',
              fontSize: AppTextSizes.size14,
              color: AppColors.accentRed,
            ),
        ],
      ),
    );
  }

  Widget _buildGroupedSection(String title, {String? description, required List<Widget> children}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderLight),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CommonText(
            title,
            fontSize: AppTextSizes.size18,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
          if (description != null)
            Padding(
              padding: const EdgeInsets.only(top: 8, bottom: 16),
              child: CommonText(
                description,
                fontSize: AppTextSizes.size12,
                color: AppColors.textSecondary,
                height: 1.4,
              ),
            ),
          ...children,
        ],
      ),
    );
  }

  Widget _buildBottomTrigger({String? value, required String hint, required VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: AppColors.cardColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.borderLight),
        ),
        child: Row(
          children: [
            Expanded(
              child: CommonText(
                (value == null || value.isEmpty) ? hint : value,
                fontSize: AppTextSizes.size14,
                color: (value == null || value.isEmpty) ? AppColors.textSecondary : AppColors.textPrimary,
              ),
            ),
            const Icon(
              Icons.calendar_today_outlined,
              color: AppColors.textSecondary,
              size: 18,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInsuranceFilePicker(VendorInsuranceController controller) {
    return GestureDetector(
      onTap: controller.pickInsuranceDocument,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 24),
        decoration: BoxDecoration(
          color: AppColors.cardColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.borderLight),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(color: AppColors.tabBackground, borderRadius: BorderRadius.circular(8)),
              child: const Icon(Icons.cloud_upload_outlined, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 12),
            RichText(
              text: const TextSpan(
                style: TextStyle(fontSize: AppTextSizes.size14, fontFamily: 'Inter'),
                children: [
                  TextSpan(text: 'Click to upload ', style: TextStyle(color: AppColors.linkBlue, fontWeight: FontWeight.bold)),
                  TextSpan(text: 'or drag and drop', style: TextStyle(color: AppColors.textSecondary)),
                ],
              ),
            ),
            const SizedBox(height: 4),
            const CommonText('PNG, JPG or PDF (max. 800x400px)', fontSize: 12, color: AppColors.textSecondary),
          ],
        ),
      ),
    );
  }

  Widget _buildInsuranceFileList(VendorInsuranceController controller) {
    final file = controller.insuranceFile.value;
    final url = controller.insuranceDocumentUrl.value;

    if (file == null && url == null) return const SizedBox.shrink();

    final name = file != null ? file.path.split('/').last : (url != null ? url.split('/').last : 'Insurance.pdf');
    final isPdf = name.toLowerCase().endsWith('.pdf');

    return Container(
      margin: const EdgeInsets.only(top: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(color: AppColors.tabBackground, borderRadius: BorderRadius.circular(8)),
            child: Icon(
              isPdf ? Icons.picture_as_pdf : Icons.image,
              color: isPdf ? AppColors.accentRed : AppColors.primary,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CommonText(
                  name,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                  maxLines: 1,
                ),
                const SizedBox(height: 2),
                CommonText(
                  file != null ? _getFileSize(file) : 'Uploaded Document',
                  fontSize: 11,
                  color: AppColors.textSecondary,
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline, color: AppColors.textSecondary, size: 22),
            onPressed: () {
              controller.insuranceFile.value = null;
              controller.insuranceDocumentUrl.value = null;
              controller.insuranceDocumentName.value = null;
            },
          ),
        ],
      ),
    );
  }

  String _getFileSize(File file) {
    try {
      if (file.existsSync()) {
        return '${(file.lengthSync() / 1024).toStringAsFixed(1)} KB';
      }
    } catch (e) {
      debugPrint('Error getting file size: $e');
    }
    return '...';
  }
}
