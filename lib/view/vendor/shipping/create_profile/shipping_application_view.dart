import 'dart:io';
import 'package:catch_ride/constant/app_colors.dart';
import 'package:catch_ride/constant/app_text_sizes.dart';
import 'package:catch_ride/controllers/vendor/shipping/shipping_application_controller.dart';
import 'package:catch_ride/widgets/common_button.dart';
import 'package:catch_ride/widgets/common_text.dart';
import 'package:catch_ride/widgets/common_textfield.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:form_field_validator/form_field_validator.dart';

class ShippingApplicationView extends StatelessWidget {
  const ShippingApplicationView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ShippingApplicationController());

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
            'Shipping Application',
            fontSize: AppTextSizes.size18,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(1.0),
            child: Container(color: AppColors.border, height: 1.0),
          ),
        ),
        body: SingleChildScrollView(
          child: Form(
            key: controller.formKey,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1. Full Name
                  _buildGroupedSection(
                    'Full Name',
                    children: [
                      CommonTextField(
                        label: '',
                        isRequired: true,
                        controller: controller.fullNameController,
                        hintText: 'Enter Your Full Name',
                        validator: RequiredValidator(errorText: "Please enter your full name").call,
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // 2. Services Bio
                  _buildGroupedSection(
                    'Why Join Our Community?',
                    children: [
                      CommonTextField(
                        label: '',
                        isRequired: true,
                        controller: controller.bioController,
                        hintText: 'Briefly describe your operation, services, and the type of routes or clients you typically work with.',
                        maxLines: 4,
                        validator: RequiredValidator(errorText: "Please tell us about your services").call,
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // 3. Physical Address
                  _buildGroupedSection(
                    'Home Base Location',
                    children: [
                      _buildFieldLabel('Country', isRequired: true),
                      _buildBottomTrigger(
                        value: 'USA',
                        hint: 'USA',
                        onTap: null, // Disabled as per requirement
                      ),
                      const SizedBox(height: 16),
                      _buildFieldLabel('State', isRequired: true),
                      Obx(() => _buildBottomTrigger(
                        value: controller.selectedState.value?['name'],
                        hint: 'Select State',
                        isLoading: controller.isLoadingStates.value,
                        onTap: () => _showLocationBottomSheet(
                          context: context,
                          title: 'Select State',
                          options: controller.states,
                          onSelected: (val) => controller.onStateSelected(val),
                        ),
                      )),
                      const SizedBox(height: 16),
                      _buildFieldLabel('City', isRequired: true),
                      Obx(() => _buildBottomTrigger(
                        value: controller.selectedCity.value?['name'],
                        hint: controller.selectedState.value == null ? 'Select State first' : 'Select City',
                        isLoading: controller.isLoadingCities.value,
                        onTap: controller.selectedState.value == null
                          ? null
                          : () => _showLocationBottomSheet(
                              context: context,
                              title: 'Select City',
                              options: controller.cities,
                              onSelected: (val) => controller.onCitySelected(val),
                            ),
                      )),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // 4. Business Information
                  _buildGroupedSection(
                    'Business Information',
                    children: [
                      CommonTextField(
                        label: 'Legal Business Name',
                        isRequired: true,
                        controller: controller.legalNameController,
                        hintText: 'Enter Legal Business Name',
                        validator: RequiredValidator(errorText: "Enter Legal Business Name").call,
                      ),
                      const SizedBox(height: 16),
                      CommonTextField(
                        label: 'USDOT Number',
                        isRequired: true,
                        controller: controller.dotNumberController,
                        hintText: 'Enter USDOT Number',
                        validator: RequiredValidator(errorText: "Enter USDOT Number").call,
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // 5. Experience
                  _buildGroupedSection(
                    'Experience',
                    isRequired: false,
                    children: [
                      Obx(() => _buildBottomTrigger(
                        value: controller.experience.value,
                        hint: 'Select Years of Experience',
                        onTap: () => _showExperienceBottomSheet(
                          context: context,
                          title: 'Hauling Experience',
                          currentValue: controller.experience.value,
                          options: controller.experienceOptions,
                          onSelected: (val) => controller.experience.value = val,
                        ),
                      )),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // 6. Operation Type
                  _buildGroupedSection(
                    'Operation Type',
                    isRequired: false,
                    children: [
                      Obx(() => Column(
                        children: [
                          _buildSelectionTile(
                            title: 'Independent Small Operation',
                            isSelected: controller.operationType.value == 'Independent Small Operation',
                            onTap: () => controller.operationType.value = 'Independent Small Operation',
                          ),
                          const SizedBox(height: 12),
                          _buildSelectionTile(
                            title: 'Established Shipping Company',
                            isSelected: controller.operationType.value == 'Established Shipping Company',
                            onTap: () => controller.operationType.value = 'Established Shipping Company',
                          ),
                        ],
                      )),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // 7. USDOT
                  _buildGroupedSection(
                    'Insurance',
                    description: 'Transport providers must carry active commercial insurance applicable to hauling client-owned horses. Documentation is reviewed as part of the approval process',
                    children: [
                      _buildFileUploadBox(
                        title: 'Click to upload',
                        targetFile: controller.dotCopy,
                        onTap: () => controller.pickFile(controller.dotCopy),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Obx(() => Checkbox(
                            value: controller.confirmUSDOT.value,
                            onChanged: (val) => controller.confirmUSDOT.value = val ?? false,
                            activeColor: AppColors.greenColor,
                          )),
                          const Expanded(
                            child: CommonText(
                              'I confirm I transport client-owned horses for compensation and am legally authorized to do so',
                              fontSize: 12,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // 8. Travel Scope
                  _buildGroupedSection(
                    'Travel Scope',
                    description: 'Select matching travel options',
                    children: [
                      Obx(() => _buildChipSelection(
                        options: controller.travelScopeOptions.toList(),
                        selectedItems: controller.selectedTravelScope,
                      )),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // 9. Regions Covered
                  _buildGroupedSection(
                    'Regions Covered',
                    description: 'Select the regions you regularly service',
                    children: [
                      _buildBottomTrigger(
                        hint: 'Search regions...',
                        onTap: () => _showMultiSelectBottomSheet(
                          context: context,
                          title: 'Select Regions',
                          options: controller.regionOptions,
                          selectedItems: controller.selectedRegions,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Obx(() => Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: controller.selectedRegions.map((region) => Chip(
                          label: CommonText(region, fontSize: 12),
                          onDeleted: () => controller.selectedRegions.remove(region),
                          deleteIcon: const Icon(Icons.close, size: 14),
                        )).toList(),
                      )),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // 10. Rig Types
                  _buildGroupedSection(
                    'Rig Types',
                    children: [
                      Obx(() => _buildChipSelection(
                        options: controller.rigTypeOptions.toList(),
                        selectedItems: controller.selectedRigTypes,
                      )),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // 10b. Stall Type
                  _buildGroupedSection(
                    'Stall Type',
                    children: [
                      Obx(() => _buildChipSelection(
                        options: controller.stallTypeOptions.toList(),
                        selectedItems: controller.selectedStallTypes,
                      )),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // 11. Driver Credentials
                  _buildGroupedSection(
                    'Driver Credentials',
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Obx(() => Checkbox(
                            value: controller.confirmLicense.value,
                            onChanged: (val) => controller.confirmLicense.value = val ?? false,
                            activeColor: const Color(0xFF001149),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                          )),
                          const Expanded(
                            child: CommonText(
                              'I hold a valid CDL (if required for my operation)',
                              fontSize: 14,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      _buildFieldLabel('Upload CDL (optional)'),
                      const SizedBox(height: 8),
                      _buildFileUploadBox(
                        title: 'Click to upload',
                        targetFile: controller.licensePhoto,
                        onTap: () => controller.pickFile(controller.licensePhoto),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // 12. Rig Capacity
                  _buildGroupedSection(
                    'Horse Capacity',
                    children: [
                      _buildFieldLabel('Max Horses'),
                      _buildStepperField(
                        value: controller.rigCapacity,
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // 12b. Social Media & Website
                  _buildGroupedSection(
                    'Social Media & Website',
                    description: 'Please include at least one profile for verification',
                    children: [
                      CommonTextField(
                        label: 'Facebook',
                        controller: controller.facebookController,
                        hintText: 'facebook.com/yourpage',
                      ),
                      const SizedBox(height: 16),
                      CommonTextField(
                        label: 'Instagram',
                        controller: controller.instagramController,
                        hintText: '@yourusername',
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // 14. Rig Photos
                  _buildGroupedSection(
                    'Add Photos',
                    description: 'Upload high-quality images of your hauling equipment.',
                    children: [
                      _buildPhotoGrid(controller),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // 15. Professional References
                  _buildProfessionalReferences(controller),
                  const SizedBox(height: 24),

                  // 16. Experience Highlights
                  _buildGroupedSection(
                    'Experience Highlights (optional)',
                    description: 'Share key experience, programs, or specialties you\'d like clients to know',
                    children: [
                      Obx(() => Column(
                        children: controller.highlightsControllers.asMap().entries.map((entry) {
                          final index = entry.key;
                          final ctrl = entry.value;
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: Row(
                              children: [
                                Expanded(
                                  child: CommonTextField(
                                    label: '',
                                    controller: ctrl,
                                    hintText: 'Write here...',
                                  ),
                                ),
                                if (controller.highlightsControllers.length > 1)
                                  IconButton(
                                    icon: const Icon(Icons.remove_circle_outline, color: AppColors.accentRed, size: 20),
                                    onPressed: () => controller.removeHighlight(index),
                                  ),
                              ],
                            ),
                          );
                        }).toList(),
                      )),
                      const SizedBox(height: 8),
                      GestureDetector(
                        onTap: controller.addHighlight,
                        child: const Padding(
                          padding: EdgeInsets.symmetric(vertical: 4),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.add, color: AppColors.linkBlue, size: 18),
                              SizedBox(width: 4),
                              CommonText(
                                'Add More',
                                color: AppColors.linkBlue,
                                fontWeight: FontWeight.w600,
                                fontSize: AppTextSizes.size14,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),

                  // 17. Final Checkboxes
                  _buildAgreementCheckbox(
                    value: controller.is18OrOlder,
                    label: 'I confirm that I am at least 18 years or older.',
                  ),
                  _buildAgreementCheckbox(
                    value: controller.agreeTerms,
                    label: 'I agree to the Terms of Service and Privacy Policy.',
                  ),
                  _buildAgreementCheckbox(
                    value: controller.agreeReferences,
                    label: 'I understand that my professional references may be contacted regarding my work history, competence, and reliability.',
                  ),
                  _buildAgreementCheckbox(
                    value: controller.agreeCompliance,
                    label: 'I operate in compliance with applicable transport regulations and licensing requirements',
                  ),
                  _buildAgreementCheckbox(
                    value: controller.agreeVerification,
                    label: 'I understand that Catch Ride reviews and verifies USDOT and licensing information to maintain a trusted provider network',
                  ),
                  const SizedBox(height: 40),

                  // 19. Submit Button
                  Obx(() => CommonButton(
                    text: 'Submit Application',
                    isLoading: controller.isSubmitting.value,
                    onPressed: controller.submitApplication,
                    height: 56,
                    backgroundColor: const Color(0xFF001149),
                  )),
                  const SizedBox(height: 48),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ── Helper Widgets ─────────────────────────────────────────────────────────

  Widget _buildSectionHeader(String title, {bool isRequired = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        children: [
          CommonText(
            title,
            fontSize: AppTextSizes.size16,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
          if (isRequired)
            const CommonText(
              ' *',
              fontSize: AppTextSizes.size18,
              color: AppColors.accentRed,
            ),
        ],
      ),
    );
  }

  Widget _buildFieldLabel(String title, {bool isRequired = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        children: [
          CommonText(
            title,
            fontSize: AppTextSizes.size14,
            fontWeight: FontWeight.w600,
            color: AppColors.textSecondary,
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

  Widget _buildGroupedSection(String title, {String? description, bool isRequired = false, required List<Widget> children}) {
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
          _buildSectionHeader(title, isRequired: isRequired),
          if (description != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: CommonText(description, fontSize: AppTextSizes.size12, color: AppColors.textSecondary),
            ),
          ...children,
        ],
      ),
    );
  }

  Widget _buildBottomTrigger({String? value, required String hint, required VoidCallback? onTap, bool isLoading = false}) {
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
            if (isLoading)
              const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary),
              )
            else if (onTap != null)
              const Icon(Icons.keyboard_arrow_down, color: AppColors.textSecondary, size: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildFileUploadBox({required String title, required Rxn<File> targetFile, required VoidCallback onTap}) {
    return Obx(() {
      final hasFile = targetFile.value != null;
      return GestureDetector(
        onTap: onTap,
        child: Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.borderLight, style: BorderStyle.solid),
          ),
          child: Center(
            child: Column(
              children: [
                if (hasFile) ...[
                  const Icon(Icons.check_circle, color: Colors.green, size: 32),
                  const SizedBox(height: 8),
                  CommonText(targetFile.value!.path.split('/').last, fontSize: 12, color: AppColors.textPrimary, overflow: TextOverflow.ellipsis),
                ] else ...[
                  const Icon(Icons.cloud_upload_outlined, color: AppColors.textSecondary, size: 32),
                  const SizedBox(height: 12),
                  Wrap(
                    alignment: WrapAlignment.center,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      CommonText(title, color: AppColors.linkBlue, fontWeight: FontWeight.bold, fontSize: 14, textAlign: TextAlign.center),
                      const CommonText(' or pull files', fontSize: 14, color: AppColors.textSecondary),
                    ],
                  ),
                  const SizedBox(height: 4),
                  const CommonText('PDF, PNG or JPG  (max. 800x400px)', fontSize: 12, color: AppColors.textSecondary),
                ],
              ],
            ),
          ),
        ),
      );
    });
  }

  Widget _buildChipSelection({required List<String> options, required RxList<String> selectedItems}) {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: options.map((opt) {
        final isSelected = selectedItems.contains(opt);
        return FilterChip(
          label: CommonText(
            opt,
            color: isSelected ? const Color(0xFF001144) : const Color(0xFF444444),
            fontSize: 13,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
          ),
          selected: isSelected,
          onSelected: (val) {
            if (val) {
              selectedItems.add(opt);
            } else {
              selectedItems.remove(opt);
            }
          },
          selectedColor: const Color(0xFFE8F0FF),
          backgroundColor: const Color(0xFFF9F9F9),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(100),
            side: BorderSide(
              color: isSelected ? const Color(0xFF001144) : const Color(0xFFE5E5E5),
              width: isSelected ? 1.5 : 1,
            ),
          ),
          showCheckmark: false,
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
        );
      }).toList(),
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
          border: Border.all(color: isSelected ? AppColors.primary : AppColors.borderLight, width: isSelected ? 2 : 1),
        ),
        child: Row(
          children: [
            Expanded(child: CommonText(title, fontSize: 14, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal)),
            if (isSelected) const Icon(Icons.check_circle, color: AppColors.primary, size: 20)
            else const Icon(Icons.radio_button_off, color: AppColors.borderMedium, size: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildStepperField({required RxInt value}) {
    return Obx(() => Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            onPressed: () => value.value > 1 ? value.value-- : null,
            icon: const Icon(Icons.remove_circle_outline, color: AppColors.borderMedium),
          ),
          CommonText('${value.value}', fontSize: 18, fontWeight: FontWeight.bold),
          IconButton(
            onPressed: () => value.value++,
            icon: const Icon(Icons.add_circle_outline, color: AppColors.borderMedium),
          ),
        ],
      ),
    ));
  }

  Widget _buildPhotoGrid(ShippingApplicationController controller) {
    return Obx(() => Column(
      children: [
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
          ),
          itemCount: controller.rigPhotos.length + 1,
          itemBuilder: (context, index) {
            if (index == controller.rigPhotos.length) {
              return GestureDetector(
                onTap: controller.pickRigPhotos,
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.tabBackground,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.borderLight, style: BorderStyle.solid),
                  ),
                  child: const Icon(Icons.add, color: AppColors.textSecondary),
                ),
              );
            }
            return Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.file(controller.rigPhotos[index], width: double.infinity, height: double.infinity, fit: BoxFit.cover),
                ),
                Positioned(
                  right: 4,
                  top: 4,
                  child: GestureDetector(
                    onTap: () => controller.removeRigPhoto(index),
                    child: Container(
                      decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                      child: const Icon(Icons.close, size: 16, color: Colors.red),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ],
    ));
  }

  Widget _buildProfessionalReferences(ShippingApplicationController controller) {
    return _buildGroupedSection(
      'Professional References',
      description: 'Provide references who can speak to your experience, professionalism, and reliability',
      children: [
        Obx(() => Column(
          children: controller.referenceControllers.asMap().entries.map((entry) {
            final idx = entry.key;
            final ref = entry.value;
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildFieldLabel('Reference ${idx + 1}'),
                const SizedBox(height: 12),
                CommonTextField(label: 'Full Name', controller: ref.fullName, hintText: 'Enter Full Name'),
                const SizedBox(height: 12),
                CommonTextField(label: 'Business Name', controller: ref.relationship, hintText: 'Enter Business Name'),
                const SizedBox(height: 12),
                CommonTextField(label: 'Relationship', controller: ref.phone, hintText: 'Enter Relationship'),
                const SizedBox(height: 24),
              ],
            );
          }).toList(),
        )),
      ],
    );
  }

  Widget _buildAgreementCheckbox({required RxBool value, required String label}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: 24,
            width: 24,
            child: Obx(() => Checkbox(
              value: value.value,
              onChanged: (val) => value.value = val ?? false,
              activeColor: Colors.green,
              side: const BorderSide(width: 2, color: Colors.black),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            )),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: CommonText(
              label,
              fontSize: 14,
              color: AppColors.textPrimary,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  // ── Bottom Sheet Methods (Omitted for brevity, but exist in logic) ─────────
  void _showLocationBottomSheet({required BuildContext context, required String title, required List<Map<String, dynamic>> options, required Function(Map<String, dynamic>) onSelected}) {
     showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => Column(
        children: [
          const SizedBox(height: 10),
          Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2))),
          Padding(padding: const EdgeInsets.all(20), child: CommonText(title, fontWeight: FontWeight.bold, fontSize: 18)),
          const Divider(),
          Expanded(child: ListView.builder(
            itemCount: options.length,
            itemBuilder: (context, index) => ListTile(
              title: CommonText(options[index]['name'] ?? ''),
              onTap: () { onSelected(options[index]); Navigator.pop(ctx); },
            ),
          )),
        ],
      ),
    );
  }

  void _showExperienceBottomSheet({required BuildContext context, required String title, String? currentValue, required List<String> options, required Function(String) onSelected}) {
     showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      builder: (ctx) => Column(
        mainAxisSize: MainAxisSize.min,
        children: options.map((opt) => ListTile(
          title: Center(child: CommonText(opt,)),
          onTap: () { onSelected(opt); Navigator.pop(ctx); },
        )).toList(),
      ),
    );
  }

  void _showMultiSelectBottomSheet({required BuildContext context, required String title, required List<String> options, required RxList<String> selectedItems}) {
     showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      builder: (ctx) => StatefulBuilder(builder: (context, setState) => Column(
        children: [
          Padding(padding: const EdgeInsets.all(20), child: CommonText(title, fontWeight: FontWeight.bold, fontSize: 18)),
          Expanded(child: ListView.builder(
            itemCount: options.length,
            itemBuilder: (context, index) {
              final opt = options[index];
              final isSelected = selectedItems.contains(opt);
              return ListTile(
                title: CommonText(opt),
                trailing: isSelected ? const Icon(Icons.check, color: AppColors.primary) : null,
                onTap: () {
                  if (isSelected) {
                    selectedItems.remove(opt);
                  } else {
                    selectedItems.add(opt);
                  }
                  setState(() {});
                },
              );
            },
          )),
        ],
      )),
    );
  }
}
