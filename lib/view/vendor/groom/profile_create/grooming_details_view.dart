import 'package:catch_ride/constant/app_colors.dart';
import 'package:catch_ride/constant/app_text_sizes.dart';
import 'package:catch_ride/controllers/vendor/groom/grooming_details_controller.dart';
import 'package:catch_ride/widgets/common_button.dart';
import 'package:catch_ride/widgets/common_text.dart';
import 'package:catch_ride/widgets/common_textfield.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class GroomingDetailsView extends StatefulWidget {
  const GroomingDetailsView({super.key});

  @override
  State<GroomingDetailsView> createState() => _GroomingDetailsViewState();
}

class _GroomingDetailsViewState extends State<GroomingDetailsView> {
  @override
  Widget build(BuildContext context) {
    final controller = Get.put(GroomingDetailsController());

    return GestureDetector(
      behavior: HitTestBehavior.opaque, // ensures taps are detected on empty space
      onTap: () {
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          centerTitle: false,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, color: AppColors.textPrimary, size: 20),
            onPressed: () => Get.back(),
          ),
          title: const CommonText(
            'Grooming Details',
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
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildRateSection(controller),
                const SizedBox(height: 16),
                _buildGroomingServices(controller),
                const SizedBox(height: 16),
                _buildSupportSection(controller),
                const SizedBox(height: 16),
                _buildHorseHandling(controller),
                const SizedBox(height: 16),
                _buildAdditionalServices(controller),
                const SizedBox(height: 16),
                _buildTravelPreferences(controller),
                const SizedBox(height: 16),
                _buildReadOnlyInfo(controller),
                const SizedBox(height: 16),
                _buildCancellationPolicy(controller),
                const SizedBox(height: 32),
                Obx(() => CommonButton(
                  text: 'Continue',
                  isLoading: controller.isSubmitting.value,
                  backgroundColor: const Color(0xFF001144),
                  onPressed: controller.submit,
                )),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),

      ),
    );
  }

  Widget _buildGroomingServices(GroomingDetailsController controller) {
    return _buildSectionContainer(
      title: 'Grooming Services',
      description: 'Select your grooming skills',
      children: [
        Obx(() => Wrap(
              spacing: 8,
              runSpacing: 8,
              children: controller.groomingServicesList.map((service) {
                final isSelected = controller.selectedGroomingServices.contains(service);
                return _buildSelectableChip(
                  service,
                  isSelected: isSelected,
                  onTap: () => controller.toggleGroomingService(service),
                );
              }).toList(),
            )),
        const SizedBox(height: 12),
        _buildActionLink('+ Add Service', onTap: () => _showAddServiceBottomSheet(context, controller)),
      ],
    );
  }

  Widget _buildRateSection(GroomingDetailsController controller) {
    return _buildSectionContainer(
      title: 'Rates',
      description: 'Set your standard rates below, so how you quickly work',
      children: [
        _buildPriceField('Daily Rate', controller.dailyRateController),
        const SizedBox(height: 20),
        _buildPriceField('Weekly Rate', controller.weeklyRateController, showDaysToggle: true, daysRx: controller.weeklyRateDays),
        const SizedBox(height: 20),
        _buildPriceField('Monthly Rate', controller.monthlyRateController, showDaysToggle: true, daysRx: controller.monthlyRateDays),
      ],
    );
  }

  Widget _buildSupportSection(GroomingDetailsController controller) {
    return _buildSectionContainer(
      title: 'Show & Barn Support',
      children: [
        Obx(() => Wrap(
          spacing: 8,
          runSpacing: 8,
          children: controller.supportOptions.map((item) {
            final isSelected = controller.selectedSupport.contains(item);
            return _buildSelectableChip(item, isSelected: isSelected, onTap: () => controller.toggleSupport(item));
          }).toList(),
        )),
      ],
    );
  }

  Widget _buildHorseHandling(GroomingDetailsController controller) {
    return _buildSectionContainer(
      title: 'Horse Handling',
      children: [
        Obx(() => Wrap(
          spacing: 8,
          runSpacing: 8,
          children: controller.handlingOptions.map((item) {
            final isSelected = controller.selectedHandling.contains(item);
            return _buildSelectableChip(item, isSelected: isSelected, onTap: () => controller.toggleHandling(item));
          }).toList(),
        )),
      ],
    );
  }

  Widget _buildAdditionalServices(GroomingDetailsController controller) {
    return _buildSectionContainer(
      title: 'Additional Services',
      description: 'Optional services offered in addition to your standard work',
      children: [
        Obx(() => Column(
          children: controller.additionalServices.map((service) {
            final isSelected = service['isSelected'].value;
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: isSelected ? const Color(0xFF001144) : const Color(0xFFF0F0F0)),
              ),
              child: Row(
                children: [
                  Checkbox(
                    value: isSelected,
                    onChanged: (val) => service['isSelected'].value = val!,
                    activeColor: const Color(0xFF001144),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CommonText(service['name'] as String, fontSize: 13, fontWeight: FontWeight.bold, color: const Color(0xFF1A1A1A)),
                        const CommonText('Per horse', fontSize: 11, color: AppColors.textSecondary),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Container(
                    width: 80,
                    height: 40,
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF5F5F5),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        const CommonText('\$', fontSize: 13, fontWeight: FontWeight.bold),
                        const SizedBox(width: 4),
                        Expanded(
                          child: TextField(
                            controller: service['price'] as TextEditingController,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              hintText: '0',
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.zero,
                              isDense: true,
                            ),
                            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        )),
        const SizedBox(height: 8),
        _buildActionLink('Add Service', onTap: () => _showAddServiceBottomSheet(context, controller, isAdditional: true)),
      ],
    );
  }


  Widget _buildTravelPreferences(GroomingDetailsController controller) {
    return _buildSectionContainer(
      title: 'Travel Preferences',
      children: [
        Obx(() => Wrap(
          spacing: 8,
          runSpacing: 8,
          children: controller.travelOptions.map((item) {
            final isSelected = controller.selectedTravel.contains(item);
            return _buildSelectableChip(item, isSelected: isSelected, onTap: () => controller.toggleTravel(item));
          }).toList(),
        )),
      ],
    );
  }

  Widget _buildReadOnlyInfo(GroomingDetailsController controller) {
    return Obx(() {
      if (controller.isLoading.value) {
        return const Center(
          child: Padding(
            padding: EdgeInsets.all(20.0),
            child: CircularProgressIndicator(),
          ),
        );
      }
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildLabelValue('Location', controller.location.value),
          const SizedBox(height: 20),
          _buildLabelValue('Years of Experience', controller.experience.value),
          const SizedBox(height: 24),
          _buildChipsList('Disciplines', controller.disciplinesSelected),
          const SizedBox(height: 24),
          _buildSectionHeader('Typical Level of Horses'),
          const SizedBox(height: 4),
          const CommonText('Select the level of horses you have the most experience with', fontSize: 13, color: AppColors.textSecondary, height: 1.4),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: controller.horseLevels
                .map((it) => Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFFF2F2F2),
                borderRadius: BorderRadius.circular(100),
              ),
              child: CommonText(it, fontSize: 12, fontWeight: FontWeight.w500, color: const Color(0xFF444444)),
            ))
                .toList(),
          ),
          const SizedBox(height: 24),
          _buildSectionHeader('Regions Covered'),
          const SizedBox(height: 4),
          const CommonText('Select the regions you have the most experience with', fontSize: 13, color: AppColors.textSecondary, height: 1.4),
          const SizedBox(height: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: controller.operatingRegions
                .map((r) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  color: const Color(0xFFF9F9F9),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFEEEEEE)),
                ),
                child: CommonText(r, fontSize: 13, color: const Color(0xFF1A1A1A), fontWeight: FontWeight.w500),
              ),
            ))
                .toList(),
          ),
        ],
      );
    });
  }

  Widget _buildCancellationPolicy(GroomingDetailsController controller) {
    return _buildSectionContainer(
      title: 'Cancellation Policy',
      description: 'Set your cancellation preference for bookings',
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: const Color(0xFFF9F9F9),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFEEEEEE)),
          ),
          child: DropdownButtonHideUnderline(
            child: Obx(() => DropdownButton<String>(
              value: controller.cancellationPolicy.value,
              hint: const CommonText('Select Cancellation Policy', color: AppColors.textSecondary, fontSize: 14, fontWeight: FontWeight.w500),
              isExpanded: true,
              icon: const Icon(Icons.keyboard_arrow_down, color: Color(0xFF999999)),
              items: ['Flexible (24+ hrs)', 'Moderate (48+ hrs)', 'Strict (72+ hrs)'].map((s) => DropdownMenuItem(value: s, child: CommonText(s, fontSize: 14, fontWeight: FontWeight.w500, color: const Color(0xFF333333)))).toList(),
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
              activeColor: const Color(0xFF001144),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
            )),
            const CommonText('Custom', fontSize: 14, fontWeight: FontWeight.w500, color: Color(0xFF444444)),
          ],
        ),
        Obx(() => AnimatedSize(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              child: controller.isCustomCancellation.value
                  ? Padding(
                      padding: const EdgeInsets.only(top: 12),
                      child: TextField(
                        controller: controller.customCancellationController,
                        maxLines: 4,
                        decoration: InputDecoration(
                          hintText: 'Write here...',
                          hintStyle: const TextStyle(color: Color(0xFFB0B0B0), fontSize: 14),
                          fillColor: const Color(0xFFF9F9F9),
                          filled: true,
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFEEEEEE))),
                          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFEEEEEE))),
                          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF001144))),
                          contentPadding: const EdgeInsets.all(16),
                        ),
                      ),
                    )
                  : const SizedBox(height: 0, width: double.infinity),
            )),
      ],
    );
  }


  void _showAddServiceBottomSheet(BuildContext context, GroomingDetailsController controller, {bool isAdditional = false}) {
    Get.bottomSheet(
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      Container(
        padding: EdgeInsets.only(top: 10, left: 24, right: 24, bottom: MediaQuery.of(context).viewInsets.bottom + 24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(topLeft: Radius.circular(32), topRight: Radius.circular(32)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 48,
                height: 5,
                decoration: BoxDecoration(color: Colors.grey[200], borderRadius: BorderRadius.circular(10)),
              ),
            ),
            const SizedBox(height: 32),
            CommonText(isAdditional ? 'Additional Services' : 'Add Service', fontSize: AppTextSizes.size20, fontWeight: FontWeight.bold),
            if (isAdditional) ...[
              const SizedBox(height: 4),
              const CommonText('Set your standard rate for this service.', fontSize: AppTextSizes.size14, color: AppColors.textSecondary),
            ],
            const SizedBox(height: 24),
            const CommonText('Service', fontSize: AppTextSizes.size14, fontWeight: FontWeight.bold),
            const SizedBox(height: 10),
            CommonTextField(
              label: '',
              controller: controller.addServiceInputController,
              hintText: 'i.e. grooming, night check, stall prep',
            ),
            if (isAdditional) ...[
              const SizedBox(height: 24),
              const CommonText('Price per horse', fontSize: AppTextSizes.size14, fontWeight: FontWeight.bold),
              const SizedBox(height: 10),
              Container(
                decoration: BoxDecoration(
                  color: AppColors.lightGray.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: CommonTextField(
                  label: '',
                  controller: controller.addServicePriceInputController,
                  hintText: 'Enter price',
                  prefixIcon: const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    child: CommonText('\$', fontSize: AppTextSizes.size16, fontWeight: FontWeight.bold),
                  ),
                  keyboardType: TextInputType.number,
                ),
              ),
            ],
            const SizedBox(height: 40),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      controller.addServiceInputController.clear();
                      controller.addServicePriceInputController.clear();
                      Get.back();
                    },
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      side: BorderSide(color: Colors.grey[300]!),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
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
                      if (isAdditional) {
                        controller.addAdditionalService(
                          controller.addServiceInputController.text,
                          controller.addServicePriceInputController.text,
                        );
                      } else {
                        controller.addGroomingService(controller.addServiceInputController.text);
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
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFF0F0F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader(title),
          if (description != null) ...[
            const SizedBox(height: 6),
            CommonText(description, fontSize: 13, color: AppColors.textSecondary, height: 1.4),
          ],
          const SizedBox(height: 20),
          ...children,
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return CommonText(title, fontSize: 17, fontWeight: FontWeight.bold, color: const Color(0xFF1A1A1A));
  }

  Widget _buildSelectableChip(String text, {required bool isSelected, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFF5F8FF) : const Color(0xFFF9F9F9),
          borderRadius: BorderRadius.circular(100),
          border: Border.all(color: isSelected ? const Color(0xFF001144) : const Color(0xFFE5E5E5)),
        ),
        child: CommonText(
          text,
          fontSize: 12.5,
          color: isSelected ? const Color(0xFF001144) : const Color(0xFF444444),
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildPriceField(String label, TextEditingController controller, {bool showDaysToggle = false, RxInt? daysRx}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CommonText(label, fontSize: 13, fontWeight: FontWeight.w600, color: const Color(0xFF444444)),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFF9F9F9),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFEEEEEE)),
                ),
                child: CommonTextField(
                  label: '',
                  controller: controller,
                  hintText: 'Enter Price',
                  prefixIcon: const Padding(
                    padding: EdgeInsets.only(left: 16, right: 8, top: 14, bottom: 14),
                    child: CommonText('\$', fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1A1A1A)),
                  ),
                  keyboardType: TextInputType.number,
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
               //   focusedBorder: InputBorder.none,
                ),
              ),
            ),
          ],
        ),
        if (showDaysToggle && daysRx != null) ...[
          const SizedBox(height: 12),
          CommonText('Select your standard schedule', fontSize: 12, color: AppColors.textSecondary, fontWeight: FontWeight.w500),
          const SizedBox(height: 10),
          Obx(() => Row(
            children: [
              _buildToggleBtn('5 days week', daysRx.value == 5, () => daysRx.value = 5),
              const SizedBox(width: 12),
              _buildToggleBtn('6 days week', daysRx.value == 6, () => daysRx.value = 6),
            ],
          )),
        ],
      ],
    );
  }

  Widget _buildToggleBtn(String text, bool isSelected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF8C3E3E) : const Color(0xFFF9F9F9),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: isSelected ? const Color(0xFF8C3E3E) : const Color(0xFFEEEEEE)),
        ),
        child: CommonText(
          text,
          fontSize: 13,
          color: isSelected ? Colors.white : const Color(0xFF666666),
          fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildActionLink(String text, {required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: CommonText(text, color: const Color(0xFF3366FF), fontWeight: FontWeight.bold, fontSize: 13),
    );
  }

  Widget _buildLabelValue(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CommonText(label, fontSize: 13, fontWeight: FontWeight.w600, color: const Color(0xFF444444)),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: const Color(0xFFF5F5F5),
            borderRadius: BorderRadius.circular(10),
          ),
          child: CommonText(value, fontSize: 14, color: const Color(0xFF1A1A1A), fontWeight: FontWeight.w500),
        ),
      ],
    );
  }

  Widget _buildChipsList(String label, List<String> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CommonText(label, fontSize: 14, fontWeight: FontWeight.bold, color: const Color(0xFF1A1A1A)),
        const SizedBox(height: 6),
        CommonText('Select the disciplines you have the most experience with', fontSize: 12, color: AppColors.textSecondary, fontWeight: FontWeight.w500),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: items
              .map((it) => Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFFF2F2F2),
              borderRadius: BorderRadius.circular(100),
            ),
            child: CommonText(it, fontSize: 12, fontWeight: FontWeight.w500, color: const Color(0xFF444444)),
          ))
              .toList(),
        ),
      ],
    );
  }
}

