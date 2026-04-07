import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:catch_ride/constant/app_colors.dart';
import 'package:catch_ride/constant/app_text_sizes.dart';
import 'package:catch_ride/widgets/common_button.dart';
import 'package:catch_ride/widgets/common_text.dart';
import 'package:catch_ride/widgets/common_textfield.dart';
import 'package:catch_ride/widgets/common_image_view.dart';
import 'package:catch_ride/controllers/vendor/bodywork/bodywork_details_controller.dart';
import 'package:intl/intl.dart';

class BodyworkDetailsView extends StatelessWidget {
  const BodyworkDetailsView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(BodyworkDetailsController());

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const CommonText(
          'Bodywork Details',
          fontSize: AppTextSizes.size18,
          fontWeight: FontWeight.bold,
          color: AppColors.textPrimary,
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: AppColors.textPrimary, size: 20),
          onPressed: () => Get.back(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildGroupedSection(
              'Bodywork Services',
              description: 'Select all services you provide and are qualified to provide.',
              children: [
                Obx(() => Column(
                  children: controller.services.map((service) => _buildServiceItem(service)).toList(),
                )),
              ],
            ),
            const SizedBox(height: 24),

            _buildGroupedSection(
              'Certification',
              description: 'Upload any relevant certifications or licenses for your services.',
              children: [
                const CommonText('Upload Certificate', fontSize: AppTextSizes.size14, fontWeight: FontWeight.w600),
                const SizedBox(height: 12),
                _buildUploadBox(
                  onTap: controller.pickCertification,
                ),
                Obx(() => Column(
                  children: controller.certifications.asMap().entries.map((entry) => _buildFileItem(
                    file: entry.value,
                    onRemove: () => controller.removeCertification(entry.key),
                  )).toList(),
                )),
              ],
            ),
            const SizedBox(height: 24),

            _buildGroupedSection(
              'Insurance Status',
              description: 'Insurance may be required for certain types of services. Documentation may be reviewed as part of approval.',
              children: [
                Obx(() => Column(
                  children: controller.insuranceOptions.map((opt) => _buildRadioItem(
                    title: opt,
                    isSelected: controller.selectedInsurance.value == opt,
                    onTap: () => controller.selectedInsurance.value = opt,
                  )).toList(),
                )),
                const SizedBox(height: 16),
                if (controller.selectedInsurance.value == 'Carries Insurance') ...[
                  const CommonText('Current Insurance Document', fontSize: AppTextSizes.size14, fontWeight: FontWeight.w600),
                  const SizedBox(height: 12),
                  Obx(() => controller.insuranceDocument.value == null 
                    ? _buildUploadBox(onTap: controller.pickInsuranceDoc)
                    : _buildFileItem(
                        file: controller.insuranceDocument.value!,
                        onRemove: () => controller.insuranceDocument.value = null,
                      )
                  ),
                  const SizedBox(height: 16),
                  _buildSectionHeader('Expiration date', isRequired: true),
                  Obx(() => _buildDatePickerTrigger(
                    value: controller.expirationDate.value != null 
                        ? DateFormat('dd MMM yyyy').format(controller.expirationDate.value!) 
                        : 'Select date',
                    onTap: () => controller.selectExpirationDate(context),
                  )),
                ],
              ],
            ),
            const SizedBox(height: 24),

            _buildGroupedSection(
              'Travel Preferences',
              description: 'Select how far you are willing to travel for services.',
              children: [
                Obx(() => Column(
                  children: controller.travelOptions.map((opt) => _buildCheckItem(
                    title: opt,
                    isSelected: controller.selectedTravel.contains(opt),
                    onTap: () {
                      if (controller.selectedTravel.contains(opt)) {
                        controller.selectedTravel.remove(opt);
                      } else {
                        controller.selectedTravel.add(opt);
                      }
                    },
                  )).toList(),
                )),
              ],
            ),
            const SizedBox(height: 24),

            Obx(() => _buildReadOnlySection('Location', value: controller.location.value.isEmpty ? 'Loading...' : controller.location.value)),
            Obx(() => _buildReadOnlySection('Years of Experience', value: controller.experience.value.isEmpty ? 'Loading...' : controller.experience.value)),
            
            Obx(() => _buildReadOnlyTags('Disciplines', tags: controller.disciplines)),
            Obx(() => _buildReadOnlyTags('Typical Level of Horses', tags: controller.horseLevels)),
            Obx(() => _buildReadOnlyTags('Regions Covered', tags: controller.regionsCovered)),

            _buildGroupedSection(
              'Cancellation Policy',
              description: 'Set your cancellation preference for bookings.',
              children: [
                Obx(() => Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.borderLight),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: controller.selectedCancellationPolicy.value,
                      hint: const CommonText('Select Cancellation Policy', color: AppColors.textSecondary, fontSize: AppTextSizes.size14),
                      isExpanded: true,
                      items: controller.cancellationOptions.map((v) => DropdownMenuItem(value: v, child: CommonText(v))).toList(),
                      onChanged: (val) => controller.selectedCancellationPolicy.value = val,
                    ),
                  ),
                )),
                const SizedBox(height: 12),
                Obx(() => _buildCheckItem(
                  title: 'Custom',
                  isSelected: controller.isCustomPolicy.value,
                  onTap: () => controller.isCustomPolicy.value = !controller.isCustomPolicy.value,
                )),
              ],
            ),
            const SizedBox(height: 32),

            Obx(() => CommonButton(
              text: 'Continue',
              isLoading: controller.isLoading.value,
              onPressed: controller.submitDetails,
              backgroundColor: const Color(0xFF001149),
            )),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildGroupedSection(String title, {String? description, List<Widget> children = const []}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
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
          CommonText(title, fontSize: AppTextSizes.size16, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
          if (description != null) ...[
            const SizedBox(height: 4),
            CommonText(description, fontSize: AppTextSizes.size12, color: AppColors.textSecondary),
          ],
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }

  Widget _buildServiceItem(Map<String, dynamic> service) {
    bool isSelected = service['isSelected'];
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: isSelected ? AppColors.primary : AppColors.borderLight),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                GestureDetector(
                  onTap: () {
                    service['isSelected'] = !isSelected;
                    Get.find<BodyworkDetailsController>().services.refresh();
                  },
                  child: Icon(
                    isSelected ? Icons.check_box : Icons.check_box_outline_blank,
                    color: isSelected ? AppColors.primary : AppColors.borderMedium,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                CommonText(service['name'], fontSize: AppTextSizes.size14, fontWeight: FontWeight.w500),
              ],
            ),
          ),
          if (isSelected) ...[
            const Divider(height: 1),
            Container(
              padding: const EdgeInsets.all(12),
              color: AppColors.lightGray.withOpacity(0.1),
              child: GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                childAspectRatio: 1.8,
                mainAxisSpacing: 8,
                crossAxisSpacing: 8,
                children: (service['rates'] as Map<String, dynamic>).entries.map((e) {
                  return Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.borderLight),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        IntrinsicWidth(
                          child: TextField(
                            onChanged: (val) => service['rates'][e.key] = val,
                            textAlign: TextAlign.center,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              isDense: true,
                              border: InputBorder.none,
                              hintText: '\$ 0.00',
                              hintStyle: TextStyle(fontSize: 14, color: AppColors.accentRed, fontWeight: FontWeight.bold),
                            ),
                            style: const TextStyle(fontSize: 14, color: AppColors.accentRed, fontWeight: FontWeight.bold),
                          ),
                        ),
                        CommonText('${e.key} mins', fontSize: AppTextSizes.size10, color: AppColors.textSecondary),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildUploadBox({required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 24),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.borderLight, style: BorderStyle.none), 
          color: Colors.white,
        ),
        child: Container(
          decoration: BoxDecoration(
             border: Border.all(color: AppColors.borderLight),
             borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(vertical: 24),
          child: Column(
            children: [
              Icon(Icons.cloud_upload_outlined, size: 28, color: AppColors.textSecondary.withOpacity(0.6)),
              const SizedBox(height: 8),
              RichText(
                text: const TextSpan(
                  children: [
                    TextSpan(text: 'Click to upload', style: TextStyle(color: AppColors.linkBlue, fontWeight: FontWeight.bold, fontSize: 12)),
                    TextSpan(text: ' or drag and drop', style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                  ],
                ),
              ),
              const SizedBox(height: 4),
              const CommonText('PNG, JPG or PDF (max. 5MB)', fontSize: 10, color: AppColors.textSecondary),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFileItem({required File file, required VoidCallback onRemove}) {
    String fileName = file.path.split('/').last;
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
          const Icon(Icons.picture_as_pdf, color: AppColors.accentRed, size: 32),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CommonText(fileName, fontSize: 12, fontWeight: FontWeight.w600, maxLines: 1),
                const CommonText('500 KB', fontSize: 10, color: AppColors.textSecondary),
              ],
            ),
          ),
          GestureDetector(
            onTap: onRemove,
            child: const Icon(Icons.delete_outline, color: AppColors.textSecondary, size: 20),
          ),
        ],
      ),
    );
  }

  Widget _buildRadioItem({required String title, required bool isSelected, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: isSelected ? AppColors.primary : AppColors.borderLight),
        ),
        child: Row(
          children: [
            Icon(isSelected ? Icons.radio_button_checked : Icons.radio_button_off, size: 20, color: isSelected ? AppColors.primary : AppColors.borderMedium),
            const SizedBox(width: 12),
            CommonText(title, fontSize: AppTextSizes.size14),
          ],
        ),
      ),
    );
  }

  Widget _buildCheckItem({required String title, required bool isSelected, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: isSelected ? AppColors.primary : AppColors.borderLight),
        ),
        child: Row(
          children: [
            Icon(isSelected ? Icons.check_box : Icons.check_box_outline_blank, size: 20, color: isSelected ? AppColors.primary : AppColors.borderMedium),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CommonText(title, fontSize: AppTextSizes.size14, fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal),
                if (title == 'Local Only') const CommonText('Home base location', fontSize: 10, color: AppColors.textSecondary),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDatePickerTrigger({required String value, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
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
             CommonText(value, fontSize: AppTextSizes.size14, color: value == 'Select date' ? AppColors.textSecondary : AppColors.textPrimary),
             const Icon(Icons.date_range_outlined, color: AppColors.textSecondary, size: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildReadOnlySection(String title, {required String value}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CommonText(title, fontSize: AppTextSizes.size14, fontWeight: FontWeight.w600),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.lightGray.withOpacity(0.5),
            borderRadius: BorderRadius.circular(12),
          ),
          child: CommonText(value, fontSize: AppTextSizes.size14),
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildReadOnlyTags(String title, {required List<String> tags}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildGroupedSection(
          title,
          description: 'Select the $title you most commonly work with.',
          children: [
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: tags.map((tag) => Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.lightGray.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: CommonText(tag, fontSize: 12),
              )).toList(),
            ),
          ],
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildSectionHeader(String title, {bool isRequired = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        children: [
          CommonText(title, fontSize: AppTextSizes.size14, fontWeight: FontWeight.w600),
          if (isRequired) const CommonText(' *', color: AppColors.accentRed),
        ],
      ),
    );
  }
}
