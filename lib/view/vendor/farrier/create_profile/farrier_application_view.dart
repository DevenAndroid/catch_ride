import 'dart:io';
import 'package:catch_ride/constant/app_colors.dart';
import 'package:catch_ride/constant/app_text_sizes.dart';
import 'package:catch_ride/controllers/vendor/farrier/farrier_application_controller.dart';
import 'package:catch_ride/widgets/common_button.dart';
import 'package:catch_ride/widgets/common_text.dart';
import 'package:catch_ride/widgets/common_textfield.dart';
import 'package:catch_ride/widgets/common_image_view.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:form_field_validator/form_field_validator.dart';

class FarrierApplicationView extends StatelessWidget {
  const FarrierApplicationView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(FarrierApplicationController());

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
          'Farrier Application',
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
                _buildGroupedSection(
                  'Full Name',
                  isRequired: true,
                  children: [
                    CommonTextField(
                      label: '',
                      controller: controller.fullNameController,
                      hintText: 'Enter Your Full Name',
                      validator: RequiredValidator(errorText: "Please enter your full name"),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                _buildGroupedSection(
                  'Why Join Our Community?',
                  children: [
                    CommonTextField(
                      label: '',
                      controller: controller.joinCommunityController,
                      hintText: 'Share a bit about your approach, experience, and anything else we should know when working with you.',
                      maxLines: 4,
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                _buildGroupedSection(
                  'Home Base Location',
                  children: [
                    _buildSectionHeader('Country', isRequired: true),
                    _buildBottomTrigger(
                      value: controller.countryController.text,
                      hint: 'Select Country',
                      onTap: null, 
                    ),
                    const SizedBox(height: 16),

                    _buildSectionHeader('State / Province', isRequired: true),
                    Obx(() => _buildBottomTrigger(
                      value: controller.selectedState.value?['name'],
                      hint: 'Select State / Province',
                      isLoading: controller.isLoadingStates.value,
                      onTap: () => _showLocationBottomSheet(
                        context: context,
                        title: 'Select State',
                        options: controller.states,
                        onSelected: (val) => controller.onStateSelected(val),
                      ),
                    )),
                    const SizedBox(height: 16),

                    _buildSectionHeader('City', isRequired: true),
                    Obx(() => _buildBottomTrigger(
                      value: controller.selectedCity.value?['name'],
                      hint: controller.selectedState.value == null 
                          ? 'Select State first' 
                          : 'Select City',
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

                _buildGroupedSection(
                  'Experience',
                  isRequired: true,
                  children: [
                    Obx(() => _buildBottomTrigger(
                      value: controller.experience.value,
                      hint: 'Select Years of Experience',
                      onTap: () => _showExperienceBottomSheet(
                        context: context,
                        title: 'Experience',
                        currentValue: controller.experience.value,
                        options: controller.experienceOptions,
                        onSelected: (val) => controller.experience.value = val,
                      ),
                    )),
                  ],
                ),
                const SizedBox(height: 24),

                _buildGroupedSection(
                  'Relevant Certifications',
                  description: 'Select any certifications you hold or describe your training and background',
                  children: [
                    Obx(() => Wrap(
                      spacing: 12,
                      children: controller.certificationOptions.map((opt) {
                        final isSelected = controller.selectedCertification.value == opt;
                        return ChoiceChip(
                          label: CommonText(opt, color: isSelected ? AppColors.cardColor : AppColors.textPrimary),
                          selected: isSelected,
                          onSelected: (val) => controller.selectedCertification.value = val ? opt : null,
                          selectedColor: AppColors.primary,
                          backgroundColor: AppColors.tabBackground,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        );
                      }).toList(),
                    )),
                    Obx(() {
                      if (controller.selectedCertification.value == 'Other') {
                        return Padding(
                          padding: const EdgeInsets.only(top: 12),
                          child: CommonTextField(
                            label: '',
                            controller: controller.otherCertificationController,
                            hintText: 'Write here...',
                          ),
                        );
                      }
                      return const SizedBox.shrink();
                    }),
                  ],
                ),
                const SizedBox(height: 24),

                _buildGroupedSection(
                  'Scope of Work',
                  description: 'Select all that apply to your business.',
                  children: [
                    Obx(() => Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: controller.scopeOfWorkOptions.map((opt) {
                        final isSelected = controller.selectedScopeOfWork.contains(opt);
                        return FilterChip(
                          label: CommonText(opt, color: isSelected ? AppColors.cardColor : AppColors.textPrimary, fontSize: AppTextSizes.size12),
                          selected: isSelected,
                          onSelected: (val) {
                            if (val) {
                              controller.selectedScopeOfWork.add(opt);
                            } else {
                              controller.selectedScopeOfWork.remove(opt);
                            }
                          },
                          selectedColor: AppColors.primary,
                          backgroundColor: AppColors.tabBackground,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20), side: BorderSide(color: isSelected ? Colors.transparent : AppColors.borderLight)),
                          showCheckmark: false,
                        );
                      }).toList(),
                    )),
                  ],
                ),
                const SizedBox(height: 24),

                _buildGroupedSection(
                  'Disciplines',
                  description: 'Select the disciplines you most commonly work with.',
                  children: [
                    Obx(() => Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: controller.disciplineOptions.map((opt) {
                        final isSelected = controller.selectedDisciplines.contains(opt);
                        return FilterChip(
                          label: CommonText(opt, color: isSelected ? AppColors.cardColor : AppColors.textPrimary, fontSize: AppTextSizes.size12),
                          selected: isSelected,
                          onSelected: (val) {
                            if (val) {
                              controller.selectedDisciplines.add(opt);
                            } else {
                              controller.selectedDisciplines.remove(opt);
                            }
                          },
                          selectedColor: AppColors.primary,
                          backgroundColor: AppColors.tabBackground,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20), side: BorderSide(color: isSelected ? Colors.transparent : AppColors.borderLight)),
                          showCheckmark: false,
                        );
                      }).toList(),
                    )),
                    Obx(() {
                      if (controller.selectedDisciplines.contains('Other')) {
                        return Padding(
                          padding: const EdgeInsets.only(top: 12),
                          child: CommonTextField(
                            label: '', 
                            controller: controller.otherDisciplineController,
                            hintText: 'Write here...',
                          ),
                        );
                      }
                      return const SizedBox.shrink();
                    }),
                  ],
                ),
                const SizedBox(height: 24),

                _buildGroupedSection(
                  'Typical Level of Horses',
                  description: 'Select the types of horses you most frequently work with.',
                  children: [
                    Obx(() => Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: controller.horseLevelOptions.map((opt) {
                        final isSelected = controller.selectedHorseLevels.contains(opt);
                        return FilterChip(
                          label: CommonText(opt, color: isSelected ? AppColors.cardColor : AppColors.textPrimary, fontSize: AppTextSizes.size12),
                          selected: isSelected,
                          onSelected: (val) {
                            if (val) {
                              controller.selectedHorseLevels.add(opt);
                            } else {
                              controller.selectedHorseLevels.remove(opt);
                            }
                          },
                          selectedColor: AppColors.primary,
                          backgroundColor: AppColors.tabBackground,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20), side: BorderSide(color: isSelected ? Colors.transparent : AppColors.borderLight)),
                          showCheckmark: false,
                        );
                      }).toList(),
                    )),
                  ],
                ),
                const SizedBox(height: 24),

                _buildGroupedSection(
                  'Regions Covered',
                  description: 'Select the regions you most commonly work in.',
                  children: [
                    Obx(() => _buildBottomTrigger(
                      value: '', 
                      hint: 'Select regions...',
                      isLoading: controller.isLoadingTags.value,
                      onTap: () => _showMultiSelectBottomSheet(
                        context: context,
                        title: 'Select Regions',
                        options: controller.regionOptions,
                        selectedItems: controller.selectedRegions,
                        onToggle: (val) {
                          if (controller.selectedRegions.contains(val)) {
                            controller.selectedRegions.remove(val);
                          } else {
                            controller.selectedRegions.add(val);
                          }
                        },
                      ),
                    )),
                    const SizedBox(height: 16),
                    Obx(() => Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: controller.selectedRegions.map((region) => Container(
                        width: double.infinity,
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(
                          color: AppColors.background,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: AppColors.borderLight),
                        ),
                        child: Row(
                          children: [
                            Expanded(child: CommonText(region, fontSize: AppTextSizes.size12, color: AppColors.textPrimary)),
                            GestureDetector(
                              onTap: () => controller.selectedRegions.remove(region),
                              child: const Icon(Icons.close, size: 16, color: AppColors.textSecondary),
                            ),
                          ],
                        ),
                      )).toList(),
                    )),
                  ],
                ),
                const SizedBox(height: 24),

                _buildGroupedSection(
                  'Social Media & Website',
                  description: 'Please include at least one profile for verification.',
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
                      hintText: '@your.username',
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                _buildSectionHeader('Add Photos'),
                const CommonText(
                  'Upload photos that showcase your work and skills.',
                  fontSize: AppTextSizes.size12,
                  color: AppColors.textSecondary,
                ),
                const SizedBox(height: 12),
                const CommonText('Upload *', fontSize: AppTextSizes.size14, fontWeight: FontWeight.w600),
                const SizedBox(height: 8),
                Obx(() => _buildPhotoGrid(controller)),
                const SizedBox(height: 24),

                _buildTrainerReferences(controller),
                const SizedBox(height: 24),

                _buildGroupedSection(
                  'Experience Highlights (optional)',
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
                const SizedBox(height: 24),

                _buildCheckboxes(controller),
                const SizedBox(height: 32),

                Obx(() => CommonButton(
                  text: 'Submit Application',
                  isLoading: controller.isSubmitting.value,
                  onPressed: controller.submitApplication,
                  height: 56,
                  backgroundColor: const Color(0xFF001149), 
                )),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
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
            fontSize: AppTextSizes.size16,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
          if (isRequired)
            const CommonText(
              ' *',
              fontSize: AppTextSizes.size16,
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
            else
              const Icon(
                Icons.keyboard_arrow_down,
                color: AppColors.textSecondary,
                size: 20,
              ),
          ],
        ),
      ),
    );
  }

  void _showLocationBottomSheet({
    required BuildContext context,
    required String title,
    required List<Map<String, dynamic>> options,
    required Function(Map<String, dynamic>) onSelected,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.cardColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.6,
          minChildSize: 0.4,
          maxChildSize: 0.9,
          builder: (_, scrollController) {
            return Column(
              children: [
                Container(
                  margin: const EdgeInsets.symmetric(vertical: 12),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.border,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  child: CommonText(
                    title,
                    fontSize: AppTextSizes.size18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const Divider(),
                Expanded(
                  child: ListView.builder(
                    controller: scrollController,
                    itemCount: options.length,
                    itemBuilder: (context, index) {
                      final item = options[index];
                      return InkWell(
                        onTap: () {
                          onSelected(item);
                          Navigator.pop(ctx);
                        },
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                          decoration: BoxDecoration(
                            border: Border(bottom: BorderSide(color: AppColors.dividerColor)),
                          ),
                          child: CommonText(
                            item['name'] ?? '',
                            fontSize: AppTextSizes.size16,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showExperienceBottomSheet({
    required BuildContext context,
    required String title,
    String? currentValue,
    required List<String> options,
    required Function(String) onSelected,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.cardColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.5,
          minChildSize: 0.3,
          maxChildSize: 0.9,
          builder: (_, scrollController) {
            return Column(
              children: [
                Container(
                  margin: const EdgeInsets.symmetric(vertical: 12),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.border,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  child: CommonText(
                    title,
                    fontSize: AppTextSizes.size18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const Divider(),
                Expanded(
                  child: ListView.builder(
                    controller: scrollController,
                    itemCount: options.length,
                    itemBuilder: (context, index) {
                      final item = options[index];
                      final isSelected = item == currentValue;
                      return InkWell(
                        onTap: () {
                          onSelected(item);
                          Navigator.pop(ctx);
                        },
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                          decoration: BoxDecoration(
                            border: Border(bottom: BorderSide(color: AppColors.dividerColor)),
                          ),
                          child: Center(
                            child: CommonText(
                              item,
                              fontSize: AppTextSizes.size16,
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                              color: isSelected ? AppColors.primary : AppColors.textPrimary,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showMultiSelectBottomSheet({
    required BuildContext context,
    required String title,
    required List<String> options,
    required List<String> selectedItems,
    required Function(String) onToggle,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.cardColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.7,
          minChildSize: 0.5,
          maxChildSize: 0.9,
          builder: (_, scrollController) {
            return Column(
              children: [
                Container(
                  margin: const EdgeInsets.symmetric(vertical: 12),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.border,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      CommonText(
                        title,
                        fontSize: AppTextSizes.size18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                      TextButton(
                        onPressed: () => Navigator.pop(ctx),
                        child: const CommonText('Done', color: AppColors.linkBlue, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
                const Divider(),
                Expanded(
                  child: Obx(() {
                    return ListView.builder(
                      controller: scrollController,
                      itemCount: options.length,
                      itemBuilder: (context, index) {
                        final item = options[index];
                        return Obx(() {
                          final isSelected = selectedItems.contains(item);
                          return CheckboxListTile(
                            title: CommonText(item, fontSize: AppTextSizes.size14),
                            value: isSelected,
                            onChanged: (val) => onToggle(item),
                            activeColor: AppColors.primary,
                            controlAffinity: ListTileControlAffinity.trailing,
                            contentPadding: const EdgeInsets.symmetric(horizontal: 20),
                          );
                        });
                      },
                    );
                  }),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildPhotoGrid(FarrierApplicationController controller) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          ...controller.photos.asMap().entries.map((entry) {
            return Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: Stack(
                children: [
                  CommonImageView(
                    file: entry.value,
                    width: 80,
                    height: 80,
                    fit: BoxFit.cover,
                    radius: 8,
                  ),
                  Positioned(
                    right: 4,
                    top: 4,
                    child: GestureDetector(
                      onTap: () => controller.removeImage(entry.key),
                      child: Container(
                        padding: const EdgeInsets.all(2),
                        decoration: const BoxDecoration(color: AppColors.accentRed, shape: BoxShape.circle),
                        child: const Icon(Icons.close, size: 12, color: AppColors.cardColor),
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
          GestureDetector(
            onTap: controller.pickImage,
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.borderLight),
                borderRadius: BorderRadius.circular(8),
                color: AppColors.lightGray,
              ),
              child: const Icon(Icons.add, color: AppColors.textSecondary),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTrainerReferences(FarrierApplicationController controller) {
    return _buildGroupedSection(
      'Professional References',
      description: 'Provide references here regarding your experience, professionalism, and reliability.',
      children: [
        _buildTrainerReferenceInputs(controller, 1),
        const SizedBox(height: 24),
        _buildTrainerReferenceInputs(controller, 2),
      ],
    );
  }

  Widget _buildTrainerReferenceInputs(FarrierApplicationController controller, int number) {
    final nameCtrl = number == 1 ? controller.ref1FullNameController : controller.ref2FullNameController;
    final busCtrl = number == 1 ? controller.ref1BusinessNameController : controller.ref2BusinessNameController;
    final relCtrl = number == 1 ? controller.ref1RelationshipController : controller.ref2RelationshipController;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CommonText('Trainer Reference \$number', color: AppColors.secondary, fontWeight: FontWeight.bold, fontSize: AppTextSizes.size14),
        const SizedBox(height: 12),
        CommonTextField(label: 'Full Name', controller: nameCtrl, hintText: 'Enter Full Name'),
        const SizedBox(height: 16),
        CommonTextField(label: 'Business Name', controller: busCtrl, hintText: 'Enter Business Name'),
        const SizedBox(height: 16),
        CommonTextField(label: 'Relationship', controller: relCtrl, hintText: 'Enter Relationship'),
      ],
    );
  }

  Widget _buildCheckboxes(FarrierApplicationController controller) {
    return Column(
      children: [
        Obx(() => _buildCheckboxTile(
          'I confirm that I am at least 18 years of age.',
          controller.is18OrOlder.value,
          (val) => controller.is18OrOlder.value = val!,
        )),
        Obx(() => _buildCheckboxTile(
          'I agree to the Terms of Service and Privacy Policy.',
          controller.agreeToTerms.value,
          (val) => controller.agreeToTerms.value = val!,
        )),
        Obx(() => _buildCheckboxTile(
          'I understand that my professional references may be contacted regarding my history, competence, and reliability.',
          controller.confirmReferences.value,
          (val) => controller.confirmReferences.value = val!,
        )),
      ],
    );
  }

  Widget _buildCheckboxTile(String title, bool value, Function(bool?) onChanged) {
    return CheckboxListTile(
      value: value,
      onChanged: onChanged,
      title: CommonText(title, fontSize: AppTextSizes.size12),
      controlAffinity: ListTileControlAffinity.leading,
      contentPadding: EdgeInsets.zero,
      activeColor: AppColors.primary,
      dense: true,
    );
  }
}
