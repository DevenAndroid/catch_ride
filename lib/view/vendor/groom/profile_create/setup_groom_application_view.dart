import 'dart:io';
import 'package:catch_ride/constant/app_colors.dart';
import 'package:catch_ride/constant/app_text_sizes.dart';
import 'package:catch_ride/controllers/vendor/groom/setup_groom_application_controller.dart';
import 'package:catch_ride/widgets/common_button.dart';
import 'package:catch_ride/widgets/common_text.dart';
import 'package:catch_ride/widgets/common_textfield.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SetupGroomApplicationView extends StatelessWidget {
  const SetupGroomApplicationView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(SetupGroomApplicationController());

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const CommonText(
          'Grooming Application',
          fontSize: AppTextSizes.size22,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: AppColors.textPrimary, size: 18),
          onPressed: () => Get.back(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        child: Form(
          key: controller.formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CommonTextField(
                label: 'Full Name',
                isRequired: true,
                controller: controller.fullNameController,
                hintText: 'Enter your full name',
                validator: (value) {
                   if (value == null || value.isEmpty) return "Please enter your full name";
                   return null;
                },
              ),
              const SizedBox(height: 24),

              _buildGroupedSection(
                'Home Base Location',
                children: [
                  CommonTextField(
                    label: 'Country',
                    isRequired: true,
                    readOnly: true,
                    controller: controller.countryController,
                    hintText: 'Select country',
                  ),
                  const SizedBox(height: 16),
                  
                  _buildSectionHeader('State/Province', isRequired: true),
                  Obx(() => _buildBottomTrigger(
                    value: controller.selectedState.value?['name'],
                    hint: 'Select state',
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
                        ? 'Select state first' 
                        : 'Select city',
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

              _buildSectionHeader('Experience', isRequired: true),
              Obx(() => _buildBottomTrigger(
                value: controller.experience.value,
                hint: 'Select years of experience',
                onTap: () => _showExperienceBottomSheet(
                  context: context,
                  title: 'Experience',
                  currentValue: controller.experience.value,
                  options: controller.experienceOptions,
                  onSelected: (val) => controller.experience.value = val,
                ),
              )),
              const SizedBox(height: 24),

              CommonTextField(
                label: 'Why Join Our Community?',
                controller: controller.joinCommunityController,
                hintText: 'Tell us why you would like to join and what you bring to the network.',
                maxLines: 4,
              ),
              const SizedBox(height: 24),

              _buildGroupedSection(
                'Disciplines',
                children: [
                  Obx(() => _buildChipsList(
                    options: controller.disciplineOptions,
                    selectedItems: controller.selectedDisciplines,
                    onSelected: (item, selected) {
                      if (selected) {
                        controller.selectedDisciplines.add(item);
                      } else {
                        controller.selectedDisciplines.remove(item);
                      }
                    },
                  )),
                  Obx(() {
                    if (controller.selectedDisciplines.contains('Other')) {
                      return Padding(
                        padding: const EdgeInsets.only(top: 16),
                        child: CommonTextField(
                          label: '', // No label as per screenshot
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
                children: [
                  Obx(() => _buildChipsList(
                    options: controller.horseLevelOptions,
                    selectedItems: controller.selectedHorseLevels,
                    onSelected: (item, selected) {
                      if (selected) {
                        controller.selectedHorseLevels.add(item);
                      } else {
                        controller.selectedHorseLevels.remove(item);
                      }
                    },
                  )),
                ],
              ),
              const SizedBox(height: 24),

              _buildGroupedSection(
                'Regions Covered',
                description: 'Select the regions you most commonly work in. Availability details will be added later.',
                children: [
                  Obx(() => _buildBottomTrigger(
                    value: '', // This will remain empty as selected regions are chips below
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
                        color: const Color(0xFFF9FAFB),
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
                    prefixIcon: const Icon(Icons.facebook, size: 20),
                  ),
                  const SizedBox(height: 16),
                  CommonTextField(
                    label: 'Instagram',
                    controller: controller.instagramController,
                    hintText: '@your.username',
                    prefixIcon: const Icon(Icons.camera_alt_outlined, size: 20),
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
                                icon: const Icon(Icons.remove_circle_outline, color: Colors.red, size: 20),
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
                          Icon(Icons.add, color: AppColors.primary, size: 18),
                          SizedBox(width: 4),
                          CommonText(
                            'Add More',
                            color: AppColors.primary,
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

              Padding(
                padding: const EdgeInsets.only(bottom: 24),
                child: CommonButton(
                  text: 'Submit Application',
                  onPressed: controller.submitApplication,
                  height: 56,
                  backgroundColor: AppColors.primaryDark,
                ),
              ),
            ],
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
              color: Colors.red,
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
          _buildSectionHeader(title),
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

  Widget _buildDropdown({String? value, required List<String> options, required Function(String?) onChanged, required String hint}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          hint: CommonText(hint, color: AppColors.textSecondary, fontSize: AppTextSizes.size14),
          isExpanded: true,
          items: options.map((s) => DropdownMenuItem(value: s, child: CommonText(s))).toList(),
          onChanged: onChanged,
        ),
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
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.borderLight),
        ),
        child: Row(
          children: [
            Expanded(
              child: CommonText(
                value ?? hint,
                fontSize: AppTextSizes.size14,
                color: value == null ? AppColors.textSecondary : AppColors.textPrimary,
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
      backgroundColor: Colors.white,
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
                    color: Colors.grey.shade300,
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
                            border: Border(bottom: BorderSide(color: Colors.grey.shade100)),
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
      backgroundColor: Colors.white,
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
                    color: Colors.grey.shade300,
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
                            border: Border(bottom: BorderSide(color: Colors.grey.shade100)),
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

  Widget _buildChipsList({required List<String> options, required List<String> selectedItems, required Function(String, bool) onSelected}) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: options.map((opt) {
        final isSelected = selectedItems.contains(opt);
        return FilterChip(
          label: CommonText(opt, color: isSelected ? Colors.white : AppColors.textPrimary, fontSize: AppTextSizes.size12),
          selected: isSelected,
          onSelected: (val) => onSelected(opt, val),
          selectedColor: AppColors.primaryDark,
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: BorderSide(color: isSelected ? Colors.transparent : AppColors.borderLight),
          ),
          showCheckmark: false,
        );
      }).toList(),
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
      backgroundColor: Colors.white,
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
                    color: Colors.grey.shade300,
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
                        child: const CommonText('Done', color: AppColors.primary, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
                const Divider(),
                Expanded(
                  child: Obx(() {
                    // Use a variable to track count so Obx reacts to list size changes
                    final itemCount = options.length;
                    return ListView.builder(
                      controller: scrollController,
                      itemCount: itemCount,
                      itemBuilder: (context, index) {
                        final item = options[index];
                        // Obx here observes the specific condition for this item
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

  Widget _buildMultiSelectDropdown({required List<String> options, required List<String> selectedItems, required String hint, required Function(String) onToggle}) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (selectedItems.isEmpty)
            CommonText(hint, color: AppColors.textSecondary, fontSize: AppTextSizes.size14)
          else
            Wrap(
              spacing: 8,
              runSpacing: 4,
              children: selectedItems.map((item) => Chip(
                label: CommonText(item, fontSize: AppTextSizes.size12),
                onDeleted: () => onToggle(item),
                visualDensity: VisualDensity.compact,
              )).toList(),
            ),
          const Divider(),
          ...options.map((opt) => CheckboxListTile(
            title: CommonText(opt, fontSize: AppTextSizes.size14),
            value: selectedItems.contains(opt),
            onChanged: (val) => onToggle(opt),
            controlAffinity: ListTileControlAffinity.trailing,
            contentPadding: EdgeInsets.zero,
            dense: true,
          )),
        ],
      ),
    );
  }

  Widget _buildPhotoGrid(SetupGroomApplicationController controller) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          ...controller.photos.asMap().entries.map((entry) {
            return Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.file(entry.value, width: 80, height: 80, fit: BoxFit.cover),
                  ),
                  Positioned(
                    right: 4,
                    top: 4,
                    child: GestureDetector(
                      onTap: () => controller.removeImage(entry.key),
                      child: Container(
                        padding: const EdgeInsets.all(2),
                        decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                        child: const Icon(Icons.close, size: 12, color: Colors.white),
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
          const SizedBox(width: 8),
          Container(
            width: 80, 
            height: 80, 
            decoration: BoxDecoration(
              color: AppColors.lightGray, 
              borderRadius: BorderRadius.circular(8)
            ), 
            child: const Icon(Icons.add, color: Colors.grey)
          ),
        ],
      ),
    );
  }

  Widget _buildTrainerReferences(SetupGroomApplicationController controller) {
    return _buildGroupedSection(
      'Professional References',
      description: 'Please provide two professional references we may contact regarding your experience and reliability.',
      children: [
        _buildTrainerReferenceInputs(controller, 1),
        const SizedBox(height: 24),
        _buildTrainerReferenceInputs(controller, 2),
      ],
    );
  }

  Widget _buildTrainerReferenceInputs(SetupGroomApplicationController controller, int number) {
    final nameCtrl = number == 1 ? controller.ref1FullNameController : controller.ref2FullNameController;
    final busCtrl = number == 1 ? controller.ref1BusinessNameController : controller.ref2BusinessNameController;
    final relCtrl = number == 1 ? controller.ref1RelationshipController : controller.ref2RelationshipController;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CommonText('Trainer Reference $number', color: AppColors.accentRed, fontWeight: FontWeight.bold, fontSize: AppTextSizes.size14),
        const SizedBox(height: 12),
        CommonTextField(
           label: 'Full Name',
           controller: nameCtrl, 
           hintText: 'Enter full name'
        ),
        const SizedBox(height: 16),
        CommonTextField(
           label: 'Business Name',
           controller: busCtrl, 
           hintText: 'Enter business name'
        ),
        const SizedBox(height: 16),
        CommonTextField(
           label: 'Relationship',
           controller: relCtrl, 
           hintText: 'Enter business name' // Placeholder matching screenshot precisely
        ),
      ],
    );
  }

  Widget _buildCheckboxes(SetupGroomApplicationController controller) {
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
      dense: true,
      activeColor: AppColors.primary,
    );
  }
}
