import 'package:catch_ride/constant/app_colors.dart';
import 'package:catch_ride/constant/app_text_sizes.dart';
import 'package:catch_ride/controllers/vendor/farrier/farrier_details_controller.dart';
import 'package:catch_ride/widgets/common_button.dart';
import 'package:catch_ride/widgets/common_text.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class FarrierDetailsView extends StatelessWidget {
  const FarrierDetailsView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(FarrierDetailsController());

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: AppColors.textPrimary, size: 20),
          onPressed: () => Get.back(),
        ),
        title: CommonText(
          'Farrier Details',
          fontSize: AppTextSizes.size18,
          fontWeight: FontWeight.bold,
          color: AppColors.textPrimary,
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(color: AppColors.border, height: 1.0),
        ),
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator(color: AppColors.primary));
        }
        return SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildServiceSection(
                  context,
                  title: 'Farrier Services',
                  description: 'Select the services you offer and set your pricing.',
                  subtitle: 'Prices listed are for baseline labor/materials.',
                  services: controller.farrierServices,
                  onAdd: () => _showAddServiceBottomSheet(context, controller, isAddOn: false),
                ),
                const SizedBox(height: 24),
                _buildServiceSection(
                  context,
                  title: 'Add - Ons',
                  description: 'Optional services or materials at all time available to your standard work.',
                  services: controller.addOns,
                  onAdd: () => _showAddServiceBottomSheet(context, controller, isAddOn: true),
                ),
                const SizedBox(height: 24),
                _buildTravelPreferences(context, controller),
                const SizedBox(height: 24),
                _buildClientIntake(controller),
                const SizedBox(height: 24),
                _buildInsuranceStatus(controller),
                const SizedBox(height: 24),
                _buildSummaryInfo(controller),
                const SizedBox(height: 24),
                _buildCancellationPolicy(controller),
                const SizedBox(height: 40),
                CommonButton(
                  text: 'Continue',
                  isLoading: controller.isSubmitting.value,
                  backgroundColor: AppColors.primaryDark,
                  onPressed: controller.submit,
                  height: 56,
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        );
      }),
    );
  }

  Widget _buildServiceSection(
    BuildContext context, {
    required String title,
    required String description,
    String? subtitle,
    required RxList<Map<String, dynamic>> services,
    required VoidCallback onAdd,
  }) {
    return _buildSectionContainer(
      title: title,
      description: description,
      children: [
        if (subtitle != null) ...[
          CommonText(subtitle, fontSize: AppTextSizes.size12, color: AppColors.textSecondary),
          const SizedBox(height: 16),
        ],
        Column(
          children: services.map((service) {
            final isSelected = service['isSelected'] as RxBool;
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Obx(() => Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isSelected.value ? AppColors.primary : AppColors.borderLight,
                    width: isSelected.value ? 1.5 : 1,
                  ),
                ),
                child: Row(
                  children: [
                    Checkbox(
                      value: isSelected.value,
                      onChanged: (val) => isSelected.value = val!,
                      activeColor: AppColors.primary,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
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
                          CommonText('Per horse', fontSize: AppTextSizes.size12, color: AppColors.textSecondary),
                        ],
                      ),
                    ),
                    Container(
                      width: 90,
                      height: 40,
                      decoration: BoxDecoration(
                        color: AppColors.tabBackground,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          const SizedBox(width: 12),
                          CommonText('\$', fontSize: AppTextSizes.size14, color: AppColors.textSecondary),
                          Expanded(
                            child: TextField(
                              controller: service['price'] as TextEditingController,
                              keyboardType: TextInputType.number,
                              textAlign: TextAlign.center,
                              style: TextStyle(fontSize: AppTextSizes.size14, fontWeight: FontWeight.bold),
                              decoration: const InputDecoration(
                                border: InputBorder.none,
                                isDense: true,
                                contentPadding: EdgeInsets.zero,
                              ),
                              onChanged: (val) {
                                if (val.isNotEmpty) isSelected.value = true;
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              )),
            );
          }).toList(),
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: onAdd,
          child: const Row(
            children: [
              Icon(Icons.add, color: AppColors.primary, size: 18),
              SizedBox(width: 4),
              CommonText(
                'Add service',
                color: AppColors.primary,
                fontWeight: FontWeight.bold,
                fontSize: AppTextSizes.size14,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTravelPreferences(BuildContext context, FarrierDetailsController controller) {
    return _buildSectionContainer(
      title: 'Travel Preferences',
      description: 'Select how far you are willing to travel and any applicable fees.',
      children: [
        Column(
          children: controller.travelCategories.map((opt) {
            final config = controller.travelConfigurations[opt];
            final feeText = config?['type'] ?? 'No travel fee';
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Obx(() {
                final isSelected = controller.selectedTravel.value == opt;
                return GestureDetector(
                  onTap: () => _showTravelFeeBottomSheet(context, controller, opt),
                  child: Container(
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
                        Container(
                          width: 20,
                          height: 20,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: isSelected ? AppColors.primary : AppColors.borderLight),
                            color: isSelected ? AppColors.primary : Colors.transparent,
                          ),
                          child: isSelected ? const Icon(Icons.check, color: Colors.white, size: 12) : null,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              CommonText(
                                opt,
                                fontSize: AppTextSizes.size14,
                                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                color: AppColors.textPrimary,
                              ),
                              CommonText(feeText, fontSize: AppTextSizes.size12, color: AppColors.textSecondary),
                            ],
                          ),
                        ),
                        if (isSelected) 
                          const Icon(Icons.edit_outlined, size: 18, color: AppColors.textSecondary),
                      ],
                    ),
                  ),
                );
              }),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildClientIntake(FarrierDetailsController controller) {
    return _buildSectionContainer(
      title: 'Client Intake + Scheduling',
      description: 'Set your availability and client preferences.',
      children: [
        CommonText('New Client Policy', fontSize: AppTextSizes.size14, fontWeight: FontWeight.bold),
        const SizedBox(height: 12),
        Column(
          children: controller.clientPolicies.map((policy) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Obx(() {
                final isSelected = controller.selectedPolicy.value == policy;
                return GestureDetector(
                  onTap: () => controller.selectedPolicy.value = policy,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected ? AppColors.primary : AppColors.borderLight,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          isSelected ? Icons.radio_button_checked : Icons.radio_button_off,
                          color: isSelected ? AppColors.primary : AppColors.borderLight,
                          size: 20,
                        ),
                        const SizedBox(width: 12),
                        CommonText(policy, fontSize: AppTextSizes.size14, color: AppColors.textPrimary),
                      ],
                    ),
                  ),
                );
              }),
            );
          }).toList(),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            CommonText('Minimum horses per stop', fontSize: AppTextSizes.size14, fontWeight: FontWeight.w500),
            Container(
              decoration: BoxDecoration(
                color: AppColors.tabBackground,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => controller.minHorsesPerStop.value > 1 ? controller.minHorsesPerStop.value-- : null,
                    icon: const Icon(Icons.remove, size: 18),
                    constraints: const BoxConstraints(),
                    padding: const EdgeInsets.all(8),
                  ),
                  Obx(() => CommonText('${controller.minHorsesPerStop.value}', fontSize: AppTextSizes.size14, fontWeight: FontWeight.bold)),
                  IconButton(
                    onPressed: () => controller.minHorsesPerStop.value++,
                    icon: const Icon(Icons.add, size: 18),
                    constraints: const BoxConstraints(),
                    padding: const EdgeInsets.all(8),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            CommonText('Emergency support', fontSize: AppTextSizes.size14, fontWeight: FontWeight.w500),
            Obx(() => CupertinoSwitch(
              value: controller.emergencySupport.value,
              activeColor: const Color(0xFF34C759),
              onChanged: (val) => controller.emergencySupport.value = val,
            )),
          ],
        ),
      ],
    );
  }

  Widget _buildInsuranceStatus(FarrierDetailsController controller) {
    return _buildSectionContainer(
      title: 'Insurance Status',
      description: 'Keep client insurance information up-to-date to maintain safety and ease of use standards.',
      children: [
        Column(
          children: controller.insuranceOptions.map((opt) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Obx(() {
                final isSelected = controller.selectedInsurance.value == opt;
                return GestureDetector(
                  onTap: () => controller.selectedInsurance.value = opt,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected ? AppColors.primary : AppColors.borderLight,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          isSelected ? Icons.radio_button_checked : Icons.radio_button_off,
                          color: isSelected ? AppColors.primary : AppColors.borderLight,
                          size: 20,
                        ),
                        const SizedBox(width: 12),
                        CommonText(opt, fontSize: AppTextSizes.size14, color: AppColors.textPrimary),
                      ],
                    ),
                  ),
                );
              }),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildSummaryInfo(FarrierDetailsController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSummaryItem('Location', controller.location.value),
        const SizedBox(height: 24),
        _buildSummaryItem('Years of Experience', controller.experience.value),
        const SizedBox(height: 24),
        _buildSummaryChips('Disciplines', 'Select the disciplines you most commonly work with.', controller.disciplines),
        const SizedBox(height: 24),
        _buildSummaryChips('Typical level of Horses', 'Select the types of horses you most frequently work with.', controller.horseLevels),
        const SizedBox(height: 24),
        _buildSummaryChips('Regions Covered', 'Select the regions you most commonly work in.', controller.regionsCovered),
      ],
    );
  }

  Widget _buildSummaryItem(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CommonText(label, fontSize: AppTextSizes.size16, fontWeight: FontWeight.bold),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          decoration: BoxDecoration(
            color: AppColors.tabBackground,
            borderRadius: BorderRadius.circular(12),
          ),
          child: CommonText(value, fontSize: AppTextSizes.size14, color: AppColors.textPrimary),
        ),
      ],
    );
  }

  Widget _buildSummaryChips(String label, String description, List<String> items) {
    return _buildSectionContainer(
      title: label,
      description: description,
      children: [
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: items.map((it) => Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.tabBackground,
              borderRadius: BorderRadius.circular(8),
            ),
            child: CommonText(it, fontSize: AppTextSizes.size12, color: AppColors.textPrimary),
          )).toList(),
        ),
      ],
    );
  }

  Widget _buildCancellationPolicy(FarrierDetailsController controller) {
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
              hint: CommonText('Select Cancellation Policy', color: AppColors.textSecondary, fontSize: AppTextSizes.size14),
              isExpanded: true,
              items: ['Flexible (24+ hrs)', 'Moderate (48+ hrs)', 'Strict (72+ hrs)'].map((s) => DropdownMenuItem(value: s, child: CommonText(s))).toList(),
              onChanged: (val) => controller.cancellationPolicy.value = val,
            )),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Obx(() => Checkbox(
              value: controller.isCustomCancellation.value,
              onChanged: (val) => controller.isCustomCancellation.value = val!,
              activeColor: AppColors.primary,
            )),
            CommonText('Custom', fontSize: AppTextSizes.size14),
          ],
        ),
      ],
    );
  }

  Widget _buildSectionContainer({required String title, String? description, required List<Widget> children}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.borderLight),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 16, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CommonText(title, fontSize: AppTextSizes.size20, fontWeight: FontWeight.bold),
          if (description != null) ...[
            const SizedBox(height: 6),
            CommonText(description, fontSize: AppTextSizes.size14, color: AppColors.textSecondary),
          ],
          const SizedBox(height: 20),
          ...children,
        ],
      ),
    );
  }

  void _showTravelFeeBottomSheet(BuildContext context, FarrierDetailsController controller, String category) {
    final config = controller.travelConfigurations[category]!;
    controller.tempSelectedFeeType.value = config['type'] ?? 'No travel fee';
    controller.travelFeePriceController.text = config['price'] ?? '';
    controller.travelFeeDisclaimerController.text = config['disclaimer'] ?? '';

    final feeOptions = ['No travel fee', 'Flat fee', 'Per-mile', 'Varies by location'];

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
                width: 60,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.borderLight,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 32),
            CommonText(category, fontSize: AppTextSizes.size22, fontWeight: FontWeight.bold),
            const SizedBox(height: 8),
            CommonText(
              'Set pricing based on travel distance or location',
              fontSize: AppTextSizes.size14,
              color: AppColors.textSecondary,
            ),
            const SizedBox(height: 24),
            Obx(() => Column(
              children: feeOptions.map((type) {
                final isTypeSelected = controller.tempSelectedFeeType.value == type;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: GestureDetector(
                    onTap: () => controller.tempSelectedFeeType.value = type,
                    child: Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: isTypeSelected ? AppColors.tabBackground : AppColors.tabBackground.withOpacity(0.4),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isTypeSelected ? AppColors.primary : Colors.transparent,
                          width: 1,
                        ),
                      ),
                      child: Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                            child: Row(
                              children: [
                                Icon(
                                  isTypeSelected ? Icons.radio_button_checked : Icons.radio_button_off,
                                  color: isTypeSelected ? AppColors.primaryDark : AppColors.borderLight,
                                  size: 20,
                                ),
                                const SizedBox(width: 12),
                                CommonText(type, fontSize: AppTextSizes.size14, fontWeight: isTypeSelected ? FontWeight.bold : FontWeight.normal, color: AppColors.textPrimary),
                              ],
                            ),
                          ),
                          if (isTypeSelected && type != 'No travel fee')
                            Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                children: [
                                  Container(
                                    height: 54,
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(color: AppColors.borderLight),
                                    ),
                                    child: Row(
                                      children: [
                                        Container(
                                          width: 45,
                                          alignment: Alignment.center,
                                          decoration: BoxDecoration(
                                            border: Border(
                                              right: BorderSide(color: AppColors.borderLight),
                                            ),
                                          ),
                                          child: CommonText(
                                            '\$',
                                            fontSize: AppTextSizes.size16,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: TextField(
                                            controller: controller.travelFeePriceController,
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
                                  const SizedBox(height: 12),
                                  TextField(
                                    controller: controller.travelFeeDisclaimerController,
                                    maxLines: 4,
                                    decoration: InputDecoration(
                                      hintText: 'Disclaimer',
                                      hintStyle: const TextStyle(color: AppColors.textSecondary, fontSize: 14),
                                      filled: true,
                                      fillColor: Colors.white,
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: const BorderSide(color: AppColors.borderLight),
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: const BorderSide(color: AppColors.borderLight),
                                      ),
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
            const SizedBox(height: 32),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Get.back(),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      side: const BorderSide(color: AppColors.borderLight),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      backgroundColor: Colors.white,
                    ),
                    child: CommonText(
                      'Cancel',
                      fontSize: AppTextSizes.size16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: CommonButton(
                    text: 'Save',
                    backgroundColor: AppColors.primaryDark,
                    onPressed: () {
                      controller.saveTravelConfig(category);
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

  void _showAddServiceBottomSheet(BuildContext context, FarrierDetailsController controller, {required bool isAddOn}) {
    final nameController = TextEditingController();
    final priceController = TextEditingController();
    
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
                width: 60,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.borderLight,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 32),
            CommonText(
              'Add Service',
              fontSize: AppTextSizes.size22,
              fontWeight: FontWeight.bold,
            ),
            const SizedBox(height: 8),
            CommonText(
              'Set your standard rate for this service',
              fontSize: AppTextSizes.size14,
              color: AppColors.textSecondary,
            ),
            const SizedBox(height: 24),
            CommonText(
              'Service',
              fontSize: AppTextSizes.size14,
              fontWeight: FontWeight.bold,
            ),
            const SizedBox(height: 10),
            TextField(
              controller: nameController,
              decoration: InputDecoration(
                hintText: 'Enter Your Service',
                hintStyle: const TextStyle(color: AppColors.textSecondary, fontSize: 16),
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
                  CommonText(
                    'Price per horse',
                    fontSize: AppTextSizes.size14,
                    fontWeight: FontWeight.bold,
                  ),
                  const SizedBox(height: 10),
                  Container(
                    height: 54,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.borderLight),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 45,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            border: Border(
                              right: BorderSide(color: AppColors.borderLight),
                            ),
                          ),
                          child: CommonText(
                            '\$',
                            fontSize: AppTextSizes.size16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextField(
                            controller: priceController,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              hintText: 'Enter price',
                              hintStyle: TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 16,
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
                    onPressed: () => Get.back(),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      side: const BorderSide(color: AppColors.borderLight),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      backgroundColor: Colors.white,
                    ),
                    child: CommonText(
                      'Cancel',
                      fontSize: AppTextSizes.size16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: CommonButton(
                    text: 'Save',
                    backgroundColor: AppColors.primaryDark,
                    onPressed: () {
                      if (nameController.text.isNotEmpty) {
                        controller.addService(nameController.text, isAddOn: isAddOn);
                        // Update price if entered
                        final list = isAddOn ? controller.addOns : controller.farrierServices;
                        final service = list.firstWhere((s) => s['name'] == nameController.text);
                        (service['price'] as TextEditingController).text = priceController.text;
                        Get.back();
                      }
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
}
