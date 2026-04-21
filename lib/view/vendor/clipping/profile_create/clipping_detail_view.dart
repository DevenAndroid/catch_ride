import 'package:catch_ride/constant/app_colors.dart';
import 'package:catch_ride/constant/app_text_sizes.dart';
import 'package:catch_ride/controllers/vendor/clipping/clipping_details_controller.dart';
import 'package:catch_ride/widgets/common_button.dart';
import 'package:catch_ride/widgets/common_text.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

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
                                keyboardType: TextInputType.number,
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
                  'Add Service',
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

  Widget _buildTravelPreferences(ClippingDetailsController controller) {
    return _buildSectionContainer(
      title: 'Travel Preferences',
      description: 'Select how far you are willing to travel and any applicable fees.',
      children: [
        Obx(() => Column(
          children: controller.travelOptions.map((item) {
            final isSelected = controller.travelFees.containsKey(item);
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: GestureDetector(
                onTap: () {
                  // If already selected, we could toggle off or open to edit
                  // For now, if not selected, open sheet. If selected, open sheet to edit.
                  _showTravelFeeBottomSheet(context, controller, item);
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
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
                      Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: isSelected ? AppColors.primary : AppColors.borderLight),
                          color: isSelected ? AppColors.primary : Colors.transparent,
                        ),
                        child: isSelected ? const Icon(Icons.check, size: 14, color: AppColors.cardColor) : null,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            CommonText(
                              item,
                              fontSize: AppTextSizes.size14,
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                              color: AppColors.textPrimary,
                            ),
                            if (isSelected) ...[
                              const SizedBox(height: 4),
                              CommonText(
                                '${controller.travelFees[item]?['type'] ?? 'No fee'}',
                                fontSize: AppTextSizes.size12,
                                color: AppColors.textSecondary,
                              ),
                            ],
                          ],
                        ),
                      ),
                      if (isSelected) 
                         const Icon(Icons.edit_outlined, size: 18, color: AppColors.textSecondary),
                    ],
                  ),
                ),
              ),
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
          _buildLabelValue('Location', controller.location.value),
          const SizedBox(height: 24),
          _buildLabelValue('Years of Experience', controller.experience.value),
          const SizedBox(height: 24),
          _buildChipsList('Disciplines', 'Select the disciplines you most commonly work with.', controller.disciplines),
          const SizedBox(height: 24),
          _buildChipsList('Typical Level of Horses', 'Select the types of horses you most frequently work with.', controller.horseLevels),
          const SizedBox(height: 24),
          _buildChipsList('Regions Covered', 'Select the regions you most commonly work in.', controller.operatingRegions),
        ],
      );
    });
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
            child: Obx(() => DropdownButton<String>(
                  value: controller.cancellationPolicy.value,
                  hint: const CommonText('Select Cancellation Policy', color: AppColors.textSecondary, fontSize: AppTextSizes.size14),
                  isExpanded: true,
                  icon: const Icon(Icons.keyboard_arrow_down, color: AppColors.textSecondary),
                  items: ['Flexible (24+ hrs)', 'Moderate (48+ hrs)', 'Strict (72+ hrs)'].map((s) => DropdownMenuItem(value: s, child: CommonText(s))).toList(),
                  onChanged: (val) => controller.cancellationPolicy.value = val,
                )),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Obx(() => GestureDetector(
                  onTap: () => controller.isCustomCancellation.value = !controller.isCustomCancellation.value,
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: controller.isCustomCancellation.value ? AppColors.primary : AppColors.cardColor,
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(color: controller.isCustomCancellation.value ? AppColors.primary : AppColors.borderLight),
                    ),
                    child: Icon(Icons.check, size: 16, color: controller.isCustomCancellation.value ? AppColors.cardColor : Colors.transparent),
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
                          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.primary)),
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
    // If editing existing
    if (controller.travelFees.containsKey(option)) {
      final config = controller.travelFees[option]!;
      controller.selectedTravelFeeType.value = config['type'] ?? 'No travel fee';
      controller.travelFeePriceController.text = config['price'] ?? '';
      controller.travelFeeNotesController.text = config['notes'] ?? '';
    } else {
      controller.selectedTravelFeeType.value = 'No travel fee';
      controller.travelFeePriceController.clear();
      controller.travelFeeNotesController.clear();
    }

    final feeOptions = ['No travel fee', 'Flat fee', 'Per-mile', 'Varies by location'];

    Get.bottomSheet(
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      Container(
        padding: EdgeInsets.only(top: 12, left: 24, right: 24, bottom: MediaQuery.of(context).viewInsets.bottom + 32),
        decoration: const BoxDecoration(
          color: AppColors.cardColor,
          borderRadius: BorderRadius.only(topLeft: Radius.circular(24), topRight: Radius.circular(24)),
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 60,
                  height: 4,
                  decoration: BoxDecoration(color: AppColors.borderLight, borderRadius: BorderRadius.circular(2)),
                ),
              ),
              const SizedBox(height: 32),
              CommonText(option, fontSize: AppTextSizes.size22, fontWeight: FontWeight.bold),
              const SizedBox(height: 8),
              CommonText('Set your travel fee structure for ${option.toLowerCase()} appointments', fontSize: AppTextSizes.size12, color: AppColors.textSecondary),
              const SizedBox(height: 24),
              
              Obx(() => Column(
                children: feeOptions.map((type) {
                  final isTypeSelected = controller.selectedTravelFeeType.value == type;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: GestureDetector(
                      onTap: () => controller.selectedTravelFeeType.value = type,
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        decoration: BoxDecoration(
                          color: isTypeSelected ? AppColors.tabBackground : AppColors.tabBackground.withOpacity(0.4),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isTypeSelected ? AppColors.primary : Colors.transparent,
                            width: 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 20,
                              height: 20,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: isTypeSelected ? AppColors.primary : AppColors.borderMedium,
                                  width: isTypeSelected ? 6 : 1,
                                ),
                                color: AppColors.cardColor,
                              ),
                            ),
                            const SizedBox(width: 12),
                            CommonText(type, fontSize: AppTextSizes.size14, fontWeight: isTypeSelected ? FontWeight.bold : FontWeight.w500, color: AppColors.textPrimary),
                          ],
                        ),
                      ),
                    ),
                  );
                }).toList(),
              )),
  
              Obx(() {
                if (controller.selectedTravelFeeType.value != 'No travel fee') {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 12),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.tabBackground,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (controller.selectedTravelFeeType.value != 'Varies by location' && controller.selectedTravelFeeType.value != 'No travel fee')
                               const CommonText('Price', fontSize: AppTextSizes.size14, fontWeight: FontWeight.w600),
                            
                            if (controller.selectedTravelFeeType.value != 'No travel fee') ...[
                              const SizedBox(height: 10),
                              Container(
                                height: 54,
                                decoration: BoxDecoration(
                                  color: AppColors.cardColor,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: AppColors.borderLight),
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 45,
                                      alignment: Alignment.center,
                                      decoration: const BoxDecoration(
                                        border: Border(right: BorderSide(color: AppColors.borderLight)),
                                      ),
                                      child: const CommonText('\$', fontSize: AppTextSizes.size16, fontWeight: FontWeight.w500),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: TextField(
                                        controller: controller.travelFeePriceController,
                                        keyboardType: TextInputType.number,
                                        decoration: const InputDecoration(
                                          hintText: 'Enter price',
                                          hintStyle: TextStyle(color: AppColors.textSecondary, fontSize: 14),
                                          border: InputBorder.none,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
  
                            const SizedBox(height: 16),
                            const CommonText('Travel Notes', fontSize: AppTextSizes.size14, fontWeight: FontWeight.w600),
                            const SizedBox(height: 10),
                            TextField(
                              controller: controller.travelFeeNotesController,
                              maxLines: 3,
                              decoration: InputDecoration(
                                hintText: 'i.e. pricing varies based on distance or number of horses',
                                hintStyle: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
                                filled: true,
                                fillColor: AppColors.cardColor,
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.borderLight)),
                                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.borderLight)),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                }
                return const SizedBox();
              }),
  
              const SizedBox(height: 32),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Get.back(),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        side: const BorderSide(color: AppColors.borderLight),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        backgroundColor: AppColors.cardColor,
                      ),
                      child: const CommonText('Cancel', fontSize: AppTextSizes.size16, fontWeight: FontWeight.w600),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: CommonButton(
                      text: 'Save',
                        backgroundColor: AppColors.primary,
                      onPressed: () {
                        controller.updateTravelFee(
                          option, 
                          controller.selectedTravelFeeType.value,
                          controller.travelFeePriceController.text,
                          controller.travelFeeNotesController.text
                        );
                        Get.back();
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showAddMoreBottomSheet(BuildContext context, ClippingDetailsController controller) {
    Get.bottomSheet(
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      Container(
        padding: EdgeInsets.only(
          top: 12,
          left: 24,
          right: 24,
          bottom: MediaQuery.of(context).viewInsets.bottom + 32,
        ),
        decoration: const BoxDecoration(
          color: AppColors.cardColor,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 60,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.borderLight,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 32),
              const CommonText(
                'Add Service',
                fontSize: AppTextSizes.size22,
                fontWeight: FontWeight.bold,
              ),
              const SizedBox(height: 24),
              const CommonText(
                'Service',
                fontSize: AppTextSizes.size14,
                fontWeight: FontWeight.w600,
              ),
              const SizedBox(height: 10),
              TextField(
                controller: controller.addServiceInputController,
                decoration: InputDecoration(
                  hintText: 'i.e. custom clip, mane pull, trace clip',
                  hintStyle: const TextStyle(color: AppColors.textSecondary, fontSize: 14),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.borderLight),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.borderLight),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.primary),
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                ),
              ),
              const SizedBox(height: 24),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.tabBackground,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const CommonText(
                      'Price per horse',
                      fontSize: AppTextSizes.size14,
                      fontWeight: FontWeight.w600,
                    ),
                    const SizedBox(height: 10),
                    Container(
                      height: 54,
                      decoration: BoxDecoration(
                        color: AppColors.cardColor,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.borderLight),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 45,
                            alignment: Alignment.center,
                            decoration: const BoxDecoration(
                              border: Border(
                                right: BorderSide(color: AppColors.borderLight),
                              ),
                            ),
                            child: const CommonText(
                              '\$',
                              fontSize: AppTextSizes.size16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TextField(
                              controller: controller.addServicePriceController,
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(
                                hintText: 'Enter price',
                                hintStyle: TextStyle(
                                  color: AppColors.textSecondary,
                                  fontSize: 14,
                                ),
                                border: InputBorder.none,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        controller.addServiceInputController.clear();
                        controller.addServicePriceController.clear();
                        Get.back();
                      },
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        side: const BorderSide(color: AppColors.borderLight),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        backgroundColor: AppColors.cardColor,
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
                        controller.addClippingService(
                          controller.addServiceInputController.text,
                          controller.addServicePriceController.text,
                        );
                        Get.back();
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
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

  Widget _buildLabelValue(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CommonText(label, fontSize: AppTextSizes.size14, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: AppColors.tabBackground, 
            borderRadius: BorderRadius.circular(12),
          ),
          child: CommonText(value, fontSize: AppTextSizes.size14, color: AppColors.textPrimary, fontWeight: FontWeight.w500),
        ),
      ],
    );
  }

  Widget _buildChipsList(String label, String description, List<String> items) {
    return _buildSectionContainer(
      title: label,
      description: description,
      children: [
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: items
              .map((it) => Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(color: AppColors.tabBackground, borderRadius: BorderRadius.circular(8)),
                    child: CommonText(it, fontSize: AppTextSizes.size12, color: AppColors.textPrimary),
                  ))
              .toList(),
        ),
      ],
    );
  }
}
