import 'dart:io';

import 'package:catch_ride/constant/app_colors.dart';
import 'package:catch_ride/constant/app_text_sizes.dart';
import 'package:catch_ride/controllers/vendor/groom/edit_vendor_profile_controller.dart';
import 'package:catch_ride/widgets/common_button.dart';
import 'package:catch_ride/widgets/common_image_view.dart';
import 'package:catch_ride/widgets/common_text.dart';
import 'package:catch_ride/widgets/common_textfield.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:catch_ride/utils/price_formatter.dart';
import 'package:intl/intl.dart';

class BodyworkEditProfileTab extends StatelessWidget {
  final EditVendorProfileController controller;

  const BodyworkEditProfileTab({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildHomeBaseLocation(),
        const SizedBox(height: 20),
        _buildExperienceSection(),
        const SizedBox(height: 20),
        _buildDisciplinesSection(),
        const SizedBox(height: 20),
        _buildTypicalLevelSection(),
        const SizedBox(height: 20),
        _buildModalitySection(),
        const SizedBox(height: 20),
        _buildRegionsCoveredSection(),
        const SizedBox(height: 20),
        _buildSocialMediaSection(),
        const SizedBox(height: 20),
        _buildCertificationSection(),
        const SizedBox(height: 20),
        _buildAddPhotosSection(),
        const SizedBox(height: 20),
        _buildTravelPreferencesSection(),
        const SizedBox(height: 20),
        _buildProfessionalStandardsSection(),
        const SizedBox(height: 20),
        _buildCancellationPolicySection(),
        const SizedBox(height: 40),
      ],
    );
  }

  Widget _buildCard({required String title, String? description, required Widget child}) {
    return Container(
      width: double.infinity,
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
          CommonText(title, fontSize: AppTextSizes.size16, fontWeight: FontWeight.bold),
          if (description != null) ...[
            const SizedBox(height: 4),
            CommonText(description, fontSize: AppTextSizes.size12, color: AppColors.textSecondary),
          ],
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }

  Widget _buildHomeBaseLocation() {
    return _buildCard(
      title: 'Home Base / Location',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CommonTextField(label: 'Country', hintText: 'Select Country', isRequired: true, controller: controller.countryController),
          const SizedBox(height: 16),
          CommonTextField(label: 'State / Province', hintText: 'Select state / province', isRequired: true, controller: controller.stateController),
          const SizedBox(height: 16),
          CommonTextField(label: 'City', hintText: 'Select city', controller: controller.cityController),
        ],
      ),
    );
  }

  Widget _buildExperienceSection() {
    return _buildCard(
      title: 'Experience',
      child: Obx(() => _buildDropdownTrigger(
        value: controller.experience.value != null ? '${controller.experience.value} Years' : null,
        hint: 'Select Years of Experience',
        onTap: () => _showPickerBottomSheet(
          title: 'Experience (Years)', 
          options: controller.experienceOptions.map((e) => '$e Years').toList(), 
          onSelected: (val) => controller.experience.value = val.replaceAll(' Years', '')
        ),
      )),
    );
  }

  Widget _buildDisciplinesSection() {
    return _buildCard(
      title: 'Disciplines',
      description: 'Select the disciplines you most commonly work with.',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Obx(() => Wrap(
            spacing: 8,
            runSpacing: 8,
            children: controller.disciplineOptions.map((disc) {
              final isSelected = controller.selectedDisciplines.contains(disc);
              return GestureDetector(
                onTap: () => controller.toggleDiscipline(disc),
                child: _buildChoiceChip(disc, isSelected),
              );
            }).toList(),
          )),
          Obx(() {
            if (controller.selectedDisciplines.contains('Other')) {
              return Padding(
                padding: const EdgeInsets.only(top: 16),
                child: CommonTextField(label: '', hintText: 'Write here...', controller: controller.otherDisciplineController, maxLines: 3),
              );
            }
            return const SizedBox.shrink();
          }),
        ],
      ),
    );
  }

  Widget _buildTypicalLevelSection() {
    return _buildCard(
      title: 'Typical Level of Horses',
      description: 'Select the colors of horses you most frequently work with.',
      child: Obx(() => Wrap(
        spacing: 8,
        runSpacing: 8,
        children: controller.horseLevelOptions.map((level) {
          final isSelected = controller.selectedHorseLevels.contains(level);
          return GestureDetector(
            onTap: () => controller.toggleHorseLevel(level),
            child: _buildChoiceChip(level, isSelected),
          );
        }).toList(),
      )),
    );
  }

  Widget _buildModalitySection() {
    return _buildCard(
      title: 'Modality offered',
      description: 'Select all modalities you are certified and qualified to provide.',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Obx(() => Wrap(
            spacing: 8,
            runSpacing: 8,
            children: controller.bodyworkServices.map((service) {
              final isSelected = service['isSelected'].value;
              return GestureDetector(
                onTap: () {
                  service['isSelected'].value = !isSelected;
                },
                child: _buildChoiceChip(service['name'], isSelected),
              );
            }).toList(),
          )),
          Obx(() {
            final hasOther = controller.bodyworkServices.any((s) => s['isSelected'].value && s['name'] == 'Other');
            if (hasOther) {
              return Padding(
                padding: const EdgeInsets.only(top: 16),
                child: CommonTextField(
                  label: '',
                  hintText: 'Write here...',
                  controller: controller.otherModalityController,
                  maxLines: 3,
                ),
              );
            }
            return const SizedBox.shrink();
          }),
        ],
      ),
    );
  }



  void _showServicePriceBottomSheet(Map service) {
    final Map rates = service['rates'];
    final editingNote = TextEditingController(text: service['note'] ?? '');
    final RxnString trainerPresence = RxnString(service['trainerPresence']);
    final RxnString vetApproval = RxnString(service['vetApproval']);

    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(30))),
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
                final textController = TextEditingController(text: rates[mins] ?? '');
                final RxBool isChecked = (rates[mins] != null && rates[mins]!.toString().isNotEmpty).obs;

                return Obx(() => Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(color: const Color(0xFFF9FAFB), borderRadius: BorderRadius.circular(16), border: Border.all(color: isChecked.value ? AppColors.primary : Colors.transparent)),
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          GestureDetector(onTap: () => isChecked.value = !isChecked.value, child: Icon(isChecked.value ? Icons.check_box : Icons.check_box_outline_blank, color: isChecked.value ? const Color(0xFF001149) : Colors.grey)),
                          const SizedBox(width: 12),
                          CommonText('$mins minutes', fontSize: 14, fontWeight: FontWeight.w500),
                        ],
                      ),
                      if (isChecked.value) ...[
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.borderLight)),
                          child: Row(
                            children: [
                              const CommonText('\$', fontSize: 14, color: AppColors.textSecondary),
                              const SizedBox(width: 8),
                              Expanded(child: TextField(controller: textController, keyboardType: const TextInputType.numberWithOptions(decimal: true), inputFormatters: [PriceInputFormatter()], onChanged: (val) => rates[mins] = val, decoration: const InputDecoration(hintText: 'Enter price', border: InputBorder.none, hintStyle: TextStyle(fontSize: 14)))),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ));
              }).toList(),

              const SizedBox(height: 16),
              const CommonText('Note', fontSize: AppTextSizes.size14, fontWeight: FontWeight.bold),
              const SizedBox(height: 8),
              CommonTextField(label: '', hintText: 'Write here...', controller: editingNote, maxLines: 3),

              const SizedBox(height: 16),
              const CommonText('Trainer Presence', fontSize: AppTextSizes.size14, fontWeight: FontWeight.bold),
              const SizedBox(height: 8),
              Obx(() => _buildDropdown(value: trainerPresence.value, hint: 'Select Trainer Preference', options: ['Required', 'Preferred', 'Not Required'], onChanged: (val) => trainerPresence.value = val)),

              const SizedBox(height: 16),
              const CommonText('Vet approval', fontSize: AppTextSizes.size14, fontWeight: FontWeight.bold),
              const SizedBox(height: 8),
              Obx(() => _buildDropdown(value: vetApproval.value, hint: 'Select Vet Preference', options: ['Required', 'Sometimes Required', 'Not Required'], onChanged: (val) => vetApproval.value = val)),

              const SizedBox(height: 32),
              Row(
                children: [
                  Expanded(child: CommonButton(text: 'Cancel', onPressed: () => Get.back(), backgroundColor: Colors.white, textColor: AppColors.textPrimary, borderColor: AppColors.borderLight)),
                  const SizedBox(width: 16),
                  Expanded(child: CommonButton(text: 'Save', onPressed: () {
                    service['note'] = editingNote.text;
                    service['trainerPresence'] = trainerPresence.value;
                    service['vetApproval'] = vetApproval.value;
                    controller.bodyworkServices.refresh();
                    Get.back();
                  }, backgroundColor: const Color(0xFF001149))),
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
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.borderLight)),
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

  Widget _buildTravelPreferencesSection() {
    return _buildCard(
      title: 'Travel Preferences',
      child: Obx(() => Column(
        children: controller.travelOptions.map((opt) {
          final details = controller.selectedTravelData[opt];
          String? summary;
          if (details != null) {
            summary = '${details['feeType']}';
            if (details['price'].toString().isNotEmpty) summary += ': \$${details['price']}';
          }
          return _buildCheckItem(
            title: opt,
            isSelected: controller.selectedTravelData.containsKey(opt),
            subTitle: summary,
            onTap: () {
              if (controller.selectedTravelData.containsKey(opt)) {
                controller.selectedTravelData.remove(opt);
              } else {
                _showTravelPreferenceBottomSheet(opt);
              }
            },
          );
        }).toList(),
      )),
    );
  }

  void _showTravelPreferenceBottomSheet(String option) {
    final existing = controller.selectedTravelData[option] ?? {'feeType': 'No travel fee', 'price': '', 'disclaimer': ''};
    final RxString selectedFeeType = (existing['feeType'] as String).obs;
    final priceController = TextEditingController(text: existing['price']);
    final disclaimerController = TextEditingController(text: existing['disclaimer']);

    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(30))),
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
                    decoration: BoxDecoration(color: isSelected && type == 'Varies by location' ? const Color(0xFFF9FAFB) : Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: isSelected ? AppColors.primary : AppColors.borderLight)),
                    child: Column(
                      children: [
                        GestureDetector(
                          onTap: () => selectedFeeType.value = type,
                          child: Padding(padding: const EdgeInsets.all(16), child: Row(children: [Icon(isSelected ? Icons.radio_button_checked : Icons.radio_button_off, color: isSelected ? const Color(0xFF001149) : Colors.grey), const SizedBox(width: 12), CommonText(type, fontSize: 14, fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal)])),
                        ),
                        if (isSelected && (type == 'Flat fee' || type == 'Per-mile' || type == 'Varies by location')) ...[
                          Padding(
                            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                            child: Column(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12),
                                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.borderLight)),
                                  child: Row(children: [const CommonText('\$', fontSize: 14, color: AppColors.textSecondary), const SizedBox(width: 8), Expanded(child: TextField(controller: priceController, keyboardType: const TextInputType.numberWithOptions(decimal: true), inputFormatters: [PriceInputFormatter()], decoration: const InputDecoration(hintText: 'Enter price', border: InputBorder.none, hintStyle: TextStyle(fontSize: 14))))]),
                                ),
                                if (type == 'Varies by location') ...[const SizedBox(height: 12), CommonTextField(label: '', hintText: 'Disclaimer', controller: disclaimerController, maxLines: 3)],
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
              Row(children: [Expanded(child: CommonButton(text: 'Cancel', onPressed: () => Get.back(), backgroundColor: Colors.white, textColor: AppColors.textPrimary, borderColor: AppColors.borderLight)), const SizedBox(width: 16), Expanded(child: CommonButton(text: 'Save', onPressed: () {
                controller.selectedTravelData[option] = {'feeType': selectedFeeType.value, 'price': priceController.text, 'disclaimer': disclaimerController.text};
                controller.selectedTravelData.refresh();
                Get.back();
              }, backgroundColor: const Color(0xFF001149)))]),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
      isScrollControlled: true,
    );
  }

  // Helper Widgets
  Widget _buildChoiceChip(String text, bool isSelected) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(color: isSelected ? const Color(0xFFF3F4FF) : Colors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: isSelected ? const Color(0xFF1E1B4B) : AppColors.borderLight, width: 1.5)),
      child: CommonText(text, fontSize: AppTextSizes.size12, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal, color: isSelected ? const Color(0xFF1E1B4B) : AppColors.textSecondary),
    );
  }

  Widget _buildDropdownTrigger({String? value, required String hint, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.borderLight)),
        child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [CommonText(value ?? hint, fontSize: AppTextSizes.size14, color: value != null ? AppColors.textPrimary : AppColors.textSecondary), const Icon(Icons.keyboard_arrow_down, color: AppColors.textSecondary)]),
      ),
    );
  }

  Widget _buildRemovableTag(String text, {bool showRemove = false, VoidCallback? onRemove}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(color: const Color(0xFFF9FAFB), borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.borderLight)),
      child: Row(mainAxisSize: MainAxisSize.min, children: [Flexible(child: CommonText(text, fontSize: AppTextSizes.size12, color: AppColors.textPrimary, overflow: TextOverflow.ellipsis, maxLines: 1)), if (showRemove) ...[const SizedBox(width: 8), GestureDetector(onTap: onRemove, child: const Icon(Icons.close, size: 14, color: AppColors.textSecondary))]]),
    );
  }

  Widget _buildCheckItem({required String title, String? subTitle, required bool isSelected, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: isSelected ? AppColors.primary : AppColors.borderLight)),
        child: Row(children: [Icon(isSelected ? Icons.check_box : Icons.check_box_outline_blank, size: 20, color: isSelected ? AppColors.primary : AppColors.borderMedium), const SizedBox(width: 12), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [CommonText(title, fontSize: AppTextSizes.size14, fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal), if (subTitle != null) CommonText(subTitle, fontSize: 10, color: AppColors.textSecondary)]))]),
      ),
    );
  }

  Widget _photoBox({String? url, File? file, required VoidCallback onRemove}) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        CommonImageView(
          url: url,
          file: file,
          width: 80,
          height: 80,
          radius: 12,
        ),
        Positioned(
          top: -4,
          right: -4,
          child: GestureDetector(
            onTap: onRemove,
            child: Container(
              padding: const EdgeInsets.all(2),
              decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
              child: const Icon(Icons.close, size: 14, color: Colors.white),
            ),
          ),
        ),
      ],
    );
  }

  Widget _addPhotoBox() {
    return GestureDetector(onTap: () => controller.addServicePhoto('Bodywork'), child: Container(width: 80, height: 80, decoration: BoxDecoration(color: const Color(0xFFF9FAFB), borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.borderLight, style: BorderStyle.none)), child: const Icon(Icons.add, color: AppColors.textSecondary, size: 24)));
  }

  Widget _buildUploadBox({required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 24),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.borderLight), 
          color: Colors.white,
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFFF9FAFB),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.borderLight),
              ),
              child: const Icon(Icons.cloud_upload_outlined, size: 24, color: AppColors.textPrimary),
            ),
            const SizedBox(height: 12),
            RichText(
              text: const TextSpan(
                children: [
                  TextSpan(text: 'Click to upload', style: TextStyle(color: Color(0xFF2563EB), fontWeight: FontWeight.bold, fontSize: 14)),
                  TextSpan(text: ' or drag and drop', style: TextStyle(color: AppColors.textSecondary, fontSize: 14)),
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

  Widget _buildFileItem({File? file, String? url, required VoidCallback onRemove}) {
    String fileName = file != null ? file.path.split('/').last : (url != null ? url.split('/').last : 'Certification.pdf');
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
              color: const Color(0xFFF9FAFB),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                const Icon(Icons.description_outlined, color: Color(0xFFEF4444), size: 32),
                Positioned(
                  bottom: -2,
                   child: Container(
                     padding: const EdgeInsets.symmetric(horizontal: 2),
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
                CommonText(fileName, fontSize: 14, fontWeight: FontWeight.w600, maxLines: 1),
/*                const SizedBox(height: 4),
                Row(
                  children: [
                    CommonText(file != null ? _getFileSize(file) : 'Uploaded', fontSize: 12, color: AppColors.textSecondary),
                    const SizedBox(width: 8),
                    const Icon(Icons.cloud_upload_outlined, size: 14, color: AppColors.textSecondary),
                    const SizedBox(width: 4),
                    const CommonText('70%', fontSize: 11, color: AppColors.textSecondary), // Progress placeholder as seen in UI
                  ],
                ),*/
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

  String _getFileSize(File file) {
    try {
      if (file.existsSync()) {
        double bytes = file.lengthSync().toDouble();
        if (bytes < 1024) return '$bytes B';
        if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
        return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
      }
    } catch (e) {
      debugPrint('Error getting file size: $e');
    }
    return '...';
  }


  Widget _buildRegionsCoveredSection() {
    return _buildCard(
      title: 'Regions Covered',
      description: 'Select the regions you most commonly work with.',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildDropdownTrigger(
            hint: 'Select Regions...',
            onTap: () => _showMultiSelectBottomSheet(
              title: 'Select Regions',
              options: controller.regionOptions,
              selectedItems: controller.selectedRegions,
              onToggle: (v) => controller.toggleRegion(v),
            ),
          ),
          const SizedBox(height: 16),
          Obx(() => Wrap(
            spacing: 8,
            runSpacing: 8,
            children: controller.selectedRegions.map((region) => _buildRemovableTag(region, showRemove: true, onRemove: () => controller.toggleRegion(region))).toList(),
          )),
        ],
      ),
    );
  }

  Widget _buildSocialMediaSection() {
    return _buildCard(
      title: 'Social Media & Website',
      description: 'Please include at least one profile for verification.',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CommonTextField(label: 'Facebook', hintText: 'facebook.com/yourpage', controller: controller.facebookController),
          const SizedBox(height: 16),
          CommonTextField(label: 'Instagram', hintText: '@yourusername', controller: controller.instagramController),
        ],
      ),
    );
  }

  Widget _buildCertificationSection() {
    return _buildCard(
      title: 'Certification',
      description: 'Upload any relevant certifications or licenses for your services',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const CommonText('Upload Certificate', fontSize: AppTextSizes.size14, fontWeight: FontWeight.w600),
          const SizedBox(height: 12),
          _buildUploadBox(onTap: () => controller.pickBodyworkCertification()),
          Obx(() => Column(
            children: [
              ...controller.bodyworkExistingCertUrls.asMap().entries.map((entry) => _buildFileItem(
                url: entry.value,
                onRemove: () => controller.removeBodyworkExistingCert(entry.key),
              )),
              ...controller.bodyworkCertFiles.asMap().entries.map((entry) => _buildFileItem(
                file: entry.value,
                onRemove: () => controller.removeBodyworkCertFile(entry.key),
              )),
            ],
          )),
        ],
      ),
    );
  }

  Widget _buildAddPhotosSection() {
    return _buildCard(
      title: 'Add Photos',
      description: 'Upload photos to showcase your work and details.',
      child: Obx(() => Wrap(
        spacing: 12,
        runSpacing: 12,
        children: [
          ...controller.serviceExistingPhotos['Bodywork']!.asMap().entries.map((entry) => _photoBox(
            url: entry.value,
            onRemove: () => controller.removeServiceExistingPhoto('Bodywork', entry.key),
          )),
          ...controller.serviceNewPhotos['Bodywork']!.asMap().entries.map((entry) => _photoBox(
            file: entry.value,
            onRemove: () => controller.removeServiceNewPhoto('Bodywork', entry.key),
          )),
          _addPhotoBox(),
        ],
      )),
    );
  }

  Widget _buildProfessionalStandardsSection() {
    return _buildCard(
      title: 'Professional Standards & Scope',
      description: 'Catch Ride members are held to a high standard of care and professionalism. Please confirm the following for your profile:',
      child: Obx(() => Column(
        children: controller.bodyworkProfessionalStandards.map((std) {
          final isSelected = controller.selectedBodyworkStandards.contains(std);
          return _buildCheckItem(
            title: std,
            isSelected: isSelected,
            onTap: () {
              if (isSelected) {
                controller.selectedBodyworkStandards.remove(std);
              } else {
                controller.selectedBodyworkStandards.add(std);
              }
            },
          );
        }).toList(),
      )),
    );
  }

  Widget _buildCancellationPolicySection() {
    return _buildCard(
      title: 'Cancellation Policy',
      description: 'Set your cancellation preferences.',
      child: Column(
        children: [
          Obx(() => _buildDropdownTrigger(
            value: controller.cancellationPolicy.value,
            hint: 'Select Cancellation Policy',
            onTap: () => _showPickerBottomSheet(
              title: 'Cancellation Policy', 
              options: ['Flexible (24+ hrs)', 'Moderate (48+ hrs)', 'Strict (72+ hrs)'], 
              onSelected: (val) => controller.cancellationPolicy.value = val
            ),
          )),
          const SizedBox(height: 12),
          Row(
            children: [
              Obx(() => Checkbox(
                value: controller.isCustomCancellation.value,
                onChanged: (val) => controller.isCustomCancellation.value = val ?? false,
                activeColor: AppColors.primary,
              )),
              const CommonText('Custom', fontSize: AppTextSizes.size14, fontWeight: FontWeight.w500),
            ],
          ),
          Obx(() {
            if (controller.isCustomCancellation.value) {
              return Padding(
                padding: const EdgeInsets.only(top: 8),
                child: CommonTextField(label: '', hintText: 'Write here...', controller: controller.customCancellationController, maxLines: 4),
              );
            }
            return const SizedBox.shrink();
          }),
        ],
      ),
    );
  }

  void _showMultiSelectBottomSheet({required String title, required List<String> options, required List<String> selectedItems, required Function(String) onToggle}) {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CommonText(title, fontSize: AppTextSizes.size18, fontWeight: FontWeight.bold),
            const SizedBox(height: 20),
            Flexible(
              child: Obx(() => ListView(
                shrinkWrap: true,
                children: options.map((item) {
                  final isSelected = selectedItems.contains(item);
                  return CheckboxListTile(
                    title: CommonText(item),
                    value: isSelected,
                    onChanged: (val) => onToggle(item),
                    activeColor: AppColors.primary,
                  );
                }).toList(),
              )),
            ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: SizedBox(
                width: double.infinity,
                child: CommonButton(
                  text: 'Done',
                  onPressed: () => Get.back(),
                ),
              ),
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
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.borderLight)),
        child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [CommonText(value, fontSize: AppTextSizes.size14, color: value.contains('Date') ? AppColors.textSecondary : AppColors.textPrimary), const Icon(Icons.calendar_today, color: AppColors.textSecondary, size: 18)]),
      ),
    );
  }

  void _showPickerBottomSheet({required String title, required List<String> options, required Function(String) onSelected}) {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CommonText(title, fontSize: AppTextSizes.size18, fontWeight: FontWeight.bold),
            const SizedBox(height: 20),
            Flexible(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: options.length,
                itemBuilder: (context, index) => ListTile(
                  title: CommonText(options[index], textAlign: TextAlign.center),
                  onTap: () {
                    onSelected(options[index]);
                    Get.back();
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _selectDate(Rxn<DateTime> dateRx) async {
    final DateTime? picked = await showDatePicker(context: Get.context!, initialDate: dateRx.value ?? DateTime.now(), firstDate: DateTime.now(), lastDate: DateTime(2100));
    if (picked != null) dateRx.value = picked;
  }
}
