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

    return GestureDetector(
      behavior: HitTestBehavior.opaque, // ensures taps are detected on empty space
      onTap: () {
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: Scaffold(
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
                  Obx(() {
                    if (controller.isLoadingServices.value) {
                      return const Center(
                        child: Padding(
                          padding: EdgeInsets.symmetric(vertical: 20),
                          child: CircularProgressIndicator(),
                        ),
                      );
                    }
                    return Column(
                      children: controller.services.map((service) => _buildServiceItem(service)).toList(),
                    );
                  }),
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
                    children: [
                      ...controller.certificationUrls.asMap().entries.map((entry) => _buildFileItem(
                        url: entry.value,
                        onRemove: () => controller.certificationUrls.removeAt(entry.key),
                      )),
                      ...controller.certifications.asMap().entries.map((entry) => _buildFileItem(
                        file: entry.value,
                        onRemove: () => controller.removeCertification(entry.key),
                      )),
                    ],
                  )),
                ],
              ),
              const SizedBox(height: 24),

              _buildGroupedSection(
                'Insurance Status',
                description: 'Insurance may be required for certain services or venues. Documentation may be reviewed as part of approval',
                children: [
                  Obx(() => Column(
                    children: controller.insuranceOptions.map((opt) => _buildRadioItem(
                      title: opt,
                      isSelected: controller.selectedInsurance.value == opt,
                      onTap: () => controller.selectedInsurance.value = opt,
                    )).toList(),
                  )),
                  const SizedBox(height: 16),
                  Obx(() {
                    if (controller.selectedInsurance.value == 'Carries Insurance') {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const CommonText('Current Insurance Document', fontSize: AppTextSizes.size14, fontWeight: FontWeight.w600),
                          const SizedBox(height: 12),
                          if (controller.insuranceDocument.value == null && controller.insuranceDocumentUrl.value == null)
                            _buildUploadBox(onTap: controller.pickInsuranceDoc)
                          else
                            _buildFileItem(
                              file: controller.insuranceDocument.value,
                              url: controller.insuranceDocumentUrl.value,
                              onRemove: () {
                                controller.insuranceDocument.value = null;
                                controller.insuranceDocumentUrl.value = null;
                                controller.insuranceDocumentName.value = null;
                              },
                            ),
                          const SizedBox(height: 16),
                          _buildSectionHeader('Expiration date', isRequired: true),
                          _buildDatePickerTrigger(
                            value: controller.expirationDate.value != null
                                ? DateFormat('dd MMM yyyy').format(controller.expirationDate.value!)
                                : 'Select date',
                            onTap: () => controller.selectExpirationDate(context),
                          ),
                        ],
                      );
                    }
                    return const SizedBox.shrink();
                  }),
                ],
              ),
              const SizedBox(height: 24),

              _buildGroupedSection(
                'Travel Preferences',
                description: 'Select how far you are willing to travel for services.',
                children: [
                  Obx(() => Column(
                    children: controller.travelOptions.map((opt) {
                      final details = controller.selectedTravel[opt];
                      String? summary;
                      if (details != null) {
                        summary = '${details['feeType']}';
                        if (details['price'].toString().isNotEmpty) summary += ': \$${details['price']}';
                      }
                      return _buildCheckItem(
                        title: opt,
                        isSelected: controller.selectedTravel.containsKey(opt),
                        subTitle: summary,
                        onTap: () {
                          if (controller.selectedTravel.containsKey(opt)) {
                            controller.selectedTravel.remove(opt);
                          } else {
                            _showTravelPreferenceBottomSheet(opt);
                          }
                        },
                      );
                    }).toList(),
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
                  Obx(() => Row(
                    children: [
                      Checkbox(
                        value: controller.isCustomPolicy.value,
                        onChanged: (val) => controller.isCustomPolicy.value = val ?? false,
                        activeColor: const Color(0xFF001149),
                        side: const BorderSide(color: AppColors.borderMedium, width: 1.5),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                      ),
                      const CommonText('Custom', fontSize: AppTextSizes.size14, fontWeight: FontWeight.w500),
                    ],
                  )),
                  Obx(() {
                    if (controller.isCustomPolicy.value) {
                      return Padding(
                        padding: const EdgeInsets.only(top: 12),
                        child: CommonTextField(
                          label: '',
                          controller: controller.customCancellationController,
                          hintText: 'Enter your custom cancellation policy details...',
                          maxLines: 3,
                        ),
                      );
                    }
                    return const SizedBox.shrink();
                  }),
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
                Expanded(child: CommonText(service['name'], fontSize: AppTextSizes.size14, fontWeight: FontWeight.w500)),
                if (isSelected)
                  GestureDetector(
                    onTap: () => _showServicePriceBottomSheet(service),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const CommonText('Configure Rates', fontSize: 10, color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ),
              ],
            ),
          ),
          if (isSelected) ...[
            const Divider(height: 1),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              color: AppColors.lightGray.withOpacity(0.1),
              child: _buildRatesSummary(service['rates']),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildRatesSummary(Map<String, dynamic> rates) {
    List<MapEntry<String, dynamic>> activeRates = rates.entries.where((e) => e.value.toString().isNotEmpty).toList();

    if (activeRates.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 8),
        child: CommonText('No rates configured. Tap to configure.', fontSize: 12, color: AppColors.textSecondary, fontStyle: FontStyle.italic),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: AppColors.lightPink.withAlpha(70),
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: List.generate(activeRates.length * 2 - 1, (index) {
          if (index.isOdd) {
            return Container(width: 1, height: 24, color: AppColors.borderLight);
          }
          final e = activeRates[index ~/ 2];
          return Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                 CommonText('\$ ${e.value}', fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.accentRed),
                 const SizedBox(height: 4),
                 CommonText('${e.key} mins', fontSize: 12, color: AppColors.textSecondary),
              ],
            ),
          );
        }),
      ),
    );
  }

  void _showServicePriceBottomSheet(Map<String, dynamic> service) {
    final controller = Get.find<BodyworkDetailsController>();
    // Clone data for editing
    final editingRates = Map<String, String>.from(service['rates']);
    final editingNote = TextEditingController(text: service['note'] ?? '');
    final RxnString trainerPresence = RxnString(service['trainerPresence']);
    final RxnString vetApproval = RxnString(service['vetApproval']);

    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2)))),
              const SizedBox(height: 24),
              CommonText(service['name'], fontSize: AppTextSizes.size20, fontWeight: FontWeight.bold),
              const SizedBox(height: 24),
              
              const CommonText('Session Length & Price', fontSize: AppTextSizes.size14, fontWeight: FontWeight.bold),
              const SizedBox(height: 16),
              ...['30', '45', '60', '90'].map((mins) {
                final hasValue = editingRates[mins] != null && editingRates[mins]!.isNotEmpty;
                final RxBool isChecked = (hasValue).obs;
                final textController = TextEditingController(text: editingRates[mins]);

                return Column(
                  children: [
                    Obx(() => Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF9FAFB),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: isChecked.value ? AppColors.primary : Colors.transparent),
                      ),
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              GestureDetector(
                                onTap: () => isChecked.value = !isChecked.value,
                                child: Icon(isChecked.value ? Icons.check_box : Icons.check_box_outline_blank, color: isChecked.value ? const Color(0xFF001149) : Colors.grey),
                              ),
                              const SizedBox(width: 12),
                              CommonText('$mins minutes', fontSize: 14, fontWeight: FontWeight.w500),
                            ],
                          ),
                          if (isChecked.value) ...[
                            const SizedBox(height: 12),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: AppColors.borderLight),
                              ),
                              child: Row(
                                children: [
                                  const CommonText('\$', fontSize: 14, color: AppColors.textSecondary),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: TextField(
                                      controller: textController,
                                      keyboardType: TextInputType.number,
                                      onChanged: (val) => editingRates[mins] = val,
                                      decoration: const InputDecoration(hintText: 'Enter price', border: InputBorder.none, hintStyle: TextStyle(fontSize: 14)),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ],
                      ),
                    )),
                  ],
                );
              }).toList(),

              const SizedBox(height: 16),
              const CommonText('Note', fontSize: AppTextSizes.size14, fontWeight: FontWeight.bold),
              const SizedBox(height: 8),
              CommonTextField(label: '', hintText: 'Write here...', controller: editingNote, maxLines: 3),

              const SizedBox(height: 16),
              const CommonText('Trainer Presence', fontSize: AppTextSizes.size14, fontWeight: FontWeight.bold),
              const SizedBox(height: 8),
              Obx(() => _buildDropdown(
                value: trainerPresence.value,
                hint: 'Select Trainer Preference',
                options: ['Required', 'Preferred', 'Not Required'],
                onChanged: (val) => trainerPresence.value = val,
              )),

              const SizedBox(height: 16),
              const CommonText('Vet approval', fontSize: AppTextSizes.size14, fontWeight: FontWeight.bold),
              const SizedBox(height: 8),
              Obx(() => _buildDropdown(
                value: vetApproval.value,
                hint: 'Select Vet Preference',
                options: ['Required', 'Sometimes Required', 'Not Required'],
                onChanged: (val) => vetApproval.value = val,
              )),

              const SizedBox(height: 32),
              Row(
                children: [
                  Expanded(
                    child: CommonButton(
                      text: 'Cancel',
                      onPressed: () => Get.back(),
                      backgroundColor: Colors.white,
                      textColor: AppColors.textPrimary,
                      borderColor: AppColors.borderLight,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: CommonButton(
                      text: 'Save',
                      onPressed: () {
                        // Clear rates for unchecked items
                        editingRates.forEach((key, value) {
                          // This logic depends on editingRates being updated in TextField onChanged
                        });
                        
                        service['rates'] = editingRates;
                        service['note'] = editingNote.text;
                        service['trainerPresence'] = trainerPresence.value;
                        service['vetApproval'] = vetApproval.value;
                        controller.services.refresh();
                        Get.back();
                      },
                      backgroundColor: const Color(0xFF001149),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
      isScrollControlled: true,
    );
  }

  Widget _buildDropdown({String? value, required String hint, required List<String> options, required Function(String) onChanged}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          hint: CommonText(hint, color: AppColors.textSecondary, fontSize: 14),
          isExpanded: true,
          items: options.map((v) => DropdownMenuItem(value: v, child: CommonText(v))).toList(),
          onChanged: (val) { if (val != null) onChanged(val); },
        ),
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

  Widget _buildFileItem({File? file, String? url, required VoidCallback onRemove}) {
    String fileName = file != null ? file.path.split('/').last : (url != null ? url.split('/').last : 'Insurance.pdf');
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
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFFFEE2E2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                const Icon(Icons.description, color: Color(0xFFEF4444), size: 32),
                Positioned(
                  bottom: 2,
                   child: Container(
                     padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 0),
                     color: const Color(0xFFEF4444),
                     child: const Text('PDF', style: TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.bold)),
                   ),
                )
              ],
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CommonText(fileName, fontSize: 13, fontWeight: FontWeight.w600, maxLines: 1),
                const SizedBox(height: 2),
                CommonText(file != null ? _getFileSize(file) : '...', fontSize: 11, color: AppColors.textSecondary),
              ],
            ),
          ),
          GestureDetector(
            onTap: onRemove,
            child: const Icon(Icons.delete_outline, color: AppColors.textSecondary, size: 22),
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

  Widget _buildCheckItem({required String title, String? subTitle, required bool isSelected, required VoidCallback onTap}) {
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
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CommonText(title, fontSize: AppTextSizes.size14, fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal),
                  if (subTitle != null) CommonText(subTitle, fontSize: 10, color: AppColors.textSecondary),
                  if (title == 'Local Only' && subTitle == null) const CommonText('Home base location', fontSize: 10, color: AppColors.textSecondary),
                ],
              ),
            ),
            if (isSelected) 
              GestureDetector(
                onTap: onTap, // Opening sheet again
                child: const Icon(Icons.edit_outlined, size: 16, color: AppColors.textSecondary),
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

  void _showTravelPreferenceBottomSheet(String option) {
    final controller = Get.find<BodyworkDetailsController>();
    final existing = controller.selectedTravel[option] ?? {
      'feeType': 'No travel fee',
      'price': '',
      'disclaimer': '',
    };

    final RxString selectedFeeType = (existing['feeType'] as String).obs;
    final priceController = TextEditingController(text: existing['price']);
    final disclaimerController = TextEditingController(text: existing['disclaimer']);

    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2)))),
              const SizedBox(height: 24),
              CommonText(option, fontSize: AppTextSizes.size20, fontWeight: FontWeight.bold),
              const SizedBox(height: 24),

              ...['No travel fee', 'Flat fee', 'Per-mile', 'Varies by location'].map((type) {
                return Obx(() {
                  bool isSelected = selectedFeeType.value == type;
                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      color: isSelected && type == 'Varies by location' ? const Color(0xFFF9FAFB) : Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: isSelected ? AppColors.primary : AppColors.borderLight),
                    ),
                    child: Column(
                      children: [
                        GestureDetector(
                          onTap: () => selectedFeeType.value = type,
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Row(
                              children: [
                                Icon(isSelected ? Icons.radio_button_checked : Icons.radio_button_off, color: isSelected ? const Color(0xFF001149) : Colors.grey),
                                const SizedBox(width: 12),
                                CommonText(type, fontSize: 14, fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal),
                              ],
                            ),
                          ),
                        ),
                        if (isSelected && (type == 'Flat fee' || type == 'Per-mile' || type == 'Varies by location')) ...[
                          Padding(
                            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                            child: Column(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(color: AppColors.borderLight),
                                  ),
                                  child: Row(
                                    children: [
                                      const CommonText('\$', fontSize: 14, color: AppColors.textSecondary),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: TextField(
                                          controller: priceController,
                                          keyboardType: TextInputType.number,
                                          decoration: const InputDecoration(hintText: 'Enter price', border: InputBorder.none, hintStyle: TextStyle(fontSize: 14)),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                if (type == 'Varies by location') ...[
                                  const SizedBox(height: 12),
                                  CommonTextField(label: '', hintText: 'Disclaimer', controller: disclaimerController, maxLines: 3),
                                ],
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  );
                });
              }).toList(),

              const SizedBox(height: 32),
              Row(
                children: [
                  Expanded(
                    child: CommonButton(
                      text: 'Cancel',
                      onPressed: () => Get.back(),
                      backgroundColor: Colors.white,
                      textColor: AppColors.textPrimary,
                      borderColor: AppColors.borderLight,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: CommonButton(
                      text: 'Save',
                      onPressed: () {
                        controller.selectedTravel[option] = {
                          'feeType': selectedFeeType.value,
                          'price': priceController.text,
                          'disclaimer': disclaimerController.text,
                        };
                        controller.selectedTravel.refresh();
                        Get.back();
                      },
                      backgroundColor: const Color(0xFF001149),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
      isScrollControlled: true,
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
