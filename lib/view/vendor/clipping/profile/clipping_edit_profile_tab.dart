import 'dart:io';

import 'package:catch_ride/constant/app_colors.dart';
import 'package:catch_ride/constant/app_text_sizes.dart';
import 'package:catch_ride/controllers/vendor/groom/edit_vendor_profile_controller.dart';
import 'package:catch_ride/widgets/common_text.dart';
import 'package:catch_ride/widgets/common_textfield.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:catch_ride/utils/price_formatter.dart';

import 'package:catch_ride/widgets/common_dropdown.dart';
import 'package:catch_ride/widgets/common_suggestion_field.dart';

import '../../../../widgets/common_button.dart';
import '../../../../widgets/common_image_view.dart';

class ClippingEditProfileTab extends StatelessWidget {
  final EditVendorProfileController controller;

  const ClippingEditProfileTab({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildExperienceSection(),
        const SizedBox(height: 20),
        _buildDisciplinesSection(),
        const SizedBox(height: 20),
        _buildHorseLevelSection(),
        const SizedBox(height: 20),
        _buildRegionsCoveredSection(),
        const SizedBox(height: 20),
        _buildSocialMediaSection(),
        const SizedBox(height: 20),
        _buildAddPhotosSection(),
        const SizedBox(height: 20),
        _buildTravelPreferencesSection(context),
        const SizedBox(height: 20),
        _buildExperienceHighlights(),
        const SizedBox(height: 20),
        _buildCancellationPolicySection(),
        const SizedBox(height: 40),
      ],
    );
  }

  Widget _buildCard({required String title, required Widget child}) {
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
          CommonText(title, fontSize: AppTextSizes.size18, fontWeight: FontWeight.bold),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }

  Widget _buildHomeBaseLocation() {
    return _buildCard(
      title: 'Home Base Location',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildFieldLabel('Country', isRequired: true),
          Obx(() {
            final _ = controller.selectedCountryCode.value;
            return CommonDropdown(
              value: controller.countryController.text,
              hint: 'Select Country',
              options: controller.countries,
              onSelected: (val) => controller.onCountrySelected(val),
            );
          }),
          const SizedBox(height: 16),
          
          _buildFieldLabel('State / Province', isRequired: true),
          Obx(() => CommonSuggestionField(
            controller: controller.stateController,
            hint: 'Select State/Province',
            suggestions: controller.states,
            isLoading: controller.isLoadingStates.value,
            onSelected: (val) => controller.onStateSelected(val),
          )),
          const SizedBox(height: 16),
          
          _buildFieldLabel('City', isRequired: true),
          Obx(() => CommonSuggestionField(
            controller: controller.cityController,
            hint: controller.stateController.text.isEmpty ? 'Select state first' : 'Select City',
            suggestions: controller.cities,
            isLoading: controller.isLoadingCities.value,
            onSelected: (val) => controller.onCitySelected(val),
          )),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const CommonText('Select the disciplines you most commonly work with.', fontSize: AppTextSizes.size12, color: AppColors.textSecondary),
          const SizedBox(height: 16),
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

  Widget _buildHorseLevelSection() {
    return _buildCard(
      title: 'Typical Level of Horses',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const CommonText('Select the types of horses you most frequently work with.', fontSize: AppTextSizes.size12, color: AppColors.textSecondary),
          const SizedBox(height: 16),
          Obx(() => Wrap(
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
        ],
      ),
    );
  }


  Widget _buildRegionsCoveredSection() {
    return _buildCard(
      title: 'Regions Covered',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const CommonText('Select the regions you work. Community work in availability details will be added later.', fontSize: AppTextSizes.size12, color: AppColors.textSecondary),
          const SizedBox(height: 16),
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
          Obx(() => Column(
            children: controller.selectedRegions.map((region) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: _buildRemovableTag(region, showRemove: true, onRemove: () => controller.toggleRegion(region)),
            )).toList(),
          )),
        ],
      ),
    );
  }

  Widget _buildSocialMediaSection() {
    return _buildCard(
      title: 'Social Media & Website',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const CommonText('Please include at least one profile for verification.', fontSize: AppTextSizes.size12, color: AppColors.textSecondary),
          const SizedBox(height: 16),
          CommonTextField(label: 'Facebook', hintText: 'facebook.com/yourpage', controller: controller.facebookController),
          const SizedBox(height: 16),
          CommonTextField(label: 'Instagram', hintText: '@yourusername', controller: controller.instagramController),
        ],
      ),
    );
  }

  Widget _buildAddPhotosSection() {
    return _buildCard(
      title: 'Add Photos',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const CommonText('Upload photos to showcase your work and details', fontSize: AppTextSizes.size12, color: AppColors.textSecondary),
          const SizedBox(height: 16),
          Obx(() => Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              ...controller.serviceExistingPhotos['Clipping']!.asMap().entries.map((entry) => _photoBox(
                url: entry.value,
                onRemove: () => controller.removeServiceExistingPhoto('Clipping', entry.key),
              )),
              ...controller.serviceNewPhotos['Clipping']!.asMap().entries.map((entry) => _photoBox(
                file: entry.value,
                onRemove: () => controller.removeServiceNewPhoto('Clipping', entry.key),
              )),
              _addPhotoBox(),
            ],
          )),
        ],
      ),
    );
  }

  Widget _buildCheckItem({
    required String title,
    String? subTitle,
    required bool isSelected,
    required VoidCallback onTap,
    VoidCallback? onEdit,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.borderLight,
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              isSelected ? Icons.check_box : Icons.check_box_outline_blank,
              color: isSelected ? AppColors.primary : AppColors.borderMedium,
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CommonText(
                    title,
                    fontSize: AppTextSizes.size14,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                    color: isSelected ? AppColors.primary : AppColors.textPrimary,
                  ),
                  if (subTitle != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: CommonText(
                        subTitle,
                        fontSize: AppTextSizes.size12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                ],
              ),
            ),
            if (isSelected) 
              GestureDetector(
                onTap: onEdit ?? onTap,
                child: const Icon(Icons.edit_outlined, size: 16, color: AppColors.textSecondary),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildTravelPreferencesSection(BuildContext context) {
    return _buildCard(
      title: 'Travel Preferences',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const CommonText(
            'Select how far you are willing to travel and any applicable fees.',
            fontSize: AppTextSizes.size12,
            color: AppColors.textSecondary,
          ),
          const SizedBox(height: 16),
          Obx(() => Column(
                children:
                    EditVendorProfileController.clippingTravelZoneOptions.map((item) {
                  final isSelected = controller.clippingTravelFees.containsKey(item);
                  final details = controller.clippingTravelFees[item];
                  String? summary;
                  if (isSelected && details != null) {
                    summary = '${details['type']}';
                    if (details['price'].toString().isNotEmpty) summary += ': \$${details['price']}';
                  }

                  return _buildCheckItem(
                    title: item,
                    isSelected: isSelected,
                    subTitle: summary,
                    onTap: () {
                      if (controller.clippingTravelFees.containsKey(item)) {
                        controller.clippingTravelFees.remove(item);
                      } else {
                        _showClippingTravelFeeBottomSheet(context, item);
                      }
                    },
                    onEdit: () {
                      _showClippingTravelFeeBottomSheet(context, item);
                    },
                  );
                }).toList(),
              )),
        ],
      ),
    );
  }

  void _showClippingTravelFeeBottomSheet(BuildContext context, String option) {
    final existing = controller.clippingTravelFees[option] ?? {
      'type': 'No travel fee',
      'price': '',
      'notes': '',
    };

    final RxString selectedFeeType = (existing['type'] as String).obs;
    final priceController = TextEditingController(text: existing['price']);
    final disclaimerController = TextEditingController(text: existing['notes']);

    Get.bottomSheet(
      GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
        child: Container(
          padding: EdgeInsets.fromLTRB(24, 24, 24, 24 + MediaQuery.of(context).viewInsets.bottom),
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
                                  Icon(isSelected ? Icons.radio_button_checked : Icons.radio_button_off, color: isSelected ? AppColors.primary : AppColors.textSecondary),
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
                                  if (type != 'Varies by location')
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
                                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                            inputFormatters: [PriceInputFormatter()],
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
                          controller.updateClippingTravelFee(
                            option,
                            selectedFeeType.value,
                            priceController.text,
                            disclaimerController.text,
                          );
                          Get.back();
                        },
                        backgroundColor: AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCancellationPolicySection() {
    return _buildCard(
      title: 'Cancellation Policy',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const CommonText('Set your cancellation preferences for bookings.', fontSize: AppTextSizes.size12, color: AppColors.textSecondary),
          const SizedBox(height: 16),
          Obx(() => _buildDropdownTrigger(
            value: controller.cancellationPresetForDropdown,
            hint: 'Select Cancellation Policy',
            onTap: () => _showPickerBottomSheet(
              title: 'Cancellation Policy', 
              options: EditVendorProfileController.cancellationPresetOptions,
              onSelected: (val) {
                controller.isCustomCancellation.value = false;
                controller.cancellationPolicy.value = val;
              },
            ),
          )),
          const SizedBox(height: 12),
          Row(
            children: [
              Obx(() => Checkbox(
                value: controller.isCustomCancellation.value,
                onChanged: (val) {
                  final v = val ?? false;
                  controller.isCustomCancellation.value = v;
                  if (v) controller.cancellationPolicy.value = null;
                },
                activeColor: AppColors.primary,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
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

  // Helper Widgets
  Widget _buildChoiceChip(String text, bool isSelected) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: isSelected ? const Color(0xFFF3F4FF) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isSelected ? const Color(0xFF1E1B4B) : AppColors.borderLight,
          width: 1.5,
        ),
      ),
      child: CommonText(
        text,
        fontSize: AppTextSizes.size12,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        color: isSelected ? const Color(0xFF1E1B4B) : AppColors.textSecondary,
      ),
    );
  }

  Widget _buildDropdownTrigger({String? value, required String hint, required VoidCallback? onTap, bool isLoading = false}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.borderLight),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(child: CommonText(value != null && value.isNotEmpty ? value : hint, fontSize: AppTextSizes.size14, color: value != null && value.isNotEmpty ? AppColors.textPrimary : AppColors.textSecondary, overflow: TextOverflow.ellipsis)),
            if (isLoading)
              const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary))
            else
              const Icon(Icons.keyboard_arrow_down, color: AppColors.textSecondary),
          ],
        ),
      ),
    );
  }

  Widget _buildRemovableTag(String text, {bool showRemove = false, VoidCallback? onRemove}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Expanded(child: CommonText(text, fontSize: AppTextSizes.size14, color: AppColors.textPrimary)),
          if (showRemove) ...[
            const SizedBox(width: 8),
            GestureDetector(
              onTap: onRemove,
              child: const Icon(Icons.close, size: 16, color: AppColors.textSecondary),
            ),
          ],
        ],
      ),
    );
  }

  Widget _photoBox({String? url, File? file, required VoidCallback onRemove}) {
    return Stack(
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
    return GestureDetector(
      onTap: () => _showImageSourceBottomSheet(),
      child: Container(
        width: 80,
        height: 80,
        decoration: BoxDecoration(
          color: const Color(0xFFF9FAFB),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.borderLight, style: BorderStyle.none),
        ),
        child: const Icon(Icons.add, color: AppColors.textSecondary, size: 24),
      ),
    );
  }

  // Bottom Sheets
  void _showPickerBottomSheet({required String title, required List<String> options, required Function(String) onSelected}) {
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
              child: Obx(() => ListView.builder(
                shrinkWrap: true,
                itemCount: options.length,
                itemBuilder: (context, index) {
                  final item = options[index];
                  final isSelected = selectedItems.contains(item);
                  return CheckboxListTile(
                    title: CommonText(item),
                    value: isSelected,
                    onChanged: (val) => onToggle(item),
                    activeColor: AppColors.primary,
                  );
                },
              )),
            ),
            const SizedBox(height: 20),
            CommonButton(text: 'Done', onPressed: () => Get.back(), backgroundColor: AppColors.primary),
          ],
        ),
      ),
    );
  }

  void _showImageSourceBottomSheet() {
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
            const CommonText('Select Image Source', fontSize: AppTextSizes.size18, fontWeight: FontWeight.bold),
            const SizedBox(height: 20),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const CommonText('Gallery'),
              onTap: () {
                controller.addServicePhoto('Clipping');
                Get.back();
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showAddClippingServiceBottomSheet() {
    Get.bottomSheet(
      Container(
        padding: EdgeInsets.fromLTRB(24, 24, 24, 24 + Get.mediaQuery.viewInsets.bottom),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const CommonText('Add More Service', fontSize: AppTextSizes.size22, fontWeight: FontWeight.bold),
            const SizedBox(height: 24),
            const CommonText('Skill', fontSize: AppTextSizes.size14, fontWeight: FontWeight.w600),
            const SizedBox(height: 8),
            CommonTextField(
              label: '',
              hintText: 'Enter your skill',
              controller: controller.clippingServiceInputController,
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
                      controller.addClippingService(controller.clippingServiceInputController.text);
                      Get.back();
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
  void _showLocationBottomSheet({
    required String title,
    required List<Map<String, dynamic>> options,
    required Function(Map<String, dynamic>) onSelected,
  }) {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          children: [
            CommonText(title, fontSize: AppTextSizes.size18, fontWeight: FontWeight.bold),
            const SizedBox(height: 20),
            const Divider(),
            Expanded(
              child: ListView.builder(
                itemCount: options.length,
                itemBuilder: (context, index) {
                  final item = options[index];
                  return ListTile(
                    title: CommonText(item['name'] ?? ''),
                    onTap: () {
                      onSelected(item);
                      Get.back();
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFieldLabel(String label, {bool isRequired = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          CommonText(
            label,
            fontSize: AppTextSizes.size14,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
          if (isRequired)
            const CommonText(
              ' *',
              color: Colors.red,
              fontSize: AppTextSizes.size14,
            ),
        ],
      ),
    );
  }

  Widget _buildExperienceHighlights() {
    return _buildCard(
      title: 'Experience Highlights',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const CommonText(
            "Share key experience, programs, or specialties you’d like clients to know",
            fontSize: AppTextSizes.size12,
            color: AppColors.textSecondary,
          ),
          const SizedBox(height: 16),
          Obx(
            () => Column(
              children: controller.highlightControllers.asMap().entries.map((
                entry,
              ) {
                final index = entry.key;
                final ctrl = entry.value;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Row(
                    children: [
                      Expanded(
                        child: CommonTextField(
                          label: '',
                          hintText: 'Write here...',
                          controller: ctrl,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(
                          Icons.remove_circle_outline,
                          color: Colors.grey,
                          size: 20,
                        ),
                        onPressed: () => controller.removeHighlight(index),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 12),
          GestureDetector(
            onTap: controller.addHighlight,
            child: const CommonText(
              '+ Add More',
              color: AppColors.linkBlue,
              fontSize: AppTextSizes.size14,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
