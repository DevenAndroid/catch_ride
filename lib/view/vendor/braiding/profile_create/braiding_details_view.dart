import 'package:catch_ride/constant/app_colors.dart';
import 'package:catch_ride/constant/app_text_sizes.dart';
import 'package:catch_ride/controllers/vendor/braiding/braiding_details_controller.dart';
import 'package:catch_ride/widgets/common_button.dart';
import 'package:catch_ride/widgets/common_text.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class BraidingDetailsView extends StatefulWidget {
  const BraidingDetailsView({super.key});

  @override
  State<BraidingDetailsView> createState() => _BraidingDetailsViewState();
}

class _BraidingDetailsViewState extends State<BraidingDetailsView> {
  @override
  Widget build(BuildContext context) {
    final controller = Get.put(BraidingDetailsController());

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
            'Braiding Details',
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
                _buildCoreBraidingServices(controller),
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

  Widget _buildCoreBraidingServices(BraidingDetailsController controller) {
    return _buildSectionContainer(
      title: 'Braiding Services',
      description: 'Select your braiding skills',
      children: [
        Obx(() => Column(
              children: controller.braidingServices.map((service) {
                final isSelected = service['isSelected'].value;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: GestureDetector(
                    onTap: () => service['isSelected'].value = !isSelected,
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
                            onChanged: (val) => service['isSelected'].value = val!,
                            activeColor: const Color(0xFF001149),
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
                              color: const Color(0xFFF3F4F6),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              children: [
                                const CommonText('\$ ', fontSize: AppTextSizes.size14, color: AppColors.textSecondary),
                                Expanded(
                                  child: TextField(
                                    controller: service['price'] as TextEditingController,
                                    decoration: const InputDecoration(border: InputBorder.none, isDense: true, contentPadding: EdgeInsets.zero, hintText: '0', hintStyle: TextStyle(color: Colors.grey)),
                                    style: const TextStyle(fontSize: AppTextSizes.size14, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
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
                  ),
                );
              }).toList(),
            )),
        const SizedBox(height: 12),
        GestureDetector(
          onTap: () => _showAddMoreBottomSheet(context, controller),
          child: Row(
            children: const [
              Icon(Icons.add, size: 18, color: AppColors.linkBlue),
              SizedBox(width: 4),
              CommonText('Add Skills', color: AppColors.linkBlue, fontWeight: FontWeight.bold, fontSize: AppTextSizes.size14),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTravelPreferences(BraidingDetailsController controller) {
    return _buildSectionContainer(
      title: 'Travel Preferences',
      children: [
        Obx(() => Wrap(
              spacing: 8,
              runSpacing: 12,
              children: controller.travelOptions.map((item) {
                final isSelected = controller.selectedTravel.contains(item);
                return _buildSelectableChip(item, isSelected: isSelected, onTap: () => controller.toggleTravel(item));
              }).toList(),
            )),
      ],
    );
  }

  Widget _buildReadOnlyInfo(BraidingDetailsController controller) {
    return Obx(() {
      if (controller.isLoading.value) {
        return const Center(child: Padding(padding: EdgeInsets.all(20), child: CircularProgressIndicator()));
      }
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildLabelValue('Location', controller.location.value),
          const SizedBox(height: 24),
          _buildLabelValue('Years of experience', controller.experience.value),
          const SizedBox(height: 24),
          _buildChipsList('Disciplines', controller.disciplines),
          const SizedBox(height: 24),
          _buildChipsList('Typical level of horses', controller.horseLevels),
          const SizedBox(height: 24),
          _buildChipsList('Regions covered', controller.operatingRegions),
        ],
      );
    });
  }

  Widget _buildCancellationPolicy(BraidingDetailsController controller) {
    return _buildSectionContainer(
      title: 'Cancellation policy',
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
                  hint: const CommonText('Select cancellation policy', color: AppColors.textSecondary, fontSize: AppTextSizes.size14),
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
                      color: controller.isCustomCancellation.value ? const Color(0xFF001149) : Colors.white,
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(color: controller.isCustomCancellation.value ? const Color(0xFF001149) : AppColors.borderLight),
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
                          hintStyle: const TextStyle(color: Colors.grey, fontSize: 14),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.borderLight)),
                          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.borderLight)),
                          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF001149))),
                          contentPadding: const EdgeInsets.all(16),
                        ),
                      ),
                    )
                  : const SizedBox(height: 0, width: double.infinity),
            )),
      ],
    );
  }

  void _showAddMoreBottomSheet(BuildContext context, BraidingDetailsController controller) {
    Get.bottomSheet(
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      Container(
        padding: EdgeInsets.only(top: 10, left: 20, right: 20, bottom: MediaQuery.of(context).viewInsets.bottom + 20),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(topLeft: Radius.circular(24), topRight: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 50,
                height: 4,
                decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2)),
              ),
            ),
            const SizedBox(height: 24),
             CommonText('Add More Service', fontSize: AppTextSizes.size22, fontWeight: FontWeight.bold),
            const SizedBox(height: 24),
            const CommonText('Skill', fontSize: AppTextSizes.size14, fontWeight: FontWeight.w600),
            const SizedBox(height: 8),
            TextField(
              controller: controller.addServiceInputController,
              decoration: InputDecoration(
                hintText: 'Enter your skill',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.borderLight)),
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
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
                      controller.addBraidingService(controller.addServiceInputController.text);
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
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.borderLight),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 16, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader(title),
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

  Widget _buildSectionHeader(String title) {
    return CommonText(title, fontSize: AppTextSizes.size16, fontWeight: FontWeight.bold);
  }

  Widget _buildSelectableChip(String text, {required bool isSelected, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: isSelected ? AppColors.primary : AppColors.borderLight, width: 1),
          boxShadow: isSelected ? [BoxShadow(color: AppColors.primary.withOpacity(0.2), blurRadius: 4, offset: const Offset(0, 2))] : null,
        ),
        child: CommonText(
          text,
          fontSize: AppTextSizes.size14,
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
          color: isSelected ? Colors.white : AppColors.textSecondary,
        ),
      ),
    );
  }

  Widget _buildActionLink(String text, {required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: CommonText(text, color: AppColors.linkBlue, fontWeight: FontWeight.w600, fontSize: AppTextSizes.size14),
    );
  }

  Widget _buildLabelValue(String label, String value) {
    return _buildSectionContainer(
      title: label,
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: const Color(0xFFF3F4F6), 
            borderRadius: BorderRadius.circular(12),
          ),
          child: CommonText(value, fontSize: AppTextSizes.size14, color: AppColors.textPrimary, fontWeight: FontWeight.w500),
        ),
      ],
    );
  }

  Widget _buildChipsList(String label, List<String> items) {
    return _buildSectionContainer(
      title: label,
      children: [
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: items
              .map((it) => Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(color: const Color(0xFFF3F4F6), borderRadius: BorderRadius.circular(8)),
                    child: CommonText(it, fontSize: AppTextSizes.size12, color: AppColors.textPrimary),
                  ))
              .toList(),
        ),
      ],
    );
  }
}
