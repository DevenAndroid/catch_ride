import 'package:catch_ride/constant/app_colors.dart';
import 'package:catch_ride/constant/app_text_sizes.dart';
import 'package:catch_ride/controllers/vendor/clipping/clipping_details_controller.dart';
import 'package:catch_ride/widgets/common_button.dart';
import 'package:catch_ride/widgets/common_text.dart';
import 'package:flutter/material.dart';
import 'package:catch_ride/utils/price_formatter.dart';
import 'package:get/get.dart';

import '../../../../widgets/common_textfield.dart';

class ClippingDetailView extends StatefulWidget {
  const ClippingDetailView({super.key});

  @override
  State<ClippingDetailView> createState() => _ClippingDetailViewState();
}

class _ClippingDetailViewState extends State<ClippingDetailView> {
  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ClippingDetailsController());

    return GestureDetector(
      behavior: HitTestBehavior.opaque, // ensures taps are detected on empty space
      onTap: () {
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: Scaffold(
        backgroundColor: AppColors.cardColor,
        appBar: AppBar(
          backgroundColor: AppColors.cardColor,
          elevation: 0,
          centerTitle: false,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, color: AppColors.textPrimary, size: 20),
            onPressed: () => Get.back(),
          ),
          title: const CommonText(
            'Clipping Details',
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
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildServiceSection(
                  title: 'Clipping Services',
                  description: 'Select the services you offer and set your pricing.',
                  services: controller.clippingServices,
                  onAddSkills: () => _showAddMoreBottomSheet(context, controller),
                ),
                const SizedBox(height: 24),
                _buildServiceSection(
                  title: 'Add - Ons',
                  description: 'Optional services offered in addition to standard clipping.',
                  services: controller.addOnServices,
                  onAddSkills: () => _showAddMoreBottomSheet(context, controller, isAddon: true),
                ),
                const SizedBox(height: 24),
                _buildTravelPreferences(controller),
                const SizedBox(height: 24),
                _buildReadOnlyInfo(controller),
                const SizedBox(height: 24),
                _buildCancellationPolicy(controller),
                const SizedBox(height: 32),
                Obx(() => CommonButton(
                  text: 'Continue',
                  isLoading: controller.isSubmitting.value,
                  backgroundColor: AppColors.primary,
                  onPressed: controller.submit,
                )),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildServiceSection({
    required String title,
    required String description,
    required RxList<Map<String, dynamic>> services,
    VoidCallback? onAddSkills,
  }) {
    return _buildSectionContainer(
      title: title,
      description: description,
      children: [
        Obx(() => Column(
          children: services.map((service) {
            final isSelected = service['isSelected'].value;
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: GestureDetector(
                onTap: () => service['isSelected'].value = !isSelected,
                child: Container(
                  padding: const EdgeInsets.all(12),
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
                      Checkbox(
                        value: isSelected,
                        onChanged: (val) => service['isSelected'].value = val!,
                        activeColor: AppColors.primary,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            CommonText(
                              service['name'] as String,
                              fontSize: AppTextSizes.size14,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                            const SizedBox(height: 4),
                            const CommonText(
                              'Per horse',
                              fontSize: AppTextSizes.size12,
                              color: AppColors.textSecondary,
                            ),
                          ],
                        ),
                      ),
                      Container(
                        width: 100,
                        height: 44,
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          color: AppColors.tabBackground,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            const CommonText('\$ ', fontSize: AppTextSizes.size14, color: AppColors.textSecondary),
                            Expanded(
                              child: TextField(
                                controller: service['price'] as TextEditingController,
                                decoration: const InputDecoration(
                                  border: InputBorder.none,
                                  isDense: true,
                                  contentPadding: EdgeInsets.zero,
                                  hintText: '0',
                                  hintStyle: TextStyle(color: AppColors.textSecondary),
                                ),
                                style: const TextStyle(
                                  fontSize: AppTextSizes.size14,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textPrimary,
                                ),
                                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                inputFormatters: [PriceInputFormatter()],
                                textAlign: TextAlign.center,
                                onTap: () {
                                  // Auto-select if price is being typed
                                  service['isSelected'].value = true;
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        )),
        if (onAddSkills != null) ...[
          const SizedBox(height: 12),
          GestureDetector(
            onTap: onAddSkills,
            child: Row(
              children: [
                Icon(Icons.add, size: 18, color: AppColors.linkBlue),
                SizedBox(width: 4),
                CommonText(
                  'Add Skills',
                  color: AppColors.linkBlue,
                  fontWeight: FontWeight.bold,
                  fontSize: AppTextSizes.size14,
                ),
              ],
            ),
          ),
        ],
      ],
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
                onTap: onEdit ?? onTap,
                child: const Icon(Icons.edit_outlined, size: 16, color: AppColors.textSecondary),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildTravelPreferences(ClippingDetailsController controller) {
    return _buildSectionContainer(
      title: 'Travel Preferences',
      description: 'Select how far you are willing to travel and any applicable fees.',
      children: [
        Obx(() => Column(
          children: controller.travelOptions.map((opt) {
            final details = controller.travelFees[opt];
            String? summary;
            if (details != null) {
              summary = '${details['type']}';
              if (details['price'].toString().isNotEmpty) summary += ': \$${details['price']}';
            }
            return _buildCheckItem(
              title: opt,
              isSelected: controller.travelFees.containsKey(opt),
              subTitle: summary,
              onTap: () {
                if (controller.travelFees.containsKey(opt)) {
                  controller.travelFees.remove(opt);
                } else {
                  _showTravelFeeBottomSheet(context, controller, opt);
                }
              },
              onEdit: () {
                _showTravelFeeBottomSheet(context, controller, opt);
              },
            );
          }).toList(),
        )),
      ],
    );
  }

  Widget _buildReadOnlyInfo(ClippingDetailsController controller) {
    return Obx(() {
      if (controller.isLoading.value) {
        return const Center(child: Padding(padding: EdgeInsets.all(20), child: CircularProgressIndicator()));
      }
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSummaryItem('Location', controller.location.value),
          const SizedBox(height: 24),
          _buildEditableExperience(controller),
          const SizedBox(height: 24),
          _buildEditableChips('Disciplines', 'Select the disciplines you most commonly work with.', controller.disciplines, controller.disciplineOptions, controller.toggleDiscipline),
          const SizedBox(height: 24),
          _buildEditableChips('Typical Level of Horses', 'Select the types of horses you most frequently work with.', controller.horseLevels, controller.horseLevelOptions, controller.toggleHorseLevel),
          const SizedBox(height: 24),
          _buildEditableRegions(controller),
        ],
      );
    });
  }

  Widget _buildSummaryItem(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CommonText(label, fontSize: AppTextSizes.size14, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: Colors.white, 
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.borderLight),
          ),
          child: CommonText(value, fontSize: AppTextSizes.size14, color: AppColors.textPrimary, fontWeight: FontWeight.w500),
        ),
      ],
    );
  }

  Widget _buildEditableExperience(ClippingDetailsController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const CommonText('Years of Experience', fontSize: AppTextSizes.size14, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
        const SizedBox(height: 12),
        Obx(() => GestureDetector(
          onTap: () => _showPickerBottomSheet(
            title: 'Experience',
            currentValue: controller.experience.value,
            options: controller.experienceOptions,
            onSelected: (val) => controller.experience.value = val,
          ),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: Colors.white, 
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.borderLight),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: CommonText(controller.experience.value ?? 'Select years of experience', fontSize: AppTextSizes.size14, color: controller.experience.value == null ? AppColors.textSecondary : AppColors.textPrimary, fontWeight: FontWeight.w500),
                ),
                const Icon(Icons.keyboard_arrow_down, color: AppColors.textSecondary, size: 20),
              ],
            ),
          ),
        )),
      ],
    );
  }

  Widget _buildEditableChips(String label, String description, RxList<String> selectedItems, RxList<String> allOptions, Function(String) onToggle) {
    return _buildSectionContainer(
      title: label,
      description: description,
      children: [
        Obx(() => Wrap(
          spacing: 8,
          runSpacing: 8,
          children: allOptions.map((it) {
            final isSelected = selectedItems.contains(it);
            return GestureDetector(
              onTap: () => onToggle(it),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected ? const Color(0xFFF5F8FF) : Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: isSelected ? AppColors.primaryDark : AppColors.borderLight),
                ),
                child: CommonText(
                  it, 
                  fontSize: 12, 
                  color: isSelected ? AppColors.primaryDark : AppColors.textPrimary,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                ),
              ),
            );
          }).toList(),
        )),
      ],
    );
  }

  Widget _buildEditableRegions(ClippingDetailsController controller) {
    return _buildSectionContainer(
      title: 'Regions Covered',
      description: 'Select the regions you most commonly work in.',
      children: [
        Obx(() => Column(
          children: [
            GestureDetector(
              onTap: () => _showMultiSelectBottomSheet(
                title: 'Select Regions',
                options: controller.regionOptions,
                selectedItems: controller.operatingRegions,
                onToggle: controller.toggleRegion,
              ),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),

                decoration: BoxDecoration(
                  color: Colors.white, 
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.borderLight),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    CommonText('Select regions...', fontSize: 13, color: AppColors.textSecondary, fontWeight: FontWeight.w500),
                    const Icon(Icons.add, color: AppColors.primary, size: 20),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: controller.operatingRegions.map((region) => Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFFF9FAFB),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.borderLight),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Flexible(
                      child: CommonText(region, fontSize: 12, color: AppColors.textPrimary, fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(width: 4),
                    GestureDetector(
                      onTap: () => controller.toggleRegion(region),
                      child: const Icon(Icons.close, size: 14, color: AppColors.textSecondary),
                    ),
                  ],
                ),
              )).toList(),
            ),
          ],
        )),
      ],
    );
  }

  void _showPickerBottomSheet({required String title, String? currentValue, required List<String> options, required Function(String) onSelected}) {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CommonText(title, fontSize: 20, fontWeight: FontWeight.bold),
            const SizedBox(height: 24),
            ...options.map((opt) {
              final isSelected = opt == currentValue;
              return ListTile(
                title: Center(child: CommonText(opt, color: isSelected ? AppColors.primary : AppColors.textPrimary, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal)),
                onTap: () {
                  onSelected(opt);
                  Get.back();
                },
              );
            }),
          ],
        ),
      ),
    );
  }

  void _showMultiSelectBottomSheet({required String title, required List<String> options, required RxList<String> selectedItems, required Function(String) onToggle}) {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CommonText(title, fontSize: 20, fontWeight: FontWeight.bold),
            const SizedBox(height: 24),
            Expanded(
              child: ListView(
                children: options.map((opt) => Obx(() => CheckboxListTile(
                  title: CommonText(opt),
                  value: selectedItems.contains(opt),
                  onChanged: (val) => onToggle(opt),
                  activeColor: AppColors.primary,
                ))).toList(),
              ),
            ),
            CommonButton(text: 'Done', onPressed: () => Get.back()),
          ],
        ),
      ),
    );
  }

  Widget _buildCancellationPolicy(ClippingDetailsController controller) {
    return _buildSectionContainer(
      title: 'Cancellation Policy',
      description: 'Set your cancellation preferences for bookings.',
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.borderLight),
          ),
          child: DropdownButtonHideUnderline(
            child: Obx(() {
              final raw = controller.cancellationPolicy.value;
              final allowed = ClippingDetailsController.cancellationPolicyOptions;
              final ok = raw != null &&
                  raw.isNotEmpty &&
                  allowed.contains(raw) &&
                  !controller.isCustomCancellation.value;
              return DropdownButton<String>(
                value: ok ? raw : null,
                hint: const CommonText('Select Cancellation Policy',
                    color: AppColors.textSecondary,
                    fontSize: AppTextSizes.size14),
                isExpanded: true,
                icon: const Icon(Icons.keyboard_arrow_down,
                    color: AppColors.textSecondary),
                items: ClippingDetailsController.cancellationPolicyOptions
                    .map((s) =>
                        DropdownMenuItem(value: s, child: CommonText(s)))
                    .toList(),
                onChanged: (val) => controller.cancellationPolicy.value = val,
              );
            }),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Obx(() => GestureDetector(
                  onTap: () {
                    final next = !controller.isCustomCancellation.value;
                    controller.isCustomCancellation.value = next;
                    if (next) controller.cancellationPolicy.value = null;
                  },
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: controller.isCustomCancellation.value ? AppColors.primaryDark : Colors.white,
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(color: controller.isCustomCancellation.value ? AppColors.primaryDark : AppColors.borderLight),
                    ),
                    child: Icon(Icons.check, size: 16, color: controller.isCustomCancellation.value ? Colors.white : Colors.transparent),
                  ),
                )),
            const SizedBox(width: 8),
            const CommonText('Custom', fontSize: AppTextSizes.size14, fontWeight: FontWeight.w500),
          ],
        ),
        Obx(() => AnimatedSize(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              child: controller.isCustomCancellation.value
                  ? Padding(
                      padding: const EdgeInsets.only(top: 16),
                      child: TextField(
                        controller: controller.customCancellationController,
                        maxLines: 4,
                        decoration: InputDecoration(
                          hintText: 'Write here...',
                          hintStyle: const TextStyle(color: AppColors.textSecondary, fontSize: 14),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.borderLight)),
                          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.borderLight)),
                          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.primaryDark)),
                          contentPadding: const EdgeInsets.all(16),
                        ),
                      ),
                    )
                  : const SizedBox(height: 0, width: double.infinity),
            )),
      ],
    );
  }

  void _showTravelFeeBottomSheet(BuildContext context, ClippingDetailsController controller, String option) {
    final existing = controller.travelFees[option] ?? {
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
                          controller.updateTravelFee(
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

  void _showAddMoreBottomSheet(BuildContext context, ClippingDetailsController controller, {bool isAddon = false}) {
    Get.bottomSheet(
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      Container(
        padding: EdgeInsets.only(
          top: 10,
          left: 20,
          right: 20,
          bottom: MediaQuery.of(context).viewInsets.bottom + 20,
        ),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 50,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 24),
            const CommonText(
              'Add More Service',
              fontSize: AppTextSizes.size22,
              fontWeight: FontWeight.bold,
            ),
            const SizedBox(height: 24),
            const CommonText(
              'Skill',
              fontSize: AppTextSizes.size14,
              fontWeight: FontWeight.w600,
            ),
            const SizedBox(height: 8),
            TextField(
              controller: controller.addServiceInputController,
              decoration: InputDecoration(
                hintText: 'Enter your skill',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.borderLight),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              ),
            ),
            const SizedBox(height: 32),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      controller.addServiceInputController.clear();
                      Get.back();
                    },
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      side: const BorderSide(color: AppColors.borderLight),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const CommonText(
                      'Cancel',
                      fontSize: AppTextSizes.size16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: CommonButton(
                    text: 'Save',
                    backgroundColor: AppColors.primary,
                    onPressed: () {
                      if (isAddon) {
                        if (controller.addServiceInputController.text.isNotEmpty) {
                          controller.addOnServices.add({
                            'name': controller.addServiceInputController.text,
                            'isSelected': true.obs,
                            'price': TextEditingController(),
                          });
                          controller.addServiceInputController.clear();
                        }
                      } else {
                        controller.addClippingService(
                          controller.addServiceInputController.text,
                        );
                      }
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

  // --- Helpers ---
  Widget _buildSectionContainer({required String title, String? description, required List<Widget> children}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.cardColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.borderLight),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 16, offset: const Offset(0, 4)),
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
          ...children,
        ],
      ),
    );
  }

}
