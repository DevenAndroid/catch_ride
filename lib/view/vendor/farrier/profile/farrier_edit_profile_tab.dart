import 'package:catch_ride/constant/app_colors.dart';
import 'package:catch_ride/constant/app_text_sizes.dart';
import 'package:catch_ride/controllers/vendor/groom/edit_vendor_profile_controller.dart';
import 'package:catch_ride/widgets/common_text.dart';
import 'package:catch_ride/widgets/common_textfield.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../widgets/common_button.dart';

class FarrierEditProfileTab extends StatelessWidget {
  final EditVendorProfileController controller;

  const FarrierEditProfileTab({
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
        _buildRegionsCoveredSection(),
        const SizedBox(height: 20),
        _buildSocialMediaSection(),
        const SizedBox(height: 20),
        _buildFarrierCertificationsSection(),
        const SizedBox(height: 20),
        _buildScopeOfWorkSection(),
        const SizedBox(height: 20),
        _buildFarrierServicesSection(),
        const SizedBox(height: 20),
        _buildAddPhotosSection(),
        const SizedBox(height: 20),
        _buildTravelPreferencesSection(),
        const SizedBox(height: 20),
        _buildClientIntakeSection(),
        const SizedBox(height: 20),
        _buildInsuranceSection(),
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
          CommonText(title, fontSize: AppTextSizes.size16, fontWeight: FontWeight.bold),
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

  Widget _buildTypicalLevelSection() {
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

  Widget _buildFarrierCertificationsSection() {
    return _buildCard(
      title: 'Farrier Certifications',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const CommonText('Select your certifications.', fontSize: AppTextSizes.size12, color: AppColors.textSecondary),
          const SizedBox(height: 16),
          Obx(() => Wrap(
            spacing: 8,
            runSpacing: 8,
            children: controller.certificationOptions.map((cert) {
              final isSelected = controller.selectedCertifications.contains(cert);
              return GestureDetector(
                onTap: () {
                  if (isSelected) {
                    controller.selectedCertifications.remove(cert);
                  } else {
                    controller.selectedCertifications.add(cert);
                  }
                },
                child: _buildChoiceChip(cert, isSelected),
              );
            }).toList(),
          )),
          Obx(() {
            if (controller.selectedCertifications.contains('Other')) {
              return Padding(
                padding: const EdgeInsets.only(top: 16),
                child: CommonTextField(label: '', hintText: 'Write here...', controller: controller.otherCertificationController, maxLines: 3),
              );
            }
            return const SizedBox.shrink();
          }),
        ],
      ),
    );
  }

  Widget _buildScopeOfWorkSection() {
    return _buildCard(
      title: 'Scope of Work',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const CommonText('Select your primary focus areas.', fontSize: AppTextSizes.size12, color: AppColors.textSecondary),
          const SizedBox(height: 16),
          Obx(() => Wrap(
            spacing: 8,
            runSpacing: 8,
            children: controller.farrierScopeOptions.map((opt) {
              final isSelected = controller.selectedFarrierScope.contains(opt);
              return GestureDetector(
                onTap: () {
                  if (isSelected) {
                    controller.selectedFarrierScope.remove(opt);
                  } else {
                    controller.selectedFarrierScope.add(opt);
                  }
                },
                child: _buildChoiceChip(opt, isSelected),
              );
            }).toList(),
          )),
          Obx(() {
            if (controller.selectedFarrierScope.contains('Other')) {
              return Padding(
                padding: const EdgeInsets.only(top: 16),
                child: CommonTextField(label: '', hintText: 'Write here...', controller: controller.otherFarrierScopeController, maxLines: 3),
              );
            }
            return const SizedBox.shrink();
          }),
        ],
      ),
    );
  }

  Widget _buildFarrierServicesSection() {
    return _buildCard(
      title: 'Farrier Services & Add-ons',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const CommonText('Farrier Services', fontSize: AppTextSizes.size14, fontWeight: FontWeight.bold),
          const SizedBox(height: 16),
          _buildServicesList(controller.farrierServices),
          const SizedBox(height: 24),
          const CommonText('Add-Ons', fontSize: AppTextSizes.size14, fontWeight: FontWeight.bold),
          const SizedBox(height: 16),
          _buildServicesList(controller.farrierAddOns),
        ],
      ),
    );
  }

  Widget _buildServicesList(RxList services) {
    return Obx(() => Column(
      children: services.asMap().entries.map((entry) {
        final index = entry.key;
        final service = entry.value;
        final isSelected = service['isSelected'].value;

        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected ? const Color(0xFF001149) : AppColors.borderLight,
                width: isSelected ? 1.5 : 1,
              ),
            ),
            child: Row(
              children: [
                Checkbox(
                  value: isSelected,
                  onChanged: (val) => service['isSelected'].value = val ?? false,
                  activeColor: const Color(0xFF001149),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: CommonText(service['name'], fontSize: AppTextSizes.size14, fontWeight: FontWeight.bold),
                ),
                Container(
                  width: 100,
                  height: 44,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF3F4F6),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      const CommonText('\$ ', fontSize: AppTextSizes.size14, color: AppColors.textSecondary),
                      Expanded(
                        child: TextField(
                          controller: service['price'],
                          decoration: const InputDecoration(border: InputBorder.none, isDense: true, contentPadding: EdgeInsets.zero, hintText: '0'),
                          style: const TextStyle(fontSize: AppTextSizes.size14, fontWeight: FontWeight.bold),
                          keyboardType: TextInputType.number,
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    ));
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
              ...controller.serviceExistingPhotos['Farrier']!.asMap().entries.map((entry) => _photoBox(
                image: NetworkImage(entry.value),
                onRemove: () => controller.removeServiceExistingPhoto('Farrier', entry.key),
              )),
              ...controller.serviceNewPhotos['Farrier']!.asMap().entries.map((entry) => _photoBox(
                image: FileImage(entry.value),
                onRemove: () => controller.removeServiceNewPhoto('Farrier', entry.key),
              )),
              _addPhotoBox(),
            ],
          )),
        ],
      ),
    );
  }

  Widget _buildTravelPreferencesSection() {
    return _buildCard(
      title: 'Travel Preferences',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const CommonText('Set your service regions and fees.', fontSize: AppTextSizes.size12, color: AppColors.textSecondary),
          const SizedBox(height: 16),
          Obx(() => Column(
            children: controller.farrierTravelFees.asMap().entries.map((entry) {
              final index = entry.key;
              final t = entry.value;
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.borderLight),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          CommonText(t['category'] ?? 'N/A', fontWeight: FontWeight.bold),
                          IconButton(
                            icon: const Icon(Icons.remove_circle_outline, color: Colors.red, size: 20),
                            onPressed: () => controller.farrierTravelFees.removeAt(index),
                          ),
                        ],
                      ),
                      CommonText('${t['type']} - \$ ${t['price']}', fontSize: AppTextSizes.size12, color: AppColors.textSecondary),
                    ],
                  ),
                ),
              );
            }).toList(),
          )),
          const SizedBox(height: 12),
          GestureDetector(
            onTap: () => _showAddTravelFeeBottomSheet(),
            child: Row(
              children: const [
                Icon(Icons.add, size: 18, color: AppColors.linkBlue),
                SizedBox(width: 4),
                CommonText('Add Service Region', color: AppColors.linkBlue, fontWeight: FontWeight.bold, fontSize: AppTextSizes.size14),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildClientIntakeSection() {
    return _buildCard(
      title: 'Client Intake & Scheduling',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const CommonText('New Client Policy', fontSize: AppTextSizes.size14, fontWeight: FontWeight.w600),
          const SizedBox(height: 12),
          Obx(() => _buildDropdownTrigger(
            value: controller.farrierNewClientPolicy.value,
            hint: 'Select Policy',
            onTap: () => _showPickerBottomSheet(
              title: 'New Client Policy',
              options: ['Accepting new clients', 'Not accepting new clients', 'Referral only'],
              onSelected: (val) => controller.farrierNewClientPolicy.value = val,
            ),
          )),
          const SizedBox(height: 20),
          CommonTextField(
            label: 'Minimum horses per barn',
            hintText: 'e.g. 1',
            controller: controller.farrierMinHorsesController,
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const CommonText('Emergency Support', fontSize: AppTextSizes.size14, fontWeight: FontWeight.w600),
              Obx(() => Switch(
                value: controller.farrierEmergencySupport.value,
                onChanged: (val) => controller.farrierEmergencySupport.value = val,
                activeColor: AppColors.secondary,
              )),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInsuranceSection() {
    return _buildCard(
      title: 'Professional Status',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const CommonText('Insurance Status', fontSize: AppTextSizes.size14, fontWeight: FontWeight.w600),
          const SizedBox(height: 12),
          Obx(() => _buildDropdownTrigger(
            value: controller.farrierInsuranceStatus.value,
            hint: 'Select Status',
            onTap: () => _showPickerBottomSheet(
              title: 'Insurance Status',
              options: ['I have professional liability insurance', 'I do not have professional liability insurance', 'Not applicable'],
              onSelected: (val) => controller.farrierInsuranceStatus.value = val,
            ),
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
          const CommonText('Set your cancellation preferences.', fontSize: AppTextSizes.size12, color: AppColors.textSecondary),
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

  Widget _buildDropdownTrigger({String? value, required String hint, required VoidCallback onTap}) {
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
            CommonText(value ?? hint, fontSize: AppTextSizes.size14, color: value != null ? AppColors.textPrimary : AppColors.textSecondary),
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

  Widget _photoBox({required ImageProvider image, required VoidCallback onRemove}) {
    return Stack(
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            image: DecorationImage(image: image, fit: BoxFit.cover),
          ),
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
                controller.addServicePhoto('Farrier');
                Get.back();
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showAddTravelFeeBottomSheet() {
    final categoryCtrl = TextEditingController();
    final priceCtrl = TextEditingController();
    String selectedType = 'Flat Fee';

    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CommonText('Add Travel Fee', fontSize: AppTextSizes.size20, fontWeight: FontWeight.bold),
            const SizedBox(height: 20),
            CommonTextField(label: 'Category Name', hintText: 'e.g. Local (within 10 miles)', controller: categoryCtrl),
            const SizedBox(height: 16),
            const CommonText('Fee Type', fontSize: AppTextSizes.size14, fontWeight: FontWeight.w600),
            const SizedBox(height: 8),
            StatefulBuilder(
              builder: (context, setState) => DropdownButtonFormField<String>(
                value: selectedType,
                items: ['Flat Fee', 'Per Mile', 'No Fee', 'Call for Quote'].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                onChanged: (v) => setState(() => selectedType = v!),
                decoration: InputDecoration(
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.borderLight)),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
              ),
            ),
            const SizedBox(height: 16),
            CommonTextField(label: 'Price', hintText: '0', controller: priceCtrl, keyboardType: TextInputType.number),
            const SizedBox(height: 30),
            CommonButton(
              text: 'Add',
              onPressed: () {
                controller.farrierTravelFees.add({
                  'category': categoryCtrl.text,
                  'type': selectedType,
                  'price': priceCtrl.text,
                  'disclaimer': '',
                });
                Get.back();
              },
            ),
          ],
        ),
      ),
    );
  }
}
