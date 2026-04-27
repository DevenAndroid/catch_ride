import 'dart:io';
import 'package:catch_ride/constant/app_colors.dart';
import 'package:catch_ride/constant/app_text_sizes.dart';
import 'package:catch_ride/controllers/vendor/groom/edit_vendor_profile_controller.dart';
import 'package:catch_ride/widgets/common_text.dart';
import 'package:catch_ride/widgets/common_textfield.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../widgets/common_button.dart';
import '../../../../widgets/common_image_view.dart';
import '../../../../widgets/common_dropdown.dart';
import '../../../../widgets/common_suggestion_field.dart';

class ShippingEditProfileTab extends StatelessWidget {
  final EditVendorProfileController controller;

  const ShippingEditProfileTab({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildHomeBaseLocation(),
        const SizedBox(height: 20),
        _buildBusinessInformation(),
        const SizedBox(height: 20),
        _buildExperienceSection(),
        const SizedBox(height: 20),
        _buildOperationTypeSection(),
        const SizedBox(height: 20),
        _buildTravelScopeSection(),
        const SizedBox(height: 20),
        _buildRegionsCoveredSection(),
        const SizedBox(height: 20),
        _buildRigTypesSection(),
        const SizedBox(height: 20),
        _buildStallTypeSection(),
        const SizedBox(height: 20),
        _buildServicesOfferedSection(),
        const SizedBox(height: 20),
        _buildDriverCredentialsSection(),
        const SizedBox(height: 20),
        _buildHorseCapacitySection(),
        const SizedBox(height: 20),
        _buildSocialMediaSection(),
        const SizedBox(height: 20),
        _buildAddPhotosSection(),
        const SizedBox(height: 20),
        _buildCancellationPolicySection(),
        const SizedBox(height: 20),
        _buildAdditionalNotesSection(),
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
          Obx(() => CommonDropdown(
            value: controller.countryController.text,
            hint: 'Select Country',
            options: controller.countries,
            onSelected: (val) => controller.onCountrySelected(val),
          )),
          const SizedBox(height: 16),
          _buildFieldLabel('State/Province', isRequired: true),
          Obx(() => CommonSuggestionField(
            controller: controller.stateController,
            isLoading: controller.isLoadingStates.value,
            hint: 'Select state/province',
            suggestions: controller.states,
            onSelected: (node) => controller.onStateSelected(node),
          )),
          const SizedBox(height: 16),
          _buildFieldLabel('City', isRequired: true),
          Obx(() => CommonSuggestionField(
            controller: controller.cityController,
            isLoading: controller.isLoadingCities.value,
            hint: controller.stateController.text.isEmpty ? 'Select state first' : 'Select city',
            suggestions: controller.cities,
            onSelected: (node) => controller.onCitySelected(node),
          )),
        ],
      ),
    );
  }

  Widget _buildBusinessInformation() {
    return _buildCard(
      title: 'Business Information',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CommonTextField(
            label: 'Legal Business Name',
            hintText: 'Enter Legal Name',
            isRequired: true,
            controller: controller.businessNameController,
          ),
          const SizedBox(height: 16),
          CommonTextField(
            label: 'USDOT Number',
            hintText: 'Enter USDOT Number',
            isRequired: true,
            controller: controller.dotNumberController,
          ),
        ],
      ),
    );
  }

  Widget _buildExperienceSection() {
    return _buildCard(
      title: 'Experience',
      child: Obx(() => _buildDropdownTrigger(
        value: controller.experience.value != null ? '${controller.experience.value} Years' : null,
        hint: 'Select years of experience',
        onTap: () => _showPickerBottomSheet(
          title: 'Experience (Years)',
          options: controller.experienceOptions.map((e) => '$e Years').toList(),
          onSelected: (val) => controller.experience.value = val.replaceAll(' Years', '')
        ),
      )),
    );
  }

  Widget _buildOperationTypeSection() {
    return _buildCard(
      title: 'Operation Type',
      child: Obx(() {
        return Column(
          children: [
            _buildSelectionTile(
              title: 'Independent / Small Operation',
              isSelected: controller.shippingOperationType.value == 'Independent / Small Operation',
              onTap: () => controller.shippingOperationType.value = 'Independent / Small Operation',
            ),
            const SizedBox(height: 12),
            _buildSelectionTile(
              title: 'Established Shipping Company',
              isSelected: controller.shippingOperationType.value == 'Established Shipping Company',
              onTap: () => controller.shippingOperationType.value = 'Established Shipping Company',
            ),
          ],
        );
      }),
    );
  }

  Widget _buildTravelScopeSection() {
    return _buildCard(
      title: 'Travel Scope',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const CommonText('Select range you typically cover', fontSize: AppTextSizes.size12, color: AppColors.textSecondary),
          const SizedBox(height: 16),
          Obx(() {
            return Wrap(
              spacing: 8,
              runSpacing: 8,
              children: ['Local', 'Nationwide'].map((opt) {
                final isSelected = controller.shippingTravelScope.contains(opt);
                return GestureDetector(
                  onTap: () {
                    if (isSelected) {
                      controller.shippingTravelScope.remove(opt);
                    } else {
                      controller.shippingTravelScope.add(opt);
                    }
                  },
                  child: _buildChoiceChip(opt, isSelected),
                );
              }).toList(),
            );
          }),
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
          const CommonText('Select the regions you work.', fontSize: AppTextSizes.size12, color: AppColors.textSecondary),
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

  Widget _buildRigTypesSection() {
    return _buildCard(
      title: 'Rig Types',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const CommonText('Select types of equipment you operate', fontSize: AppTextSizes.size12, color: AppColors.textSecondary),
          const SizedBox(height: 16),
          Obx(() {
            final options = controller.shippingRigTypeOptions.isNotEmpty
                ? controller.shippingRigTypeOptions
                : ['Gooseneck', 'Box Truck', 'Semi', 'Other'];

            return Wrap(
              spacing: 8,
              runSpacing: 8,
              children: options.map((opt) {
                final isSelected = controller.shippingRigTypes.contains(opt);
                return GestureDetector(
                  onTap: () {
                    if (isSelected) {
                      controller.shippingRigTypes.remove(opt);
                    } else {
                      controller.shippingRigTypes.add(opt);
                    }
                  },
                  child: _buildChoiceChip(opt, isSelected),
                );
              }).toList(),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildStallTypeSection() {
    return _buildCard(
      title: 'Stall Type',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const CommonText('Select the types of stalls available', fontSize: AppTextSizes.size12, color: AppColors.textSecondary),
          const SizedBox(height: 16),
          Obx(() {
            final options = controller.shippingStallOptions.isNotEmpty
                ? controller.shippingStallOptions
                : ['Box Stall', 'Slant Load', 'Front Facing', 'Rear Facing'];

            return Wrap(
              spacing: 8,
              runSpacing: 8,
              children: options.map((opt) {
                final isSelected = controller.shippingStallTypes.contains(opt);
                return GestureDetector(
                  onTap: () {
                    if (isSelected) {
                      controller.shippingStallTypes.remove(opt);
                    } else {
                      controller.shippingStallTypes.add(opt);
                    }
                  },
                  child: _buildChoiceChip(opt, isSelected),
                );
              }).toList(),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildServicesOfferedSection() {
    return _buildCard(
      title: 'Services Offered',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const CommonText('Select additional services provided', fontSize: AppTextSizes.size12, color: AppColors.textSecondary),
          const SizedBox(height: 16),
          Obx(() {
            final options = controller.shippingServicesOptions.isNotEmpty
                ? controller.shippingServicesOptions
                : [
                    'Long distance transport',
                    'Hay Hauling',
                    'Box-at-a-time transport',
                    'Clippers / unbranded equipment',
                    'Day of event / night support'
                  ];

            return Wrap(
              spacing: 8,
              runSpacing: 8,
              children: options.map((opt) {
                final isSelected = controller.shippingServicesOffered.contains(opt);
                return GestureDetector(
                  onTap: () {
                    if (isSelected) {
                      controller.shippingServicesOffered.remove(opt);
                    } else {
                      controller.shippingServicesOffered.add(opt);
                    }
                  },
                  child: _buildChoiceChip(opt, isSelected),
                );
              }).toList(),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildDriverCredentialsSection() {
    return _buildCard(
      title: 'Driver Credentials',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Obx(() => Checkbox(
                value: controller.shippingHasCDL.value,
                onChanged: (val) => controller.shippingHasCDL.value = val ?? false,
                activeColor: const Color(0xFF001149),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
              )),
              const Expanded(
                child: CommonText(
                  'I have a valid CDL/DLI for the equipment I operate.',
                  fontSize: AppTextSizes.size12,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          GestureDetector(
            onTap: controller.pickShippingCDLFile,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 24),
              decoration: BoxDecoration(
                color: const Color(0xFFF9FAFB),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.borderLight, style: BorderStyle.none),
              ),
              child: Column(
                children: [
                  Obx(() {
                    final hasFile = controller.shippingCDLFile.value != null || (controller.shippingExistingCDLUrl.value != null && controller.shippingExistingCDLUrl.value!.isNotEmpty);
                    return Icon(
                      hasFile ? Icons.check_circle : Icons.cloud_upload_outlined,
                      color: hasFile ? Colors.green : AppColors.textSecondary,
                      size: 32,
                    );
                  }),
                  const SizedBox(height: 8),
                  Obx(() {
                    String text = 'Click to upload copy of license';
                    if (controller.shippingCDLFile.value != null) {
                      text = controller.shippingCDLFile.value!.path.split('/').last;
                    } else if (controller.shippingExistingCDLUrl.value != null && controller.shippingExistingCDLUrl.value!.isNotEmpty) {
                      text = 'License copy uploaded';
                    }
                    return CommonText(
                      text,
                      color: AppColors.linkBlue,
                      fontSize: AppTextSizes.size14,
                      fontWeight: FontWeight.bold,
                    );
                  }),
                  const SizedBox(height: 4),
                  const CommonText('PDF, JPG, PNG (max 10MB)', fontSize: 10, color: AppColors.textSecondary),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHorseCapacitySection() {
    return _buildCard(
      title: 'Horse Capacity',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const CommonText('Max Horses', fontSize: AppTextSizes.size12, color: AppColors.textSecondary),
          const SizedBox(height: 16),
          Obx(() => Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                onPressed: () => controller.shippingRigCapacity.value > 1 ? controller.shippingRigCapacity.value-- : null,
                icon: const Icon(Icons.remove_circle_outline, color: AppColors.borderMedium),
              ),
              CommonText('${controller.shippingRigCapacity.value}', fontSize: 18, fontWeight: FontWeight.bold),
              IconButton(
                onPressed: () => controller.shippingRigCapacity.value++,
                icon: const Icon(Icons.add_circle_outline, color: AppColors.borderMedium),
              ),
            ],
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
              ...controller.shippingRigPhotos.asMap().entries.map((entry) => _photoBox(
                url: entry.value,
                onRemove: () => controller.removeExistingShippingRigPhoto(entry.key),
              )),
              ...controller.newShippingRigPhotos.asMap().entries.map((entry) => _photoBox(
                file: entry.value,
                onRemove: () => controller.removeNewShippingRigPhoto(entry.key),
              )),
              _addPhotoBox(),
            ],
          )),
        ],
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

  Widget _buildAdditionalNotesSection() {
    return _buildCard(
      title: 'Additional Notes (optional)',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const CommonText('Share key experience, programs, or specialties you\'d like clients to know', fontSize: AppTextSizes.size12, color: AppColors.textSecondary),
          const SizedBox(height: 16),
          CommonTextField(
            label: '',
            hintText: 'Share here...',
            maxLines: 4,
            controller: controller.shippingNotesController,
          ),
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

  Widget _buildSelectionTile({required String title, required bool isSelected, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? const Color(0xFF001149) : AppColors.borderLight,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Expanded(child: CommonText(title, fontSize: AppTextSizes.size14, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal)),
            if (isSelected) const Icon(Icons.check_circle, color: Color(0xFF001149), size: 20)
            else const Icon(Icons.radio_button_off, color: AppColors.borderMedium, size: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildDropdownTrigger({
    String? value,
    required String hint,
    VoidCallback? onTap,
    bool isLoading = false,
  }) {
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
            Expanded(
              child: CommonText(
                value != null && value.isNotEmpty ? value : hint,
                fontSize: AppTextSizes.size14,
                color: value != null && value.isNotEmpty ? AppColors.textPrimary : AppColors.textSecondary,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (isLoading)
              const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
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
      clipBehavior: Clip.none,
      children: [
        CommonImageView(
          url: url,
          file: file,
          width: 80,
          height: 80,
          radius: 12,
          fit: BoxFit.cover,
        ),
        Positioned(
          top: -4,
          right: -4,
          child: GestureDetector(
            onTap: onRemove,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 4,
                  ),
                ],
              ),
              child: const Icon(
                Icons.close,
                size: 14,
                color: Colors.red,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _addPhotoBox() {
    return GestureDetector(
      onTap: () => controller.addShippingRigPhoto(),
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

  Widget _buildFieldLabel(String label, {bool isRequired = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          CommonText(label,                 fontSize: AppTextSizes.size14,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,),
          if (isRequired)
            const CommonText(' *', fontSize: AppTextSizes.size14, color: Colors.red),
        ],
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
          mainAxisSize: MainAxisSize.min,
          children: [
            CommonText(title, fontSize: AppTextSizes.size18, fontWeight: FontWeight.bold),
            const SizedBox(height: 20),
            Flexible(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: options.length,
                itemBuilder: (context, index) {
                  final node = options[index];
                  return ListTile(
                    title: CommonText(node['name'] ?? ''),
                    onTap: () {
                      onSelected(node);
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

  // Picker Bottom Sheet
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
}
